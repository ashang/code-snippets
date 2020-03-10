// clang -fsanitize=address a.c -O -c  && nm a.o | grep asan_stack_malloc
// clang -fsanitize=address a.c -O -c -mllvm -asan-stack=0 && nm a.o | grep asan_stack_malloc

int foo(int a, int b) {
  int x[10];
  x[b] = 1;
  return x[a];
}
