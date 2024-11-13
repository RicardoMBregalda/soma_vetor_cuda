#include <iostream>

#define N 10240  // Valor de N maior que o limite de threads por bloco

// Kernel para a soma de vetores
__global__ void somaVetores(int *a, int *b, int *c, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) {  // Verifica se o índice está dentro dos limites
        c[i] = a[i] + b[i];
    }
}

int main() {
    int *a, *b, *c;             // Vetores no host
    int *d_a, *d_b, *d_c;       // Vetores no device
    int size = N * sizeof(int);

    // Aloca memória no host
    a = (int *)malloc(size);
    b = (int *)malloc(size);
    c = (int *)malloc(size);

    // Inicializa os vetores no host
    for (int i = 0; i < N; i++) {
        a[i] = i;
        b[i] = i * 2;
    }

    // Aloca memória no device
    cudaMalloc((void **)&d_a, size);
    cudaMalloc((void **)&d_b, size);
    cudaMalloc((void **)&d_c, size);

    // Copia os vetores do host para o device
    cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

    // Define o número de threads por bloco e o número de blocos
    int threadsPerBlock = 256;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;

    // Executa o kernel para a soma de vetores
    somaVetores<<<blocksPerGrid, threadsPerBlock>>>(d_a, d_b, d_c, N);

    // Copia o resultado do device para o host
    cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);

    // Imprime alguns resultados para verificação
    for (int i = 0; i < 10; i++) {
        std::cout << "c[" << i << "] = " << c[i] << std::endl;
    }

    // Libera a memória alocada no device
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    // Libera a memória alocada no host
    free(a);
    free(b);
    free(c);

    return 0;
}
