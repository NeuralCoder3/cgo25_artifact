docker build . -t local_planning

handle_timeout() {
    if [ "$1" = "timeout" ]; then
        echo "Timeout for $2"
    else
        echo "$2 took $1 seconds"
    fi
}

# docker run --privileged -v $(pwd):/root/app local_planning planutils run lama sequential/domain.pddl sequential/problem.pddl
tseq=$(python watch.py sequential/domain.pddl sequential/problem.pddl seq_plan.txt 77 30)
handle_timeout $tseq "Sequential"

tseq=$(python watch.py conditional_parallel/domain.pddl conditional_parallel/problem.pddl parallel.txt 77 900)
handle_timeout $tseq "Parallel"

# docker run --privileged -v $(pwd):/root/app local_planning planutils run lama grounded/domain.pddl grounded/problem.pddl
tseq=$(python watch.py grounded/domain.pddl grounded/problem.pddl grounded.txt 77 900)
handle_timeout $tseq "Parallel"
