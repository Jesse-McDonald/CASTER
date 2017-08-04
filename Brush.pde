/**
Brush is designed to provide a simple brush to draw with, brush depends on having
a global EMImage called this.img for some of its functionality and should only exist
as a member of that object
Brush should only ever change the overlay, never the actual image
Brush requires access to int x, int y, Pixel(int x, int y, color), and color c, from the Pixel
float getZoom(), Pixel getPixel(int layer, int x, int y),color get(int layer, int x, int y), int layer, and EMOverlay overlay from EMImage (this.img)
void set(int layer,int x,int y,color), get(int layer,int x,int y) from EMOverlay

Brush depends on color, PImage,       color g.strokeColor, float g.strokeWeight, color g.fillColorvoid, line(int x, int y, int x2, int y2), void ellipse(int x, int y, int width, int height), void PImage.resize(int w,int h), color PImage.get(int x, int y), void PImage.set(int x,int y, color), PImage createImage(int w, int h, int colorMode),PImage loadImage(String path), image(PImage this.img, int xPos, int yPos, int xScale, int yScale), image(PImage this.img, int xPos, int yPos), color(int red, int green, int blue, int alpha) from processing 
also depends on "bucket.png" in program dir
*/
//TODO: remove dependance on golbal this.img
class Brush{
	private int size=9;//odd numbers work best due to always having a single "center" pixel, there is a very good reason that this is a float, but I don’t remember what it is
	private PImage shape;//used to track the current brush shape
	private color c;//used to track current brush color
	public int mode=0;//0 none, 1 circle, 2 square, 3 diamond, 4 fill, 5 gradient flood, 6 ray cast
	public boolean erase=false;//if true a bush should generally erase instead of fill during paint()
	ArrayList<Pixel> floodFillBackup=new ArrayList<Pixel>();//used to store pixels for processes taking more than 1 frame
  float rayCastAngle=0;
  EMImage img;
	public Brush(color col,EMImage image){
    this.img=image;
		mode =0;
		c=col;
		update();//update does almost everything we would want the constructor to do anyway
	}

