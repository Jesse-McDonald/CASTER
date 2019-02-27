/**
Brush is designed to provide a simple brush to draw with, brush depends on having
a global EMImage called this.img for some of its functionality and should only exist
as a member of that object
Brush is now polymorphic, new brushes should simply extend Brush and replace img.brush when in use, this replaces mode in a more elegant manner
Brush should only ever change the overlay, never the actual image
Brush requires access to int x, int y, Pixel(int x, int y, color), and color c, from the Pixel
float getZoom(), Pixel getPixel(int layer, int x, int y),color get(int layer, int x, int y), int layer, and EMOverlay overlay from EMImage (this.img)
void set(int layer,int x,int y,color), get(int layer,int x,int y) from EMOverlay

Brush depends on color, PImage,       color g.strokeColor, float g.strokeWeight, color g.fillColorvoid, line(int x, int y, int x2, int y2), void ellipse(int x, int y, int width, int height), void PImage.resize(int w,int h), color PImage.get(int x, int y), void PImage.set(int x,int y, color), PImage createImage(int w, int h, int colorMode),PImage loadImage(String path), image(PImage this.img, int xPos, int yPos, int xScale, int yScale), image(PImage this.img, int xPos, int yPos), color(int red, int green, int blue, int alpha) from processing 
also depends on "ui/bucket.png" in program dir
*/
//TODO: remove dependance on golbal this.img
class Brush{
	public int size;//odd numbers work best due to always having a single "center" pixel, there is a very good reason that this is a float, but I don’t remember what it is
	protected PImage shape;//used to track the current brush shape
	protected color c;//used to track current brush color
	public boolean erase=false;//if true a bush should generally erase instead of fill during paint()
  public float pressure;//pressure from a wacom tablet, if not used set to 0
	EMImage img;
        public Brush(){
            this(color(0,0,0,0), (EMImage)null,9);//please never try to use this constructor, java just instits we have it so here is something
            pressure=0;
        }
	public Brush(color col,EMImage image,int s){
                this.img=image;
                this.setSize(s);
		            c=col;
		            update();//update does almost everything we would want the constructor to do anyway
	}

	public Brush draw(){//this draws the shape of the brush to the screen, generally should not update overlay unless there is a multi-frame process
		//this should be called every frame
		float zoom=this.img.getZoom();
		return this; 
	}

  Pixel brushPosition(){//calculates the offset to the top left corner of the image based on the pixel under the mouse
    float zoom=this.img.getZoom();
    return this.img.getPixel(int(mouseX-shape.width/2.0*zoom+zoom/2),int(mouseY-shape.width/2.0*zoom+zoom/2));
  }

	float grayVal(color c){//this averages the RGB values of a given color to determine its grayscale value
		return ((c >> 16 & 0xFF) + (c >> 8 & 0xFF) + (c & 0xFF))/3.0;//extract and average rgb values
	}

	public Brush setSize(int s){//sets the size, this should be odd numbers for best performance
		//after brush is resized it updates the shape to accurately reflect the change
		this.size=max(1,s);
		this.update();
		return this;
	}

	public Brush paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
		return this;
	}

	public Brush increase(int n){//increases brush size by n, note that n should be even so that size always remains odd
		return setSize(size+n);
	}

	public Brush changeSize(int n){//no real difference from increase, just feels different when you use it
		setSize(size+n);
		return this; 
	}

	public Brush decrease(int n){//decreases brush size by n, note that n should be even so that size always remains odd
		return setSize(size-n);
	}
  public Brush sendPressure(float in){
    //handle pressure input later, not entirely sure what do do with it
    return this;
  }
	public Brush update(){//updates the shape of the brush, this should only be called when there is a reasonable certainty that the brush has changed in some way
		//as it can be a computationally complex operation
                 shape=createImage(1,1,ARGB);//incase no shape is created for a brush in specific it will still have an image, shockingly this does need to be 1,1 not 0,0
		return this;
	}
        public int getSize(){
         return size; 
        }
        public Brush eStop(){//usualy never used, this is included for if a brush (ie flood fill) has an emergency stop condition that might need to happen
          return this; 
        }
}