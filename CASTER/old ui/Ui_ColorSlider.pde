
class Ui_ColorSlider extends Ui_Slider{
 Ui_ColorSlider(){
    super();
    init();
 }
  Ui_ColorSlider(float rX,float rY,float rS,PImage img){//use this constructor if you want the button to self scale
    super(rX,rY,rS,img);
    init();
  }
  Ui_ColorSlider(int x, int y, PImage img){//use this constructor if you dont want the button to self scale
    super(x,y,img);
    init();
  }
  Ui_ColorSlider(int x, int y, String imgPath){//no scale load image constructor
    super(x,y,imgPath);
    init();
  } 

  Ui_ColorSlider(float x, float y, float s, String imgPath){//scale load image constructor
    super(x,y,s,imgPath);
    init();
  }
  Ui_ColorSlider init(){//this is only here because I can not call a super constructor and a this constructor, so this is the real this constructor
   minV=0;
   maxV=255;
   return this;
  }
 Ui_Slider draw(){
   if (valChanged){
     track.loadPixels();
     for(int i =0 ;i<track.pixels.length;i++){
       track.pixels[i]=tColor(value,value,value);
     }
     track.updatePixels();
   }
   return super.draw();
 }
}