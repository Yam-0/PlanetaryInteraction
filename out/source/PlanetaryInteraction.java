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

int Gray = color(123, 123, 123);
int White = color(255, 255, 255);

public void setup() {
	
}

public void draw() {
	background(0);
	fill(Gray);
	ellipse(512, 512, 800, 800);
	fill(White);
	ellipse(512, 512, 50, 50);
}
  public void settings() { 	size(1024, 1024); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "PlanetaryInteraction" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
