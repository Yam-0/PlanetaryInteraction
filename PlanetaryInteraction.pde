color Gray = color(123, 123, 123);
color White = color(255, 255, 255);

void setup() {
	size(1024, 1024);
}

void draw() {
	background(0);
	fill(Gray);
	ellipse(512, 512, 800, 800);
	fill(White);
	ellipse(512, 512, 50, 50);
}
