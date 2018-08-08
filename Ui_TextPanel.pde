class Ui_TextPanel extends Ui_Panel{
  String lable;
  float size;
  PFont font;
  float offsetX;//the fractional offset from the top corner of the panel
  float offsetY;
  int textColor;
  Ui_TextPanel(int x, int y, PImage img){super(x,y,img);}//WHY JAVA!!!! WHY!!! I have all of these declared in super, polymorphism should allow me to use it here
  Ui_TextPanel(int x, int y, String imgPath){super(x,y,imgPath);}
  Ui_TextPanel(float rX, float rY, float rS, PImage img){super(rX,rY,rS,img);}
  Ui_TextPanel(float x, float y, float w, float h, color c){super(x,y,w,h,c);}
  Ui_TextPanel(int x, int y, int w, int h, color c){super(x,y,w,h,c);}
  Ui_TextPanel(){super();}
  Ui_TextPanel draw(){
    super.draw();
    if (font!=null) dm.textFont(font);
    dm.textSize(size);
    dm.stroke(textColor);
    dm.text(lable,posX+offsetX*tile.width,posY+offsetY*tile.height+size/4);//executive decision, shift is relative to the left center of the text box
    return this;
  }
}