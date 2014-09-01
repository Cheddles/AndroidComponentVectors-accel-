// This application written by Chris Heddles
// Copyright 2014 South Australian Department of Education and Child Development (DECD)
// Released under GPL v3 (https://www.gnu.org/licenses/gpl.html)

// import the Android libraries required to access the accelerometer
import android.content.Context;
import android.os.Bundle;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.view.WindowManager;
import android.view.View;

//declare objects required to access accelerometer data
SensorManager sensorManager;      
SensorListener sensorListener;
Sensor accelerometer;             

final String units=" m/s/s"; // units for the vector (with a leading space)
final int smoothFactor = 20;  // the number of acceleration samples to be used to calculate a rolling average
float[][] accelData = new float[3][smoothFactor];       // 3-value array to store X, Y and Z acceleration value sums
                                                      // with enough rows to store the smoothing data
int counter=0;  // keeps track of the data line to be overwritten in accelData (cycled to replace oldest)

int lineWeight;  // set line weight for all arrows
float scale;  // pixels of vector per m/s/s vector value

// size of each vector (+/- for component vectors to indicate up/down or left/right)
float magnitudeVertical;
float magnitudeHorizontal;
float magnitudeTotal;

// set up arrows for each vector (red, green, blue, line weight)
Arrow totalVector;
Arrow verticalComponent;
Arrow horizontalComponent;

void setup(){
 orientation(PORTRAIT);
// getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
// frameRate(10);  // to keep the acceleration values from getting too jumpy
 scale=width/8.0;
 lineWeight = int(float(width)/80.0);
 totalVector = new Arrow (0, 0, 0, lineWeight);
 verticalComponent = new Arrow (255, 0, 0, lineWeight);
 horizontalComponent = new Arrow (0, 0, 255, lineWeight);
}

void draw(){

  background(255);
  
  //reset average values
  magnitudeHorizontal=0;
  magnitudeVertical=0;
  magnitudeTotal=0;

  // calculate average component values from array of <smoothFactor> samples
  for (int i=0; i<smoothFactor; i++){
    magnitudeHorizontal=magnitudeHorizontal+accelData[0][i];
    magnitudeVertical=magnitudeVertical+accelData[1][i];
  }
  
  magnitudeHorizontal = magnitudeHorizontal/float(smoothFactor);
  magnitudeVertical = magnitudeVertical/float(smoothFactor);
  magnitudeTotal = pow(pow(magnitudeHorizontal,2)+pow(magnitudeVertical,2),0.5);  // using Pythagorus' theorum
  
  // calculate vector values
//  float totalValue = pow(pow(accelData[0],2)+pow(accelData[1],2),0.5);
//  float verticalValue = abs(accelData[1]);
//  float horizontalValue = abs(accelData[0]);

  // determine horizontal component directions
  String horizontalDirection=" right";
  if (magnitudeHorizontal<0) horizontalDirection=" left";

  // set display height to empty half of the screen and determine vertical component direction
  int textTop = int(float(height)/10);
  String verticalDirection = " down";
  if (magnitudeVertical>0){
    textTop = int(6*float(height)/10);
    verticalDirection = " up";
  }
  
  // draw horizontal arrow
  float angle = 0;
  if (horizontalDirection==" left") angle=PI;
     horizontalComponent.display(width/2, height/2, abs(magnitudeHorizontal)*scale, angle);
  
  //draw vertical arrow starting from end of horizontal arrow
  angle = 1.5*PI;
  if (verticalDirection==" down") angle=PI/2;
  verticalComponent.display(int(width/2+(magnitudeHorizontal*scale)), height/2, abs(magnitudeVertical)*scale, angle);

  // draw total vector arrow (last, to ensure on top)
  angle = atan(magnitudeVertical/-magnitudeHorizontal);
  if (horizontalDirection==" left") angle=angle+PI;
  totalVector.display(width/2, height/2, magnitudeTotal*scale, angle); // draw this last to display on top
  
  // display vector values (colour coded to match vector arrows)
  textSize(int(float(height/20)));
  textAlign(LEFT, TOP);
  fill(totalVector.colour[0],totalVector.colour[1],totalVector.colour[2]);
  text(String.format("%.1f",magnitudeTotal)+units, width/6, textTop);
  fill(verticalComponent.colour[0],verticalComponent.colour[1],verticalComponent.colour[2]);
  text(String.format("%.1f",abs(magnitudeVertical))+units+verticalDirection, width/6, textTop+(height/12));
  fill(horizontalComponent.colour[0],horizontalComponent.colour[1],horizontalComponent.colour[2]);
  text(String.format("%.1f",abs(magnitudeHorizontal))+units+horizontalDirection, width/6, textTop+(height/6));

}

void onCreate(Bundle bundle) {
  super.onCreate(bundle);
  // stop screen turning off automatically
  getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
}

void onResume() {
  // restart sensors when app is resumed in foreground
  super.onResume();
  sensorManager = (SensorManager)getSystemService(Context.SENSOR_SERVICE);
  sensorListener = new SensorListener();
  accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
  sensorManager.registerListener(sensorListener, accelerometer, SensorManager.SENSOR_DELAY_FASTEST); 
}
 
void onPause(){
  // shut down sensors to save battery power when app is in background
  sensorManager.unregisterListener(sensorListener);
  super.onPause();
}
 
 
class SensorListener implements SensorEventListener{
  void onSensorChanged(SensorEvent event)
  {
    if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER)
    {
      // replace the oldest data samples with new data
      accelData[0][counter] = event.values[0];
      accelData[1][counter] = event.values[1];
      accelData[2][counter] = event.values[2];
      counter=counter+1;
      if (counter==smoothFactor) counter=0;  //reset the counter if it has reached the maximum number of samples
    }
  }
  
  void onAccuracyChanged(Sensor sensor, int accuracy) {
       //not required for this app (but required by Android)
  }
}
