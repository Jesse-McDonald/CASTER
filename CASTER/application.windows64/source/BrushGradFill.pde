
class BrushGradFill extends Brush{
    public BrushGradFill(color col,EMImage image,int s){
      super(col,image,s);
    }
  ArrayList<Pixel> floodFillBackup=new ArrayList<Pixel>();//used to store pixels for processes taking more than 1 frame
 
  public BrushGradFill draw(){//this draws the shape of the brush to the screen, generally should not update overlay unless there is a multi-frame process
    //this should be called every frame
    float zoom=this.img.getZoom();
    Pixel pixel = brushPosition();
    
      gradientFloodUpdate();
      if(erase){//clears ongoing gradient flood if overflow
        floodFillBackup=new ArrayList<Pixel>();
      }
    return this; 
  }
  
  public BrushGradFill gradientFlood(Pixel pixel){//initializes gradient flood fill with initial pixel/pixels
    floodFillBackup.add(pixel);
    return this;
  }
  protected void floodAdd(Pixel temp,Pixel p){//add a pixel to (depricated) gradient flood fill
     if(gradMatch(temp,p)){
      floodFillBackup.add(temp);
    }  
  }
  protected boolean gradMatch(Pixel temp,Pixel p){//determins if 2 pixels have enough of a gradient to them
    float threshold=32;//arbitrary threshold for comparison 32 seems to work well for ray cast
    float _1=grayVal(temp.c);
    float _2=grayVal(p.c);
    return (_1-_2)*(_1-_2)*3>threshold*threshold;
  }
  public BrushGradFill gradientFloodUpdate(){//updates ongoing flood fill (didnt work, depercated)
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

  public BrushGradFill paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    Pixel pixel= brushPosition();
    this.img=img;  
    float zoom=this.img.getZoom();
    gradientFlood(this.img.getPixel(int(mouseX-zoom/2),int(mouseY-zoom/2)));  //not sure why I am doing this instead of just passing pixel in, will test when not documenting
    return this;
  }


  public BrushGradFill update(){//updates the shape of the brush, this should only be called when there is a reasonable certainty that the brush has changed in some way
    //as it can be a computationally complex operation
    shape=createImage((int)1,(int)1,ARGB);//incase no shape is created for a brush in specific it will still have an image shockingly this does need to be 1,1 not 0,0
    //gradient flood is not yet implemented enough to get a shape
    return this;
  }
 public Brush eStop(){//clear the list in an emergency
          floodFillBackup=new ArrayList<Pixel>();
          return this; 
        }
}