	public Brush draw(){//this draws the shape of the brush to the screen, generally should not update overlay unless there is a multi-frame process
		//this should be called every frame
		float zoom=this.img.getZoom();
		Pixel pixel = brushPosition();
		if(mode==1||mode==2||mode==3){//draw shape for circle, square, and diamond brush, centered on mouse
			image(shape,(pixel.x*zoom+this.img.offsetX),(pixel.y*zoom+this.img.offsetY),shape.width*zoom,shape.height*zoom); 
		}else if(mode==4){//draw the bucket icon for flood fill, so that drip is on mouse, updates ongoing flood fill
			image(shape,mouseX-shape.width+9,mouseY-shape.height+13); 
			floodFillUpdate();
			if(erase){//clears ongoing flood fill in case of overflow
				floodFillBackup=new ArrayList<Pixel>();
			}
		}else if(mode==5){//updates existing gradient Flood
			gradientFloodUpdate();
			if(erase){//clears ongoing gradient flood if overflow
				floodFillBackup=new ArrayList<Pixel>();
			}
		}else if(mode==6){
      color temp=g.strokeColor;//store the current stroke color so we can restore it later
      float w=g.strokeWeight;//same for stroke width
      color fill=g.fillColor;//and fill
      stroke(c);//set stroke to layer color
      strokeWeight(10);//nice wide lines
      /*final int RAY_COUNT=4;
      for(int i=0;i<size*RAY_COUNT;i++){//this code draws the rays, does not look the greatest so instead I use the rotating ray
        float theta=PI*2.0/size/RAY_COUNT;
        //image(shape,(pixel.x*zoom+this.img.offsetX),(pixel.y*zoom+this.img.offsetY),shape.width*zoom,shape.height*zoom); 
        //line((pixel.x*zoom+this.img.offsetX+zoom/2),(pixel.y*zoom+this.img.offsetY+zoom/2),(pixel.x*zoom+this.img.offsetX+zoom/2)+cos(theta*i)*size/2*zoom,(pixel.y*zoom+this.img.offsetY+zoom/2)+sin(theta*i)*size/2*zoom);
        for(int j=0;j<=size;j++){
          line((pixel.x*zoom+this.img.offsetX+zoom/2),(pixel.y*zoom+this.img.offsetY+zoom/2),(pixel.x*zoom+this.img.offsetX+zoom/2)+cos(theta*i)*size/2*zoom,(pixel.y*zoom+this.img.offsetY+zoom/2)+sin(theta*i)*size/2*zoom);
        }
      }*/
      line(mouseX,mouseY,mouseX+cos(rayCastAngle)*size/2*zoom,mouseY+sin(rayCastAngle)*size/2*zoom);//draw line at current angle angle
      fill(color(0,0,0,0),0);//set fill to transparrent so the circle is no color inside        
      ellipse(mouseX,mouseY,size*zoom,size*zoom);//draw a circle arround the mouse where the ray will sweep
      stroke(temp);//restor stroke
      strokeWeight(w);//and weight
      fill(fill);//and fill
      rayCastAngle+=.2;//increment angle, larger values are generaly faster, smaller are slower, I found 0.2 is about right
    }
		return this; 
	}
  Pixel brushPosition(){//calculates the offset to the top left corner of the image based on the pixel under the mouse
    float zoom=this.img.getZoom();
    return this.img.getPixel(int(mouseX-shape.width/2.0*zoom+zoom/2),int(mouseY-shape.width/2.0*zoom+zoom/2));
  }
	public Brush rayCastBrush(int x, int y){//projects rays from the mouse which stop and fill when a certain gradiant is met, then smooth the result
      Pixel pixel =this.img.getPixel(x,y);//seed first pixel
      final int RAY_COUNT=4;//rays go out in this many directions 
      float zoom=this.img.zoom;
      //smoothBrush(pixel.x,pixel.y);//comment other smooth and un comment this one to see how it works
      for(int i=0;i<size*RAY_COUNT;i++){//make circle of rays
        float theta=PI*2.0/size/RAY_COUNT;//determine angle of rays
        //image(shape,(pixel.x*zoom+this.img.offsetX),(pixel.y*zoom+this.img.offsetY),shape.width*zoom,shape.height*zoom); 
        //line((pixel.x*zoom+this.img.offsetX+zoom/2),(pixel.y*zoom+this.img.offsetY+zoom/2),(pixel.x*zoom+this.img.offsetX+zoom/2)+cos(theta*i)*size/2*zoom,(pixel.y*zoom+this.img.offsetY+zoom/2)+sin(theta*i)*size/2*zoom);
        ArrayList<Pixel> line=new ArrayList<Pixel>();//get a list ready to add pixels to allong the line
        Pixel last=new Pixel(pixel.x,pixel.y,c);//track the last pixel, faster than following the linked list
        for(int j=0;j<=size;j++){//run a dot scan allong the line and add all pixels to the list
          Pixel p=this.img.getPixel(int((pixel.x*zoom+this.img.offsetX+zoom/2)+cos(theta*i)*j/2*zoom),int((pixel.y*zoom+this.img.offsetY+zoom/2)+sin(theta*i)*j/2*zoom));//record new pixel
          //ellipse(int((pixel.x*zoom+this.img.offsetX+zoom/2)+cos(theta*i)*j/2*zoom),int((pixel.y*zoom+this.img.offsetY+zoom/2)+sin(theta*i)*j/2*zoom),10,10);//visualize scan, lags program
          line.add(last);//add last pixel
          if((p.x!=last.x||p.y!=last.y)&&gradMatch(last,p)){//check that current and last are not the same pixel, if they arent, check them against gradMatch to see if we should stop the line
            this.img.overlay.set(this.img.layer,last.x,last.y,c);//fill last pixel
            break;//break out of the for, we have all of the 
          }
          last=p;//swap current to last
        }
        for(int j=0; j<line.size();j++){//fill entire line to end point
          this.img.overlay.set(this.img.layer,line.get(j).x,line.get(j).y,c);
        }
      }
      smoothBrush(pixel.x,pixel.y);//smooths area
		  return this;
	}

	public Brush gradientFlood(Pixel pixel){//initializes gradient flood fill with initial pixel/pixels
		floodFillBackup.add(pixel);
		return this;
	}

