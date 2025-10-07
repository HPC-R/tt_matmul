# Matmul on Nvidia GPUs

This directory includes a [matmul.py](matmul.py) file providing implementations for stateless and stateful matrix multiplication using `nvmath`. For instructions on how to run see the script [run.sh](run.sh). Logs from a GPU node on [Cirrus](https://www.cirrus.ac.uk/) can be found in the [cirrus-r2i4n8](cirrus-r2i4n8/) dir. 

## Install

```
# on Cirrus, issue 
module load python/3.9.13-gpu

# create a virtual environment and source it
python3 -m venv venv
source venv/bin/activate

# on a login node with internet connection
pip install nvmath-python
```

## Running

On a Cirrus login node, run in an interactive session:
```
srun --nodes=1 --exclusive --partition=gpu --gres=gpu:1 --qos=lowpriority --time=0:20:0 --account=d403-mk --pty /bin/bash
```

The run.sh script defines
- the number of runs or repetition which runtime is averaged over,
- a set of matrix sizes (M, N, K), and
- a `--stateless` flag: when defined, a stateless computation is performed, otherwise a stateful computation is run.

The default directory for `CUPY_CACHE_DIR` is the user's home directory. On the compute node, we work in the `/work` directory (the home directory is not accessible), thus set cache directory to somwhere readable:
```
export CUPY_CACHE_DIR=${SCRIPT_DIR}/.cupy/kernel_cache
```

The matmul.py and run.sh scripts will print performance results to the command line output. Run the script with:
```
./run.sh &> run.log001
```

## Stateful vs stateless API

Stateless:
```
import nvmath
a = cupy.asarray([[1, 2], [3, 4]], dtype=cupy.float32)
b = cupy.asarray([[0, 1], [2, 3]], dtype=cupy.float32)
result = nvmath.linalg.advanced.matmul(a, b)
```

Stateful, note the capital M in `Matmul()`:
```
import nvmath
a = cupy.asarray([[1, 2], [3, 4]], dtype=cupy.float32)
b = cupy.asarray([[0, 1], [2, 3]], dtype=cupy.float32)
mm = nvmath.linalg.advanced.Matmul(a, b)
mm.plan()
mm.autotune()
result = mm.execute()
```

For more info, see the [nvmath-python docs](https://docs.nvidia.com/cuda/nvmath-python/0.3.0/tutorials/notebooks/matmul/01_introduction.html).

## Logging

Nvidia logging is available but not activated by default, activate by uncommenting the following lines:
```
import logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)-8s %(message)s', datefmt='%m-%d %H:%M:%S')
```

Logging information from stateful and stateless runs are included in the [cirrus-r2i4n8](cirrus-r2i4n8/) dir.
