

// clang -g -fsanitize=address i1.cc i2.cc
// ASAN_OPTIONS=check_initialization_order=1 ./a.out
// i1.cc
extern int B;
int A = B;
int main() {
  return A;
}
