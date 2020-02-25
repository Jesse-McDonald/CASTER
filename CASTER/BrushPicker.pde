class BrushPicker extends Brush{//yah, not a real brush again, but it fits the slot so why not
    PImage mask;
    PImage map;
    color maskColor;
    public BrushPicker(color col,EMImage image,int s){
      super(col,image,s);
      shape=loadImage("ui/picker.png");
      shape.resize(128,128);
      mask=loadImage("ui/pickerMap.png");
      mask.resize(128,128);
      map=createImage(mask.width,mask.height,ARGB);
      maskColor=0;
    }
    public BrushPicker draw(){
      int x=mouseX, y=mouseY;
     Pixel pixel= this.img.getPixel(x,y);
     image(shape,x,y-shape.height);
    image(map,x,y-mask.height);
    
    updateMask(img.overlay.get(img.layer,pixel.x,pixel.y));
    return this;
  }
  BrushPicker updateMask(color c){
    if(maskColor !=c){
       maskColor=c;
       map.loadPixels();
       mask.loadPixels();
       for(int i=0;i<map.pixels.length;i++){
         if(mask.pixels[i]==tColor(255,255,255)){
           map.pixels[i]=c;
         }
       }
       map.updatePixels();
    }
    return this;
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
    sidebar.setColor(new Color(round(red(c)),round(green(c)),round(blue(c))));

    return this;
  }
  public BrushPicker update(){
    return this;
  }
}
