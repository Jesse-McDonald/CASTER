class Ui_PaintButton extends Ui_Button{//this class grabs the color of the current brush and paints the background of a button with it
  //EMImage img;//object to grab color from//fine screw it, we are going global
  color c;//current color

  PImage mask;
  Ui_PaintButton constructor(){//the basic constructor, java is an idiot that wont let you call the super and another constructor so this is a work arround
    c=0;
    return this;
  }
  Ui_PaintButton(float rX,float rY,float rS,PImage img){//use this constructor if you want the button to self scale
    super(rX,rY,rS,img);
    constructor();
}
  Ui_PaintButton(int x, int y, PImage img){//use this constructor if you dont want the button to self scale
    super(x,y,img);
    constructor();
  }

  Ui_PaintButton(int x, int y, String imgPath){//no scale load image constructor
    super(x,y,imgPath);
    constructor();
  } 

  Ui_PaintButton(float x, float y, float s, String imgPath){//scale load image constructor
    super(x,y,s,imgPath);
    constructor();
  }
  Ui_PaintButton draw(){
    if(img!=null){
      if(c!=img.brush.c){

         c=img.brush.c;
         background.loadPixels();
         mask.loadPixels();
         if(background.pixels.length!=mask.pixels.length){
          
           background=createImage(mask.width,mask.height,ARGB);
           background.loadPixels();
         }
         for(int i =0;i<mask.pixels.length;i++){
           background.pixels[i]=((((int(alpha(c)>0)*255)&0xff)<<24)+((round(red(c))&0xff)<<16)+((round(green(c))&0xff)<<8)  +(round(blue(c))&0xff))*int(mask.pixels[i]!=0); 
           
         }
         background.updatePixels();
      }
    }
    super.draw();
    return this;
    
  }
}