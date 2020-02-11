import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class PlanetaryInteraction extends PApplet {


float a;
float fx, fy;
float b;

public void setup() {
  
  
  fill(255);
  rectMode(CENTER);
}

public void draw() {
  background(0);

  pushMatrix();
  translate(512, 512);
  rotate(b); 
  rect(0, 0, 50, 50);
  b += 0.1f;
  popMatrix();
}
public void rectDraw(int r, int s, float c, float d)
{
  for (float i=0; i<2*PI; i=i+c)
  {
    fx = r*cos(i);
    fy = r*sin(i);
    rect(fx, fy, s, s);
  }
}

  public void settings() {  size(1024, 1024);  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "PlanetaryInteraction" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
