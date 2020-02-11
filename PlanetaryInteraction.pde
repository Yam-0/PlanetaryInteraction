PVector speed;
PVector position;
PVector addSpeed;

float thrusterStrength;
float rotationSpeed;
float heading;
float angle;
float maxSpeed;

float addspeedX;
float addspeedY;

boolean up, down, left, right;

void setup() {
	//window size
	size(1024, 1024);
	
	//vector2 variables
	speed = new PVector(0, 0);
	position = new PVector(512, 512);
	addSpeed = new PVector(0, 0);

	//positional variables
	thrusterStrength = 0.05;
	rotationSpeed = 2;
	heading = 0;
	angle = 0;
	maxSpeed = 5;

	//input booleans
	up = down = left = right = false;
}

void draw() {

	//update angle on input
	if(right == true) angle += rotationSpeed;
	if(left == true) angle -= rotationSpeed;

	if(up == true)
	{
		//angle to vector2
		addspeedX = (float)Math.cos(radians(angle));
		addspeedY = (float)Math.sin(radians(angle));

		//round addSpeed to two decimal places
		addSpeed.x = (float)Math.round(addspeedX * 100) / 100;
		addSpeed.y = (float)Math.round(addspeedY * 100) / 100;

		//print for debugging
		//println(addSpeed);

		//apply to speed
		speed.x += addSpeed.x * thrusterStrength;
		speed.y += addSpeed.y * thrusterStrength;
	}
	
	//limit speed
	if(speed.x > maxSpeed)
	{
		speed.x = maxSpeed;
	}
	if(speed.y > maxSpeed)
	{
		speed.y = maxSpeed;
	}
	
	//round speed
	speed.x = (float)Math.round(speed.x * 100) / 100;
	speed.y = (float)Math.round(speed.y * 100) / 100;
	
	//print for debugging
	println(speed);

	//apply speed
	position.x += speed.y;
	position.y -= speed.x;

	//set background color
	background(0);

	//update position and rotation
	pushMatrix();
	translate(position.x, position.y);
	rotate(radians(angle));
	rectMode(CENTER);
	fill(255);
	rect(0, 0, 50, 100);
	popMatrix();
}

//key held down variable updates
void keyPressed()
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
