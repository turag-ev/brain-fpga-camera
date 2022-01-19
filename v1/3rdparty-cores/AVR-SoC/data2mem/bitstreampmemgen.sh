#!/bin/bash

if [ "$1" = "" ]; then
	echo "Usage: $0 <BananaCam_XXX.bit> [AVR firmware dir]"
	exit 1
fi

if [ "$2" == "" ]; then
	AVRFW=AVR_Softcore
else
	AVRFW="$2"
fi

BMM=../fpga/prog_mem_bd.bmm
ELF=../firmware/${AVRFW}/${AVRFW}.elf
PLT=$1
BIT=../../BananaCam_${PLT}.bit
OUTBIT=../../BananaCam_${PLT}-avrpmem.bit

pushd $(dirname $0)

data2mem -bm ${BMM} -bd ${ELF} -bt ${BIT} -o b ${OUTBIT}

popd

