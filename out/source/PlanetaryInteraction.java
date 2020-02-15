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

PImage rocketImage;

PVector offset;
PVector speed;
PVector position;
PVector rocketCenterOfMass;
PVector addSpeed;
PVector speedToStar;
PVector rocketScale;
PVector tipPosition;

ArrayList <Asteroid> asteroids = new ArrayList <Asteroid>();

float thrusterStrength;
float gravityStrength;
float rotationSpeed;
float heading;
float angle;
float angleToStar;
float distanceToStar;
float maxSpeed;
float centerOffset;
float playfield;
float distanceToTip;

int ammo;
int startAmmo;
int sceneIndex;
int astroidSpawnFrames;
int score;
int lives;
int highscore;

String[] highscores;

float addspeedX;
float addspeedY;
float speedToStarX;
float speedToStarY;

boolean up, down, left, right;
boolean fired;
boolean debugView;
boolean infiniteAmmo = false;
boolean enteredAmmoZone;
boolean fetched;

public void setup() {
	sceneIndex = 0;

	//set start amount of ammo
	startAmmo = 3;

	//window size
	

	//set variables
	reset();

	//don't start in debug mode
	debugView = false;
}
public void reset(){
	//reset every variable except debug
	//load rocket.png image 
	rocketImage = loadImage("Rocket.png");
	
	//vector2 variables
	speed = new PVector(0, 4);
	position = new PVector(512, 700);
	addSpeed = new PVector(0, 0);
	rocketScale = new PVector(25, 50);
	speedToStar = new PVector(0, 0);
	offset = new PVector(0, 0);
	tipPosition = new PVector(0, 0);
	
	ArrayList <Asteroid> asteroids = new ArrayList <Asteroid>();

	//positional variables and other floats
	distanceToStar = 0;
	thrusterStrength = 0.016f;
	gravityStrength = 0.05f;
	rotationSpeed = 3;
	heading = 0;
	angle = 0;
	maxSpeed = 5.5f;
	centerOffset = 15;
	angleToStar = 0;
	playfield = 800;
	distanceToTip = 45;

	//integers
	score = 0;
	lives = 3;

	//reset to start amount
	ammo = startAmmo;

	//input booleans
	up = down = left = right = false;
	enteredAmmoZone = false;
	fetched = false;
}

public void draw() {

	//makes sure to never stroke
	noStroke();

	//decides which scene to draw based on the current scene index
	switch(sceneIndex)
	{
	case 0:
		StartScreen();
		break;

	case 1:	
		InstructionsForSinglePlayer();
		break;

	case 2:
		SinglePlayer();
		break;

	case 3:
		SinglePlayerLostScreen();
		break;
	}
}
//-----------------------------------------------------------------------
//these are some useful math functions
public PVector offsetWithAngle(PVector source, float angle, float length)
{
	PVector lengths = getXYWithAngle(angle - 90);
	PVector lengthsMult = new PVector((lengths.x * length), (lengths.y * length));
	return lengthsMult;
}
public PVector getXYWithAngle(float angle)
{
	PVector vector2 = new PVector(0, 0);
	vector2.x= (float)Math.cos(radians(angle));
	vector2.y= (float)Math.sin(radians(angle));
	return vector2;
}
public float getDistance(float x, float y)
{
	//pythagorean theorem
	float distance = (float)(Math.sqrt(Math.pow((x - 512), 2) + Math.pow((y - 512), 2)));
	return distance;
}
public float getAngleXY(float x, float y)
{
	//arctan and rad to degrees - to get angle with x and y
    float deg = (float)(Math.atan2(y, x)*180.0f/Math.PI);
	deg -= 90;
	return deg;
}
public float getAngle(PVector target, PVector here) {

	//arctan and rad to degrees - to get angle between points
    float angle = (float) Math.toDegrees(Math.atan2(target.y - here.x, target.x - here.y));

    if(angle < 0){
        angle += 360;
    }

    return angle;
}
//-----------------------------------------------------------------------

