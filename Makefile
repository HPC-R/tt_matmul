CXX=clang++-17

INCLUDES=-I${TT_METAL_HOME}/tt_metal/api -I${TT_METAL_HOME}/tt_metal/api/tt-metalium -I${TT_METAL_HOME}/build_Release/include -I${TT_METAL_HOME}/build_Release/include/metalium-thirdparty -I${TT_METAL_HOME}/build_Release/include/umd/device/device/api -I${TT_METAL_HOME}/tt_metal/hostdevcommon/api/ -I${TT_METAL_HOME}/tt_metal/third_party/tracy/public

CFLAGS=${INCLUDES} -O3 -Wno-int-to-pointer-cast -stdlib=libc++ -mavx2 -fPIC -DFMT_HEADER_ONLY -fvisibility-inlines-hidden -fno-lto -DARCH_WORMHOLE -DDISABLE_ISSUE_3487_FIX -Werror -Wdelete-non-virtual-dtor -Wreturn-type -Wswitch -Wuninitialized -Wno-unused-parameter -Wsometimes-uninitialized -Wno-c++11-narrowing -Wno-c++23-extensions -Wno-error=local-type-template-args -Wno-delete-non-abstract-non-virtual-dtor -Wno-c99-designator -Wno-shift-op-parentheses -Wno-non-c-typedef-for-linkage -Wno-deprecated-this-capture -Wno-deprecated-volatile -Wno-deprecated-builtins -Wno-deprecated-declarations -std=c++20

LINKER=clang++-17
LFLAGS=-rdynamic -L${TT_METAL_HOME}/build_Release/lib -ltt_metal -ldl -lstdc++fs -pthread -lyaml-cpp -lm -lc++ -ldevice

all: clean single_core multi_core multicore_reuse multicore_reuse_mcast
mkrefdir:
	mkdir -p bin
clean:
	rm src/matmul_single_core.o
	rm src/matmul_multi_core.o
	rm src/matmul_multicore_reuse.o
	rm src/matmul_multicore_reuse_mcast.o
	rm bin/matmul_single_core
	rm bin/matmul_multi_core
	rm bin/matmul_multicore_reuse
	rm bin/matmul_multicore_reuse_mcast
single_core: mkrefdir
	${CXX} ${CFLAGS} -c src/matmul_single_core.cpp -o src/matmul_single_core.o
	${LINKER} src/matmul_single_core.o -o bin/matmul_single_core ${LFLAGS}

multi_core: mkrefdir
	${CXX} ${CFLAGS} -c src/matmul_multi_core.cpp -o src/matmul_multi_core.o
	${LINKER} src/matmul_multi_core.o -o bin/matmul_multi_core ${LFLAGS}

multicore_reuse: mkrefdir
	${CXX} ${CFLAGS} -c src/matmul_multicore_reuse.cpp -o src/matmul_multicore_reuse.o
	${LINKER} src/matmul_multicore_reuse.o -o bin/matmul_multicore_reuse ${LFLAGS} 

multicore_reuse_mcast: mkrefdir
	${CXX} ${CFLAGS} -c src/matmul_multicore_reuse_mcast.cpp -o src/matmul_multicore_reuse_mcast.o
	${LINKER} src/matmul_multicore_reuse_mcast.o -o bin/matmul_multicore_reuse_mcast ${LFLAGS}
