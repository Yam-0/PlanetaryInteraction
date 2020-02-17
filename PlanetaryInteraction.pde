import processing.sound.*;
Sound s;

PImage rocketImage;
PImage asteroid1;
PImage parallax1;
PImage parallax2;
PImage parallax3;
PImage parallax4;

PVector offset;
PVector speed;
PVector position;
PVector rocketCenterOfMass;
PVector addSpeed;
PVector speedToStar;
PVector rocketScale;
PVector tipPosition;

ArrayList <Asteroid> asteroids = new ArrayList <Asteroid>();
ArrayList <ExhaustParticle> exhaustParticles = new ArrayList <ExhaustParticle>();

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

float middle;

int ammo;
int startAmmo;
int sceneIndex;
int asteroidspawnFrames;
int score;
int lives;
int highscore;
int framesPlayingCrystalSong;
int loadingScreenIterator;

String[] highscores;

float addspeedX;
float addspeedY;
float speedToStarX;
float speedToStarY;

boolean up, down, left, right;
boolean spawnasteroids;
boolean fired;
boolean debugView;
boolean infiniteAmmo = false;
boolean enteredAmmoZone;
boolean fetched;
boolean frameSwitch;

SoundFile hitSound;
SoundFile laserSound;
SoundFile pickupSound;
SoundFile menuMusic;
SoundFile main;
SoundFile crystal;
SoundFile asteroidHitSound;
SoundFile rocketThrustSound;

