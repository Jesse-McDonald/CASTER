import java.util.BitSet;
/**
A class to provide ease in scaling elements
depends a fully implimented Ui_Element to extend
also depends on PImage loadImage(String path), void image(PImage,int x, int y), int displayWidth int height, void pushMatrix(), void popMatrix(), void translate(int posX,int posY), void scale(float scale) from processing
*/
class Ui_ElementScalable extends Ui_Element{
  float relativeX;//used for self scaling, relative to displayWidth
  float relativeY;//used for self scaling, relative to height
  float relativeScale;//used for self scaling, relative to height
  float scale=1;//current scale
  Ui_ElementScalable(){super();}//default constructor only exists so it can be inherited by Ui_MomentaryButton
  //replace this later
  Ui_ElementScalable(float rX,float rY,float rS,PImage img){//use this constructor if you want the button to self scale
    this(round(rX*PPI),round(rY*PPI),img);
    scale=(PPI/img.width)*rS;

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
    dm.pushMatrix();//prep matrix
    if(autoReposition){//do magic scaling stuff if this button is auto scaling
      scale=displayHeight*relativeScale/ (float)tile.height;
      posX=round(relativeX*displayWidth);
      posY=round(relativeY*displayHeight);
    }
    dm.translate(posX,posY);//prep translation
    dm.scale(scale);//prep scale
    drawIt();
    dm.popMatrix();//apply matrix
    return this;
  }
  private Ui_ElementScalable drawIt(){
   dm.image(tile,0,0); 
   return this;
  }
}