boolean switchV;

void setup() {
	switchV = true;
}

void draw() {
	if(switchV){
		background(255);
		switchV = false;
	}
}

void keyPressed() {
	switchV = true;
}
