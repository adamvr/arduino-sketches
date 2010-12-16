int rgbPins[3] = { 3, 5, 6 };
int analogPin = 0;
int rgb1[3];
int analogValue;
int hueAngle;

void setup() {
  Serial.begin(9600);
  for(int i = 0; i < 3; i++) {
    pinMode(rgbPins[i], OUTPUT);
  }
}

void loop() {
  analogValue = analogRead(0);
  hueAngle = map(analogValue, 0, 1024, 0, 360);
  
  int hprime = hueAngle / 60;
  int x = 1 - abs((hprime % 2) - 1);
  
  if( (0 <= hprime) && (hprime < 1) ) {
    rgb1[0] = 1;
    rgb1[1] = x;
    rgb1[2] = 0;
  } else if( (1 <= hprime) && (hprime < 2) ) {
    rgb1[0] = x;
    rgb1[1] = 1;
    rgb1[2] = 0;
  } else if( (2 <= hprime) && (hprime < 3) ) {
    rgb1[0] = 0;
    rgb1[1] = 1;
    rgb1[2] = x;
  } else if( (3 <= hprime) && (hprime < 4) ) {
    rgb1[0] = 0;
    rgb1[1] = x;
    rgb1[2] = 1;
  } else if( (4 <= hprime) && (hprime < 5) ) {
    rgb1[0] = x;
    rgb1[1] = 0;
    rgb1[2] = 1;
  } else if( (5 <= hprime) && (hprime < 6) ) {
    rgb1[0] = 1;
    rgb1[1] = 0;
    rgb1[2] = x;
  }
  
  for(int i = 0; i < 3; i++) {
    analogWrite(rgbPins[i], rgb1[i] * 32);
  }
  delay(10);
}
