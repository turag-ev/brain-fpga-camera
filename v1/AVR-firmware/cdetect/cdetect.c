#include <avr/io.h>
#include <util/delay.h>

#include "config.h"
#include "cdetect.h"
#include "gpio.h"
#include "knight.h"
#include "i2c.h"
#include "mt.h"
#include "spi.h"
#include "sillydet.h"
#include "test.h"

/* ROM: 4 kB
 * RAM map:
 * 0x0000 - 0x1fff => SRAM, 4 kB
 * 0x8000 - 0xcaff => Image RAM, 19200 bytes
 */

void cdetect_init(void)
{
#if RAM_TEST
    uint8_t i;
#endif

    gpo_set_DEVLED(0x01);
    i2c_init();

#if !NO_INIT
    gpo_set_DEVLED(0x02);
    mt_init();
#endif

    gpo_set_DEVLED(0x04);
    spi_init();

#if RAM_TEST
    i = ram_test(IRAM_BASE, 19200);
    if (i)
        gpo_set_DEVLED(0x33); // bad
    else
        gpo_set_DEVLED(0x55); // good

    _delay_ms(1000);
#endif

#if KNIGHT_RIDER
	knight_rider();
#endif

    gpo_set_DEVLED(0x08);
}

int main(void)
{
#if OBJECT_DETECTION
    uint8_t objcnt, objects[sizeof(detected_object) * OBJECTS_MAX] = { 0 };
#endif
    uint8_t failcnt = 0, foo, i, first = 1;

#if !NO_INIT
    _delay_ms(200);
#endif

    cdetect_init();

    // wait until camera is init'ed
    while (!gpi_get_CAM_GOOD()) {
        _delay_ms(10);

        // try for 500 ms, then try init again
        if (failcnt++ >= 40) {
            gpo_set_DEVLED(0xff);
            _delay_ms(100);
            cdetect_init();
            failcnt = 0;
        }
    }

    gpo_set_DEVLED(0x10);

    // configure some FPGA internal components ...

    gpo_set_AVR_SETTINGS(0x00);
    gpo_set_PT_MIN(0x10);
    gpo_set_PT_MAX(0x35);

    // cbmin
    gpo_set_STADR(0);
    gpo_set_STDAT(72);
    gpo_set_STADR(1);
    // cbmax
    gpo_set_STADR(0);
    gpo_set_STDAT(129);
    gpo_set_STADR(2);
    // crmin
    gpo_set_STADR(0);
    gpo_set_STDAT(127);
    gpo_set_STADR(3);
    // crmax
    gpo_set_STADR(0);
    gpo_set_STDAT(155);
    gpo_set_STADR(4);
    // ymin
    gpo_set_STADR(0);
    gpo_set_STDAT(160);
    gpo_set_STADR(5);
    // done
    gpo_set_STADR(0);
    gpo_set_STDAT(0);

    // power-up LEDs
    gpo_set_POWERLED_VAL(4);
    gpo_set_POWERLED_EN(1);

    for (i = 5; i < 20; i++) {
#if !NO_INIT
        _delay_ms(30);
#endif
        gpo_set_POWERLED_VAL(i);
    }

    while (1) {
        if (first || gpi_get_PC_OVERRIDE()) {
            first = 0;
            // PC wants access to RAMs

            // pipe RIM_SEL through
            foo = gpi_get_FXL_RIM_SEL();
            gpo_set_RIM_SEL(foo);
            gpo_set_DEVLED(foo);

            // disable cam trigger mode
            gpo_set_TRIG_MODE(1);
            gpo_set_TRIG_OUT(0);

            // disable ipc
            if (!foo) {
                gpo_set_IPC_RST(1);
                gpo_set_IPC_START(1);

                gpo_set_IPC_RST(0);
                gpo_set_IPC_START(0);

                while (!gpi_get_IPC_DONE());
                while (!gpi_get_FXL_RIM_SEL())
                    gpo_set_DEVLED(0x80);
            } else {
                gpo_set_IPC_RST(0);
                gpo_set_IPC_START(0);
            }
        } else {
            // set cam trigger mode and trigger
            gpo_set_TRIG_MODE(1);
            gpo_set_TRIG_OUT(0);
        }

        if (!gpi_get_ARM_BUSY() && !gpi_get_PC_OVERRIDE()) {
            // ARM is ready, PC doesn't want data, capture a frame and send the data

            // we don't need it, so let the PC see the RAM's content
            gpo_set_RIM_SEL(1);

            // set cam trigger mode and trigger
            gpo_set_TRIG_MODE(1);
            gpo_set_TRIG_OUT(1);

            // wait until frame is being captured and then until it's done
            while (!gpi_get_FRM_SHOOT())
                gpo_set_DEVLED(0x01);

            // release trigger
            gpo_set_TRIG_OUT(0);

            while (!gpi_get_FRM_DONE())
                gpo_set_DEVLED(0x02);

            // reset and start ipctl
            gpo_set_RIM_SEL(0); // select path for IPC

            gpo_set_IPC_RST(1);
            gpo_set_IPC_START(1);

            gpo_set_IPC_RST(0);
            gpo_set_IPC_START(0);

            // wait until it's done
            while (!gpi_get_IPC_DONE())
                gpo_set_DEVLED(0x03);

            gpo_set_RIM_SEL(1); // deselect IPC path, so the PC can access the RAMs

            // "object detection may start"
            gpo_set_DEVLED(0x04);

#if OBJECT_DETECTION
            // do object detection
            objcnt = detect_coins(IRAM_BASE, objects, OBJECTS_MAX);
            gpo_set_DEVLED(objcnt);

//            spi_send_bytes16(objects, objcnt * sizeof(detected_object));
            spi_send_bytes16(IRAM_BASE, 19200);
            gpo_set_DEVLED(0x10);
#endif

            // transfer IRAM content via SPI to the ARM
            spi_send_bytes16(IRAM_BASE, 19200);
            gpo_set_DEVLED(0x08);
        }
    }
}

