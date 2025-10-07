#!/bin/bash

source venv-python3.9.13-gpu/bin/activate

# repetitions are performed in the .py file
REPS=100 
MATRIX_SIZES=(
    "128 128 128"
    "3584 3072 768"
)
# if --stateless is set, will perform stateless matmul
# if ommitted, will perform stateful matmul

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export CUPY_CACHE_DIR=${SCRIPT_DIR}/.cupy/kernel_cache

echo "bench,M,N,K,reps,avg_time,gflops"
for size in "${MATRIX_SIZES[@]}"; do
    python3 matmul.py ${size} ${REPS} --stateless
done
