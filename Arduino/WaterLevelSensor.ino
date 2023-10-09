void LevelRead(){
pinMode(waterLevelPin, INPUT);
level_json.add("DeviceUID", DEVICE_UID2);
level_json.add("Name", "Water Level");
level_json.add("value", level);

String jsonStr;
level_json.toString(jsonStr, true);
Serial.println(jsonStr);
}

void updateLevel(){
Serial.println("------------------------------------");
Serial.println("Reading Water Level data ...");
level = digitalRead(waterLevelPin);
// Check if any reads failed and exit early (to try again).
if (isnan(level)) {
 Serial.println(F("Failed to read from Water Level sensor!"));
 return;
 }
if (level == HIGH) {
    Serial.printf("Water Level reading: %.2f \n", level);
    level_json.set("value", level);
  } else {
    Serial.printf("Water Level reading: %.2f \n", level);
    level_json.set("value", level);
  }
}