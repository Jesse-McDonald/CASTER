import java.util.BitSet;
/**
A class to provide ease in scaling elements
depends a fully implimented Ui_Element to extend
also depends on PImage loadImage(String path), void image(PImage,int x, int y), int width, int height, void pushMatrix(), void popMatrix(), void translate(int posX,int posY), void scale(float scale) from processing
*/
class Ui_ElementScalable extends Ui_Element{
  float relativeX;//used for self scaling, relative to width
  float relativeY;//used for self scaling, relative to height
  float relativeScale;//used for self scaling, relative to height
  float scale=1;//current scale
  Ui_ElementScalable(){super();}//default constructor only exists so it can be inherited by Ui_MomentaryButton
  
  Ui_ElementScalable(float rX,float rY,float rS,PImage img){//use this constructor if you want the button to self scale
    this(round(rX*width),round(rY*height),img);//we over ride most of what this constructor does anyway so it does not matter that is is the no scale one
    relativeX=rX;
    relativeY=rY;
    relativeScale=rS;
    autoReposition=true;
    this.draw();
  }

  Ui_ElementScalable(int x, int y, PImage img){//use this constructor if you dont want the button to self scale
    posX=x;
    posY=y;
    tile=img;//usual initilization
    autoReposition=false;
    scale=1;
  }

  Ui_ElementScalable(int x, int y, String imgPath){//no scale load image constructor
    this(x,y,loadImage(imgPath));
  } 

  Ui_ElementScalable(float x, float y, float s, String imgPath){//scale load image constructor
    this(x,y,s,loadImage(imgPath));
  }

 

  public Ui_ElementScalable draw(){//draw the button
    pushMatrix();//prep matrix
    if(autoReposition){//do magic scaling stuff if this button is auto scaling
      scale=height*relativeScale/ (float)tile.height;
      posX=round(relativeX*width);
      posY=round(relativeY*height);
    }
    translate(posX,posY);//prep translation
    scale(scale);//prep scale
    drawIt();
    popMatrix();//apply matrix
    return this;
  }
  private Ui_ElementScalable drawIt(){
   image(tile,0,0); 
   return this;
  }
}