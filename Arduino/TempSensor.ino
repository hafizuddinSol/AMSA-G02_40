void TempRead(){
  sensors.begin();
temperature_json.add("DeviceUID", DEVICE_UID);
temperature_json.add("Name", "Water Temperature");
temperature_json.add("value", temperature);

String jsonStr;
temperature_json.toString(jsonStr, true);
Serial.println(jsonStr);
}

void updateSensorReadings(){
Serial.println("------------------------------------");
Serial.println("Reading Sensor data ...");
sensors.requestTemperatures(); 
temperature = sensors.getTempCByIndex(0);
// Check if any reads failed and exit early (to try again).
if (isnan(temperature)) {
 Serial.println(F("Failed to read from Temperature sensor!"));
 return;
 }
Serial.printf("Temperature reading: %.2f \n", temperature);
temperature_json.set("value", temperature);
}