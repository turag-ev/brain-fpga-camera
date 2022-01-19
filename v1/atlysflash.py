#!/usr/bin/python
# LD_LIBRARY_PATH=/home/bob/src/libfpgalink-20120507/linux.x86_64/rel PYTHONPATH=/home/bob/src/libfpgalink-20120507/examples/python python ./atlysflash.py BC2_top_atlys.xsvf

from sys import argv, exit
from os.path import exists
from time import sleep
from logging import getLogger, DEBUG, info

if len(argv) != 2:
	print "Usage:", argv[0], "<.svf|.xsvf|.csvf>"
	exit(1)

jtagfile = argv[1]
if not exists(jtagfile):
	print "file does not exist"
	exit(2)

getLogger().setLevel(DEBUG)

from fpgalink2 import *
vp = "1443:0007"

info("loading FX2 fw ...")
flLoadStandardFirmware(vp, vp, "D0234")
info("waiting for device enumeration ...")
flAwaitDevice(vp, 50)
info("opening device ...")
handle = flOpen(vp)
info("playing JTAG commands ...")
flPlayXSVF(handle, jtagfile)
info("done")
flClose(handle)

