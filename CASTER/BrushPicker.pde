class BrushPicker extends Brush{//yah, not a real brush again, but it fits the slot so why not
    public BrushPicker(color col,EMImage image,int s){
      super(col,image,s);
      shape=loadImage("bucket.png");//TODO: change icon
      shape.resize(128,128);
    }
  public BrushPicker paint(EMImage img){
    this.img=img;
    float zoom=this.img.getZoom();
    Pixel pixel= this.img.getPixel(int(mouseX-zoom/2),int(mouseY-zoom/2));//isnt there a function to get the pixel under the mouse?
    c= this.img.overlay.get(this.img.layer,pixel.x,pixel.y);//pickup color under mouse
    if(erase){//I dont technically need anything for erase, but I thought it would be fun if it inverted the color you click on
    //c=~c;//I wish I could use this, but it flips the alpha channel too
      c=c^0x00ffffff;//this is essencialy bitwise not, but I exclude the alpha channel from being changed
      
    }
    return this;
  }
  public BrushPicker update(){
    return this;
  }
}