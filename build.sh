#!/bin/bash
# Build script for ARM64 kernel with Clang

# Basic configuration
CORES=$(( $(nproc --all) - 2 ))
KERNEL_ROOT=$(pwd)
ARCH="arm64"
DEFCONFIG="clover_defconfig"

# Set toolchain paths
CROSS_TOOLCHAIN="/opt/proton-clang/bin"

# Add toolchains to PATH
export PATH="$CROSS_TOOLCHAIN:$PATH"

# Output folder
OUTPUT="out"

# Output working directory
echo "Cores: $CORES"
echo $KERNEL_ROOT

# Handle --cleanup
if [ "${1-}" == "--cleanup" ]; then
	echo "[+] Cleaning up previous build..."
	rm -rf "$OUTPUT"
	make -j1 \
		ARCH="$ARCH" \
		CLANG_TRIPLE=aarch64-linux-gnu- \
                clean
	make -j1 \
                ARCH="$ARCH" \
                CLANG_TRIPLE=aarch64-linux-gnu- \
		mrproper
	echo "[+] Cleanup done."
	exit 0
fi

# Make Defconfig
if [ ! -d "$OUTPUT" ] || [ ! "$OUTPUT/.config" ]; then
	echo "Generating a config file"
	make -j"$CORES" \
		O="$OUTPUT" \
		ARCH="$ARCH" \
		CC=clang \
		CLANG_TRIPLE=aarch64-linux-gnu- \
		CROSS_COMPILE=aarch64-linux-gnu- \
		"$DEFCONFIG"
fi

if [ "${1-}" == "--menu" ]; then
	echo "Entering menuconfig"
	if [ ! -d "$OUTPUT" ] || [ ! "$OUTPUT/.config" ]; then
		echo "Generating a config file since it doesnt exist"
	        make -j1 \
	                O="$OUTPUT" \
	                ARCH="$ARCH" \
	                CC=clang \
	                CLANG_TRIPLE=aarch64-linux-gnu- \
	                CROSS_COMPILE=aarch64-linux-gnu- \
	                "$DEFCONFIG"
	fi

	make -j1 \
	        O="$OUTPUT" \
	        ARCH="$ARCH" \
	        CC=clang \
	        CLANG_TRIPLE=aarch64-linux-gnu- \
	        CROSS_COMPILE=aarch64-linux-gnu- \
	        menuconfig
	exit 0
fi

# Build kernel
echo "Building the kernel"
make V=1 -j"$CORES" \
	O="$OUTPUT" \
	ARCH="$ARCH" \
	CC=clang \
	CLANG_TRIPLE=aarch64-linux-gnu- \
	CROSS_COMPILE=aarch64-linux-gnu- \
	LLVM=1 \
	LLVM_IAS=1
