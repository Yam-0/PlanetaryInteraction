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

float fx, fy;
float rotation;

float boxPosX = 0;
float boxPosY = 0;

boolean Dkey = false;
boolean Akey = false;
boolean Wkey = false;

public void setup() {
  
  fill(255);
  rectMode(CENTER);
}

public void draw() {
  background(0);
  if(Dkey == true)
  {
	  rotation += 0.1f;
  }
  if(Akey == true)
  {
	  rotation -= 0.1f;
  }
  if(Wkey == true)
  {
	  boxPosY += 5;
  }

  pushMatrix();
  translate(512, 512);
  rotate(rotation); 
  rect(boxPosX, boxPosY, 50, 50);
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

public void keyPressed() {
	switch (key) {
		case 'd':
		case 'D':
			Dkey = true;
		break;
		case 'a':
		case 'A':
			Akey = true;
		break;
		case 'w':
		case 'W':
			Wkey = true;
		break;
	}
}
public void keyReleased() {
	switch (key) {
		case 'd':
		case 'D':
			Dkey = false;
		break;
		case 'a':
		case 'A':
			Akey = false;
		break;
		case 'w':
		case 'W':
			Wkey = false;
		break;
	}
}


  public void settings() {  size(1024, 1024); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "PlanetaryInteraction" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
