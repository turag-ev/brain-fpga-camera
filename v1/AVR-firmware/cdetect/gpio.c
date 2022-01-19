#include <avr/io.h>

#include "config.h"
#include "gpio.h"
#include "cdetect.h"

/* GPIO mapping can be found in AVR-SoC/fpga/AVR_SoC_Top.vhd */

/** GPI TASTER **/

uint8_t gpi_get_TASTER(void)
{
    return (~TASTER & 0x0f); // only 4 push buttons connected
}

/** GPI MISC_IA **/

uint8_t gpi_get_IPC_DONE(void)
{
    return (MISC_IA & 0x01);
}

uint8_t gpi_get_FRM_SHOOT(void)
{
    return (MISC_IA & 0x02);
}

uint8_t gpi_get_FRM_DONE(void)
{
    return (MISC_IA & 0x04);
}

uint8_t gpi_get_FXL_RIM_SEL(void)
{
    return (MISC_IA & 0x08);
}

uint8_t gpi_get_CAM_GOOD(void)
{
    return (MISC_IA & 0x10);
}

uint8_t gpi_get_PC_OVERRIDE(void)
{
    return (MISC_IA & 0x20);
}

uint8_t gpi_get_ARM_BUSY(void)
{
    return (MISC_IA & 0x40);
}

/** GPI MISC_IB **/

/** GPI MISC_IC **/

/** GPO DEVLED **/

void gpo_set_DEVLED(uint8_t val)
{
    // inverted!
    DEVLED = ~val;
}

uint8_t gpo_get_DEVLED(void)
{
    return ~DEVLED;
}

/** GPO POWERLED_VAL **/

void gpo_set_POWERLED_VAL(uint8_t val)
{
    POWERLED_VAL = val;
}

uint8_t gpo_get_POWERLED_VAL(void)
{
    return POWERLED_VAL;
}

/** GPO MISC_OA **/

void gpo_set_bit_MISC_OA(uint8_t bitno, uint8_t val)
{
    if (val)
        MISC_OA |= (1<<bitno);
    else
        MISC_OA &= ~(1<<bitno);
}

uint8_t gpo_get_bit_MISC_OA(uint8_t bitno)
{
    return (MISC_OA & (1<<bitno));
}
/**/
void gpo_set_POWERLED_EN(uint8_t val)
{
    gpo_set_bit_MISC_OA(0, val);
}

uint8_t gpo_get_POWERLED_EN(void)
{
    return gpo_get_bit_MISC_OA(0);
}
/**/
void gpo_set_IPC_START(uint8_t val)
{
    gpo_set_bit_MISC_OA(1, val);
}

uint8_t gpo_get_IPC_START(void)
{
    return gpo_get_bit_MISC_OA(1);
}
/**/
void gpo_set_IPC_RST(uint8_t val)
{
    gpo_set_bit_MISC_OA(2, val);
}

uint8_t gpo_get_IPC_RST(void)
{
    return gpo_get_bit_MISC_OA(2);
}
/**/
void gpo_set_RIM_SEL(uint8_t val)
{
    gpo_set_bit_MISC_OA(3, val);
}

uint8_t gpo_get_RIM_SEL(void)
{
    return gpo_get_bit_MISC_OA(3);
}
/**/
void gpo_set_TRIG_MODE(uint8_t val)
{
    gpo_set_bit_MISC_OA(4, val);
}

uint8_t gpo_get_TRIG_MODE(void)
{
    return gpo_get_bit_MISC_OA(4);
}
/**/
void gpo_set_TRIG_OUT(uint8_t val)
{
    gpo_set_bit_MISC_OA(5, val);
}

uint8_t gpo_get_TRIG_OUT(void)
{
    return gpo_get_bit_MISC_OA(5);
}
/**/
void gpo_set_EXPOSURE_TIMESTAMP(uint8_t val)
{
    gpo_set_bit_MISC_OA(6, val);
}

uint8_t gpo_get_EXPOSURE_TIMESTAMP(void)
{
    return gpo_get_bit_MISC_OA(6);
}
/**/
void gpo_set_SPI_CS(uint8_t val)
{
    gpo_set_bit_MISC_OA(7, val);
}

uint8_t gpo_get_SPI_CS(void)
{
    return gpo_get_bit_MISC_OA(7);
}

/** GPO MISC_OB **/

void gpo_set_bit_MISC_OB(uint8_t bitno, uint8_t val)
{
    if (val)
        MISC_OB |= (1<<bitno);
    else
        MISC_OB &= ~(1<<bitno);
}

uint8_t gpo_get_bit_MISC_OB(uint8_t bitno)
{
    return (MISC_OB & (1<<bitno));
}
/**/
void gpo_set_AVR_SETTINGS(uint8_t val)
{
    MISC_OB = val;
}

uint8_t gpo_get_AVR_SETTINGS(void)
{
    return MISC_OB;
}
/**/
void gpo_set_PT_MIN(uint8_t val)
{
    MISC_OC = val;
}

uint8_t gpo_get_PT_MIN(void)
{
    return MISC_OC;
}
/**/
void gpo_set_PT_MAX(uint8_t val)
{
    MISC_OD = val;
}

uint8_t gpo_get_PT_MAX(void)
{
    return MISC_OD;
}
/**/
void gpo_set_STADR(uint8_t val)
{
    STADR = val;
}

uint8_t gpo_get_STADR(void)
{
    return STADR;
}
/**/
void gpo_set_STDAT(uint8_t val)
{
    STDAT = val;
}

uint8_t gpo_get_STDAT(void)
{
    return STDAT;
}

