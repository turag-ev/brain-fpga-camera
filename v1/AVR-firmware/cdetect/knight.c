#include <avr/io.h>
#include <util/delay.h>

#include "config.h"
#include "cdetect.h"
#include "knight.h"

#if KNIGHT_RIDER
void knight_rider(void)
{    
	uint8_t left = 1;
	uint16_t leds = 0x0010, mask1 = 0, mask2 = 0, mask3 = 0, mask4 = 0, i = 0;

    while (1) {
	    // LED pins are low active
    	DEVLED = (uint8_t)~(leds>>4);
    	
    	// XOR mask for the tail
    	if (left) {
    	    mask1 = leds>>1;
    	    mask2 = leds>>2;
    	    mask3 = leds<<1;
    	    mask4 = leds<<2;
    	} else {
    	    mask1 = leds<<1;
    	    mask2 = leds<<2;
    	    mask3 = leds>>1;
    	    mask4 = leds>>2;
    	}
    	
    	// PWM tail
    	for (i = 0; i < 255; i++) {
    	    // leds on
    	    DEVLED &= ~((mask1|mask2|mask3|mask4)>>4);
    	    _delay_us(25);
    	    
    	    // off
    	    DEVLED |= (mask2|mask4)>>4;
    	    _delay_us(50);
    	    
    	    DEVLED |= (mask1|mask3)>>4;
    	    _delay_us(100);
    	}

        // left/right edges
	    if (leds == 0x0800) {
	        left = 0;
	        
	        for (i = 0; i < 512; i++) {
        	    // leds on
    	        DEVLED &= ~((mask1|mask2|mask3|mask4)>>4);
        	    _delay_us(25);
    	    
        	    // off
        	    DEVLED |= (mask2|mask4)>>4;
        	    _delay_us(50);
    	    
        	    DEVLED |= (mask1|mask3)>>4;
        	    _delay_us(100);
        	}
	    } else if (leds == 0x0010) {
	        left = 1;
        	
        	for (i = 0; i < 512; i++) {
        	    // leds on
    	        DEVLED &= ~((mask1|mask2|mask3|mask4)>>4);
        	    _delay_us(25);
    	    
        	    // off
        	    DEVLED |= (mask2|mask4)>>4;
        	    _delay_us(50);
    	    
        	    DEVLED |= (mask1|mask3)>>4;
        	    _delay_us(100);
        	}
	    }

        // slide
        if (left)
            leds <<= 1;
	    else
	        leds >>= 1;
	}
}
#endif