public void StartScreen()
{
	//draws background
	background(255, 255, 255);
	fill(200, 200, 200);
	rect(212, 0, 600, 1024);

	//header
	fill(150, 150, 150);
	textAlign(CENTER);
	textSize(44);
	text("PLANETARY INTERACTION", 512, 512);
	
	//"click to continue" text
	//mouse hover effect
	if(mouseY > 770 && mouseY < 800 && mouseX < 612 && mouseX > 412)
	{
		fill(250, 250, 250);
		if(mousePressed){
			sceneIndex++;
		}
	}
	else 
	{
		fill(150, 150, 150);
	}

	textAlign(CENTER);
	textSize(22);
	text("Click to continue", 512, 800);

	//debug mode tools
	if(debugView)
	{
		//draws mousepos X
		fill(255, 0, 0);
		textAlign(LEFT);
		textSize(12);
		text("MouseX : " + mouseX, 10, 40);

		//draws mousepos Y 
		fill(255, 0, 0);
		textAlign(LEFT);
		textSize(12);
		text("MouseY : " + mouseY, 10, 20);
	}
}
public void InstructionsForSinglePlayer()
{
	background(0);
	if(keyPressed){
		sceneIndex = 2;
	}
}
public void SinglePlayer()
{
	if(lives <= 0)
	{
		sceneIndex = 3;
	}

	//set tip position vector 2
	offset = (offsetWithAngle((rocketCenterOfMass), angle, distanceToTip));
	tipPosition.x = (offset.x + position.x);
	tipPosition.y = (offset.y + position.y);

	//reload if close to star
	if(distanceToStar <= (playfield/3)/2 && enteredAmmoZone == false)
	{
		enteredAmmoZone = true;
		if(ammo != startAmmo)
		{
			ammo = startAmmo;
			if(debugView == true)
			{
				println("Reloaded! : " + ammo + " shots left");
			}
		}
	}
	if(distanceToStar >= (playfield/3)/2 && enteredAmmoZone == true)
	{
		enteredAmmoZone = false;
	}

	//apply speed
	position.x += speed.y;
	position.y -= speed.x;

	//get distance to star
	distanceToStar = getDistance(position.x, position.y);
	if(distanceToStar <= 5)
	{
		sceneIndex = 3;
		return;
	}

	//update angle on input
	if(right == true) angle += rotationSpeed;
	if(left == true) angle -= rotationSpeed;

	//Make sure angle is within grad range;
	while(angle < 0)
	{
		angle += 360;
	}
	while(angle > 360)
	{
		angle -= 360;
	}

	//get "forward" speed vector2
	if(up == true)
	{
		//get vector2 from angle
		addspeedX = (float)Math.cos(radians(angle));
		addspeedY = (float)Math.sin(radians(angle));

		//round addSpeed to two decimal places
		addSpeed.x = (float)Math.round(addspeedX * 100) / 100;
		addSpeed.y = (float)Math.round(addspeedY * 100) / 100;

		//apply to speed
		speed.x += addSpeed.x * thrusterStrength;
		speed.y += addSpeed.y * thrusterStrength;
	}

	//get vector2 speeds towards star
	//get angle to star
	rocketCenterOfMass = new PVector(position.x, position.y);
	angleToStar = getAngle(rocketCenterOfMass, new PVector(512, 512));
	float angleToStarOffset = angleToStar - 90;
	//println("angleToStar: "+ angleToStar);

	//angle to vector2
	speedToStarX = (float)Math.cos(radians(angleToStarOffset));
	speedToStarY = (float)Math.sin(radians(angleToStarOffset));

	//round addSpeed to two decimal places
	speedToStar.x = (float)Math.round(speedToStarX * 100) / 100;
	speedToStar.y = (float)Math.round(speedToStarY * 100) / 100;

	//calculate gravity scale
	gravityStrength = (float)(2 * (50)/(Math.pow(distanceToStar, 1.4f))); //realistic gravity formula
	//exponentially increases gravity if outside playing fiel
	if(distanceToStar > playfield/2){ 
		gravityStrength = (float)((Math.pow((distanceToStar)-(playfield/2), 1.1f))/1000);
	}

	//apply to speed
	speed.x += (speedToStar.x * gravityStrength);
	speed.y += (speedToStar.y * gravityStrength);

	//round speed
	speed.x = (float)Math.round(speed.x * 100) / 100;
	speed.y = (float)Math.round(speed.y * 100) / 100;
	
	//limit speed
	if(speed.x > maxSpeed)
	{
		speed.x = maxSpeed;
	}
	if(speed.y > maxSpeed)
	{
		speed.y = maxSpeed;
	}
	if(speed.x < -maxSpeed)
	{
		speed.x = -maxSpeed;
	}
	if(speed.y < -maxSpeed)
	{
		speed.y = -maxSpeed;
	}

	//set background color
	background(0);

	//star reload area, and play area
	fill(15, 15, 15);
	ellipse(512, 512, playfield, playfield);
	fill(25, 25, 25);
	ellipse(512, 512, playfield/3, playfield/3);
	fill(255, 255, 0);
	ellipse(512, 512, 25, 25);

	//draw asteroid
	for (Asteroid s : asteroids) 
	{
		s.display();
	}

	//update position and rotation
	pushMatrix();
	translate(position.x, position.y);
	rotate(radians(angle));
	image(rocketImage, (-rocketScale.x)/2, (-rocketScale.y)/2 - centerOffset, rocketScale.x, rocketScale.y);
	popMatrix();

	heading = getAngleXY(speed.x, speed.y);

	if(astroidSpawnFrames >= 300)
	{
		asteroids.add(new Asteroid());
		astroidSpawnFrames = 0;
	}
	else
	{
		if(sceneIndex == 2)
		{
			astroidSpawnFrames++;
		}
	}


	//fire event
	if(fired == true)
	{
		if(ammo != 0 || infiniteAmmo == true)
		{
			pushMatrix();
			translate(tipPosition.x, tipPosition.y);
			rotate(radians(angle - 90));
			fill(255, 0, 0);
			rect(0, -2, 1000, 4);
			popMatrix();

			//don't decrease ammo if in infinite ammo mode
			if(!infiniteAmmo)
			{
				ammo--;
			}

			if(debugView == true)
			{
				if(!infiniteAmmo)
				{	
					//no need to print this is in infinite ammo mode
					println("Fired! : " + ammo + " shots left");
				}
			}
		}
		else
		if(debugView == true)
		{
			println("Out of ammo : " + ammo);
		}
		fired = false;
	}

	//only show this if in debug view
	if(debugView)
	{
		//draw trejectory
		noFill();
		stroke(255, 255, 255);
		strokeWeight(2);
		ellipse(512, 512, distanceToStar*2, distanceToStar*2);
		noStroke();

		//show center off mass
		fill(255, 0, 0);
		ellipse(rocketCenterOfMass.x, rocketCenterOfMass.y, 10, 10);
		//print for debugging
		//println(rocketCenterOfMass);
		
		//draw line to star
		pushMatrix();
		translate(512, 512);
		rotate(radians(angleToStar));
		fill(255, 0, 0);
		rect(0, -1, (playfield/2), 2);
		popMatrix();

		//ammo region line
		pushMatrix();
		translate(512, 512);
		rotate(radians(angleToStar));
		if(distanceToStar < ((playfield/3)/2))
		{
			fill(0, 255, 0);
		}
		else
		{
			fill(255, 0, 0);
		}
		rect(0, -2, (playfield/6), 4);
		popMatrix();

		//draw movement direction
		pushMatrix();
		translate(rocketCenterOfMass.x, rocketCenterOfMass.y);
		rotate(radians(heading));
		fill(0, 0, 255);
		rect(0, -1, 100, 2);
		popMatrix();

		//draw angle direction
		pushMatrix();
		translate(rocketCenterOfMass.x, rocketCenterOfMass.y);
		rotate(radians(angle - 90));
		fill(0, 255, 0);
		rect(0, -1, 100, 2);
		popMatrix();

		//print some variables for debugging purposes
		if(keyPressed)
		{
			if(key == '\'')
			{
				String gravityStrengthRounded = String.format("%.7f", gravityStrength);
				float distanceToStarRounded = (round(distanceToStar * 100)/100);
				float positionXRounded = (round(position.x * 100)/100);
				float positionYRounded = (round(position.y * 100)/100);
				println(
					millis() 
					+ " | Gravity Strength: "
					+ gravityStrengthRounded
					+ " | Distance to star: "
					+ distanceToStarRounded
					+ " | Current Position: " 
					+ positionXRounded 
					+ ", " 
					+ positionYRounded
					+ " | Current Speed "
					+ String.format("%.2f", speed.x)
					+ ", "
					+ String.format("%.2f", speed.y)
				);
			}
		}
	}


// Heads Up Display:
	//Score text
	textAlign(LEFT);
	textSize(44);
	fill(255, 255, 255);
	text("Score : " + score, 20, 60);

	//lives text
	text("Lives : " + lives, 20, 100);

	//ammo text
	text("Ammo : " + ammo, 20, 1000);
}
public void SinglePlayerLostScreen()
{
	background(255, 0, 0);
	textSize(50);
	fill(255, 255, 255);
	textAlign(CENTER);
	text("Game Over!", 512, 512);
	//mouse hover effect
	if(mouseY > 770 && mouseY < 800 && mouseX < 612 && mouseX > 412)
	{
		fill(255, 255, 0);
		if(mousePressed){
			reset();
			sceneIndex = 2;
		}
	}
	else 
	{
		fill(255, 255, 255);
	}

	textAlign(CENTER);
	textSize(22);
	text("Click to retry", 512, 800);

	fill(255, 255, 255);
	textSize(36);
	text("Score : " + score, 512, 600);

	//Highscore
	//only fetch highscore once
	if(fetched != true)
	{
		highscores = loadStrings("highscore.txt");
		highscore = Integer.parseInt(highscores[0]);
		println(highscore);

		fetched = true;
	}
	if(score > highscore)
	{
		highscore = score;
		highscores[0] = str(highscore);
		saveStrings("highscore.txt", highscores);
	}


	text("Highscore : " + highscore, 512, 650);

	//debug mode tools
	if(debugView)
	{
		//draws mousepos X
		fill(255, 255, 255);
		textAlign(LEFT);
		textSize(12);
		text("MouseX : " + mouseX, 10, 40);

		//draws mousepos Y 
		fill(255, 255, 255);
		textAlign(LEFT);
		textSize(12);
		text("MouseY : " + mouseY, 10, 20);
	}
}