	public Brush gradientFloodUpdate(){//updates ongoing flood fill (didnt work, depercated)
		int ittr=0;
		while(!floodFillBackup.isEmpty()&ittr<floodFillBackup.size()){//end flood fill for this frame conditions
			Pixel p=floodFillBackup.get(0);
			floodFillBackup.remove(0);
			if (this.img.overlay.get(this.img.layer,p.x,p.y)!=c){ //detects previously colored pixel
				this.img.overlay.set(this.img.layer,p.x,p.y,c);//colors new pixel

				//check the gradient condition on all 4 cardinal pixels unless they are off the edge of the this.img
				//the inequalities will 0 the shift when false, else time they will shift by 1
				floodAdd(this.img.get(p.x+int(p.x<this.img.overlay.width-1),p.y),p);
				floodAdd(this.img.get(p.x-int(p.x>0),p.y),p);
				floodAdd(this.img.get(p.x,p.y+int(p.y<this.img.overlay.height-1)),p);
				floodAdd(this.img.get(p.x,p.y-int(p.y>0)),p);

				ittr++;
			}
		}
		return this;
	}
  private void floodAdd(Pixel temp,Pixel p){//add a pixel to (depricated) gradient flood fill
     if(gradMatch(temp,p)){
      floodFillBackup.add(temp);
    }  
  }
	private boolean gradMatch(Pixel temp,Pixel p){//determins if 2 pixels have enough of a gradient to them
		float threshold=32;//arbitrary threshold for comparison 32 seems to work well for ray cast
		float _1=greyVal(temp.c);
		float _2=greyVal(p.c);
    return (_1-_2)*(_1-_2)*3>threshold*threshold;
	}

	float greyVal(color c){//this averages the RGB values of a given color to determine its grayscale value
		return ((c >> 16 & 0xFF) + (c >> 8 & 0xF) + (c & 0xFF))/3.0;//extract and average rgb values
	}



	public Brush setSize(int s){//sets the size, this should be odd numbers for best performance
		//after brush is resized it updates the shape to accurately reflect the change
		this.size=max(1,s);
		this.update();
		return this;
	}

