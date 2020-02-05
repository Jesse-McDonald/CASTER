/**
this class exists only to allow for buttons that do not lock on
depends on fully implemented Ui_Button to extends
also depends on mousePressed, mouseButton and LEFT from processing
*/
class Ui_MomentaryButton extends Ui_Button{
//redirct all constructors to Ui_Button
	Ui_MomentaryButton(){
		super();
	} 
	Ui_MomentaryButton(float rX,float rY,float rS,PImage img){
		super(rX,rY,rS,img);
	}

	Ui_MomentaryButton(int x, int y, PImage img){
		super(x,y,img);
	}

	Ui_MomentaryButton(int x, int y, String imgPath){
		super(x,y,loadImage(imgPath));
	} 

	Ui_MomentaryButton(float x, float y, float s, String imgPath){
		super(x,y,s,loadImage(imgPath));
	}

	public boolean detectClick(boolean onButton){//detect click now sets state to clicked state rather than toggling it
		boolean ret=false;
		boolean currentState=dm.mousePressed&&dm.mouseButton==LEFT&&onButton;
		ret=!currentState&&super.MOUSE_STATE&&onButton;
		super.MOUSE_STATE=currentState;
		boolean cState=ret;
		state.set(0,cState);
		return ret;
	}

}
