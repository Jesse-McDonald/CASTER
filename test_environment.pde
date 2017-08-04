/** base program to run test_environment
this depends on all implimented functions of all implimented classes in some way
this is heavily reliant much of on processing
*/
//version INDEV-B (INDEV-17w31a)
EMImage img;//global so they dont change, as they never should
Ui ui;
int RADIO_INDEX=1;//constants to keep track of ui elements
int ERASER=2;
boolean PAINTING=false;
//finds the largest number, and the smallest number given to it and returns the number between the two
float range(float a, float b, float c){
	float minV=min(a,b,c);
	float maxV=max(a,b,c);
	float inV=a+b+c-minV-maxV;//clever way to find the unused variable, this way the 2 that have been used cancel out
	float ret = max(minV,inV);
	ret=min(ret,maxV);
	return ret;

}

void load(File selection){// this is the handler for the load event
	if(selection!=null){
		img=new EMImage(new EMStack(selection.getAbsolutePath()));
	}
}

void setup(){//setup the window
  
	frameRate(60);
	size(2000,1000);//window size
	EMStack stack=new EMStack();//get the stack ready
	stack.add(createImage(0,0,ARGB));//get ANYTHING on that stack before we try to draw it
	img=new EMImage(stack);//build an EMImage around that stack
	surface.setResizable(true);//allow the window to be resized
	selectInput("Select an image in the Stack","load");//trigger stack load
	ui=buildUi();
	noSmooth();//without this line, the picture will be smoothed as we zoom in, great for zooming pictures and not having them get pixilated.... but we want pixilated
	
}

void draw(){
	background(50);//set background to nondiscript gray
  if(PAINTING){
   img.brush.paint(img); 
  }
	img.draw();//draw the image
	stroke(0,0,255,100);//set stroke to blue
	line(width/2,0,width/2,height);//draw center lines
	line(width,height/2,0,height/2); 
	ui.draw();//draw ui on top
  //text(frameRate,width/2,height/2);
}

void mouseDragged(){//mouse drag handler
	boolean onUi=ui.onUi();
	if (mouseButton==CENTER&&!onUi){//dont do anything if we are on the ui
		//move image
		img.move(mouseX-pmouseX,mouseY-pmouseY);
	}else if (mouseButton==RIGHT&&!onUi){
		//zoom image
		img.zoom(pmouseY-mouseY);
	}else if (mouseButton==LEFT&&!onUi){
		//paint image
		img.brush.paint(img);
	}
}

void keyTyped(){//key type handler, obsolete brush resizing
	if (key=='-'){
		img.brush.decrease(2);
	}else if(key=='+'){
		img.brush.increase(2);
	}
}

void mousePressed(){//mouse pressed handler
	boolean onUi=ui.onUi();
	if (mouseButton==LEFT&&!onUi){//theoretically we could also handle button presses here.... but there is no mechanic for it in Ui_Element and button already handles it so there is no need
		img.brush.paint(img);//lay down paint, this would other wise not happen unless the mouse was moved afterwards making placing a single shape hard to imposible
	  PAINTING=true;
  }
}

void mouseReleased(){//mouse pressed handler
  boolean onUi=ui.onUi();
  if (mouseButton==LEFT&&!onUi){//turn off painter when mouse un pressed
      PAINTING=false;
  }

}

void keyPressed(){//key press handler
	if(key==CODED&&keyCode==ALT){//eraser set on alt
		((Ui_Button)ui.getId("eraser")).state.set(0,true);
	}
}

void keyReleased(){//key release handler
	if(key==CODED&&keyCode==ALT){//eraser clear on alt release
		((Ui_Button)ui.getId("eraser")).state.set(0,false);
	}  
}

void mouseWheel(MouseEvent event){//mouse scrole handler
	if(event.isControlDown()){//there is this handy function already build for detecting controle pressed :) how nice
		img.brush.changeSize(int(2*event.getAmount()));//change shape size, and rember, keep it even
	}else{
		img.changeLayer(event.getAmount());//change layer
	}
}