//Asteroid class
class Asteroid {
	PVector asteroidPos;
	PVector asteroidSpawnPos;
	PVector asteroidOffset;
	PVector delta;
	
	float startRotPos;//rotation around star to spawn at
	float spawnDist = 400;
	float asteroidRotation;
	float astroidGravity = 1;
	float fallSpeed = 5;
	float asteroidSize;
	float asteroidDistToStar;
	float rocketToAsteroidDistance;
	float hitboxEdgeDist;
	float deltaAngle;
	float rocketToAstroidAngle;

	boolean init = false; //boolean to check if class object spawned this frame
	boolean alive = true;

	public void display()
	{
		if(init)
		{	
			asteroidOffset.x = (astroidGravity * sin(asteroidRotation));
			asteroidOffset.y = (astroidGravity * cos(asteroidRotation));

			asteroidPos.x = asteroidSpawnPos.x + asteroidOffset.x + 512;
			asteroidPos.y = asteroidSpawnPos.y + asteroidOffset.y + 512;

			asteroidDistToStar = getDistance(asteroidPos.x, asteroidPos.y);
			if(asteroidDistToStar <= 5 && alive == true)
			{
				alive = false;
				lives--;
			}

			pushMatrix();
			rectMode(CENTER);
			translate(asteroidPos.x, asteroidPos.y);
			rotate(radians(asteroidRotation));
			fill(255, 255, 255);
			if(alive)
			{
				ellipse(0, 0, asteroidSize, asteroidSize);
			}

			popMatrix();

			rectMode(LEFT);//reset rectMode
			astroidGravity -= asteroidSize/5 - asteroidSize/6;

			//hit reg - check if player hit astroid with laser
			if(fired && alive == true)
			{
				//only do hit detection if you have ammo to shoot
				if(infiniteAmmo || ammo != 0)
				{
					float angleToRocket = (getAngle(asteroidPos, position));

					float deltaX = asteroidPos.x - position.x;
					float deltaY = asteroidPos.y - position.y;

					deltaX = (float)Math.pow(deltaX, 2);
					deltaY = (float)Math.pow(deltaY, 2);
					float diagonalSquared = deltaX + deltaY;

					rocketToAsteroidDistance = (float)Math.sqrt(diagonalSquared);				
					
					deltaAngle = (float)Math.atan((asteroidSize/2)/(rocketToAsteroidDistance));
					deltaAngle = (degrees(deltaAngle)); //convert to degrees

					deltaX = position.x - asteroidPos.x;
					deltaY = position.y - asteroidPos.y;
					rocketToAstroidAngle = getAngleXY(deltaX, deltaY);

					//set max angles to be able check if hit astroid
					float maxAngle = rocketToAstroidAngle + deltaAngle;
					float minAngle = rocketToAstroidAngle - deltaAngle;

					//make sure max and min angle are within degree range
					while(maxAngle < 0) 
					{
						maxAngle += 360;
					}
					while(maxAngle > 360)
					{
						maxAngle -= 360;
					}

					while(minAngle < 0)
					{
						minAngle += 360;
					}
					while(minAngle > 360)
					{
						minAngle -= 360;
					}

					//print hitreg data if in debugview
					if(debugView)
					{
						println(minAngle + ", " + rocketToAstroidAngle + ", " + maxAngle + " | " + angle);
					}

					//kill astroid if hit
					if(angle > minAngle && angle < maxAngle)
					{
						score++;
						alive = false;
					}
				}
			}			
		}
		else
		{
			asteroidSize = random(30, 60);
			startRotPos = random(0, 360);
			asteroidRotation = startRotPos;

			asteroidOffset = new PVector(512, 512);
			asteroidSpawnPos = new PVector(spawnDist * sin(startRotPos), spawnDist * cos(startRotPos));
			asteroidPos = new PVector((asteroidSpawnPos.x + asteroidOffset.x), (asteroidSpawnPos.y + asteroidOffset.y));

			init = true;
		}
	}
}

