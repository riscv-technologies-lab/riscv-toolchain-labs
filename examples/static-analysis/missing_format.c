#include <stdio.h>

void print_message(const char *msg) {
  printf(msg); // Потенциальная уязвимость: отсутствие спецификатора формата
}

int main() {
  char *message = "Привет, мир!";
  print_message(message);
  return 0;
}