	public Brush paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
		Pixel pixel= brushPosition();
    this.img=img;
		if(mode==0){//if there is no brush, do nothing, hard coded just in case
		}else if(mode==1||mode==2||mode==3){//draw the shape to the overlay if it is the circle, square, or diamond
			for (int x=0;x<this.img.overlay.width&&x<shape.width;x++){
				for (int y=0;y<this.img.overlay.width&&y<shape.width;y++){
					if(erase){//determine if ink is to be removed or layed down
						if(shape.get(x,y)!=color(0,0,0,0)){
							this.img.overlay.set(this.img.layer,pixel.x+x,pixel.y+y,color(0,0,0,0));//note iff a pixel is non transparent it will remove set the overlay transparent
						}
					}else{
						if(shape.get(x,y)!=color(0,0,0,0)){//this prevents brushes from having visible edges
							this.img.overlay.set(this.img.layer,pixel.x+x,pixel.y+y,shape.get(x,y));
						}
					}
				}  
			}
		}else if(mode==4){//set a floodFill start
			float zoom=this.img.getZoom();
			floodFill(this.img.getPixel(int(mouseX-zoom/2),int(mouseY-zoom/2)));//not sure why I am doing this instead of just passing pixel in, will test when not documenting
		}else if(mode==5){// set a gradient fill start
			float zoom=this.img.getZoom();
			gradientFlood(this.img.getPixel(int(mouseX-zoom/2),int(mouseY-zoom/2)));  //not sure why I am doing this instead of just passing pixel in, will test when not documenting
		}else if(mode==6){
      rayCastBrush(mouseX,mouseY);
    }
		return this;
	}

	public Brush floodFill(Pixel pixel){//add initial flood fill pixel
		floodFillBackup.add(pixel);
		return this;
	}

	public Brush floodFillUpdate(){//expand the flood fill
		ArrayList<Pixel> pixels=floodFillBackup;
		int ittr=0;
		while(!pixels.isEmpty()&ittr<pixels.size()){//flood fill ends when there are no non c colored pixels to spread to
			Pixel p=pixels.get(0);
			pixels.remove(0);
			if (this.img.overlay.get(this.img.layer,p.x,p.y)!=c){
				this.img.overlay.set(this.img.layer,p.x,p.y,c);

				pixels.add(new Pixel(p.x+1*int(p.x<this.img.overlay.width-1),p.y,c));//don’t worry, pixel is never checked for color anyway so we can get away with this short cut
				pixels.add(new Pixel(p.x-1*int(p.x>0),p.y,c));
				pixels.add(new Pixel(p.x,p.y+1*int(p.y<this.img.overlay.height-1),c));
				pixels.add(new Pixel(p.x,p.y-1*int(p.y>0),c));
				ittr++;
			}
		}
		floodFillBackup=pixels;//I don’t know why I don’t edit floodFillBackup directly, but for some reason I implemented this way sooooo
		return this;
	}

	public Brush increase(int n){//increases brush size by n, note that n should be even so that size always remains odd
		return setSize(size+n);
	}

  public Brush smoothBrush(int startX, int startY){//this brush smooths out thin ridges and fills in thin gaps, it does this by checking the number of neighboring pixels for each pixel, it is designed to be used with ray fill, but can be used independantly
    ArrayList<Pixel> add=new ArrayList<Pixel>();//list of pixels to fill, we have to do these last or it will throw off the calculations
    ArrayList<Pixel> remove=new ArrayList<Pixel>();  //list of pixels to clear, we have to do these last or it will throw off the calculations
    float ss=size*size/4;//callculate r^2 from D
    for(int x=0;x<size;x++){
      for(int y=0;y<size;y++){
        //this.img.overlay.set(this.img.layer,startX+x,startY+y,c);
        int posX=x-size/2;
        int posY=y-size/2;
        if (posX*posX+posY*posY<ss){//good old pathagrean circle from inequality for filling a circle
          if(this.img.overlay.get(this.img.layer,startX+posX,startY+posY)!=c){//check for empty pixel
            int count=0;
            for(int i=-1;i<2;i++){//for loops for getting a 9 square (3x3) area centered on the point inside the cricle
              for(int j=-1;j<2;j++){
                count+=int(this.img.overlay.get(this.img.layer,startX+posX+i,startY+posY+j)==c);//count adjacent pixels
              }  
            }
            
            if(count>4){
               add.add(new Pixel(startX+posX,startY+posY,c));//if enough pixels are full arround it, fill this one in
            }
          }else if(this.img.overlay.get(this.img.layer,startX+posX,startY+posY)==c){//check full pixels
            int count=0;
            for(int i=-1;i<2;i++){//for loops for getting a 9 square (3x3) area centered on the point inside the cricle
              for(int j=-1;j<2;j++){
                count+=int(this.img.overlay.get(this.img.layer,startX+posX+i,startY+posY+j)!=c);//couund adjacent pixels
              }  
            }
            
            if(count>4){
              remove.add(new Pixel(startX+posX,startY+posY,color(0,0,0,0)));//add pixel to remove
            }
          }
        }
      }
    }
    for(int i=0;i<add.size();i++){
      this.img.overlay.set(this.img.layer,add.get(i).x,add.get(i).y,c);//add pixles to add
    }
    for(int i=0;i<remove.size();i++){
      this.img.overlay.set(this.img.layer,remove.get(i).x,remove.get(i).y,color(0,0,0,0));//clear pixels to clear
    }
    return this;
  }
	public Brush changeSize(int n){//no real difference from increase, just feels different when you use it
		setSize(size+n);
		return this; 
	}

	public Brush decrease(int n){//decreases brush size by n, note that n should be even so that size always remains odd
		return setSize(size-n);
	}

	public Brush clearBrush(int n){//clears specific brush n, this is built to aid in the radio button selection as one button is activated before the previous one is deactivated
		//leading to the brush being cleared when set from radio buttons
		mode=mode*int(mode!=n);
		return this;
	}

	public Brush update(){//updates the shape of the brush, this should only be called when there is a reasonable certainty that the brush has changed in some way
		//as it can be a computationally complex operation
		shape=createImage((int)1,(int)1,ARGB);//incase no shape is created for a brush in specific it will still have an image shockingly this does need to be 1,1 not 0,0
		if(mode==1){//circle
			shape=createImage((int)size,(int)size,ARGB);    
			float ss=size*size/4;//callculate r^2 from D
			for(int x=0;x<shape.width;x++){
				for(int y=0;y<shape.height;y++){
					float posX=x-shape.width/2;
					float posY=y-shape.height/2;
					if (posX*posX+posY*posY<ss){//good old pathagrean circle from inequality for filling a circle
						shape.set(x,y,c);
					}
				}
			}
		}else if(mode==2){//square
			shape=createImage((int)size,(int)size,ARGB);
			for(int x=0;x<shape.width;x++){
				for(int y=0;y<shape.height;y++){
					shape.set(x,y,c);//extreamly simple, color every pixel
				}
		  }
		}else if(mode==3){//diamond
			shape=createImage((int)size,(int)size,ARGB);
			for(int x=0;x<shape.width;x++){
				for(int y=0;y<shape.height;y++){
					float posX=x-shape.width/2;
					float posY=y-shape.height/2;
					if (abs(posX)+abs(posY)<size/2){//this took some head scratching, essentially this is the exact same as a circle... just don’t square every term
						shape.set(x,y,c);
					}
				}
		  }
		}else if(mode==4){
			shape=loadImage("bucket.png");//load up the bucket encase of flood fill
			shape.resize(128,128);
		}//gradient flood and ray cast not yet implemented enough to get a shape
		return this;
	}

}