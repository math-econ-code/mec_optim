
// clang++-mp-5.0 -std=c++11 -Ofast -march=native -S -mllvm --x86-asm-syntax=intel simple_float.cpp -o simple_float_On.s

#define num_type float

void add_vec(num_type* __restrict a, num_type* __restrict b, const num_type k, int n)
{
    for (int i=0; i<n; i++)
	{
        a[i] += k*b[i];
    }
}
