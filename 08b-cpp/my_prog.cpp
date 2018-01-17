
// to compile: g++ my_prog.cpp -o my_prog.out
// to generate assembly code: g++ -S my_prog.cpp -o my_prog.S
//                  on macOS: g++ -mllvm --x86-asm-syntax=intel -S my_prog.cpp -o my_prog.S

#include  <iostream>

int  main()
{
    double a = 3.0, b = 2.0;
    double c = a + b;

    std::cout  << "a + b = " << c << std::endl;

    return  0;
}
