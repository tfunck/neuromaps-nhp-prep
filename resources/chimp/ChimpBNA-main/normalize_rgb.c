
#include <stdio.h>

int main() {

  int i, val, r, g, b;

  for( i = 0; i <= 101; i++ ) {

    fscanf( stdin, "%d %d %d %d", &val, &r, &g, &b );
    printf( "%d %6.4f %6.4f %6.4f\n", val, r/255.0, g/255.0, b/255.0 );
  }
}
