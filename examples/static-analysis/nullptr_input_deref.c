#include <stdio.h>
#include <stdlib.h>

int foo() {
  int *nullptr = NULL;
  return *nullptr;
}

int main() {
  int input = 0;
  scanf("%d\n", &input);
  if (input < 3) {
    foo();
  }
  return 0;
}
