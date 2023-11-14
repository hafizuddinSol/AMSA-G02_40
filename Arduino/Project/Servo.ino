
void Servo() {
  myservo.attach(5);  // Attaches the servo motor to pin 9 and initializes the servo object
}

void Servo1() {
  if(Firebase.getInt(firebasEData, "/feedTime")){
  x = firebasEData.intData();
  for (pos = 0; pos <= 90; pos += 1) {
    myservo.write(pos);
    delay(1);
  }

  delay(x);

  for (pos = 90; pos >= 0; pos -= 1) {
    myservo.write(pos);
    delay(1);
  }
  }
  

  delay(1000);

    if (Firebase.getString(firebaseData, "/feedFish")) {
      feedValue = firebaseData.stringData();
         // Move the servo if the user enters "Now"
    if (feedValue == "Now") {
      for (pos = 0; pos <= 90; pos += 1) {
        myservo.write(pos);
        delay(1);
      }

      delay(1000);

      for (pos = 90 ; pos >= 0; pos -= 1) {
        myservo.write(pos);
        delay(1);
      }

      delay(1000);
    }
    // Add a condition to handle "Not"
    else if (feedValue == "Not") {
      // Add the code for the "Not" condition if needed
    }
    }
}
