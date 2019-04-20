#! /bin/sh -

# Todd M. Ernst 2019

INPUT_DIR=proj4_tests
OUTPUT_DIR=test_cases/phase_4

alias spim="~/school_work/compilers/spim.linux -trap_file ~/school_work/compilers/trap.handler"

mkdir -p "${OUTPUT_DIR}"

test_offset() {
  cat ${INPUT_DIR}/$1 | ./parser -o > ${OUTPUT_DIR}/$1.test.out

  TEST_OUTPUT=$(diff -b ${OUTPUT_DIR}/$1.test.out ${INPUT_DIR}/$1.out)
  if [ -z "${TEST_OUTPUT}" ]; then
    echo "$1 offset pass"
  else
    echo "${TEST_OUTPUT}"
  fi
}

test_execution() {
  cat ${INPUT_DIR}/$1 | ./parser > ${OUTPUT_DIR}/$1.test.src

  if [ -z "$2" ]; then 
    spim -file ${OUTPUT_DIR}/$1.test.src > ${OUTPUT_DIR}/$1.test.out
  else
    echo "$2" | spim -file ${OUTPUT_DIR}/$1.test.src > ${OUTPUT_DIR}/$1.test.out
  fi

  TEST_OUTPUT=$(diff -b -I 'Loaded:*' ${OUTPUT_DIR}/$1.test.out ${INPUT_DIR}/$1.run)
  if [ -z "${TEST_OUTPUT}" ]; then
    echo "$1 run passes"
  else
    echo "${TEST_OUTPUT}"
  fi
}

# Test the offset generation of the various files.
test_offset "src0"
test_offset "src1"
test_offset "src2"
test_offset "src3"
test_offset "src4"
test_offset "src5"
test_offset "src6"
test_offset "src7"
test_offset "src8"
test_offset "src9"
test_offset "src10"

# Test the run output of the test files
test_execution "src0"
test_execution "src1"
test_execution "src2"
test_execution "src3" "7"
test_execution "src4"
test_execution "src5"
test_execution "src6"
test_execution "src7"
test_execution "src8"
test_execution "src9"
test_execution "src10" "7"