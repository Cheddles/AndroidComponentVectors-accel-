class SensorListener implements SensorEventListener{
  void onSensorChanged(SensorEvent event) {
    if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER) {
      // replace the oldest data samples with new data
      accelData[0][counter] = event.values[0];
      accelData[1][counter] = event.values[1];
      accelData[2][counter] = event.values[2];
      
      counter=counter+1;  // increment counter
      if (counter==smoothFactor) counter=0;  //reset the counter if it has reached the maximum number of samples
    }
  }
  
  void onAccuracyChanged(Sensor sensor, int accuracy) {
       //not required for this app (but required by Android)
  }
}
