
float a;
float fx, fy;
float b;

void setup() {
  size(1024, 1024);
  smooth();
  fill(255);
  rectMode(CENTER);
}

void draw() {
  background(0);

  pushMatrix();
  translate(512, 512);
  rotate(b); 
  rect(0, 0, 50, 50);
  b += 0.1;
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

