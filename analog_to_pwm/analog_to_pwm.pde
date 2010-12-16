/*
  Analog in, PWM out
 
 Circuit: Force sensing resistor, 1kohm resistor
          in voltage divider on analog port 0.
          LED in series with 330ohm resistor on
          digital port 9
 Effects: When the FSR is squeezed, the LED is lit or dimmed
          proportional to the force applied to the FSR
    
 */
 
 /* Pin to read FSR data from */
 int analogPin = 0;
 /* Pin to write PWM to */
 int pwmPin = 3;
 /* Value read from analog pin */
 int analogValue;
 /* Value to write the PWM pin */
 int pwmValue;
 /* Upper limit of the analog pin */
 int analogUpper = 1024;
 /* Lower limit of the analog pin */
 int analogLower = 0;
 /* Upper limit of the PWM pin */
 int pwmUpper = 255;
 /* Lower limit of the PWM pin */
 int pwmLower = 0;
 
 void setup() {
   /* Nothing to do */
 }
 
 
 void loop() {
   /* Read value of the analog pin */
   analogValue = analogRead(analogPin);
   /* Map the analog range to the PWM range */
   pwmValue = map(analogValue, analogLower, analogUpper, 
       pwmLower, pwmUpper);
   /* Write the PWM value to the pwm pin */
   analogWrite(pwmPin, pwmValue);
   
   /* Pause and allow everything to settle */
   delay(30);
 }
