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

PVector rocketLocation;
float rocketAngle;
float rocketHeading;
float rocketSpeed, maxSpeed;
float angle;
float maxangle = PI/4;
float offsetBase, minWB, maxWB;
float turnStrength;

boolean plus, minus, up, down, left, right, steerLock;


PVector back;
PVector dirSpeed;


public void setup()
{
	
	

	up = down = left = right = steerLock = false;

	rocketLocation = new PVector(width/2, height/2);
	rocketAngle = PI;
	rocketSpeed = 0;
	maxSpeed = 5;
	angle = 0;
	
	minWB = 30;
	maxWB = 150;
	turnStrength = 0.1f;
}


public void draw()
{
	//sets background color
	background(100, 100, 100);

	
	
	back =  new PVector(rocketLocation.x-(offsetBase/2)*sin(rocketAngle), rocketLocation.y-(offsetBase/2)*cos(rocketAngle));

	//set rocket pos start
	pushMatrix();
	translate(rocketLocation.x, rocketLocation.y);
	rotate(-rocketAngle);
	rectMode(CENTER);
	fill(255);
	rect(0, 0, 50, 100);
	popMatrix();
	//set rocket pos end

	
	back.add(rocketSpeed*sin(rocketAngle), rocketSpeed*cos(rocketAngle), 0);

	
	
	rocketLocation.div(2);

	//loop pos at top and bottom of screen
	if (rocketLocation.x<0) rocketLocation.x=width;  
	if (rocketLocation.x>width) rocketLocation.x=0;  
	if (rocketLocation.y<0) rocketLocation.y=height;  
	if (rocketLocation.y>height) rocketLocation.y=0;  

	//Don't touch this please - it does things maf related
	

	//fill lmao
	fill(255);

	//left
	if (left) 
	{
		if (angle < maxangle) angle += turnStrength;
		if (angle>maxangle) angle = maxangle;
	}
	else
	{
		if (!steerLock) if (angle > 0) angle -= turnStrength;
	}

	//right
	if (right)
	{
		if (angle >  -maxangle)  angle -= turnStrength;
		if (angle<-maxangle) angle = -maxangle;
	}
	else
	{
		if (!steerLock) if (angle < 0) angle += turnStrength;
	}

	//up
	if (up)
	{ 
		if (rocketSpeed<maxSpeed) rocketSpeed += 0.05f;
	}

	//down
	if (down)
	{
		if (rocketSpeed>0) rocketSpeed -= 0.15f; //brake
		else 
			if (abs(rocketSpeed)<maxSpeed) rocketSpeed -= 0.05f; // reverse
	}

	//rounds angle
	if (abs(angle)<turnStrength) angle = 0;

	if (rocketSpeed>0) rocketSpeed -= 0.01f; //friction for forward
	if (rocketSpeed<0) rocketSpeed += 0.01f; //friction for backward

	//slow down if neither up or down is pressed
	if ((!up && !down) && (abs(rocketSpeed)<0.01f))  rocketSpeed=0; 
}

public void keyPressed()
{
	if (key == CODED) 
	{
		switch(keyCode) {
			case LEFT: 
				left=true;
				break;
			case RIGHT:
				right=true;
				break;
			case UP:
				up=true;
				break;
			case DOWN:
				down=true;
				break;
		}
	}
}

public void keyReleased()
{
	if (key == CODED) 
	{
		switch(keyCode) {
			case LEFT: 
				left=false;
				break;
			case RIGHT:
				right=false;
				break;
			case UP:
				up=false;
				break;
			case DOWN:
				down=false;
				break;
		}
	}
}
  public void settings() { 	size(1024, 1024); 	smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "PlanetaryInteraction" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
