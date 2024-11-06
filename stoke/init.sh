set -e 

if ! command -v stoke &> /dev/null
then
    echo "stoke could not be found"
    exit
fi

PROGRAM=main.cc
OUTPUT=./a.out
BIN_FOLDER=./bins
TARGET=$BIN_FOLDER/sort3.s

# check if files exist
USED_FILES=( $PROGRAM )
for file in "${USED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "$file does not exist"
        exit
    fi
done

echo "Compiling..."
g++ -std=c++11 -O3 -fno-inline $PROGRAM -o $OUTPUT

echo "Extracting..."
stoke extract -i $OUTPUT -o $BIN_FOLDER

echo "Creating test cases..."

SYM_TEST_FILE=sym/test.tc
BOUND=64
echo "Creating symbolic test case $SYM_TEST_FILE"
stoke_tcgen --target $BIN_FOLDER/sort3_manual.s --bound $BOUND --output $SYM_TEST_FILE

RANDOM_TEST_FILE=random/test.tc
NUM_TESTS=1024
echo "Creating random test case $RANDOM_TEST_FILE"
stoke testcase --target $TARGET --max_testcases $NUM_TESTS -o $RANDOM_TEST_FILE

echo "Test cases created"
echo "Execute run.sh from sym/ or random/ to run the benchmarks"
