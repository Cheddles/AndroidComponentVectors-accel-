class Arrow{
  
  int[] colour = new int[3];  // RBG values for the arrow
  int lineThickness;  // line weight for the arrow
  
  Arrow(int red, int green, int blue, int weight){
    colour[0]=red;
    colour[1]=green;
    colour[2]=blue;
    lineThickness=weight;
  }
  
  void display(int x, int y, float len, float angle){
    strokeWeight(lineThickness);
//    strokeWeight(5);
    stroke(colour[0], colour[1], colour[2]);
    pushMatrix();
      translate(x, y);
      rotate(angle);
      line(0, 0, len, 0);
      line(len, 0, len - min(height/50, len/3), -min(height/50,len/3));
      line(len, 0, len - min(height/50, len/3), min(height/50,len/3));
    popMatrix();
    // display the value

  }
  
}
