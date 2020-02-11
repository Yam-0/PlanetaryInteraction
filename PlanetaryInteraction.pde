PVector rocketLocation;
float rocketHeading;
float rocketSpeed, maxSpeed;
float angle;
float maxangle = PI/4;
float offsetBase, minWB, maxWB;
float turnStrength;

boolean plus, minus, up, down, left, right, steerLock;

PVector front;
PVector back;


void setup()
{
	size(1024, 1024);
	smooth();

	up = down = left = right = steerLock = false;

	rocketLocation = new PVector(width/2, height/2);
	rocketHeading = PI;
	rocketSpeed = 0;
	maxSpeed = 5;
	angle = 0;
	offsetBase = 50; //used for front and back of rocket calculations
	minWB = 30;
	maxWB = 150;
	turnStrength = 0.1;
}


void draw()
{
	//sets background color
	background(100, 100, 100);

	//updates front and back pos
	front =  new PVector(rocketLocation.x+(offsetBase/2)*sin(rocketHeading), rocketLocation.y+(offsetBase/2)*cos(rocketHeading));
	back =  new PVector(rocketLocation.x-(offsetBase/2)*sin(rocketHeading), rocketLocation.y-(offsetBase/2)*cos(rocketHeading));

	//set rocket pos start
	pushMatrix();
	translate(rocketLocation.x, rocketLocation.y);
	rotate(-rocketHeading);
	rectMode(CENTER);
	fill(255);
	rect(0, 0, 50, 100);
	popMatrix();
	//set rocket pos end

	front.add(rocketSpeed*sin(rocketHeading+angle), rocketSpeed*cos(rocketHeading+angle), 0);
	back.add(rocketSpeed*sin(rocketHeading), rocketSpeed*cos(rocketHeading), 0);

	//rounds front and back of rocket to set rocketlocation
	rocketLocation.set(front.x+back.x, front.y+back.y, 0) ;
	rocketLocation.div(2);

	//loop pos at top and bottom of screen
	if (rocketLocation.x<0) rocketLocation.x=width;  
	if (rocketLocation.x>width) rocketLocation.x=0;  
	if (rocketLocation.y<0) rocketLocation.y=height;  
	if (rocketLocation.y>height) rocketLocation.y=0;  

	//Don't touch this please - it does things maf related
	rocketHeading = atan2( front.x - back.x, front.y - back.y );

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
		if (rocketSpeed<maxSpeed) rocketSpeed += 0.05;
	}

	//down
	if (down)
	{
		if (rocketSpeed>0) rocketSpeed -= 0.15; //brake
		else 
			if (abs(rocketSpeed)<maxSpeed) rocketSpeed -= 0.05; // reverse
	}

	//rounds angle
	if (abs(angle)<turnStrength) angle = 0;

	if (rocketSpeed>0) rocketSpeed -= 0.01; //friction for forward
	if (rocketSpeed<0) rocketSpeed += 0.01; //friction for backward

	//slow down if neither up or down is pressed
	if ((!up && !down) && (abs(rocketSpeed)<0.01))  rocketSpeed=0; 
}

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
}

void keyReleased()
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