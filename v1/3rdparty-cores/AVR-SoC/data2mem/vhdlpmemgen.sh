#!/bin/bash

if [ "$1" == "" ]; then
	AVRFW=AVR_Softcore
else
	AVRFW="$1"
fi

BMM=../fpga/prog_mem.bmm
ELF=../firmware/${AVRFW}/${AVRFW}.elf
PMEM=../fpga/progMemInit.vhd

pushd $(dirname $0)

set -x
data2mem -bm ${BMM} -bd ${ELF} -o h ${PMEM}
set +x

popd