//Toggle key held variables
public void keyPressed()
{
	//turn on/off debug mode
	if(key == '§')
	{
		if(debugView == false)
		{
			println("Debug mode turned on!");
			debugView = true;
		}
		else 
		{
			println("Debug mode turned off!");
			debugView = false;
		}
	}
	//reset button for debug mode
	if(key == '+')
	{
		if(debugView == true)
		{
			reset();
		}
	}
	if(key == ' ')
	{
		fired = true;
	}
	if(key == '<'){
		if(debugView == true)
		{
			asteroids.add(new Asteroid());
			println("Spawned asteroid!");
		}
	}
	if(key == 'z')
	{
		if(infiniteAmmo == false)
		{
			println("Infinite ammo turned on!");
			infiniteAmmo = true;
		}
		else 
		{
			println("Infinite ammo turned off!");
			infiniteAmmo = false;
		}
	}
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
	if (key != CODED)
	{
		switch(key)
		{
			case 'd':
			case 'D':
				right=true;
				break;
			case 'a':
			case 'A':
				left=true;
				break;
			case 'w':
			case 'W':
				up=true;
				break;
			case 's':
			case 'S':
				down=true;
				break;
		}
	}
}

//update key held variables
public void keyReleased()
{
	if (key == CODED) 
	{
		switch(keyCode) 
		{
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
	if (key != CODED)
	{
		switch(key)
		{
			case 'd':
			case 'D':
				right=false;
				break;
			case 'a':
			case 'A':
				left=false;
				break;
			case 'w':
			case 'W':
				up=false;
				break;
			case 's':
			case 'S':
				down=false;
				break;
		}
	}
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
