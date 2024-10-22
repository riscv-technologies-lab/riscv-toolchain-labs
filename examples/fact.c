#include <stdio.h>

int factorial(int num) {
  if (num == 1) {
    return 1;
  }
  return num * factorial(num - 1);
}

int main() {
  int result = factorial(10);
  printf("%d\n", result);
  return 0;
}
