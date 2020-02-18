/**
Ui_Panel is a basic display element designed as a background to other things
Ui_Panel depends on Ui_Element to extends that contains int posX, int posY, PImage tile, 
Ui_Panel also depends on void image(PImage, int x, int y), PImage loadImage(String path), void PImage.set(int x, int y, color), and PImage createImage(int displayWidth int height, int mode) from processing
*/
class Ui_Panel extends Ui_Element{
	Ui_Panel(int x, int y, PImage img){//create panel from provided image
		posX=x;
		posY=y;
		tile=img;
	}
	
	Ui_Panel(int x, int y, String imgPath){//create panel by loading image
		this(x,y,loadImage(imgPath));
	}
	Ui_Panel(float rX, float rY, float rS, PImage img){
      this(round(rX*PPI),round(rY*PPI),img);
      scale=(PPI/img.width)*rS;
}
Ui_Panel(float x, float y, float w, float h, color c){
  this(x,y,1,createImage(round(w*PPI),round(h*PPI),ARGB));
   for(int i=0;i<tile.width;i++){
      for (int j=0;j<tile.height;j++){
        tile.set(i,j,c); //color in image
      }
    }
}
	Ui_Panel(int x, int y, int w, int h, color c){//create panel with flat color
		this(x, y, createImage(w,h,ARGB));
		for(int i=0;i<w;i++){
			for (int j=0;j<h;j++){
				tile.set(i,j,c); //color in image
			}
		}
	}
	Ui_Panel(){this(0,0,0,0,tColor(0,0,0,0));}//default constructor sets up invisible panel with no size
	
	public boolean mouseOn(){//detects if the mouse would be over the panel where it was not transparent
		boolean ret=(dm.mouseX>=posX&&dm.mouseY>=posY)&&(dm.mouseX<=posX+tile.width&&dm.mouseY<=posY+tile.height)&&tile.get(dm.mouseX-posX,dm.mouseY-posY)!=color(0,0,0,0);    
		return ret;
	}
	public int calcWidth(){
    return ceil(posX+tile.width);
  }
  public int calcHeight(){
    return ceil(posY+tile.height);
  }
	public Ui_Panel draw(){
		dm.image(tile,posX,posY);//draw panel to screen
		return this;
	}
}
