#! /bin/sh -

# Todd M. Ernst 2019

INPUT_DIR=proj1_tests
OUTPUT_DIR=test_cases/phase_1

mkdir -p "${OUTPUT_DIR}"

cat ${INPUT_DIR}/hello.mjava | ./lexer > ${OUTPUT_DIR}/hello.lexer.out
cat ${INPUT_DIR}/strings.mjava | ./lexer > ${OUTPUT_DIR}/strings.lexer.out
cat ${INPUT_DIR}/test.mjava | ./lexer > ${OUTPUT_DIR}/test.lexer.out
cat ${INPUT_DIR}/test2.mjava | ./lexer > ${OUTPUT_DIR}/test2.lexer.out

TEST_OUTPUT=`diff -b ${OUTPUT_DIR}/hello.lexer.out ${INPUT_DIR}/hello.mjava.out`
if [ -z "${TEST_OUTPUT}" ]
then 
	echo "hello.mjava test pass"
else
	echo "${TEST_OUTPUT}"
fi

TEST_OUTPUT=`diff -b ${OUTPUT_DIR}/strings.lexer.out ${INPUT_DIR}/strings.mjava.out`
if [ -z "${TEST_OUTPUT}" ]
then 
	echo "strings.mjava test pass"
else
	echo "${TEST_OUTPUT}"
fi

TEST_OUTPUT=`diff -b ${OUTPUT_DIR}/test.lexer.out ${INPUT_DIR}/test.mjava.out`
if [ -z "${TEST_OUTPUT}" ]
then 
	echo "test.mjava test pass"
else
	echo "${TEST_OUTPUT}"
fi

TEST_OUTPUT=`diff -b ${OUTPUT_DIR}/test2.lexer.out ${INPUT_DIR}/test2.mjava.out`
if [ -z "${TEST_OUTPUT}" ]
then 
	echo "test2.mjava test pass"
else
	echo "${TEST_OUTPUT}"
fi