void setup() 
{
	//window size
	size(1024, 1024);
	middle = 1024/2;

	thread("loading");

	//import sound effects from data folder
	hitSound = new SoundFile(this, "Hit.wav");
  	laserSound = new SoundFile(this, "Laser.wav");
	pickupSound = new SoundFile(this, "Pickup.wav");
	asteroidHitSound = new SoundFile(this, "AsteroidDestroy.wav");
	rocketThrustSound = new SoundFile(this, "Rocket.wav");

	//load music files
	menuMusic = new SoundFile(this, "Menu.wav");
	main = new SoundFile(this, "Main.wav");
	crystal = new SoundFile(this, "crystal.mp3");

	//load images
	rocketImage = loadImage("Rocket.png");

	parallax1 = loadImage("Parallax1.png");
	parallax2 = loadImage("Parallax2.png");
	parallax3 = loadImage("Parallax3.png");
	parallax4 = loadImage("Parallax4.png");

	asteroid1 = loadImage("Asteroid1.png");

	//defines start scene
	sceneIndex = 0;

	//ignore this
	frameSwitch = true;

	//set start amount of ammo
	startAmmo = 3;

	//set variables
	reset();

	//don't start in debug mode
	debugView = false;
}
void loading()
{
	background(0);
	textAlign(CENTER);
	textSize(44);
	text("Loading", middle, middle);
}
void reset()
{
	//reset every variable except debug
	
	//vector2 variables
	speed = new PVector(0, 4);
	position = new PVector(middle, 700);
	addSpeed = new PVector(0, 0);
	rocketScale = new PVector(25, 50);
	speedToStar = new PVector(0, 0);
	offset = new PVector(0, 0);
	tipPosition = new PVector(0, 0);

	//positional variables and other floats
	distanceToStar = 0;
	thrusterStrength = 0.016;
	gravityStrength = 0.05;
	rotationSpeed = 3;
	heading = 0;
	angle = 0;
	maxSpeed = 5.5;
	centerOffset = 15;
	angleToStar = 0;
	playfield = 800;
	distanceToTip = 45;

	//integers
	score = 0;
	lives = 3;
	asteroidspawnFrames = 0;
	framesPlayingCrystalSong = 0;

	//reset to start amount
	ammo = startAmmo;

	//input booleans
	spawnasteroids = true;
	up = down = left = right = false;
	enteredAmmoZone = false;
	fetched = false;
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
	float distance = (float)(Math.sqrt(Math.pow((x - middle), 2) + Math.pow((y - middle), 2)));
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

void StartScreen()
{
	//loop music
	if(menuMusic.isPlaying() != true)
	{
		menuMusic.play();
	}


	//draws background
	background(0);

	imageMode(CORNER);
	image(parallax4, 0 + (mouseX/24 - middle), 0 + (mouseY/24 - middle));
	image(parallax3, 0 + (mouseX/12 - middle), 0 + (mouseY/12 - middle));
	image(parallax2, 0 + (mouseX/8 - middle), 0 + (mouseY/8 - middle));
	image(parallax1, 0 + (mouseX/4 - middle), 0 + (mouseY/4 - middle));

	//header backdrop
	fill(0);
	rectMode(CENTER);
	rect(middle, 500, 600, 100);

	//header
	fill(255, 255, 255);
	textAlign(CENTER);
	textSize(44);
	text("PLANETARY INTERACTION", middle, middle);
	
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
	text("Click to continue", middle, 800);

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
void InstructionsForSinglePlayer()
{
	//loop music
	if(menuMusic.isPlaying() != true)
	{
		menuMusic.play();
	}

	//background black
	background(0);

	textAlign(LEFT);
	textSize(24);
	text("These are some basic instructions for my game", 10, 40);


	if(keyPressed){
		sceneIndex = 2;
	}
}
void SinglePlayer()
{
	//change and loop other music file
	if(menuMusic.isPlaying() == false && main.isPlaying() == false && crystal.isPlaying() == false)
	{
		main.play();
	}
	if(crystal.isPlaying() == true)
	{
		maxSpeed = 10;
		thrusterStrength = 10;
	}

	//rocket thrust sound effect
	if(rocketThrustSound.isPlaying() != true && up == true)
	{
		rocketThrustSound.play();
	}
	if(rocketThrustSound.isPlaying() == true && up == false)
	{
		rocketThrustSound.stop();
	}

	if(lives <= 0 && debugView == false)
	{
		main.stop();
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
			pickupSound.play();
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
	if(distanceToStar <= 25)
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
	angleToStar = getAngle(rocketCenterOfMass, new PVector(middle, middle));
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

	//star reload area, and play area
	fill(15, 15, 15);
	ellipse(middle, middle, playfield, playfield);
	fill(25, 25, 25);
	ellipse(middle, middle, playfield/3, playfield/3);
	fill(255, 255, 0);
	ellipse(middle, middle, 25, 25);

	if(up == true)
	{
		exhaustParticles.add(new ExhaustParticle());
	}

	//draw asteroid
	for (Asteroid a1 : asteroids) 
	{
		a1.displayAstroid();
	}

	//draw exhaust
	for (ExhaustParticle a2 : exhaustParticles) 
	{
		a2.displayParticle();
	}

	//update position and rotation
	pushMatrix();
	translate(position.x, position.y);
	rotate(radians(angle));
	image(rocketImage, (-rocketScale.x)/2, (-rocketScale.y)/2 - centerOffset, rocketScale.x, rocketScale.y);
	popMatrix();

	heading = getAngleXY(speed.x, speed.y);

	if(asteroidspawnFrames >= 300)
	{
		if(spawnasteroids == true)
		{
			asteroids.add(new Asteroid());
			asteroidspawnFrames = 0;
		}
	}
	else
	{
		if(sceneIndex == 2)
		{
			asteroidspawnFrames++;
		}
	}

	//Laser sight
	pushMatrix();
	translate(tipPosition.x, tipPosition.y);
	rotate(radians(angle - 90));
	fill(255, 255, 255);
	rectMode(LEFT);
	rect(0, -0.05/2, 2048, 0.05);
	popMatrix();

	//fire event
	if(fired == true)
	{
		if(ammo != 0 || infiniteAmmo == true)
		{
			laserSound.play();
			pushMatrix();
			translate(tipPosition.x, tipPosition.y);
			rotate(radians(angle - 90));
			fill(255, 0, 0);
			rect(0, -2, 2048, 4);
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
		ellipse(middle, middle, distanceToStar*2, distanceToStar*2);
		noStroke();

		//show center off mass
		fill(255, 0, 0);
		ellipse(rocketCenterOfMass.x, rocketCenterOfMass.y, 10, 10);
		//print for debugging
		//println(rocketCenterOfMass);
		
		//draw line to star
		pushMatrix();
		translate(middle, middle);
		rotate(radians(angleToStar));
		fill(255, 0, 0);
		rect(0, -1, (playfield/2), 2);
		popMatrix();

		//ammo region line
		pushMatrix();
		translate(middle, middle);
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
void SinglePlayerLostScreen()
{
	background(255, 0, 0);

	//loop music
	if(debugView == true)
	{
		main.stop();
	}
	if(crystal.isPlaying() == true)
	{
		framesPlayingCrystalSong++;
	}
	if(crystal.isPlaying() == false && debugView == true)
	{
		crystal.play();
	}
	if(debugView == true && framesPlayingCrystalSong >= 900)
	{
		if(frameSwitch)
		{
			background(0);
			fill(255, 255, 255);
			frameSwitch = false;
		}
		else
		{
			background(255, 255, 255);
			fill(0);
			frameSwitch = true;
		}
		textSize(200);
		textAlign(CENTER);
		text("DU SUGER!", middle, middle);
	}
	if(debugView == false)
	{
		framesPlayingCrystalSong = 0;
		crystal.stop();
	}

	textSize(50);
	fill(255, 255, 255);
	textAlign(CENTER);
	text("Game Over!", middle, middle);
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
	text("Click to retry", middle, 800);

	fill(255, 255, 255);
	textSize(36);
	text("Score : " + score, middle, 600);

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


	text("Highscore : " + highscore, middle, 650);

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
	float spawnDist = 800;
	float asteroidRotationInit;
	float asteroidRotation = 0;
	float asteroidGravity = 1;
	float fallSpeed = 5;
	float asteroidSize;
	float asteroidDistToStar;
	float rocketToAsteroidDistance;
	float hitboxEdgeDist;
	float deltaAngle;
	float rocketToAsteroidAngle;
	float asteroidRotationSpeed;

	boolean rotationDir;
	boolean init = false; //boolean to check if class object spawned this frame
	boolean alive = true;

	void displayAstroid()
	{
		if(init)
		{	
			asteroidOffset.x = (asteroidGravity * sin(asteroidRotationInit));
			asteroidOffset.y = (asteroidGravity * cos(asteroidRotationInit));

			asteroidPos.x = asteroidSpawnPos.x + middle;
			asteroidPos.y = asteroidSpawnPos.y + middle;

			asteroidPos.x += asteroidOffset.x;
			asteroidPos.y += asteroidOffset.y;

			asteroidDistToStar = getDistance(asteroidPos.x, asteroidPos.y);
			if(asteroidDistToStar <= 5 && alive == true)
			{
				alive = false;
				if(!debugView)
				{
					hitSound.play();
					lives--;
				}
			}

			asteroidRotation += asteroidRotationSpeed;

			
			pushMatrix();
			imageMode(CENTER);
			translate(asteroidPos.x, asteroidPos.y);
			fill(255, 255, 255);
			if(alive)
			{
				rotate(radians(asteroidRotation));
				image(asteroid1, 0, 0, asteroidSize, asteroidSize);
			}
			popMatrix();
				

			rectMode(LEFT);//reset rectMode
			asteroidGravity -= asteroidSize/5 - asteroidSize/6;

			//trigonemetry math to calculate distance to astroid from rocket
			float deltaX = asteroidPos.x - position.x;
			float deltaY = asteroidPos.y - position.y;

			deltaX = (float)Math.pow(deltaX, 2);
			deltaY = (float)Math.pow(deltaY, 2);
			float diagonalSquared = deltaX + deltaY;

			rocketToAsteroidDistance = (float)Math.sqrt(diagonalSquared);

			//collision with astroid
			if(rocketToAsteroidDistance <= asteroidSize/2 && alive == true)
			{
				hitSound.play();
				alive = false; //disable astroid
				if(!debugView)
				{
					lives--; 
				}
			}


			//hit reg - check if player hit astroid with laser
			if(fired && alive == true)
			{
				//only do hit detection if you have ammo to shoot
				if(infiniteAmmo || ammo != 0)
				{
					float angleToRocket = (getAngle(asteroidPos, position));			
					
					deltaAngle = (float)Math.atan((asteroidSize/2)/(rocketToAsteroidDistance));
					deltaAngle = (degrees(deltaAngle)); //convert to degrees

					deltaX = position.x - asteroidPos.x;
					deltaY = position.y - asteroidPos.y;
					rocketToAsteroidAngle = getAngleXY(deltaX, deltaY);

					//set max angles to be able check if hit astroid
					float maxAngle = rocketToAsteroidAngle + deltaAngle;
					float minAngle = rocketToAsteroidAngle - deltaAngle;

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
						println(minAngle + ", " + rocketToAsteroidAngle + ", " + maxAngle + " | " + angle);
					}

					//kill astroid if hit
					if(angle > minAngle && angle < maxAngle)
					{
						if(!debugView)
						{
							asteroidHitSound.play();
							score++;
						}
						
						alive = false;
					}
				}
			}			
		}
		else
		{	//only do this once when the astroid spawns
			asteroidSize = random(30, 60);
			if((-1 + (int)random(2) * 2) == 1) //creates a 50/50 chance of inverting astroid rotation direction
			{
				rotationDir = true;
			}
			else
			{
				rotationDir = false;
			}
			asteroidRotationSpeed = ((random(10, 60) / 30));
			if(rotationDir == true)
			{
				asteroidRotationSpeed = -asteroidRotationSpeed;
				println(asteroidRotationSpeed);
			}
			startRotPos = random(0, 360);
			asteroidRotationInit = startRotPos;

			asteroidOffset = new PVector(middle, middle);
			asteroidSpawnPos = new PVector(spawnDist * sin(startRotPos), spawnDist * cos(startRotPos));
			asteroidPos = new PVector((asteroidSpawnPos.x + asteroidOffset.x), (asteroidSpawnPos.y + asteroidOffset.y));

			//makes sure this only happens once
			init = true;
		}
	}
}

class ExhaustParticle {
	PVector particlePos;
	PVector particleSpawnPos;
	PVector particleOffset;
	PVector particleSize;
	PVector delta;
	PVector exhaustPos;

	float particleSpeed;
	float killSpeed;
	
	int aliveTime;

	boolean initParticle = false; //boolean to check if class object spawned this frame
	boolean aliveParticle = false;

	void displayParticle()
	{
		if(initParticle)
		{
			if(aliveTime >= 50)
			{
				aliveParticle = false;
			}

			if(aliveParticle)
			{
				particleSize.x -= 0.05;
				particleSize.y -= 0.05;

				if(particleSize.x <= 0 || particleSize.y <= 0)
				{
					aliveParticle = false;
				}

				rectMode(CENTER);
				if(aliveTime <= 20)
				{
					fill(lerpColor((#ff5900), (#ffff00), (float)(aliveTime)/20));
				}
				else if(aliveTime <= 40)
				{
					fill(lerpColor((#ffff00), (#c9c9c9), (float)(aliveTime - 20)/20));
				}
				else
				{
					fill(lerpColor((#c9c9c9), (color(201, 201, 201, 0)), (float)(aliveTime - 40)/10));
				}
				rect(particlePos.x, particlePos.y, particleSize.x, particleSize.y);
				aliveTime++;
				rectMode(LEFT);
			}
		}
		else
		{
			//only do this once when the exhaust particle spawns
			exhaustPos = (offsetWithAngle((rocketCenterOfMass), angle, -5));

			PVector spawnOffset = new PVector(random(0, 10) + exhaustPos.x, random(0, 10) + exhaustPos.y);
			particlePos = new PVector(rocketCenterOfMass.x + spawnOffset.x, rocketCenterOfMass.y + spawnOffset.y);
			float particleSizeRandom = random(5, 10);
			particleSize = new PVector(particleSizeRandom, particleSizeRandom);
			aliveTime = 0;
			aliveParticle = true;

			//makes sure this only happens once
			initParticle = true;
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
			infiniteAmmo = false;
			spawnasteroids = true;
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
	if(key == 'z' && debugView == true)
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
		if(key == 'x' && debugView == true)
	{
		if(spawnasteroids == false)
		{
			println("Astroid spawning turned on!");
			spawnasteroids = true;
		}
		else 
		{
			println("Astroid spawning turned off!");
			spawnasteroids = false;
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