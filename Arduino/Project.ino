#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
#include "addons/TokenHelper.h" //Provide the token generation process info.
#include "addons/RTDBHelper.h" //Provide the RTDB payload printing info and other helper functions.
#include <OneWire.h>
#include <DallasTemperature.h>


// Insert your network credentials
#define WIFI_SSID "Kiwak"
#define WIFI_PASSWORD "piju1403"
#define API_KEY "AIzaSyAHsV2UF6GTzqBWLSQwcfF-cggs_SZv4Fw" // Insert Firebase project API Key
#define DATABASE_URL "https://aquarium-management-system-default-rtdb.firebaseio.com/" // Insert RTDB URLefine the RTDB URL */

#define DEVICE_UID "1X"
#define DEVICE_UID2 "2X"
const int oneWireBus = 4;  

// Temperature
OneWire oneWire(oneWireBus);
DallasTemperature sensors(&oneWire);
FirebaseJson temperature_json;
float temperature = 0;

// Water Level
const int waterLevelPin = 2; // Replace with the GPIO pin you're using
int level = 0;
FirebaseJson level_json;

//Define Firebase Data object
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
FirebaseData fbdo2;
FirebaseAuth auth2;


String device_location = "Living Room"; // Device Location config


String databasePath = ""; // Firebase database path
String fuid = ""; // Firebase Unique Identifier
unsigned long elapsedMillis = 0; // Stores the elapsed time from device start up
unsigned long LevelelapsedMillis = 0; // Stores the elapsed time from device start up
unsigned long update_interval = 5000; // The frequency of sensor updates to firebase, set to 10seconds
int count = 0; // Dummy counter to test initial firebase updates
bool isAuthenticated = false; // Store device authentication status



void Wifi_Init();
void firebase_init();
void database_test();
void TempRead();
void uploadSensorData();
void LevelRead();
void uploadLevel();

void setup(){
  //SFirebase_Wifi();
  Serial.begin(115200);
  Wifi_Init();
  firebase_init();
  TempRead();
  LevelRead();
}

void loop(){
  //LFirebase();
  uploadSensorData();
  uploadLevel();
}