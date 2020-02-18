//Tage Åkerström - TE19A | 2020
import processing.sound.*; //library for sound handling
Sound s; //defined sound derivative

//variables representing images - get loaded in setup
PImage rocketImage; //Rocket shape
PImage asteroid1; //Asteroid image

//images for "parallax effect" used in start screen - get loaded in setup
PImage parallax1;
PImage parallax2;
PImage parallax3;
PImage parallax4;

//vector2 variables 
PVector offset;//temporary vector2 used for offsetting in vector based math
PVector speed;//current speed of rocket
PVector position;//current position of rocket
PVector rocketCenterOfMass;//center of mass position
PVector addSpeed;//speed to add each frame
PVector speedToStar;//gravity adds speed towards star each frame
PVector rocketScale;//scale of rocket
PVector tipPosition;//position of rocket tip

//arrays for spawning objects from class
ArrayList <Asteroid> asteroids = new ArrayList <Asteroid>();
ArrayList <ExhaustParticle> exhaustParticles = new ArrayList <ExhaustParticle>();

//floats
float thrusterStrength;//strength of rocket thrusters
float gravityStrength;//strength of gravity
float rotationSpeed;//speed of rotation 
float heading;//rocket direction of momentum
float angle;//rocket angle
float angleToStar;//anglr from rocket to star
float distanceToStar;//distance from rocket to star
float maxSpeed;//limit speed
float centerOffset;//offset from center
float playfield;//scale of playinh field
float distanceToTip;//distance to tip of rocket
float middle;//center of screen

//integers
int ammo;//current ammo value
int startAmmo;//start ammo value
int sceneIndex;//current scene index
int asteroidspawnFrames;//spawn asteroid cooldown iteratable variable
int spawnVal;//frames until spawn asteroid trigger
int score;//current score
int lives;//current health
int highscore;//highscore read from txt
int framesPlayingCrystalSong;//ignore
int loadingScreenIterator;//iteratable variable used during startup
int i; //temp variable for debugging purposes

//string array for writing/reading - highscores.txt
String[] highscores;

//vector2 temporary float variables
float addspeedX;
float addspeedY;
float speedToStarX;
float speedToStarY;

//booleans
boolean up, down, left, right;
boolean spawnasteroids;//to be able to disable asteroid spawning
boolean fired;//if fired this frame
boolean debugView;//debug mode
boolean infiniteAmmo = false;//infinite ammo mode
boolean enteredAmmoZone;//if entered ammo zone this frame
boolean enteredBoosterZone;//if inside booster zone
boolean fetched;//if highscored got loaded
boolean frameSwitch;//for doing this every other frame

//sound files - get loaded in setup
SoundFile hitSound;
SoundFile laserSound;
SoundFile pickupSound;
SoundFile menuMusic;
SoundFile main;
SoundFile crystal;
SoundFile asteroidHitSound;
SoundFile rocketThrustSound;

