
#include <stdlib.h>

int foo() {
  int* nullptr = NULL;
  return *nullptr;
}

int main() {
  int input = 0;
  foo();
  return 0;
}
