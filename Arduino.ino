char Buff;
bool SendVibration = false;
int Counter;

void setup() {
  pinMode(3, OUTPUT); 
  Serial.begin(115200);
  Counter = 0;
}

void loop() {
  
  if (SendVibration) {
    Counter+=1;
    if (Counter > 10000) {
        SendVibration = false;
        digitalWrite(3, LOW);
        Counter = 0;
    }
  }
  
  if (Serial.available() > 0) {
    Buff = Serial.read();
    if (Buff == 'V') {
      if (SendVibration == false) digitalWrite(3, HIGH);
      SendVibration = true;
      Counter = 0;
    }
  }
}