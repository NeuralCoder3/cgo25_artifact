use itertools::Itertools;
use std::collections::HashSet;
use rayon::iter::IntoParallelIterator as _;
use rayon::iter::ParallelIterator as _;

pub mod common;
use common::*;

fn main() {
    let possible_cmds = possible_commands();
    let permutations: Vec<Vec<u8>> = (1..=NUMBERS_U8).permutations(NUMBERS).collect(); 
    let init_perm_count = permutations.len();

    // let perm_count = 6;
    // let permutations = permutations.choose_multiple(&mut rand::thread_rng(), perm_count).cloned().collect::<Vec<_>>();


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
    let initial_state : State = permutations
        .iter()
        .map(|p| {
            let mut perm = Permutation([0; REGS + 2]);
            for (i, &x) in p.iter().enumerate() {
                perm[i] = x;
            }
            perm
        })
        .collect();

    // length_map.insert(state_positions(&initial_state), vec![0 as u8]).unwrap();

    // let node0 = Node{cmd: (0,0,0), prev: None};

    let mut visited : u64 = 0;
    let mut duplicate : u64 = 0;
    // let mut cut : u64 = 0;

    let mut min_perm_count = [init_perm_count; (MAX_LEN as usize)+1];

    let start = std::time::Instant::now();




    let mut frontier = vec![initial_state.clone()];

    let mut length = 0;
    while length<MAX_LEN {
        print!("Length: {}, ", length);
        print!("Frontier: {}, ", frontier.len());
        print!("Seen: {}, ", seen.len());
        print!("Elapsed: {:?}, ", start.elapsed());
        println!();


        min_perm_count[length as usize] = 
            frontier.iter()
            .map(|state| 
                state.iter().map(|p| &p[0..NUMBERS]).unique().count()
            )
            .min()
            .unwrap();

        visited += frontier.len() as u64;
        let new_frontier =
            frontier
            .into_par_iter()
            // .into_iter()
            .flat_map(|state| {
                // visited.inc();
                // if visited.get() % 1000 == 0 {
                //     println!("Visited: {}, Duplicate: {} (length: {})", visited.get(), duplicate.get(), length);
                // }

                possible_cmds
                    .iter()
                    .filter_map(|cmd| {
                        let new_state = apply_all(cmd, &state);

                        if !viable(&new_state) {
                            return None;
                        }
                        // if seen.lock().unwrap().contains(&new_state) {
                        //     duplicate.inc();
                        //     return None;
                        // }
                        // seen.lock().unwrap().insert(new_state.clone());

                        if seen.contains(&new_state) {
                        //     duplicate += 1;
                            return None;
                        }

                        // CUT
                        #[cfg(feature = "heuristic1")]
                        {
                            let new_perm_count = new_state.iter().map(|p| &p[0..NUMBERS]).unique().count();
                            if new_perm_count < min_perm_count[length as usize] {
                                // cut += 1;
                                return None;
                            }
                        }

                        Some(new_state)
                    })
                    .collect::<Vec<_>>()
            })
            .collect::<Vec<_>>();
        let new_frontier_length = new_frontier.len();
        // visited += new_frontier_length;

        println!("Filter out duplicates");
        let frontier_filtered = new_frontier
            // filter seen
            .into_iter()
            .unique()
            // .filter(|state| { return !seen.contains(state); })
            .collect::<Vec<_>>();
        duplicate += (new_frontier_length - frontier_filtered.len()) as u64;
        println!("Visited: {}, Duplicate: {} (length: {})", visited, duplicate, length);

        // add all to seen
        seen.extend(frontier_filtered.iter().cloned());
        // if solution_lengths.lock().unwrap().len() > 0 {
        //     println!("Found: {:?} of length: {}", solution_lengths.lock().unwrap(), length);
        //     break;
        // }
        length += 1;
        frontier = frontier_filtered;

        // check for solutions
        let found = 
            frontier.iter().any(|state| 
                // state.iter().all(|p| p[0..NUMBERS] == state[0][0..NUMBERS])
                state.iter().all(|p| p[0..NUMBERS] == (1..=NUMBERS_U8).collect::<Vec<_>>()
            ));
        if found {
            println!("Found: solution of length: {}", length);
            let elapsed = start.elapsed();
            println!("Elapsed: {:?}", elapsed);
            // solution_lengths.lock().unwrap().push(length);
            // exit program
            std::process::exit(0);
            // return vec![state];
        }
    }






    println!();

    // println!("Found {} solutions", solution_count);

    println!("Visited: {}, Duplicate: {}", visited, duplicate);
    println!("Elapsed: {:?}", start.elapsed());
}