//$ cat lsan-suppressed.cc 
//$ clang++ lsan-suppressed.cc -fsanitize=address
#include <stdlib.h>

void FooBar() {
  malloc(7);
}

void Baz() {
  malloc(5);
}

int main() {
  FooBar();
  Baz();
  return 0;
}
