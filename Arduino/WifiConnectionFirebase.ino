// void LFirebase(){
//  if (Firebase.ready() && signupOK && (millis() - sendDataPrevMillis > 15000 || sendDataPrevMillis == 0)){
//     sendDataPrevMillis = millis();
//     // Write an Int number on the database path test/int
//     if (Firebase.RTDB.setInt(&fbdo, "test/int", count)){
//       Serial.println("PASSED");
//       Serial.println("PATH: " + fbdo.dataPath());
//       Serial.println("TYPE: " + fbdo.dataType());
//     }
//     else {
//       Serial.println("FAILED");
//       Serial.println("REASON: " + fbdo.errorReason());
//     }
//     count++;
    
//     // Write an Float number on the database path test/float
//     if (Firebase.RTDB.setFloat(&fbdo, "test/float", 0.01 + random(0,100))){
//       Serial.println("PASSED");
//       Serial.println("PATH: " + fbdo.dataPath());
//       Serial.println("TYPE: " + fbdo.dataType());
//     }
//     else {
//       Serial.println("FAILED");
//       Serial.println("REASON: " + fbdo.errorReason());
//     }
//   }
// }

// void SFirebase_Wifi(){
//   Serial.begin(115200);
//   WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
//   Serial.print("Connecting to Wi-Fi");
//   while (WiFi.status() != WL_CONNECTED){
//     Serial.print(".");
//     delay(300);
//   }
//   Serial.println();
//   Serial.print("Connected with IP: ");
//   Serial.println(WiFi.localIP());
//   Serial.println();

//   /* Assign the api key (required) */
//   config.api_key = API_KEY;

//   /* Assign the RTDB URL (required) */
//   config.database_url = DATABASE_URL;

//   /* Sign up */
//   if (Firebase.signUp(&config, &auth, "", "")){
//     Serial.println("ok");
//     signupOK = true;
//   }
//   else{
//     Serial.printf("%s\n", config.signer.signupError.message.c_str());
//   }

//   /* Assign the callback function for the long running token generation task */
//   config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h
  
//   Firebase.begin(&config, &auth);
//   Firebase.reconnectWiFi(true);
// }

void Wifi_Init() {
 WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
 Serial.print("Connecting to Wi-Fi");
 while (WiFi.status() != WL_CONNECTED){
  Serial.print(".");
  delay(300);
  }
 Serial.println();
 Serial.print("Connected with IP: ");
 Serial.println(WiFi.localIP());
 Serial.println();
}

void firebase_init() {
// configure firebase API Key
config.api_key = API_KEY;
// configure firebase realtime database url
config.database_url = DATABASE_URL;
// Enable WiFi reconnection 
Firebase.reconnectWiFi(true);
Serial.println("------------------------------------");
Serial.println("Sign up new user...");
// Sign in to firebase Anonymously
if (Firebase.signUp(&config, &auth, "", ""))
{
Serial.println("Success");
 isAuthenticated = true;
// Set the database path where updates will be loaded for this device
 databasePath = "/" + device_location;
 fuid = auth.token.uid.c_str();
}
else
{
 Serial.printf("Failed, %s\n", config.signer.signupError.message.c_str());
 isAuthenticated = false;
}
// Assign the callback function for the long running token generation task, see addons/TokenHelper.h
config.token_status_callback = tokenStatusCallback;
// Initialise the firebase library
Firebase.begin(&config, &auth);
}
