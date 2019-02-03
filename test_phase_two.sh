#! /bin/sh -

# Todd M. Ernst 2019

INPUT_DIR=proj2_tests
OUTPUT_DIR=test_cases/phase_2

mkdir -p "${OUTPUT_DIR}"

test() {
	cat ${INPUT_DIR}/$1 | ./parser > ${OUTPUT_DIR}/$1.test.out

  TEST_OUTPUT=`diff -b ${OUTPUT_DIR}/$1.test.out ${INPUT_DIR}/$1.out`
  if [ -z "${TEST_OUTPUT}" ]
  then 
    echo "$1 test pass"
  else
    echo "${TEST_OUTPUT}"
  fi
}

test "src1"
test "src2"
test "src3"
test "src4"
test "src5"
test "src6"
test "src7"
test "src8"
test "src9"
test "src10"
