PImage rocketImage;

PVector speed;
PVector position;
PVector rocketCenterOfMass;
PVector addSpeed;
PVector speedToStar;
PVector rocketScale;

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

float addspeedX;
float addspeedY;
float speedToStarX;
float speedToStarY;

boolean up, down, left, right;
boolean debugView;

void setup() {
	//load rocket.png image 
	rocketImage = loadImage("Rocket.png");

	//window size
	size(1024, 1024);
	
	//vector2 variables
	speed = new PVector(0, 4);
	position = new PVector(512, 700);
	addSpeed = new PVector(0, 0);
	rocketScale = new PVector(25, 50);
	speedToStar = new PVector(0, 0);
	
	//positional variables
	distanceToStar = 0;
	thrusterStrength = 0.01;
	gravityStrength = 0.05;
	rotationSpeed = 2.5;
	heading = 0;
	angle = 0;
	maxSpeed = 5;
	centerOffset = 15;
	angleToStar = 0;
	playfield = 800;

	//input booleans
	up = down = left = right = false;
	debugView = false;
}

void draw() {

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
	gravityStrength = (float)(2 * (100)/(Math.pow(distanceToStar, 1.5))); //realistic gravity formula
	//exponentially increases gravity if outside playing field
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

	//apply speed
	position.x += speed.y;
	position.y -= speed.x;

	//set background color
	background(0);

	//star and play area
	fill(5, 5, 5);
	ellipse(512, 512, playfield, playfield);
	fill(255, 255, 0);
	ellipse(512, 512, 25, 25);

	//update position and rotation
	pushMatrix();
	translate(position.x, position.y);
	rotate(radians(angle));
	image(rocketImage, (-rocketScale.x)/2, (-rocketScale.y)/2 - centerOffset, rocketScale.x, rocketScale.y);
	popMatrix();

	heading = getAngleXY(speed.x, speed.y);

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
		rect(0, -1, 1000, 2);
		popMatrix();

		//draw movement direction
		pushMatrix();
		translate(rocketCenterOfMass.x, rocketCenterOfMass.y);
		rotate(radians(heading));
		fill(0, 0, 255);
		rect(0, -1, 100, 2);
		popMatrix();

		println("gravityStrength: "+ gravityStrength + " | distanceToStar: "+ distanceToStar + " | " + position);
	}
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
//key held down variable updates
void keyPressed()
{
	//turn on/off debug mode
	if(key == '§')
	{
		if(debugView == false)
		{
			debugView = true;
		}
		else 
		{
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
void reset(){
	//reset every variable except debug
	//load rocket.png image 
	rocketImage = loadImage("Rocket.png");

	//window size
	size(1024, 1024);
	
	//vector2 variables
	speed = new PVector(0, 4);
	position = new PVector(512, 700);
	addSpeed = new PVector(0, 0);
	rocketScale = new PVector(25, 50);
	speedToStar = new PVector(0, 0);
	
	//positional variables
	distanceToStar = 0;
	thrusterStrength = 0.01;
	gravityStrength = 0.05;
	rotationSpeed = 2.5;
	heading = 0;
	angle = 0;
	maxSpeed = 5;
	centerOffset = 15;
	angleToStar = 0;
	playfield = 800;

	//input booleans
	up = down = left = right = false;
	debugView = false;
}