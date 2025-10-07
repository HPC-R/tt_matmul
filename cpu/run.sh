#!/bin/bash

source ../venv/bin/activate

# repetitions are performed in the .py file
REPS=100	
MATRIX_SIZES=(
	"128 128 128"
    "3584 3072 768"
)

echo "bench,M,N,K,reps,avg_time,gflops"
for size in "${MATRIX_SIZES[@]}"; do
	python3 dgemm.py ${size} ${REPS}
done
