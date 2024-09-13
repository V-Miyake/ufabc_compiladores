#include <stdio.h>
#include <string.h>

int main(){
    int a;
    int b;
    int c;
    int d;
    char x[100];
    float m;

    scanf("%d", &a);
    scanf("%f", &m);
    scanf("%s", x);
    d = 0;
    printf("Hello World");
    printf("%d\n", d);
    a = 5 + 5 * 8 + 4 / 4;
    a = 2 / 2 + 4;
    if (a<5){
        printf("%d\n", a);
        printf("%f\n", m);
        printf("%s\n", x);
    }else{
        printf("nao a");
        printf("%d\n", d);
    }
    b = 5;
    c = 3;
    m = 5.555;
    strcpy(x, "texto");
    while (b<6){
        b = b + 1;
    }
    a = 1;
    do{
    printf("%d\n", c);
    c = c + a;
    } while (c<= 7);

    return 0;
}
