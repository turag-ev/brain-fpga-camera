#ifndef config_H_
#define config_H_

#define KNIGHT_RIDER     0
#define OBJECT_DETECTION 0
#define LED_POWER_OFF    0

// only for simulation!
#define NO_INIT         0

// only for testing!
#define RAM_TEST        0

// warnings
#if KNIGHT_RIDER
#warning "KNIGHT_RIDER!"
#endif

#if NO_INIT
#warning "NO_INIT!"
#endif

#if RAM_TEST
#warning "RAM_TEST!"
#endif

#if OBJECT_DETECTION
#warning "OBJECT_DETECTION!"
#endif

#endif
