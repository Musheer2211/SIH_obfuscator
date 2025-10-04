// test.c -- intentionally non-trivial so obfuscator will modify it
#include <stdio.h>

int add(int a, int b) {
    int s = a + b;
    s = s * 2;
    s = s + 3;
    // create a bit more work to avoid trivial single-block functions
    for (int i = 0; i < 2; ++i) {
        s += i;
    }
    if (s % 2 == 0) {
        s = s / 2;
    } else {
        s = s * 3 + 1;
    }
    return s;
}

int main(void) {
    int x,y;
    scanf("%d %d", &x, &y);
    int r = add(x, y);
    printf("r=%d\n", r);
    return 0;
}
