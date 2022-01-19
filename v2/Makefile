# bcam makefile

ifndef PLATFORM
    PLATFORM = ufm2
endif

ifeq ($(PLATFORM),ufm2)
    TOP_LEVEL = BC2_top_ufm
    SN = xxxxxx
endif

all:

# the following target is for ZTEX UFM
prog:
	FWLoader -ss $(SN) -rf -uf $(TOP_LEVEL).bit
