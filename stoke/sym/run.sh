# set -e

# we assume the file has been compiled and extracted
# and test cases have been created by a pre-setup


# check if stoke is installed
if ! command -v stoke &> /dev/null
then
    echo "stoke could not be found"
    exit
fi

FOLDER=./sym
TEST_FILE=$FOLDER/test.tc
COMPILED=./a.out
USED_FILES=($COMPILED bins/sort3.s $TEST_FILE)
TESTS=5
BENCHCOUNT=5
OPERATION="synthesize"
SUFFIX="syn"
OUTPUT_FOLDER=$FOLDER/output_$SUFFIX

# ./sym/run.sh | tee -a sym/log_opt.txt

# check if files exist
for file in "${USED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "$file does not exist"
        exit
    fi
done

# function to time a command
bench() {
    CMD=$1
    I=$2
    TIME=0
    echo "Benchmarking $CMD"
    for i in $(seq 1 $BENCHCOUNT); do
        RUNLOG=$OUTPUT_FOLDER/runlog_$I\_$i.txt
        TIME=$(echo "$TIME + $(/usr/bin/time -f "%e" $CMD 2>&1 1>$RUNLOG)" | bc -l)
    done
    # two digits after comma
    echo "Average time: $(echo "scale=2; $TIME / $BENCHCOUNT" | bc -l)"
}




# BEGIN OF REAL COMMANDS

echo "Baseline:"
LOC=$(wc -l < bins/sort3.s)
echo "LOC: $LOC"
bench "$COMPILED 100000000" 0
echo ""

mkdir -p $OUTPUT_FOLDER

for i in $(seq 1 $TESTS); do
    echo "Running test $i"
  RESULT=$OUTPUT_FOLDER/result_$SUFFIX\_$i.s
  OUTPUT=$OUTPUT_FOLDER/a_$SUFFIX\_$i.out
  LOG=$OUTPUT_FOLDER/log_$i.txt
  WLOG=$OUTPUT_FOLDER/wlog_$i.txt
  echo "Running stoke $OPERATION"
  stoke $OPERATION --config $FOLDER/synthesize.conf --out $RESULT --testcases $TEST_FILE > $LOG 2> $WLOG
  if [ ! -f "$RESULT" ]; then
      echo "stoke $OPERATION failed"
      continue
  fi
  LOC=$(wc -l < $RESULT)
  echo "Optimized to $LOC lines"
  cp $COMPILED $OUTPUT
  stoke replace -i $OUTPUT --rewrite $RESULT
  bench "$OUTPUT 100000000" $i
  echo ""
done
