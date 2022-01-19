#include <avr/io.h>

#include "config.h"
#include "sillydet.h"
#include "cdetect.h"

#if OBJECT_DETECTION
uint8_t detect_coins(uint8_t *base, uint8_t *result, uint8_t result_len)
{/*
    uint16_t i;
    int16_t idx_down, idx_lower, idx_center, idx_right, idx_rightedge;
    uint8_t objcnt = 0, j, l;
    int8_t k, m;
  */
    unsigned short i;
    short idx_down, idx_lower, idx_center, idx_right, idx_rightedge, idx_left, idx_leftedge, k, m, n;
    short nonwhite_down, nonwhite_right, objcnt = 0, j, l, o;
    char found = 0;
    detected_object *detobj = 0;

    for (i = PIXELS_X+1; i < PIXELS_X*(PIXELS_Y-1)-2; i++) {
        // we look for 0 degree edges
        if ((!IS_EDGE_R0(base[i]) && !IS_EDGE_R0(base[i-PIXELS_X])) \
                || (!IS_EDGE_R0(base[i-1]) && !IS_EDGE_R0(base[i-PIXELS_X-1])) \
                || (!IS_EDGE_R0(base[i+1]) && !IS_EDGE_R0(base[i-PIXELS_X+1])))
            continue;
        
        // and a white pixel surrounded by white pixels
        if (!IS_WHITE(base[i]) || !IS_WHITE(base[i-1]) || !IS_WHITE(base[i+1]))
            continue;
        
        nonwhite_down = 0;
    
        // go down and look for another white pixel with 0 degree edge
        for (j = 7; j < 40; j++) {
            idx_down = i + j*PIXELS_X; // j lines down
            if (idx_down >= FRAMEPX)  // check boundary
                continue;

            // count non-white pixels and break
            if (!IS_WHITE(base[idx_down])) {
                nonwhite_down++;
                if (nonwhite_down > 8)
                    break;
            }
            
            // swerve left and right
            for (k = -1; k <= 1; k++) {
                // index of lower edge
                idx_lower = idx_down + k;
                                                
                if ((idx_lower >= FRAMEPX) || (idx_lower < 0))
                    continue;
                
                if ((!IS_EDGE_R0(base[idx_lower]) && !IS_EDGE_R0(base[idx_lower+PIXELS_X])) \
                        || (!IS_WHITE(base[idx_lower]) && !IS_WHITE(base[idx_lower+PIXELS_X])))
                    continue;

                // calculate center pixel
                idx_center = i + (j>>1)*PIXELS_X + (k/2);
                found = 0;
                
                nonwhite_right = 0;
                
                // go to the right from the center
                for (l = 5; l < 30 && !found; l++) {
                    idx_right = idx_center + l;
                    
                    // count non-white ...
                    if (!IS_WHITE(base[idx_right])) {
                        nonwhite_right++;
                        if (nonwhite_right > 10)
                            break;
                    }
                    
                    // go up and down
                    for (m = -3; m <= 3 && !found; m++) {
                        // maybe the right edge
                        idx_rightedge = idx_right + m*PIXELS_X;
                        
                        if ((idx_rightedge >= FRAMEPX) || (idx_rightedge < 0))
                            continue;
                            
                        // is it an edge?
                        if (!IS_EDGE_R90(base[idx_rightedge]))
                            continue;

                        // are the preceding pixels white?
                        if (!IS_WHITE(base[idx_rightedge]) && !IS_WHITE(base[idx_rightedge-1]))
                            continue;
                        
                        base[idx_center] = 0xef;
                
                        // look for a left edge
                        for (n = l-2; n <= l+2 && !found; n++) {
                            idx_left = idx_center - n;
                            
                            for (o = m-2; o <= m+2 && !found; o++) {
                                idx_leftedge = idx_left - o*PIXELS_X;
                                
                                if ((idx_leftedge >= FRAMEPX) || (idx_leftedge < 0))
                                    continue;
                                    
                                // is it an edge?
                                if (!IS_EDGE_R90(base[idx_leftedge]))
                                    continue;

                                // are the preceding pixels white?
                                if (!IS_WHITE(base[idx_leftedge]) && !IS_WHITE(base[idx_leftedge+1]))
                                    continue;
                                    
                                // TODO: check radius dependent on distance
                                
                                // good enough, it's a coin
                                /*
                                detobj = (detected_object*) base + objcnt*sizeof(detected_object);
                                detobj->center_x = idx_center % PIXELS_X;
                                detobj->center_y = idx_center / PIXELS_X;
                                detobj->certainty = 123;
                                detobj->object_type = OBJECT_COIN;
                                detobj->radius = j>>1; // half of the lines down
                                */
                                base[idx_center] = 0xff;
                                objcnt++;
                                found = 1;
                                
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    return objcnt;
}
#endif

