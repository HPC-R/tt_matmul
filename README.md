# tt-matmul

Benchmarking optimised matrix multiplication kernels on the [Tenstorrent Wormhole n300 accelerator card](https://tenstorrent.com/hardware/wormhole). For the step-wise incremental optimisations, see the various kernels in the [src](src/) directory:

- matmul_single_core.cpp
- matmul_multi_core.cpp
- matmul_multicore_reuse.cpp
- matmul_multicore_reuse_mcast.cpp

## Build

Clone the repository, initialise the `tt-power` submodule and build the code using the provided Makefile. Note, for power draw measurements, we require openMP for threading in the host code.

```
git clone git@github.com:markxio/tt-matmul.git
git submodule init
git submodule update
make all
```

## WIP

- per kernel, write perf, power, energy to csv
- add kernel descriptions
- add matrix size scaling
