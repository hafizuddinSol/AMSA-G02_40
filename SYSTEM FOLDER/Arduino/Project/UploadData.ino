void uploadSensorData() {
if (millis() - elapsedMillis > update_interval && isAuthenticated && Firebase.ready())
{
 elapsedMillis = millis();
 updateSensorReadings();
 String temperature_node = databasePath + "/temperature"; 
 if (Firebase.setJSON(fbdo, temperature_node.c_str(), temperature_json))
 {
 Serial.println("PASSED"); 
 Serial.println("PATH: " + fbdo.dataPath());
 Serial.println("TYPE: " + fbdo.dataType());
 Serial.println("ETag: " + fbdo.ETag());
 Serial.print("VALUE: ");
 printResult(fbdo); //see addons/RTDBHelper.h
 Serial.println("------------------------------------");
 Serial.println();
 }
 else
 {
 Serial.println("FAILED");
 Serial.println("REASON: " + fbdo.errorReason());
 Serial.println("------------------------------------");
 Serial.println();
 }
 }
}

void uploadLevel() {
if (millis() - LevelelapsedMillis > update_interval && isAuthenticated && Firebase.ready())
{
 LevelelapsedMillis = millis();
 updateLevel();
 String level_node2 = databasePath + "/waterlevel"; 
 if (Firebase.setJSON(fbdo2, level_node2.c_str(), level_json))
 {
 Serial.println("PASSED"); 
 Serial.println("PATH: " + fbdo2.dataPath());
 Serial.println("TYPE: " + fbdo2.dataType());
 Serial.println("ETag: " + fbdo2.ETag());
 Serial.print("VALUE: ");
 printResult(fbdo2); //see addons/RTDBHelper.h
 Serial.println("------------------------------------");
 Serial.println();
 }
 else
 {
 Serial.println("FAILED");
 Serial.println("REASON: " + fbdo2.errorReason());
 Serial.println("------------------------------------");
 Serial.println();
 }
 }
}