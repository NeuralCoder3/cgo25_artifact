use itertools::Itertools;
extern crate ocl;
// needs opencl-headers opencl-info ocl-icd (these are the nix packages)

pub mod common;
use common::*;

fn viable_perm(perm: &[u8]) -> bool {
    for n in 1..=NUMBERS_U8 {
        if !perm[0..REGS].contains(&n) {
            return false;
        }
    }
    true
}

// like parallel but expanded into gpu kernel

fn main() {
    let possible_cmds = possible_commands();
    let permutations: Vec<Vec<u8>> = (1..=NUMBERS_U8).permutations(NUMBERS).collect();
    let init_perm_count = permutations.len();

    // find unused sled-mapX file in a temporary directory (_CONDOR_SCRATCH_DIR or /tmp/ else)
    let tmp_dir = std::env::var("_CONDOR_SCRATCH_DIR").unwrap_or("/tmp".to_string());
    let mut i = 0;
    let mut path = format!("{}/sled-map{}", tmp_dir, i);
    while std::path::Path::new(&path).exists() {
        i += 1;
        path = format!("{}/sled-map{}", tmp_dir, i);
    }
    println!("Using sled map: {}", path);

    // if in git repository, print hash
    let git_hash = std::process::Command::new("git")
        .args(&["rev-parse", "--short", "HEAD"])
        .output()
        .expect("failed to execute git")
        .stdout;
    let git_hash = String::from_utf8(git_hash).unwrap();
    println!("Git hash: {}", git_hash);
    println!("n = {}", NUMBERS);
    println!("max_len = {}", MAX_LEN);
    println!("swaps = {}", SWAPS);

    let seen = sled::open(path).unwrap();

    // extend numerical permutations with register for swap and flags
    // we use RC to avoid cloning the state
    let initial_state: State = permutations
        .iter()
        .map(|p| {
            let mut perm = Permutation([0; REGS + 2]);
            for (i, &x) in p.iter().enumerate() {
                perm[i] = x;
            }
            perm
        })
        .collect();

    let mut visited: u64 = 0;
    let mut duplicate: u64 = 0;

    let start = std::time::Instant::now();

    let flat_init_state = initial_state.iter().flat_map(|p| p.0).collect::<Vec<_>>();
    let mut frontier : Vec<u8> = flat_init_state.clone();
    println!("Initial state: {:?}", flat_init_state);

    let permutation_size = REGS + 2;
    let state_size = init_perm_count * permutation_size;
    assert_eq!(state_size, flat_init_state.len());

    let mut length = 0;
    while length < MAX_LEN {
        let state_count = frontier.len() / state_size;
        print!("Length: {}, ", length);
        print!("Frontier Bytes: {}, ", frontier.len());
        print!("Frontier States: {}, ", state_count);
        print!("Seen: {}, ", seen.len());
        print!("Elapsed: {:?}, ", start.elapsed());
        println!();

        let mut ctx = ocl::ProQue::builder()
            .src(include_str!("gpu.cl"))
            .build()
            .unwrap();
        ctx.set_dims(frontier.len());

        visited += state_count as u64;
        let new_frontier = possible_cmds
            .iter()
            .flat_map(|cmd| {

                // 56s CPU
                // 17s Parallel (22s without dedup) -- 46 vs 17s for main_parallel

                let output_buffer = ctx.create_buffer::<u8>().unwrap();
                let mut output_array = vec![0; state_size];
                output_buffer.write(&output_array).enq().unwrap();

                let state_buffer = ctx.create_buffer::<u8>().unwrap();
                state_buffer.write(&frontier).enq().unwrap();

                let command_buffer = ctx.create_buffer::<u8>().unwrap();
                let command_array = [cmd.0 as u8, cmd.1 as u8, cmd.2 as u8];
                command_buffer.write(command_array.as_slice()).enq().unwrap();

                let program = ctx.program();
                let kernel = ocl::Kernel::builder()
                    .program(&program)
                    .name("apply")
                    .queue(ctx.queue().clone())
                    .global_work_size(frontier.len() / state_size)
                    .arg(&state_buffer)
                    .arg(&command_buffer)
                    .arg(&output_buffer)
                    // .arg(&state_size)
                    // .arg(&permutation_size)
                    .build()
                    .unwrap();

                unsafe {
                    kernel.enq().unwrap();
                }

                output_buffer.read(&mut output_array).enq().unwrap();
                let mut new_frontier = vec![0; state_size * state_count];
                state_buffer.read(&mut new_frontier).enq().unwrap();

                // instead of sort use sorted of idx of perms (via trie?)
                // reconstruct frontier from state_array

                let new_frontier=new_frontier
                    .chunks_exact(state_size)
                    .filter_map(|s| {
                        for pi in 0..init_perm_count {
                            let perm = &s[pi * permutation_size..(pi + 1) * permutation_size];
                            if !viable_perm(perm) {
                                return None;
                            }
                        }

                        // sort perm (chunked) without copying
                        // first chunk
                        // then sort
                        // then flatten
                        // check if duplicate
                        // else insert and keep
                        // sorted_state 
                        // let permutations = s.chunks_exact(permutation_size).collect::<Vec<_>>();
                        let sorted_perms = 
                            s.chunks_exact(permutation_size)
                            .sorted()
                            .flatten()
                            .copied()
                            .collect::<Vec<_>>();
                        if let Some(_) = seen.get(&sorted_perms).unwrap() {
                            return None;
                        }
                        seen.insert(sorted_perms.clone(), vec![0]).unwrap();
                        Some(sorted_perms)
                    })
                    .flatten()
                    .collect::<Vec<_>>();
                new_frontier
                
            })
            .collect::<Vec<_>>();

        let new_frontier_length = new_frontier.len();

        println!("Filter out duplicates");
        let frontier_filtered = new_frontier
            // filter seen
            .into_iter()
            // .unique()
            // .filter(|state| { return !seen.contains(state); })
            .collect::<Vec<_>>();
        duplicate += (new_frontier_length - frontier_filtered.len()) as u64;
        println!(
            "Visited: {}, Duplicate: {} (length: {})",
            visited, duplicate, length
        );

        length += 1;
        frontier = frontier_filtered;

        let found = 
            frontier.chunks_exact(state_size)
            .any(|s| {
                s.chunks_exact(permutation_size)
                .all(|p| p[0..NUMBERS].iter().all(|&x| x == 1))
            });
        if found {
            println!("Found: solution of length: {}", length);
            let elapsed = start.elapsed();
            println!("Elapsed: {:?}", elapsed);
            std::process::exit(0);
        }
    }

    println!("Visited: {}, Duplicate: {}", visited, duplicate);
    println!("Elapsed: {:?}", start.elapsed());
}
