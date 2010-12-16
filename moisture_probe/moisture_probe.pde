void setup() {
  analogReference(EXTERNAL);
  Serial.begin(9660);
}

#define MAX_SAMPLES 10

int sampleNum = 0;
int samples[MAX_SAMPLES];

void loop() {
  if(sampleNum < MAX_SAMPLES) {
    samples[sampleNum++] = analogRead(0);
    delay(1000/MAX_SAMPLES);
  } else if(sampleNum >= MAX_SAMPLES) {
    //Serial.print("Samples: [");
    int avg = 0;
    for(int i = 0; i < MAX_SAMPLES; i++) {
      //Serial.print(samples[i]);
      //Serial.print(", ");
      avg += samples[i];
      samples[i] = 0;
    }
    //Serial.print(samples[MAX_SAMPLES - 1]);
    //Serial.println("]");
    Serial.println(avg/MAX_SAMPLES);
    sampleNum = 0;
  }
}
