#include <avr/io.h>

#include "test.h"

uint8_t ram_test(uint8_t *base, uint16_t len)
{
    uint8_t errors = 0, wanted;
    uint16_t i;
    
    // write a backward counting value
    for (i = 0; i < len; i++) {
        base[i] = (uint8_t)(~i);
    }
    
    // verify
    for (i = 0; i < len; i++) {
        wanted = (uint8_t)(~i);
        
        if (base[i] != wanted) {
            // fail
            if (errors < 0xff)
                errors++;
        }
    }
    
    return errors;
}

