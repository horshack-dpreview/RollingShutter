
/*
 ****************************************************************************
 *
 * led_rolling_shutter.ino
 *
 * Toggles built-in LED on ELEGOO UNO R3 Board ATmega328 board, which
 * currently sells for $17 at https://www.amazon.com/dp/B01EWOE0UU. This
 * code is based the idea and logic written by a1ex at Magic Lantern, which
 * can be accessed at https://www.magiclantern.fm/forum/index.php?topic=23040
 */ 

#include <stdarg.h>

//
// Define USE_DIGITAL_WRITE to use the library function when setting
// the LED state, otherwise we directly access the GPIO line via
// the registers. The former is more portable while the latter
// is much faster
//
//#define USE_DIGITAL_WRITE

#define LED_HZ                (500)  // ex: 500 Hz = 1,000 LED power toggles per second
#define LED_TOGGLES_PER_SEC   (LED_HZ * 2)

#define CLK_BASE              (16000000)      // 16 Mhz
#define CLK_DIV               (8)
#define OCR1A_VAL_FOR_LED_HZ  (CLK_BASE / CLK_DIV / LED_TOGGLES_PER_SEC)
#if OCR1A_VAL_FOR_LED_HZ > 65535
#error Invalid OCR1A_VAL_FOR_LED_HZ
#endif

#define LED_PIN               (LED_BUILTIN)
#define LED_PIN_PORT          (PORTB)         // LED is on GPIO PIN 13. PORTA = pins 0..7, PORTB = pins 8..15
#define LED_PIN_PORT_BIT_MASK (0x20)          // GPIO PIN 13 is bit 5 on PORTB, which is data port for pins 8..15

int ledState = 0;

void serialPrintf(const char *fmt, ...) {
  char buff[80];
  va_list arg_ptr;                                                             
  va_start(arg_ptr, fmt);                                                      
  vsnprintf(buff, sizeof(buff), fmt, arg_ptr);                                              
  va_end(arg_ptr);                                                              
  Serial.write(buff);
}      

void setup() {

  Serial.begin(115200);
  serialPrintf("Starting...%d Hz (%d toggles/sec)\n", LED_HZ, LED_TOGGLES_PER_SEC);

  pinMode(LED_PIN, OUTPUT);
  TCCR1A = 0;
  TCCR1B = (1 << WGM12) | (1 << CS11); /* CTC, clock / 8 */
  TIMSK1 = (1 << OCIE1A);              /* output compare interrupt */
  OCR1A = OCR1A_VAL_FOR_LED_HZ - 1;    /* 10000 = 100 Hz, 5000 = 200 Hz, 2000 = 500 Hz and so on */
}

void loop() {
  /* nothing to do */
}

ISR(TIMER1_COMPA_vect) {
  /* toggle LED state */
  ledState = !ledState;
#if defined(USE_DIGITAL_WRITE)
  digitalWrite(LED_PIN, ledState);
#else
  if (ledState)
    LED_PIN_PORT |= LED_PIN_PORT_BIT_MASK;
  else
    LED_PIN_PORT &= ~LED_PIN_PORT_BIT_MASK;
#endif
}
