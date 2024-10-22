
int main() {
  int *p = (int*) 0xDEADBEEF;
  *p = 5; /* boom */
}

