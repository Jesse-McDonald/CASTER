class BrushCircle extends Brush{
    public BrushCircle(color col,EMImage image,int s){
      super(col,image,s);
    }
    public BrushCircle draw(){//this draws the shape of the brush to the screen, generally should not update overlay unless there is a multi-frame process
    //this should be called every frame
    float zoom=this.img.getZoom();
    Pixel pixel = brushPosition();
    //draw shape centered on mouse
    image(shape,(pixel.x*zoom+this.img.offsetX),(pixel.y*zoom+this.img.offsetY),shape.width*zoom,shape.height*zoom); 
    return this; 
  }
    public BrushCircle paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    Pixel pixel= brushPosition();
    this.img=img;
    for (int x=0;x<this.img.overlay.width&&x<shape.width;x++){
        for (int y=0;y<this.img.overlay.width&&y<shape.width;y++){
          if(erase){//determine if ink is to be removed or layed down
            if(shape.get(x,y)!=color(0,0,0,0)){
              if(this.img.overlay.get(this.img.layer,pixel.x+x,pixel.y+y)==c){//only errase the color that the brush is
                this.img.overlay.set(this.img.layer,pixel.x+x,pixel.y+y,color(0,0,0,0));//note iff a pixel is non transparent it will remove set the overlay transparent
              }
            }
          }else{
            if(shape.get(x,y)!=color(0,0,0,0)){//this prevents brushes from having visible edges
              this.img.overlay.set(this.img.layer,pixel.x+x,pixel.y+y,shape.get(x,y));
            }
          }
        }  
      }
    return this;
  }
  
  public BrushCircle update(){//updates the shape of the brush, this should only be called when there is a reasonable certainty that the brush has changed in some way
    //as it can be a computationally complex operation
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
    return this;
  }
  
}
