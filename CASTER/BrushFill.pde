class BrushFill extends Brush{
  int undoFrames=0;
  color target;
    public BrushFill(color col,EMImage image,int s){
      super(col,image,s);
      shape=loadImage("ui/bucket.png");//load up the bucket encase of flood fill
      shape.resize(128,128);
    }
  ArrayList<Pixel> floodFillBackup=new ArrayList<Pixel>();//used to store pixels for processes taking more than 1 frame
  public Brush draw(){//this draws the shape of the brush to the screen, generally should not update overlay unless there is a multi-frame process
  
 
    //this should be called every frame
    float zoom=this.img.getZoom();
    Pixel pixel = brushPosition();
    
      image(shape,mouseX-shape.width+9,mouseY-shape.height+13); 
      floodFillUpdate();
      if(erase){//clears ongoing flood fill in case of overflow
        floodFillBackup=new ArrayList<Pixel>();
      }
    return this; 
  }
  
  public BrushFill paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    this.img=img;
    float zoom=this.img.getZoom();
    Pixel pixel= this.img.getPixel(int(mouseX-zoom/2),int(mouseY-zoom/2));//not sure why I am doing this instead of just passing pixel in, will test when not documenting
    //pixel is the top left corner, I want the pixel under the mouse, so I did this apparently
    
    //target=this.img.overlay.get(this.img.layer,pixel.x,pixel.y);//this is not multi click safe
    //floodFillBackup=new ArrayList<Pixel>();//you might need this line, it will make this multi click safe
    //oh yah, you very much need that line, with out that line the program will enter a valid flood fill of a color (lets say 0), it will go through the if and enter the loop, then on the next mouse event, the color is set to what
    //is under the mouse (now c, we just flood filled there) and this new flood fill fails to start because of the if, buuuuuuuuuut 1 flood is still going... now with c as its color... you see the problem?
    //unfortunatly that line actually causes the flood fill to insta clear and set target to c, so it does not lock up, but at the same time it does not flood fill either, use these lines
    if(floodFillBackup.size()==0){//there, we only change colors if there is not a flood fill in progress, a better solution would be a FloodArea class that keeps track of c and target, then you could just make 2 FloodArea objects
    //that would allow the multi point flood fill that this does not
      target= this.img.overlay.get(this.img.layer,pixel.x,pixel.y);
    }
    if(target!=c){//without this line, if you click on an area the same color as the brush color it will infinitly fill its self over and over and over
      floodFill(pixel);
    }
    return this;
  }

  public BrushFill floodFill(Pixel pixel){//add initial flood fill pixel
    floodFillBackup.add(pixel);
    return this;
  }

  public BrushFill floodFillUpdate(){//expand the flood fill

    if(target==c){//I have had so many problems with this that I am saying "Screw it" if we ever enter this condition for any reason, drop the entire flood fill emediatly
      floodFillBackup=new ArrayList<Pixel>();
    }//I should also probiably dump on color change in general, but this is just so fun to use, so I am going to leave it
    ArrayList<Pixel> pixels=floodFillBackup;
    if(!pixels.isEmpty()){
       undoFrames++;
       if(undoFrames>100){
         img.snap(); 
         undoFrames=0;
       }
    }
    int ittr=0;
    int startNum=pixels.size();
    while(!pixels.isEmpty()&ittr<startNum){//flood fill ends when there are no non c colored pixels to spread to
      Pixel p=pixels.get(0);
      pixels.remove(0);

      if (this.img.overlay.get(this.img.layer,p.x,p.y)==target){//check if pixle is transparrent for flood fill, for future, !=c checks for same color
        
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

  public BrushFill update(){//updates the shape of the brush, this should only be called when there is a reasonable certainty that the brush has changed in some way
    //as it can be a computationally complex operation

    return this;
  }
       public Brush eStop(){//clear the list in an emergency
          floodFillBackup=new ArrayList<Pixel>();
          img.snap();//commit changes to undo record
          return this; 
        }
}
