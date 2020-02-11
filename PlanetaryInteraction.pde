float fx, fy;
float rotation;

boolean Dkey = false;
boolean Akey = false;

void setup() {
  size(1024, 1024);
  fill(255);
  rectMode(CENTER);
}

void draw() {
  background(0);
  if(Dkey == true)
  {
	  rotation += 0.1;
  }
  if(Akey == true)
  {
	  rotation -= 0.1;
  }

  pushMatrix();
  translate(512, 512);
  rotate(rotation); 
  rect(0, 0, 50, 50);
  popMatrix();
}
void rectDraw(int r, int s, float c, float d)
{
  for (float i=0; i<2*PI; i=i+c)
  {
    fx = r*cos(i);
    fy = r*sin(i);
    rect(fx, fy, s, s);
  }
}

void keyPressed() {
	switch (key) {
		case 'd':
		case 'D':
			Dkey = true;
		break;
		case 'a':
		case 'A':
			Akey = true;
		break;
	}
}
void keyReleased() {
	switch (key) {
		case 'd':
		case 'D':
			Dkey = false;
		break;
		case 'a':
		case 'A':
			Akey = false;
		break;
	}
}


