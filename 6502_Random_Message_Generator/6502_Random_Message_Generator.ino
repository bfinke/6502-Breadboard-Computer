#define BUTTON 22
#define INTERRUPT 23
const int SELECTION[] = {47, 49, 51, 53};

int buttonState;

void setup() {
  pinMode(BUTTON, INPUT);
  pinMode(INTERRUPT, OUTPUT);
  for (int i = 0; i < 4; i++) {
    pinMode(SELECTION[i], OUTPUT);
    }
  randomSeed(analogRead(0));
  digitalWrite(INTERRUPT, HIGH);

  Serial.begin(9600);

}

void loop() {
  buttonState = digitalRead(BUTTON);
  if (buttonState != HIGH) {
    delay(100); // just because I'm not making a debounced button
    for (int i = 0; i < 4; i++) {
      int randomBit = random(2);
      if (randomBit == 1) {
        digitalWrite(SELECTION[i], HIGH);
       } else {
          digitalWrite(SELECTION[i], LOW);
          }
      Serial.print(randomBit);
      }
    Serial.println();
    digitalWrite(INTERRUPT, LOW);
    delay(100);
    digitalWrite(INTERRUPT, HIGH);
  }
}
