import cupy as cp
import nvmath
import time
import argparse
import math
    
#import logging
#logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)-8s %(message)s', datefmt='%m-%d %H:%M:%S')

def matmul_stateless(M, N, K):
    
    A = cp.random.rand(M, K).astype(cp.float32)
    B = cp.random.rand(K, N).astype(cp.float32)

    compute_type = nvmath.linalg.advanced.MatmulComputeType.COMPUTE_32F_FAST_TF32
    o = nvmath.linalg.advanced.MatmulOptions(compute_type=compute_type)
    
    start = time.time()
    C = nvmath.linalg.advanced.matmul(A, B, options=o)
    end = time.time()
    
    total_time = end - start

    return total_time

def matmul_stateful(M, N, K):
    
    A = cp.random.rand(M, K).astype(cp.float32)
    B = cp.random.rand(K, N).astype(cp.float32)

    compute_type = nvmath.linalg.advanced.MatmulComputeType.COMPUTE_32F_FAST_TF32
    o = nvmath.linalg.advanced.MatmulOptions(compute_type=compute_type)
    mm = nvmath.linalg.advanced.Matmul(A, B, options=o)
    mm.plan()

    start = time.time()
    mm.execute()
    end = time.time()
    total_time = end - start

    return total_time

def bench(M, N, K, reps, stateless):
    times = []
    for i in range(reps):
        if stateless:
            t = matmul_stateless(M, N, K)
        else:
            t = matmul_stateful(M, N, K)
        times.append(t)
    avg_time = math.fsum(times) / reps
    return avg_time

if __name__=="__main__":
    parser = argparse.ArgumentParser(description="Matrix Multiplication using DGEMM")
    parser.add_argument("M", type=str, help="Number of rows in matrix A")
    parser.add_argument("N", type=str, help="Number of columns in matrix A and rows in matrix B")
    parser.add_argument("K", type=str, help="Number of columns in matrix B")
    parser.add_argument("reps", type=str, help="Number of runs to average runtime over")
    parser.add_argument("--stateless", action=argparse.BooleanOptionalAction, help="Stateless or stateful API")
    args = parser.parse_args()

    M = int(args.M)
    N = int(args.N)
    K = int(args.K)
    reps = int(args.reps)
    stateless = args.stateless

    avg_time = bench(M, N, K, reps, stateless)
    gflops = 2*M*N*K/(avg_time*1e9)
    print(f"matmul-float32-nvmath-python-{'stateless' if stateless else 'stateful'},{M},{N},{K},{reps},{avg_time:.6f},{gflops:.2f}")
