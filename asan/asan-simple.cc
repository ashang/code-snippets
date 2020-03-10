
#include <stdio.h>

void print(int *pBuf, int size) {
    for (int i = 0; i < size; ++i) {
        printf("%d ", pBuf[i]);
    }
    printf("\n");
}

//set -x
//#PASS
//clang++ -shared -fPIC libtest.cpp -o libtest.so
//#PASS
//clang++ -shared -fPIC libtest.cpp -o libtest.so -fsanitize=address
//#FAIL
//clang++ -shared -fPIC libtest.cpp -o libtest.so -fsanitize=address -Wl,--no-undefined
//
//#PASS
//g++ -shared -fPIC libtest.cpp -o libtest.so
//#PASS
//g++ -shared -fPIC libtest.cpp -o libtest.so -fsanitize=address
//#FAIL
//g++ -shared -fPIC libtest.cpp -o libtest.so -fsanitize=address -Wl,--no-undefined
//
//#PASS
//clang++ -shared -fPIC libtest.cpp -o libtest.so -Wl,--no-undefined
//#PASS
//g++ -shared -fPIC libtest.cpp -o libtest.so -Wl,--no-undefined

