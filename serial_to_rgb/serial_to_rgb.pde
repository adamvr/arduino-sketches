#include <string.h>
#include <ctype.h>

/* SERIAL TO RGB
 * 
 * Circuit - three colour LED connected to PWM pins
 * 3, 5 and 6 for R, G and B respectively.
 *
 * Effects - Listens to inputs on serial port and converts
 * messages of the form /(r|g|b)(0-2)(0-5)(0-5)/ into 
 * RGB values to be written to the LED PWM ports
 */

int rgbPins[3] = { 3, 5, 6 };
char tmp[5];

void setup() {
  Serial.begin(9600);
  tmp[0] = '\0';
}

void loop() {
  int i = 0;
  /* Read 4 characters or all that is available in COM3 */
  while(i < 5 && Serial.available()) {
    char c = Serial.read();
    if(!isalnum(c)) {
      break;
    }
    tmp[i] = c;
    i++;
  }
  tmp[i] = '\0';
  if(tmp[0] == 'r') {
    analogWrite(rgbPins[0], atoi(tmp+1));
  } else if(tmp[0] == 'g') {
    analogWrite(rgbPins[1], atoi(tmp+1));
  } else if(tmp[0] == 'b') {
    analogWrite(rgbPins[2], atoi(tmp+1));
  }
  delay(10);
}
  
  
