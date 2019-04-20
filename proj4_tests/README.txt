The *.out files and proj4.rst were generated using the following commands.

$ ./codegen < ./cases/src1 > ./tests/proj4_tests/src1.out
$ cat ./tests/proj4_tests/dummy.in | ./spim.linux -asm -file ./tests/proj4_tests/src1.s >> ./tests/proj4_tests/proj4.rst
$ ./codegen < ./cases/src10 > ./tests/proj4_tests/src10.out
$ cat ./tests/proj4_tests/src10.in | ./spim.linux -asm -file ./tests/proj4_tests/src10.s >> ./tests/proj4_tests/proj4.rst
$ ./codegen < ./cases/src2 > ./tests/proj4_tests/src2.out
$ cat ./tests/proj4_tests/dummy.in | ./spim.linux -asm -file ./tests/proj4_tests/src2.s >> ./tests/proj4_tests/proj4.rst
$ ./codegen < ./cases/src3 > ./tests/proj4_tests/src3.out
$ cat ./tests/proj4_tests/src3.in | ./spim.linux -asm -file ./tests/proj4_tests/src3.s >> ./tests/proj4_tests/proj4.rst
$ ./codegen < ./cases/src4 > ./tests/proj4_tests/src4.out
$ cat ./tests/proj4_tests/dummy.in | ./spim.linux -asm -file ./tests/proj4_tests/src4.s >> ./tests/proj4_tests/proj4.rst
$ ./codegen < ./cases/src5 > ./tests/proj4_tests/src5.out
$ cat ./tests/proj4_tests/dummy.in | ./spim.linux -asm -file ./tests/proj4_tests/src5.s >> ./tests/proj4_tests/proj4.rst
$ ./codegen < ./cases/src6 > ./tests/proj4_tests/src6.out
$ cat ./tests/proj4_tests/dummy.in | ./spim.linux -asm -file ./tests/proj4_tests/src6.s >> ./tests/proj4_tests/proj4.rst
$ ./codegen < ./cases/src7 > ./tests/proj4_tests/src7.out
$ cat ./tests/proj4_tests/dummy.in | ./spim.linux -asm -file ./tests/proj4_tests/src7.s >> ./tests/proj4_tests/proj4.rst
$ ./codegen < ./cases/src8 > ./tests/proj4_tests/src8.out
$ cat ./tests/proj4_tests/dummy.in | ./spim.linux -asm -file ./tests/proj4_tests/src8.s >> ./tests/proj4_tests/proj4.rst
$ ./codegen < ./cases/src9 > ./tests/proj4_tests/src9.out
$ cat ./tests/proj4_tests/dummy.in | ./spim.linux -asm -file ./tests/proj4_tests/src9.s >> ./tests/proj4_tests/proj4.rst
$ ./codegen < ./cases/src0 > ./tests/proj4_tests/src0.out
$ cat ./tests/proj4_tests/dummy.in | ./spim.linux -asm -file ./tests/proj4_tests/src0.s >> ./tests/proj4_tests/proj4.rst

The output of your generated code (proj4.rst) should match the answer output.
The actual generated code *.s files may differ.  You are free to come up
with your own calling convention and code generation protocol.
