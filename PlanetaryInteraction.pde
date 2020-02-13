PImage rocketImage;

PVector offset;
PVector speed;
PVector position;
PVector rocketCenterOfMass;
PVector addSpeed;
PVector speedToStar;
PVector rocketScale;
PVector tipPosition;

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

float addspeedX;
float addspeedY;
float speedToStarX;
float speedToStarY;

boolean up, down, left, right;
boolean fired;
boolean debugView;

void setup() {
	sceneIndex = 0;

	//set start amount of ammo
	startAmmo = 3;

	//window size
	size(1024, 1024);

	//set variables
	reset();

	//don't start in debug mode
	debugView = false;
}
void reset(){
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
	
	//positional variables and other floats
	distanceToStar = 0;
	thrusterStrength = 0.02;
	gravityStrength = 0.05;
	rotationSpeed = 3;
	heading = 0;
	angle = 0;
	maxSpeed = 6;
	centerOffset = 15;
	angleToStar = 0;
	playfield = 800;
	distanceToTip = 45;

	//reset to start amount
	ammo = startAmmo;

	//input booleans
	up = down = left = right = false;
}

void draw() {

	//makes sure to never stroke
	noStroke();

	//decides which scene to draw based on the current scene index
	switch(sceneIndex)
	{
	case 0:
		StartScreen();
		break;

	case 1:	
		Menu();
		break;

	case 2:
		SinglePlayer();
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
    float deg = (float)(Math.atan2(y, x)*180.0/Math.PI);
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

//checks to see if laser hit
public boolean hitReg(PVector target)
{
	return(false);
}

void StartScreen()
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
void Menu()
{
	background(0);
	if(keyPressed){
		sceneIndex = 2;
	}
}
void SinglePlayer()
{
	//set tip position vector 2
	offset = (offsetWithAngle((rocketCenterOfMass), angle, distanceToTip));
	tipPosition.x = (offset.x + position.x);
	tipPosition.y = (offset.y + position.y);

	//reload if close to star
	if(distanceToStar <= (playfield/3)/2)
	{
		if(ammo != startAmmo)
		{
			ammo = startAmmo;
			if(debugView == true)
			{
				println("Reloaded! : " + ammo + " shots left");
			}
		}
	}

	//apply speed
	position.x += speed.y;
	position.y -= speed.x;

	//get distance to star
	distanceToStar = getDistance(position.x, position.y);
	if(distanceToStar <= 5)
	{
		reset();
		return;
	}

	//update angle on input
	if(right == true) angle += rotationSpeed;
	if(left == true) angle -= rotationSpeed;

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
	gravityStrength = (float)(2 * (50)/(Math.pow(distanceToStar, 1.4))); //realistic gravity formula
	//exponentially increases gravity if outside playing fiel
	if(distanceToStar > playfield/2){ 
		gravityStrength = (float)((Math.pow((distanceToStar)-(playfield/2), 1.1))/1000);
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

	//star and play area
	fill(15, 15, 15);
	ellipse(512, 512, playfield, playfield);
	fill(25, 25, 25);
	ellipse(512, 512, playfield/3, playfield/3);
	fill(255, 255, 0);
	ellipse(512, 512, 25, 25);

	//update position and rotation
	pushMatrix();
	translate(position.x, position.y);
	rotate(radians(angle));
	image(rocketImage, (-rocketScale.x)/2, (-rocketScale.y)/2 - centerOffset, rocketScale.x, rocketScale.y);
	popMatrix();

	heading = getAngleXY(speed.x, speed.y);

		//fire event
	if(fired == true)
	{
		if(ammo != 0)
		{
			pushMatrix();
			translate(tipPosition.x, tipPosition.y);
			rotate(radians(angle - 90));
			fill(255, 0, 0);
			rect(0, -2, 1000, 4);
			popMatrix();
			ammo--;

			if(debugView == true)
			{
				println("Fired! : " + ammo + " shots left");
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
}

//Toggle key held variables
void keyPressed()
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
void keyReleased()
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