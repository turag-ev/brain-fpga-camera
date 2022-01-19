#ifndef cdetect_H_
#define cdetect_H_
	
// define the IO addresses for the attached devices

// GPO
#define GPO_BASE	0x08
#define DEVLED		_SFR_IO8(GPO_BASE+0)
#define POWERLED_VAL _SFR_IO8(GPO_BASE+1)
#define MISC_OA		_SFR_IO8(GPO_BASE+2)
#define MISC_OB		_SFR_IO8(GPO_BASE+3)
#define IPC_SETTINGS MISC_OB
#define MISC_OC		_SFR_IO8(GPO_BASE+4)
#define MISC_OD		_SFR_IO8(GPO_BASE+5)
#define STADR		_SFR_IO8(GPO_BASE+6)
#define STDAT		_SFR_IO8(GPO_BASE+7)

// GPI
#define GPI_BASE 	0x10
#define TASTER		_SFR_IO8(GPI_BASE+0)
#define MISC_IA		_SFR_IO8(GPI_BASE+1)
#define MISC_IB		_SFR_IO8(GPI_BASE+2)
#define MISC_IC		_SFR_IO8(GPI_BASE+3)

// I2C
#define I2C_BASE    0x18
#define I2C_PRERlo  _SFR_IO8(I2C_BASE+0)
#define I2C_PRERhi  _SFR_IO8(I2C_BASE+1)
#define I2C_CTR     _SFR_IO8(I2C_BASE+2)
#define I2C_TXR     _SFR_IO8(I2C_BASE+3)
#define I2C_RXR     _SFR_IO8(I2C_BASE+3)
#define I2C_CR      _SFR_IO8(I2C_BASE+4)
#define I2C_SR      _SFR_IO8(I2C_BASE+4)

// SPI
#define SPI_BASE    0x20
#define SPI_CR      _SFR_IO8(SPI_BASE+0)
#define SPI_SR      _SFR_IO8(SPI_BASE+1)
#define SPI_DR      _SFR_IO8(SPI_BASE+2)
#define SPI_ER      _SFR_IO8(SPI_BASE+3)

#endif
