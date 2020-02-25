import java.util.BitSet;
/**
A complicated class for a simple concept, a button that you can click to toggle it on or off
depends on access to void run() from Lambda,
and a fully implimented Ui_Element to extend
also depends on boolean mousePressed, int mouseButton, LEFT, PImage loadImage(String path), void image(PImage,int x, int y), int displayWidth int displayHeight int mouseX, int mouseY, void pushMatrix(), void popMatrix(), void translate(int posX,int posY), void scale(float scale) from processing
*/
class Ui_Button extends Ui_Element{
	private boolean MOUSE_STATE;//previous mouse state
	public BitSet state;//current button state, bit 0, pressed/not, bit 1 mouse on/off, bit 2 button active/not
  public PImage background;//background of button, not used but left avaliable
	public PImage highlighted;//an image overlayed over button when it is moused over
	public PImage pressed;//an image displayed when button is pressed
	public PImage dissabled;//an image overlayed over the button when it is dissabled
	float relativeX;//used for self scaling, relative to displayWidth
	float relativeY;//used for self scaling, relative to displayHeight
	float relativeScale;//used for self scaling, relative to displayHeight
	float scale=1;//current scale
	boolean prevState;//previous state[0]
	Lambda onActivate;//run this objects .run() when clicked on
	Lambda onDeactivate;//run this objects .run() when clicked off
	Lambda whileActive;//run this objects .run() every draw when the button is on
	Lambda whileDeactive;//run this objects .run() every draw when the button is off
	Lambda dummy=new Lambda();//a blank empty lambda to  increase speed in certain situations
	Ui_Button(){super();}//default constructor only exists so it can be inherited by Ui_MomentaryButton
	/*I am stealing this constructor, hence forth this shall be inch measures
	Ui_Button(float rX,float rY,float rS,PImage img){//use this constructor if you want the button to self scale
		this(round(rX*displayWidth),round(rY*displayHeight),img);//we over ride most of what this constructor does anyway so it does not matter that is is the no scale one
		relativeX=rX;
		relativeY=rY;
		relativeScale=rS;
		autoReposition=true;
		//this.draw();//What kind of idiot (apparently me btw) would call draw from a constructor? thats just asking for trouble
	}
*/
Ui_Button(float rX,float rY,float rS,PImage img){//use this constructor if you want the button to self scale
    this(round(rX*PPI),round(rY*PPI),img);
    scale=(PPI/img.width)*rS;
}
	Ui_Button(int x, int y, PImage img){//use this constructor if you dont want the button to self scale
    background=new PImage(1,1,ARGB);
		posX=x;
		posY=y;
		tile=img;//usual initilization
		state=new BitSet(3);
		state.clear(0,2);//clear out states
		highlighted=createImage(img.width,img.height,ARGB);
		pressed=createImage(img.width,img.height,ARGB);//create the images for extra behavior
		dissabled=createImage(img.width,img.height,ARGB);
		for(int i=0;i<img.width;i++){
			for (int j=0;j<img.height;j++){
				highlighted.set(i,j,tColor(135,206,250,100));
				pressed.set(i,j,tColor(100,100,100,50));//set each of the created images to a unique color incase we never get an image to base on
				dissabled.set(i,j,tColor(100,100,100,100));
			}
		}
		onActivate=new Lambda();//set all Lambdas to blank incase we dont recieve one later
		onDeactivate=new Lambda();
		whileActive=new Lambda();
		whileDeactive=new Lambda();
		autoReposition=false;
		scale=1;
	}

	Ui_Button(int x, int y, String imgPath){//no scale load image constructor
		this(x,y,loadImage(imgPath));
	} 

	Ui_Button(float x, float y, float s, String imgPath){//scale load image constructor
		this(x,y,s,loadImage(imgPath));
	}

	public boolean mouseOn(){//detect if mouse is in the button, does not check transparency 
		boolean ret=(dm.mouseX>=posX)&&(dm.mouseY>=posY)&&(dm.mouseX<=posX+tile.width*scale)&&(dm.mouseY<=posY+tile.height*scale);
		state.set(1,ret);
		detectClick(ret);//we know where the mouse is so this is the natural time to check for button clicks
		return ret;
	}

	public boolean detectClick(boolean onButton){//detect click, expects to know wether the mouse is already on the button
		boolean ret=false;
		boolean currentState=dm.mousePressed&&dm.mouseButton==LEFT&&onButton;//detect if mouse is pressed or not
		ret=!currentState&&MOUSE_STATE&&onButton;//detect if mouse is still pressed (or not) from last time, if it is clearly no click happened
		MOUSE_STATE=currentState;//update last state
		boolean cState=state.get(0)^ret;//use xor to toggle state if ret is true
		state.set(0,cState);
		return ret;
	}
  public int calcWidth(){//remember to update if you change scaling
    return ceil(posX+scale*tile.width);
  }
  public int calcHeight(){
    return ceil(posY+scale*tile.height);
  }
	public Ui_Button draw(){//draw the button

		dm.pushMatrix();//prep matrix
		if(autoReposition){//do magic scaling stuff if this button is auto scaling
			scale=displayHeight*relativeScale/ (float)tile.height;
			posX=round(relativeX*displayWidth);
			posY=round(relativeY*displayHeight);
		}
		dm.translate(posX,posY);//prep translation
		dm.scale(scale);//prep scale
		Lambda[] func={dummy,onDeactivate,onActivate};//that optimization that uses dummy
		func[(1+int(state.get(0)))*int(prevState^state.get(0))].run();//this should run dummy if the previous state and current state are the same otherwise
		//it should run onDeactivate if state is false, and onActivate if true
		prevState=state.get(0);//update previous state
		mouseOn();//run mouseOn again because it also handles click processing and kinda needs to get ran
		//this is the reason that mouseOn and detectClick have been optimised, they can be expected to run twice in each frame so have to be lite
    dm.image(background,0,0);
		if(state.get(0)){//button is active
			dm.image(pressed,0,0);//the matrix handles the positioning
			whileActive.run();//run lambda for while deactive
		}else{//matrix is deactive
			dm.image(tile,0,0);
			whileDeactive.run();//run lambda
		}
		if(state.get(2)){//detect if button is disabled
			dm.image(dissabled,00,00);
		}else if(state.get(1)){//detect if button is highlighted, it cant be if dissabled
			dm.image(highlighted,0,0);
		}
		dm.popMatrix();//apply matrix
		return this;
	}
	//if you want to set these directly rather than from a file... the variables for them are public...
	public Ui_Button setHighlightedImg(String path){//change the higlight image
		highlighted=loadImage(path);
		return this;
	}

	public Ui_Button setPressedImg(String path){//change the pressed image
		pressed=loadImage(path);
		return this;
	}
	public Ui_Button setDissabledImg(String path){//change the dissable image
		dissabled=loadImage(path);
		return this;
	}
		public Ui_Button setButtonImg(String path){//change the unpressed image
		tile=loadImage(path);
		return this;
	}

	Ui_Button activate(){//untested, I probiably will never use these
		state.set(2,false);
		return this;
	}

	Ui_Button deactivate(){//untested, I probiably will never use these
		state.set(2,true);
		return this;
	}
  Ui_Button hide(){
     state.set(0,false);
     return this;
  }
}