#ifndef gpio_H_
#define gpio_H_

#include <avr/io.h>

uint8_t gpi_get_TASTER(void);

uint8_t gpi_get_IPC_DONE(void);
uint8_t gpi_get_FRM_SHOOT(void);
uint8_t gpi_get_FRM_DONE(void);
uint8_t gpi_get_FXL_RIM_SEL(void);
uint8_t gpi_get_CAM_GOOD(void);
uint8_t gpi_get_PC_OVERRIDE(void);
uint8_t gpi_get_ARM_BUSY(void);

void gpo_set_DEVLED(uint8_t val);
uint8_t gpo_get_DEVLED(void);

void gpo_set_POWERLED_VAL(uint8_t val);
uint8_t gpo_get_POWERLED_VAL(void);

void gpo_set_bit_MISC_OA(uint8_t bitno, uint8_t val);
uint8_t gpo_get_bit_MISC_OA(uint8_t bitno);
void gpo_set_POWERLED_EN(uint8_t val);
uint8_t gpo_get_POWERLED_EN(void);
void gpo_set_IPC_START(uint8_t val);
uint8_t gpo_get_IPC_START(void);
void gpo_set_IPC_RST(uint8_t val);
uint8_t gpo_get_IPC_RST(void);
void gpo_set_RIM_SEL(uint8_t val);
uint8_t gpo_get_RIM_SEL(void);
void gpo_set_TRIG_MODE(uint8_t val);
uint8_t gpo_get_TRIG_MODE(void);
void gpo_set_TRIG_OUT(uint8_t val);
uint8_t gpo_get_TRIG_OUT(void);
void gpo_set_EXPOSURE_TIMESTAMP(uint8_t val);
uint8_t gpo_get_EXPOSURE_TIMESTAMP(void);
void gpo_set_SPI_CS(uint8_t val);
uint8_t gpo_get_SPI_CS(void);

void gpo_set_bit_MISC_OB(uint8_t bitno, uint8_t val);
uint8_t gpo_get_bit_MISC_OB(uint8_t bitno);
void gpo_set_AVR_SETTINGS(uint8_t val);
uint8_t gpo_get_AVR_SETTINGS(void);

void gpo_set_PT_MIN(uint8_t val);
uint8_t gpo_get_PT_MIN(void);

void gpo_set_PT_MAX(uint8_t val);
uint8_t gpo_get_PT_MAX(void);

void gpo_set_STADR(uint8_t val);
uint8_t gpo_get_STADR(void);

void gpo_set_STDAT(uint8_t val);
uint8_t gpo_get_STDAT(void);

#endif