//setup function used for loading assets
void setup() 
{
	//window size
	size(1024, 1024);
	middle = 1024/2;

	//"loading" text function
	loading0();

	//load sound effect files
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
	parallax1 = loadImage("Parallax1.png");
	parallax2 = loadImage("Parallax2.png");
	parallax3 = loadImage("Parallax3.png");
	parallax4 = loadImage("Parallax4.png");

	rocketImage = loadImage("Rocket.png");
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
void loading0()
{
	//loading text shown during startup
	background(0);
	textAlign(CENTER);
	textSize(44);
	text("Loading", middle, middle);
}
void reset()
{
	//reset gameplay variables
	
	//vector2 variables, set to standard values
	speed = new PVector(0, 4);
	position = new PVector(middle, 700);
	addSpeed = new PVector(0, 0);
	rocketScale = new PVector(25, 50);
	speedToStar = new PVector(0, 0);
	offset = new PVector(0, 0);
	tipPosition = new PVector(0, 0);

	//positional variables
	distanceToStar = 0; //distance to star from rocket
	heading = 0; //direction of momentum 0-360
	angle = 0; //angle of rocket 0-360
	centerOffset = 15; //offset from center off mass
	angleToStar = 0; //rocket to star angle 0-360
	playfield = 800; //size of outer circle
	distanceToTip = 45; //offset distance from center off mass to tip off rocket

	//other floats
	rotationSpeed = 3; //amount to rotate rocket by
	gravityStrength = 0.05; //default strength - never used
	maxSpeed = 5.5; //limits speed
	thrusterStrength = 0.016; //strength of rocket

	//integers
	score = 0; //start score 0
	lives = 3; //start health 0
	asteroidspawnFrames = 0; //iteratable variable
	framesPlayingCrystalSong = 0; //ignore this
	spawnVal = 300; //spawn asteroid every five secounds in the beginning

	//reset to start amount
	ammo = startAmmo;

	//input booleans
	up = down = left = right = false;
	
	//other booleans
	enteredAmmoZone = false; //update boolean to reload
	fetched = false; //switch boolean to make sure highscore is only loaded once
	spawnasteroids = true; //makes it possible to disable asteroid spawning
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

	//images used for parallax effect
	imageMode(CORNER); //center images
	image(parallax4, 0 + (mouseX/24 - middle), 0 + (mouseY/24 - middle)); //offset from center 1/24 of mouse pos
	image(parallax3, 0 + (mouseX/12 - middle), 0 + (mouseY/12 - middle)); //offset from center 1/12 of mouse pos
	image(parallax2, 0 + (mouseX/8 - middle), 0 + (mouseY/8 - middle)); //offset from center 1/8 of mouse pos
	image(parallax1, 0 + (mouseX/4 - middle), 0 + (mouseY/4 - middle)); //offset from center 1/4 of mouse pos

	//header backdrop
	fill(0); //black
	rectMode(CENTER);
	rect(middle, 500, 600, 100);//makes sure stars never show upp behind title

	//header
	fill(255, 255, 255);//white
	textAlign(CENTER);
	textSize(44);
	text("PLANETARY INTERACTION", middle, middle); //main header text
	
	//"click to continue" text
	//mouse hover effect
	if(mouseY > 770 && mouseY < 800 && mouseX < 612 && mouseX > 412)//tests if mouse pos is over button pos
	{
		fill(250, 250, 250); //hover effect
		if(mousePressed){
			sceneIndex++; //go to next scene if button clicked
		}
	}
	else 
	{
		fill(150, 150, 150);// standard color
	}

	textAlign(CENTER);
	textSize(22);
	text("Click to continue", middle, 800); //startscreen button

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

	textAlign(CENTER);
	textSize(24);
	text("Press any button to start", 512, 512);//instructions header

	//goto next scene if any button pressed
	if(keyPressed){
		sceneIndex = 2;
	}
}
//main gameplay loop
void SinglePlayer()
{
	//change and loop other music file
	if(menuMusic.isPlaying() == false && main.isPlaying() == false && crystal.isPlaying() == false)
	{
		main.play();//play main music file
	}
	if(crystal.isPlaying() == true) //easter egg song
	{
		//easter egg gameplay settings
		maxSpeed = 10;
		thrusterStrength = 10;
	}

	//rocket thrust sound effect
	if(rocketThrustSound.isPlaying() != true && up == true)
	{
		//play sound effect if up is true
		rocketThrustSound.play();
	}
	if(rocketThrustSound.isPlaying() == true && up == false)
	{
		//stop sound effect if up is false
		rocketThrustSound.stop();
	}

	if(lives <= 0 && debugView == false)
	{
		//kill player if lives is less or equal to zero
		main.stop(); //stop playing music
		sceneIndex = 3; //change to game over scene
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
	if(distanceToStar <= (playfield/3)/4 && enteredBoosterZone != true)
	{
		enteredBoosterZone = true;
		thrusterStrength *= 2; //double thruster strength if really close to star
	}
	if(distanceToStar >= (playfield/3)/4 && enteredBoosterZone == true)
	{
		enteredBoosterZone = false;
		thrusterStrength /= 2; //half thruster strength if player exit "close to star" zone
	}

	//apply speed to position
	position.x += speed.y;
	position.y -= speed.x;

	//get distance to star
	distanceToStar = getDistance(position.x, position.y);
	if(distanceToStar <= 25) //kill player if too close to star
	{
		sceneIndex = 3;
		return;
	}

	//update angle on input
	if(right == true) angle += rotationSpeed;
	if(left == true) angle -= rotationSpeed;

	//Make sure angle is within grad range 0-360
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
	imageMode(CENTER);
	image(parallax4, 512, 512); //background image
	imageMode(CORNER);

	//star reload area, and play area
	fill(15, 15, 15, 150);
	ellipse(middle, middle, playfield, playfield);
	fill(25, 25, 25, 150);
	ellipse(middle, middle, playfield/3, playfield/3);
	fill(255, 255, 0);
	ellipse(middle, middle, 25, 25);

	if(up == true)
	{
		exhaustParticles.add(new ExhaustParticle());//instantiate exhaust particles
	}

	//draw asteroid
	for (Asteroid a1 : asteroids) 
	{
		a1.displayAsteroid();
	}

	//draw exhaust particles
	for (ExhaustParticle a2 : exhaustParticles) 
	{
		a2.displayParticle();
	}

	//update position and rotation
	pushMatrix(); //create matrix
	translate(position.x, position.y); //translate matrix origin
	rotate(radians(angle)); //rotate around new matrix origin
	imageMode(CORNER); //center image
	image(rocketImage, (-rocketScale.x)/2, (-rocketScale.y)/2 - centerOffset, rocketScale.x, rocketScale.y); //rocket image
	popMatrix(); //restore original matrix

	heading = getAngleXY(speed.x, speed.y); //calculate momentum direction

	if(asteroidspawnFrames >= spawnVal) //instantiate asteroid if iteratable variable is over 300 frames
	{
		if(spawnasteroids == true) //only spawn if spawn asteroids is allowed 
		{
			asteroids.add(new Asteroid()); //spawn asteroid
			asteroidspawnFrames = 0; //reset spawn iteration
			if(spawnVal > 90)
			{
				spawnVal -= 5;//instantiate asteroid five frames earlier for every asteroid spawned until asteroids spawn every 1.5 secounds
			}
		}
	}
	else
	{
		if(sceneIndex == 2)//make sure asteroids only spawn in singleplayer scene
		{
			asteroidspawnFrames++; //decrease time until next asteroid spawn
		}
	}

	//Laser sight
	pushMatrix();
	translate(tipPosition.x, tipPosition.y);
	rotate(radians(angle - 90));
	fill(255, 255, 255);
	rectMode(RIGHT);
	rect(0, 0/2, 2048, 0.05);
	popMatrix();

	//fire event
	if(fired == true) //checks if player hit space this frame
	{
		if(ammo != 0 || infiniteAmmo == true) //only fire if player has ammo or if player is in infinite ammo mode
		{
			laserSound.play(); //play laser sound
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
					println("Fired! : " + ammo + " shots left"); //show fire ammo data if in debug mode
				}
			}
		}
		else
		if(debugView == true)
		{
			println("Out of ammo : " + ammo); //print to console if in debug mode
		}
		fired = false; //player has fired
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
//game over screen
void SinglePlayerLostScreen()
{
	rocketThrustSound.stop(); //stop rocket sound when game over
	background(255, 0, 0); //red background

	//loop music
	if(debugView == true)
	{
		main.stop();
	}
	if(crystal.isPlaying() == true)//easter egg
	{
		framesPlayingCrystalSong++;//easter egg timer
	}
	if(crystal.isPlaying() == false && debugView == true)
	{
		crystal.play();//easter egg start
	}
	if(debugView == true && framesPlayingCrystalSong >= 900)
	{
		//epilepsi säger jag
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
		text("DU SUGER!", middle, middle); //ignore please
	}
	if(debugView == false)
	{
		framesPlayingCrystalSong = 0;
		crystal.stop(); //stop easter egg song
	}

	textSize(50);
	fill(255, 255, 255);
	textAlign(CENTER);
	text("Game Over!", middle, middle); //game over text
	//mouse hover effect
	if(mouseY > 770 && mouseY < 800 && mouseX < 612 && mouseX > 412)//check if mouse pos within button pos
	{
		fill(255, 255, 0);//fill yellow
		if(mousePressed){
			reset();//reset if button hit
			sceneIndex = 2; //reset to main gamemode
		}
	}
	else 
	{
		fill(255, 255, 255);//standard button color
	}

	textAlign(CENTER);//center button
	textSize(22);
	text("Click to retry", middle, 800);//button text

	fill(255, 255, 255);
	textSize(36);
	text("Score : " + score, middle, 600);//displays current score

	//Highscore
	//only fetch highscore once
	if(fetched != true)
	{
		highscores = loadStrings("highscore.txt");//load highscore string array from txt file
		highscore = Integer.parseInt(highscores[0]);//get one string from "list"
		println(highscore);//print highscore for debugging purposes

		fetched = true;//boolean to see if highscored got loaded this frame
	}
	if(score > highscore)//checks if score is better than highscore
	{
		highscore = score;//display score as highscore if better
		highscores[0] = str(highscore);//set string array highscore list to new highscore value
		saveStrings("highscore.txt", highscores);//save new highscore value to txt file
	}


	text("Highscore : " + highscore, middle, 650);//display highscore text

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
	//vector2 variables
	PVector asteroidPos; //current asteroid position
	PVector asteroidSpawnPos; //spawn position of asteroid
	PVector asteroidOffset; //offset amount per frame
	PVector delta; //delta value container for math reasons
	
	//floats
	float startRotPos;//rotation around star to spawn at
	float spawnDist = 800; //distance from star to spawn asteroid at - outside screen
	float asteroidRotationInit; //initial asteroid rotation
	float asteroidRotation = 0; //current asteroid rotation
	float asteroidGravity = 1;//standard gravity scale
	float fallSpeed = 5; //speed off asteroid
	float asteroidSize; //size off asteroid
	float asteroidDistToStar; //distance to star
	float rocketToAsteroidDistance; //distance to rocket
	float hitboxEdgeDist;//radius of asteroid
	float deltaAngle;//delta angle for hit registration
	float rocketToAsteroidAngle;//angle to rocket
	float asteroidRotationSpeed; //speed of rotation

	//booleans
	boolean rotationDir; //direction of asteroid rotation
	boolean init = false; //boolean to check if class object spawned this frame
	boolean alive = true; //is asteroid "alive"

	//display asteroid this frame
	void displayAsteroid()
	{
		if(init)
		{	
			//calculate asteroid offset to add this frame
			asteroidOffset.x = (asteroidGravity * sin(asteroidRotationInit)); //trigonometry baby
			asteroidOffset.y = (asteroidGravity * cos(asteroidRotationInit));

			//apply asteroid offset from center
			asteroidPos.x = asteroidSpawnPos.x + middle;
			asteroidPos.y = asteroidSpawnPos.y + middle;

			//apply offset vector2
			asteroidPos.x += asteroidOffset.x;
			asteroidPos.y += asteroidOffset.y;

			//distance to star calculation
			asteroidDistToStar = getDistance(asteroidPos.x, asteroidPos.y);
			if(asteroidDistToStar <= 5 && alive == true)//remove asteroid if too close to star
			{
				alive = false;//disables asteroid
				if(!debugView)//don't lose lives in debug mode
				{
					hitSound.play();//play asteroid hit sound
					lives--;//decrease lives if hit star
				}
			}

			asteroidRotation += asteroidRotationSpeed; //rotate asteroid
			
			pushMatrix();
			imageMode(CENTER);
			translate(asteroidPos.x, asteroidPos.y);
			fill(255, 255, 255);
			if(alive)
			{
				rotate(radians(asteroidRotation)); //apply asteroid rotation
				image(asteroid1, 0, 0, asteroidSize, asteroidSize);
			}
			popMatrix();
				

			rectMode(LEFT);//reset rectMode
			asteroidGravity -= asteroidSize/5 - asteroidSize/6; //increase asteroid gravity if big

			//trigonemetry math to calculate distance to asteroid from rocket
			float deltaX = asteroidPos.x - position.x;
			float deltaY = asteroidPos.y - position.y;

			deltaX = (float)Math.pow(deltaX, 2);
			deltaY = (float)Math.pow(deltaY, 2);
			float diagonalSquared = deltaX + deltaY;

			rocketToAsteroidDistance = (float)Math.sqrt(diagonalSquared); //pytgagorean theorem

			//collision with asteroid
			if(rocketToAsteroidDistance <= asteroidSize/2 && alive == true)//collide with asteroid if close enough and asteroid is active
			{
				hitSound.play(); //play hit sound on collision
				alive = false; //disable asteroid
				if(!debugView)
				{
					//only decrease lives if not in debugview
					lives--; 
				}
			}


			//hit reg - check if player hit asteroid with laser
			if(fired && alive == true)
			{
				//only do hit detection if you have ammo to shoot
				if(infiniteAmmo || ammo != 0)
				{
					float angleToRocket = (getAngle(asteroidPos, position)); //calculate angle to rocket		
					
					deltaAngle = (float)Math.atan((asteroidSize/2)/(rocketToAsteroidDistance));
					deltaAngle = (degrees(deltaAngle)); //convert to degrees

					deltaX = position.x - asteroidPos.x;
					deltaY = position.y - asteroidPos.y;
					rocketToAsteroidAngle = getAngleXY(deltaX, deltaY); //get angle from rocket to asteroid

					//keep rocket to asteroid angle within grad range
					while(rocketToAsteroidAngle < 0) 
					{
						rocketToAsteroidAngle += 360;
					}
					while(rocketToAsteroidAngle > 360)
					{
						rocketToAsteroidAngle -= 360;
					}

					//set max angles to be able check if hit asteroid
					float maxAngle = rocketToAsteroidAngle + deltaAngle;
					float minAngle = rocketToAsteroidAngle - deltaAngle;

					//print hitreg data if in debugview
					if(debugView)
					{
						println(minAngle + ", " + rocketToAsteroidAngle + ", " + maxAngle + " | " + angle);
					}

					//kill asteroid if hit
					if(angle > minAngle && angle < maxAngle)
					{
						if(!debugView)//only do this if not in debug mode
						{
							asteroidHitSound.play(); //play asteroid hit sound if asteroid hit
							score++; //increase score on asteroid hit
						}
						
						alive = false; //disable asteroid
					}
				}
			}			
		}
		else
		{	//only do this once when the asteroid spawns
			asteroidSize = random(30, 60);
			if((-1 + (int)random(2) * 2) == 1) //creates a 50/50 chance of inverting asteroid rotation direction
			{
				rotationDir = true;//normal rotation direction
			}
			else
			{
				rotationDir = false;//inverted rotation direction
			}
			asteroidRotationSpeed = ((random(10, 60) / 30));//random rotation speed
			if(rotationDir == true)//invert rotation speed
			{
				asteroidRotationSpeed = -asteroidRotationSpeed;
			}
			startRotPos = random(0, 360);//random spawn rotation relative to star
			asteroidRotationInit = startRotPos;//apply spawn rotation

			asteroidOffset = new PVector(middle, middle);//instantiate asteroid offset vector2
			asteroidSpawnPos = new PVector(spawnDist * sin(startRotPos), spawnDist * cos(startRotPos));//instantiate asteroid initial position vector2
			asteroidPos = new PVector((asteroidSpawnPos.x + asteroidOffset.x), (asteroidSpawnPos.y + asteroidOffset.y));//instantiate asteroid position vector2

			//makes sure this only happens once
			init = true;
		}
	}
}

//rocket exhaust particle class
class ExhaustParticle {
	//vectpr2 variables
	PVector particlePos;//position of particle
	PVector particleSpawnPos;//spawn position of particle
	PVector particleOffset;//offset position of particle
	PVector particleSize;//size
	PVector delta;//delta xy for math purposes
	PVector exhaustPos;//position to instantiate particle at

	float particleSpeed;//speed of particle
	
	int aliveTime;//iteratable variable for time alive

	boolean initParticle = false;//boolean to check if class object spawned this frame
	boolean aliveParticle = false;//is particle active?

	//Draw particle
	void displayParticle()
	{
		if(initParticle)//did particle spawn this frame?
		{
			if(aliveTime >= 50) //kill particle if it has existed for 50 frames - 5/6 0f a secound
			{
				aliveParticle = false;
			}

			if(aliveParticle)//if particle is alive
			{
				//decrease particle size over time
				particleSize.x -= 0.05;
				particleSize.y -= 0.05;

				//disable particle if it's smaller than 0 pixels
				if(particleSize.x <= 0 || particleSize.y <= 0)
				{
					aliveParticle = false;
				}

				rectMode(CENTER);//center particle rectangle

				//lerp between 4 colors
				if(aliveTime <= 20)
				{
					fill(lerpColor((#ff5900), (#ffff00), (float)(aliveTime)/20));//color 1-2
				}
				else if(aliveTime <= 40)
				{
					fill(lerpColor((#ffff00), (#c9c9c9), (float)(aliveTime - 20)/20));//color 2-3
				}
				else
				{
					fill(lerpColor((#c9c9c9), (color(201, 201, 201, 0)), (float)(aliveTime - 40)/10));//color 3-4
				}
				rect(particlePos.x, particlePos.y, particleSize.x, particleSize.y);//draw particle
				aliveTime++;//iterate alive time
				rectMode(LEFT);//reset rectmode
			}
		}
		else
		{
			//only do this once when the exhaust particle spawns
			exhaustPos = (offsetWithAngle((rocketCenterOfMass), angle, -5));//defines spawn pos for particles

			PVector spawnOffset = new PVector(random(0, 10) + exhaustPos.x, random(0, 10) + exhaustPos.y);//offset particle 
			particlePos = new PVector(rocketCenterOfMass.x + spawnOffset.x, rocketCenterOfMass.y + spawnOffset.y);//instantiate particle position vector2
			float particleSizeRandom = random(5, 10);//random start size of particle
			particleSize = new PVector(particleSizeRandom, particleSizeRandom);//apply particle size
			aliveTime = 0;//start alive time frames at 0
			aliveParticle = true;//particle is active on spawn

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
			reset();//reset scene
		}
	}
	if(key == ' ')
	{
		fired = true;//activate fire event on "space" button pressed
	}
	if(key == '<'){
		if(debugView == true)
		{
			//manually spawn asteroid
			asteroids.add(new Asteroid());
			println("Spawned asteroid!");
		}
	}
	if(key == 'z' && debugView == true)
	{
		//turn on/off infinite ammo
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
			//turn on/off asteroid spawning
			if(spawnasteroids == false)
			{
				println("Asteroid spawning turned on!");
				spawnasteroids = true;
			}
			else 
			{
				println("Asteroid spawning turned off!");
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