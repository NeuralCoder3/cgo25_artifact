use itertools::Itertools;
use rayon::iter::IntoParallelRefIterator;
use rayon::iter::ParallelIterator as _;
use std::collections::HashSet;
extern crate ocl;

pub mod common;
use common::*;

// see gpu for info

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

    // let length_map = sled::open(path).unwrap();
    let mut seen = HashSet::new();

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
    let mut min_perm_count = [init_perm_count; (MAX_LEN as usize) + 1];
    let start = std::time::Instant::now();
    let mut frontier = vec![initial_state.clone()];

    let mut length = 0;
    while length < MAX_LEN {
        print!("Length: {}, ", length);
        print!("Frontier: {}, ", frontier.len());
        print!("Seen: {}, ", seen.len());
        print!("Elapsed: {:?}, ", start.elapsed());
        println!();

        min_perm_count[length as usize] = frontier
            .iter()
            .map(|state| state.iter().map(|p| &p[0..NUMBERS]).unique().count())
            .min()
            .unwrap();

        let mut ctx = ocl::ProQue::builder()
            .src(include_str!("gpu.cl"))
            .build()
            .unwrap();
        // assert that all frontier states have the same length
        assert!(frontier.iter().all(|state| state.len() == init_perm_count));
        let permutation_size = frontier[0][0].0.len();
        let state_size = init_perm_count * permutation_size;
        let frontier_size = frontier.len() * state_size;
        ctx.set_dims(frontier_size);

        visited += frontier.len() as u64;
        let new_frontier = possible_cmds
            .iter()
            .flat_map(|cmd| {

                let output_buffer = ctx.create_buffer::<u8>().unwrap();
                let mut output_array = vec![0; state_size];
                output_buffer.write(&output_array).enq().unwrap();

                let state_buffer = ctx.create_buffer::<u8>().unwrap();
                let mut state_array = frontier
                    .iter()
                    .flat_map(|state| state.iter().flat_map(|p| p.0))
                    .collect::<Vec<_>>();
                state_buffer.write(&state_array).enq().unwrap();

                let command_buffer = ctx.create_buffer::<u8>().unwrap();
                let command_array = [cmd.0 as u8, cmd.1 as u8, cmd.2 as u8];
                command_buffer.write(command_array.as_slice()).enq().unwrap();

                let program = ctx.program();
                let kernel = ocl::Kernel::builder()
                    .program(&program)
                    .name("apply")
                    .queue(ctx.queue().clone())
                    .global_work_size(frontier.len())
                    .arg(&state_buffer)
                    .arg(&command_buffer)
                    .arg(&output_buffer)
                    .build()
                    .unwrap();

                unsafe {
                    kernel.enq().unwrap();
                }

                output_buffer.read(&mut output_array).enq().unwrap();
                state_buffer.read(&mut state_array).enq().unwrap();

                // reconstruct frontier from state_array
                state_array
                    .chunks_exact(state_size)
                    .map(|s| {
                        s.chunks_exact(permutation_size)
                            .map(|p| {
                                // create permutation out of p directly
                                let perm = Permutation(p.try_into().unwrap());
                                perm
                            })
                            .collect::<Vec<_>>()
                    })
                    .filter_map(|mut state| {
                        state.sort();
                        if !viable(&state) {
                            return None;
                        }
                        if seen.contains(&state) {
                            return None;
                        }
                        Some(state)
                    })
                    .for_each(drop);

                frontier
                .par_iter()
                .filter_map(|state| {
                    let mut new_state = apply_all_no_dedup(cmd, &state);
                    new_state.sort();
                    if !viable(&new_state) {
                        return None;
                    }
                    if seen.contains(&new_state) {
                        // duplicate += 1;
                        return None;
                    }
                    Some(new_state)
                })
                .collect::<Vec<_>>()

            })
            .collect::<Vec<_>>();

        let new_frontier_length = new_frontier.len();

        println!("Filter out duplicates");
        let frontier_filtered = new_frontier
            // filter seen
            .into_iter()
            .unique()
            // .filter(|state| { return !seen.contains(state); })
            .collect::<Vec<_>>();
        duplicate += (new_frontier_length - frontier_filtered.len()) as u64;
        println!(
            "Visited: {}, Duplicate: {} (length: {})",
            visited, duplicate, length
        );

        // add all to seen
        seen.extend(frontier_filtered.iter().cloned());
        length += 1;
        frontier = frontier_filtered;

        // check for solutions
        let found = 
            frontier.iter().any(|state| 
                state.iter().all(|p| p[0..NUMBERS] == (1..=NUMBERS_U8).collect::<Vec<_>>()
            ));
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
