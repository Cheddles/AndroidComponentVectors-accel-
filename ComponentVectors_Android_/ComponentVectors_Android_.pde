// This application written by Chris Heddles
// Copyright 2014 South Australian Department of Education and Child Development (DECD)
// Released under GPL v3 (https://www.gnu.org/licenses/gpl.html)


// import the Android libraries required to access the accelerometer
import android.content.Context;               
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;

//declare objects required to access accelerometer data
SensorManager sensorManager;      
SensorListener sensorListener;
Sensor accelerometer;             

float[] accelData = new float[3];       // 3-value array to store X, Y and Z acceleration value sums
int counter;  // counts the number of acceleration events stored in accelData

Float scale;  // pixels of vector per m/s/s vector value
String units=" m/s/s"; // units for the vector (with a leading space)

int lineWeight;  // set line weight for all arrows

// set up arrows for each vector (red, green, blue, line weight)
Arrow totalVector;
Arrow verticalComponent;
Arrow horizontalComponent;

void setup(){
 orientation(PORTRAIT);
 frameRate(10);  // to keep the acceleration values from getting too jumpy
 scale=width/5.0;
 lineWeight = int(float(width)/80.0);
 totalVector = new Arrow (0, 0, 0, lineWeight);
 verticalComponent = new Arrow (255, 0, 0, lineWeight);
 horizontalComponent = new Arrow (0, 0, 255, lineWeight);
}

void draw(){
  
  background(255);
  if (counter != 0){
    // divide acceleration sums by counter value to get average values
    accelData[0]=accelData[0]/float(counter);
    accelData[1]=accelData[1]/float(counter);
    accelData[2]=accelData[2]/float(counter);
    
    // calculate vector values
    float totalValue = pow(pow(accelData[0],2)+pow(accelData[1],2),0.5);
    float verticalValue = abs(accelData[1]);
    float horizontalValue = abs(accelData[0]);

    // determine horizontal component directions
    String horizontalDirection=" right";
    if (accelData[0]>0) horizontalDirection=" left";

    // set display height to empty half of the screen and determine vertical component direction
    int textTop = int(float(height)/10);
    String verticalDirection = " down";
    if (accelData[1]<0){
      textTop = int(6*float(height)/10);
      verticalDirection = " up";
    }

    // Draw arrows
    float angle;  // angle of the arrow to be drawn (in radians counterclockwise from directly right)
    
    // draw horizontal arrow
    angle = 0;
    if (horizontalDirection==" left") angle=PI;
    //    horizontalComponent.display(width/2, height/2, horizontalValue*width, angle);
        horizontalComponent.display(width/2, height/2, horizontalValue*scale, angle);
    
    //draw vertical arrow starting from end of horizontal arrow
    angle = PI/2;
    if (verticalDirection==" up") angle=1.5*PI;
    verticalComponent.display(int(width/2-accelData[0]*scale), height/2, verticalValue*scale, angle);

    // draw total vector arrow (last, to ensure on top)
    angle = atan(accelData[1]/-accelData[0]);
    if (horizontalDirection==" left") angle=angle+PI;
    totalVector.display(width/2, height/2, totalValue*scale, angle); // draw this last to display on top
    
    // display vector values (colour coded to match vector arrows)
    textSize(int(float(height/20)));
    textAlign(LEFT, TOP);
    fill(totalVector.colour[0],totalVector.colour[1],totalVector.colour[2]);
    text(String.format("%.2f",totalValue)+units, width/6, textTop);
    fill(verticalComponent.colour[0],verticalComponent.colour[1],verticalComponent.colour[2]);
    text(String.format("%.2f",verticalValue)+units+verticalDirection, width/6, textTop+(height/12));
    fill(horizontalComponent.colour[0],horizontalComponent.colour[1],horizontalComponent.colour[2]);
    text(String.format("%.2f",horizontalValue)+units+horizontalDirection, width/6, textTop+(height/6));
//    text(str(lineWeight), width/6, textTop+(height/6));
    
    //reset average values
    accelData = new float[3];
    counter=0;
  }
}

void onResume()
{
  super.onResume();
  sensorManager = (SensorManager)getSystemService(Context.SENSOR_SERVICE);
  sensorListener = new SensorListener();
  accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
  sensorManager.registerListener(sensorListener, accelerometer, SensorManager.SENSOR_DELAY_FASTEST); 
};
 
void onPause()
{
  sensorManager.unregisterListener(sensorListener);
  super.onPause();
};
 
 
class SensorListener implements SensorEventListener
{
  void onSensorChanged(SensorEvent event)
  {
    if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER)
    {
      accelData[0] = accelData[0]+event.values[0];
      accelData[1] = accelData[1]+event.values[1];
      accelData[2] = accelData[2]+event.values[2];
      counter=counter+1;
    }
  }
  void onAccuracyChanged(Sensor sensor, int accuracy)
  {
       //not required for this app (but required by Android)
  }
}
