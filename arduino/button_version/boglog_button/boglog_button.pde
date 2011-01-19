#include <SPI.h>
#include <Ethernet.h>

byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,168,115 };
byte gateway[] = {192,168,168,254 };
// the subnet:
byte subnet[] = { 255, 255, 255, 0 }; 
byte server[] = { 184,106,156,81};//PC 192,168,168,114 };//209,85,227,99 }; // Google
Client client(server, 80);


int inPin = 7;   // choose the input pin (for a pushbutton)
int ledPin = 13;
int sensorValue = 0;
int threshold = 150;
int secondsInNewState = 0;
String cState, nState, STATE_ENGAGED, STATE_DISENGAGED;

void setup() {
  Ethernet.begin(mac, ip);

  STATE_ENGAGED = String("engage");
  STATE_DISENGAGED = String("disengage");
  cState = STATE_DISENGAGED;
  nState = "";
  // declare the ledPin as an OUTPUT:
  pinMode(ledPin, OUTPUT);  
  pinMode(inPin, INPUT);    // declare pushbutton as input

  Ethernet.begin(mac, ip, gateway, subnet);
  Serial.begin(9600);
  delay(1000);
  
  //establishContact();
}

void loop() {
  digitalWrite(ledPin, LOW); 
  
  sensorValue = digitalRead(inPin);

  if ( sensorValue == LOW ) {
    if(cState == STATE_ENGAGED)
      resetTransition();
    else
      nState = STATE_ENGAGED; //start transition
  }
  else if( sensorValue == HIGH )
  {
    if(cState == STATE_DISENGAGED)
      resetTransition();
    else
      nState = STATE_DISENGAGED; //start transition
  }

  if( nState != "")
  {
    secondsInNewState++;
    if(secondsInNewState == 1) //complete transition
    {
      cState = nState;
      digitalWrite(ledPin, HIGH);
      resetTransition();
      // call service
      if (Serial.available() > 0) {
        Serial.println("CALL SERVICE "+ cState);
      }

      if (client.connect()) {
        Serial.print(" - Connected");

        // Send the HTTP GET to the server
        client.println("GET /api/action/"+cState+"/ HTTP/1.0");
        client.println("Host: boglogging.com");
        client.println();

        // Read the response
        Serial.print(" - ");
        Serial.print(ReadResponse(), DEC);
        Serial.println(" bytes received");

        // Disconnect from the server
        client.flush();
        client.stop();

      } 
      else {
        // Connection failed
        Serial.println(" - CONNECTION FAILED!");
      }

    }
  }

  //debug
  if (Serial.available() > 0) {
    Serial.println("CURRENT:  "+cState+"     NEW:  "+nState);
    Serial.println(sensorValue, DEC);
  }

  delay(1000);                
}

void resetTransition() {
  nState = "";
  secondsInNewState = 0;
}

void establishContact() { 
  while (Serial.available() <= 0) { 
    Serial.println("waiting for any message");   // send an initial string 
    delay(300); 
  } 
} 

int ReadResponse(){
  int totalBytes=0;
  unsigned long startTime = millis();

// First wait up to 5 seconds for the server to return some data.
// If we don't have this initial timeout period we might try to
// read the data "too quickly" before the server can generate the
// response to the request

  while ((!client.available()) && ((millis() - startTime ) < 5000));
  
  //Serial.println();
  while (client.available()) {
    char c = client.read();
    //Serial.print(c);
    totalBytes+=1;
  }
  return totalBytes;
} 

