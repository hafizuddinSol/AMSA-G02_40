#define SensorPin A1            //pH meter Analog output to Arduino Analog Input 0
#define Offset 0.00            //deviation compensate
#define LED 13
#define samplingInterval 20
#define printInterval 3000
#define ArrayLenth  40    //times of collection
#include <OneWire.h>
#include <DallasTemperature.h>
#define ONE_WIRE_BUS 2

OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);
 
int pHArray[ArrayLenth];   //Store the average value of the sensor feedback
int pHArrayIndex=0;
const int read = A0;
int value;
int pos = 0;

void setup(void)
{
  pinMode(LED,OUTPUT);
  Serial.begin(9600);
  Serial.println("pH meter experiment!");    //Test the serial monitor

  Serial.begin(9600); //Begin serial communication
  Serial.println("Arduino Digital Temperature // Serial Monitor Version"); //Print a message
  sensors.begin();
}
void loop(void)
{
  static unsigned long samplingTime = millis();
  static unsigned long printTime = millis();
  static float pHValue,voltage;
  if(millis()-samplingTime > samplingInterval)
  {
      pHArray[pHArrayIndex++]=analogRead(SensorPin);
      if(pHArrayIndex==ArrayLenth)pHArrayIndex=0;
      voltage = avergearray(pHArray, ArrayLenth)*5.0/1024;
      pHValue = 3.5*voltage+Offset;
      samplingTime=millis();
  }
  if(millis() - printTime > printInterval)   //Every 800 milliseconds, print a numerical, convert the state of the LED indicator
  {
    Serial.print("Voltage:");
        Serial.print(voltage,2);
        Serial.print("    pH value: ");
    Serial.println(pHValue,2);
        digitalWrite(LED,digitalRead(LED)^1);
        printTime=millis();
  }

value = analogRead(read); //Read data from analog pin and store it to value variable
	
	if (value<=480){ 
		Serial.println("Water level: 0mm - Empty!"); 
	}
	else if (value>480 && value<=530){ 
		Serial.println("Water level: 0mm to 5mm"); 
	}
	else if (value>530 && value<=615){ 
		Serial.println("Water level: 5mm to 10mm"); 
	}
	else if (value>615 && value<=660){ 
		Serial.println("Water level: 10mm to 15mm"); 
	}	
	else if (value>660 && value<=680){ 
		Serial.println("Water level: 15mm to 20mm"); 
	}
	else if (value>680 && value<=690){ 
		Serial.println("Water level: 20mm to 25mm"); 
	}
	else if (value>690 && value<=700){ 
		Serial.println("Water level: 25mm to 30mm"); 
	}
	else if (value>700 && value<=705){ 
		Serial.println("Water level: 30mm to 35mm"); 
	}
	else if (value>705){ 
		Serial.println("Water level: 35mm to 40mm Full"); 
	}
	
	delay(3000); // Check for new value every 3 sec

  sensors.requestTemperatures();  
  Serial.print("Temperature is: ");
  Serial.println(sensors.getTempCByIndex(0)); // Why "byIndex"? You can have more than one IC on the same bus. 0 refers to the first IC on the wire
  //Update value every 3 sec.
  delay(3000);
}
double avergearray(int* arr, int number){
  int i;
  int max,min;
  double avg;
  long amount=0;
  if(number<=0){
    Serial.println("Error number for the array to avraging!/n");
    return 0;
  }
  if(number<5){   //less than 5, calculated directly statistics
    for(i=0;i<number;i++){
      amount+=arr[i];
    }
    avg = amount/number;
    return avg;
  }else{
    if(arr[0]<arr[1]){
      min = arr[0];max=arr[1];
    }
    else{
      min=arr[1];max=arr[0];
    }
    for(i=2;i<number;i++){
      if(arr[i]<min){
        amount+=min;        //arr<min
        min=arr[i];
      }else {
        if(arr[i]>max){
          amount+=max;    //arr>max
          max=arr[i];
        }else{
          amount+=arr[i]; //min<=arr<=max
        }
      }//if
    }//for
    avg = (double)amount/(number-2);
  }//if
  return avg;
}