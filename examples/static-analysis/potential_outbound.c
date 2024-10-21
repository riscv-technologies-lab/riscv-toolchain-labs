#include <stdlib.h>
#include <assert.h>

int g[100];

int foo(int* a, int len) {
  assert((a != NULL) && (len > 1));
  return a[len / 2];
}


int main() {
  foo(g, 300);
}
