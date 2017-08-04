import java.util.BitSet;
/**
This class extends Ui_Element so that it can be automaticaly scaled with the window
Depends on fully implimented Ui_Element to extend
also depends on PImage loadImage(String path), void image(PImage,int x, int y), int width, int height, int mouseX, int mouseY, void pushMatrix(), void popMatrix(), void translate(int posX,int posY), void scale(float scale) from processing
*/
class Ui_ScalePanel extends Ui_Element{
	float relativeX;//fraction of width to put x at
	float relativeY;//fraction of height to put y at
	float relativeScale;//fraction of height to scale to
	float scale=1;//absolute scale tracker
	Ui_ScalePanel(float rX, float rY, float w, float h, color c){//make flat colored panel
		this(rX,rY,h,createImage(round(w*width),round(h*height),ARGB)); 
		for(int i=0;i<round(w*width);i++){
			for (int j=0;j<round(h*height);j++){
				tile.set(i,j,c); //color all pixels
			}
		}
	}
	
	Ui_ScalePanel(float rX,float rY,float rS,PImage img){//make panel from image
		this(round(rX*width),round(rY*height),img);
		relativeX=rX;
		relativeY=rY;
		relativeScale=rS;
		this.draw();
	}

	private Ui_ScalePanel(int x, int y, PImage img){//this constructor only exists to be called as a super constructor, dont call directly
		posX=x;
		posY=y;
		tile=img;
		scale=1;
  }
  
	Ui_ScalePanel(float xR, float yR, float s, String imgPath){//make panel from img path
		this(xR,yR,s,loadImage(imgPath));
	}

	public boolean mouseOn(){//calculate if mouse is in shape and not on a transparent pixel
		boolean ret=(mouseX>=posX)&&(mouseY>=posY)&&(mouseX<=posX+tile.width*scale)&&(mouseY<=posY+tile.height*scale)&&tile.get(round(mouseX-posX),round(mouseY-posY))!=color(0,0,0,0);
		return ret;
	}

	public Ui_ScalePanel draw(){//render the panel
		pushMatrix();//prep transformation matrix
		scale=height*relativeScale/ (float)tile.height;//calculate scale
		posX=round(relativeX*width);//calculate position
		posY=round(relativeY*height);
		translate(posX,posY);//prep translation
		scale(scale);//prep scale
		image(tile,0,0);//display image
		popMatrix();//apply transformation matrix to move image to the correct place
		return this;
	}
}