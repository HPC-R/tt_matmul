import numpy as np
import scipy.linalg.blas as slb
import time
import argparse
import math
import pyrapl

#np.show_config()

def dgemm(M, N, K):
    a = np.array(np.random.random((M, N)), dtype=np.double, order='C', copy=False)
    b = np.array(np.random.random((N, K)), dtype=np.double, order='C', copy=False)
    A = np.matrix(a, dtype=np.double, copy=False)
    B = np.matrix(b, dtype=np.double, copy=False)

    start = time.time()
    energy_start = pyrapl.get_joules_rapl()
    
    C = slb.dgemm(1.0, a=A, b=B)
    
    energy_end = pyrapl.get_joules_rapl()
    end = time.time()

    total_time = end - start
    total_energy = energy_end - energy_start
    
    return total_time, total_energy

def bench(M, N, K, reps):
    times = []
    energy = []
    for i in range(reps):
        t, e = dgemm(M, N, K)
        times.append(t)
        energy.append(e)
    avg_time = math.fsum(times) / reps
    avg_energy = math.fsum(energy) / reps
    
    return avg_time, avg_energy

if __name__=="__main__":
    parser = argparse.ArgumentParser(description="Matrix Multiplication using DGEMM")
    parser.add_argument("M", type=str, help="Number of rows in matrix A")
    parser.add_argument("N", type=str, help="Number of columns in matrix A and rows in matrix B")
    parser.add_argument("K", type=str, help="Number of columns in matrix B")
    parser.add_argument("reps", type=str, help="Number of runs to average runtime over")
    args = parser.parse_args()

    M = int(args.M)
    N = int(args.N)
    K = int(args.K)
    reps = int(args.reps)

    avg_time, avg_energy = bench(M, N, K, reps)
    gflops = 2*M*N*K/(avg_time*1e9)
    print(f"dgemm-python,{M},{N},{K},{reps},{avg_time:.6f},{avg_energy:.6f},{gflops:.2f}")
