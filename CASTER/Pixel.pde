/**
Pixel only exists as a container for a single pixel including its position and color
Pixel does not depend on any custom classes
Pixel does depend on color from processing
*/
public class Pixel{
	int x;//pixel x pos
	int y;//pixel y pos
	color c;//pixel color
	Pixel(int x, int y, color c){//basic constructor
		this.x=x;
		this.y=y;
		this.c=c;
	}

}