#ifndef sillydet_H_
#define sillydet_H_

#include <avr/io.h>

uint8_t detect_coins(uint8_t *base, uint8_t *result, uint8_t result_len);

typedef struct {
    uint8_t center_x, center_y;
    uint8_t certainty;
    uint8_t object_type;
    uint8_t radius;
} detected_object;

#define OBJECTS_MAX 64

#define OBJECT_COIN 1

#define IRAM_BASE   ((uint8_t*)(0x8000))
#define PIXELS_X    (160)
#define PIXELS_Y    (120)
#define FRAMEPX     (PIXELS_X*PIXELS_Y)

#define IS_WHITE(x)     ((x & 0xf0) == 0x50)

#define IS_EDGE(x)      (x & 3)
#define IS_EDGE_0(x)    (IS_EDGE(x) && ((x & 0xc) == 0))
#define IS_EDGE_45(x)   (IS_EDGE(x) && ((x & 0xc) == 4))
#define IS_EDGE_90(x)   (IS_EDGE(x) && ((x & 0xc) == 8))
#define IS_EDGE_135(x)  (IS_EDGE(x) && ((x & 0xc) == 0xc))
// compensate errors, lol
#define IS_EDGE_R0(x)    IS_EDGE_0(x)
#define IS_EDGE_R45(x)   (IS_EDGE_90(x) || IS_EDGE_45(x))
#define IS_EDGE_R90(x)   IS_EDGE_135(x)
#define IS_EDGE_R135(x)  IS_EDGE_0(x)

#endif
