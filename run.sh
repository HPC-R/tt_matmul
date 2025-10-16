#!/bin/bash

#constexpr uint32_t M = 3584;  // user-defined
#constexpr uint32_t N = 3072;  // user-defined
#constexpr uint32_t K = 768;   // user-defined
#constexpr uint32_t B = 1;     // user-defined

EXE=bin/matmul_multicore_reuse_mcast_args  
PERF_CSV="perf.csv"
PERF_AVG_CSV="perf_avg.csv"
REPS=100

# NOTE: Only supports matmuls where output is blocks of 16 x 16 tiles (ie. multiples of 16*32 x 16*32)
# NOTE: Maximum number of tiles in output is 120 * 16^2 = 30,720 (eg. [1, 1, 5120, 6144])

# Examples That Will Fail
# 1024, 1024, 1024: too few tiles per block; invalid CoreRange
# 256, 4096, 1024: underflows the core grid in M
# 8192, 8192, 1024: exceeds the 30,720 tile output limit

# supported matrices for the Wormhole matmul_multicore_reuse_mcast kernel are those where M, N, and K are multiples of 32, 
# the resulting output (M×N) forms 16×16 tile blocks (multiples of 512), and the total number of output tiles <= 30,720.

# M, N, K
MATRIX_SIZES=(
    "1536 1536 768"
    "2048 2048 1024"
    "3072 3584 1024"
    "3584 3072 768"
    "5120 6144 2048"
)
# working
#    "1536 1536 1024"
#    "3584 3072 768"

export LD_LIBRARY_PATH=/opt/llvm-17.0.6-omp:$LD_LIBRARY_PATH ;

echo "filename,M,N,K,B,total_time,xfer_on_time,exec_time,xfer_off_time,power_xfer_on,power_exec,power_xfer_off,total_energy,energy_xfer_on,energy_exec" > $PERF_CSV
for size in "${MATRIX_SIZES[@]}"; do
    read -r M N K <<< "$size"
	for i in $(seq 1 $(($REPS))); do
    	$EXE $M $N $K 1
    done
done

source venv/bin/activate
python3 utils/average.py $PERF_CSV $PERF_AVG_CSV

mkdir -p results
mv $PERF_CSV results/perf_$(date +%Y%m%d_%H%M%S).csv
mv $PERF_AVG_CSV results/perf_$(date +%Y%m%d_%H%M%S)_avg.csv
