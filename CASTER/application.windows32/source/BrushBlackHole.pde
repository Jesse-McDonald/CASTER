class BrushBlackHole extends Brush{
    int undoFrames=0;
      public BrushBlackHole(color col,EMImage image,int s){
        super(col,image,s);
        shape=loadImage("ui/blackHoleIcon.png");//load up the bucket incase of flood fill
        shape.resize(128,128);
    }
  ArrayList<Pixel> floodFillBackup=new ArrayList<Pixel>();//used to store pixels for processes taking more than 1 frame
  public Brush draw(){//this draws the shape of the brush to the screen, generally should not update overlay unless there is a multi-frame process
  
 
    //this should be called every frame
    float zoom=this.img.getZoom();
    Pixel pixel = brushPosition();
    
      image(shape,mouseX-shape.width/2,mouseY-shape.height/2); 
      floodFillUpdate();
      if(erase){//clears ongoing flood fill in case of overflow
        floodFillBackup=new ArrayList<Pixel>();
      }
    return this; 
  }
  

  public BrushBlackHole paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    Pixel pixel= brushPosition();
    this.img=img;
    float zoom=this.img.getZoom();
    floodFill(this.img.getPixel(int(mouseX-zoom/2),int(mouseY-zoom/2)));//not sure why I am doing this instead of just passing pixel in, will test when not documenting
    return this;
  }

  public BrushBlackHole floodFill(Pixel pixel){//add initial flood fill pixel
    floodFillBackup.add(pixel);
    return this;
  }

  public BrushBlackHole floodFillUpdate(){//expand the flood fill
    ArrayList<Pixel> pixels=floodFillBackup;
    int ittr=0;
    if(!pixels.isEmpty()){
       undoFrames++;
       if(undoFrames>100){
         img.snap(); 
         undoFrames=0;
       }
    }else if(undoFrames>0){
        img.snap(); 
        undoFrames=0;
    }
    while(!pixels.isEmpty()&ittr<pixels.size()*size/5.){//flood fill ends when there are no non c colored pixels to spread to
      Pixel p=pixels.get(0);
      pixels.remove(0);
      if (this.img.overlay.get(this.img.layer,p.x,p.y)==c){//its flood fill, but anti, this and the next line is all that needs changed
        this.img.overlay.set(this.img.layer,p.x,p.y,0);

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

  public BrushBlackHole update(){//updates the shape of the brush, this should only be called when there is a reasonable certainty that the brush has changed in some way
    //as it can be a computationally complex operation

    return this;
  }
       public Brush eStop(){//clear the list in an emergency
          if(floodFillBackup.size()>0){
            img.snap();//commit changes to undo record
          }
          floodFillBackup=new ArrayList<Pixel>();
          
          return this; 
        }
}
