#include <Adafruit_ADS1X15.h>

Adafruit_ADS1115 adc;

// the setup routine runs once when you press reset:
void setup() {
  Serial.begin(115200);
  adc.setDataRate(RATE_ADS1115_860SPS);
  adc.setGain(GAIN_TWOTHIRDS);  //default value
  adc.begin();
}

void loop() {
  int voltage = adc.readADC_SingleEnded(0);
  int current = adc.readADC_SingleEnded(1);
  Serial.println(voltage);
  Serial.println(current);
}
