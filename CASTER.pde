/** base program to run test_environment
this depends on all implimented functions of all implimented classes in some way
this is heavily reliant much of on processing
*/
//version: INDEV-18w26a
//https://github.com/Jesse-McDonald/CASTER
EMImage img;//global because so many things need it
Ui ui;
int RADIO_INDEX=1;//constants to keep track of ui elements
int ERASER=2;
boolean PAINTING=false;

int snapFrameCounter=0;//counter for the frames
int snapFrames=100;//number of frames before auto saving a snap, in theory at 600 it should save every 10 seconds or so and populate the 100 deep buffer at 16 minutes of continuous drawing
//experimentation showes that 100 frames while drawing is about 4 seconds or so due to frame lag, and should fill the buffer in 8 minutes
//finds the largest number, and the smallest number given to it and returns the number between the two

//finds the largest number and the smallest number given to it, then returns the number between the other number
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
//PrintWriter output;
void settings()
{
  size(2000,1000);//window size
  noSmooth();//without this line, the picture will be smoothed as we zoom in, great for zooming pictures and not having them get pixilated.... but we want pixilated
  
}
void setup(){//setup the window
  //output = createWriter("log.txt");//not sure we need a log file right now
	frameRate(60);
	
	EMStack stack=new EMStack();//get the stack ready
	//stack.add(createImage(0,0,ARGB));//get ANYTHING on that stack before we try to draw it
	img=new EMImage(stack);//build an EMImage around that stack
	surface.setResizable(true);//allow the window to be resized
	selectInput("Select an image in the Stack","load");//trigger stack load
	ui=buildUi();
	
}

void draw(){
	background(50);//set background to non discript gray
  if(PAINTING){
   img.brush.paint(img); 
   snapFrameCounter++;
   //println(snapFrameCounter);
   if(snapFrameCounter%snapFrames==0){
     //println("snap");
     img.snap(); 
   }
  }
	img.draw(this);//draw the image
	stroke(0,0,255,100);//set stroke to blue
	line(width/2,0,width/2,height);//draw center lines
	line(width,height/2,0,height/2); 
	ui.draw();//draw ui on top
  //text(frameRate,width/2,height/2);
   if(img.img.files!=null){//hard code in file loading bar because I didnt feel like trying to shove it somewhere
      noStroke();
      fill(200,200,150,200);
      rect(width/4-10,0,width/2+20,60);
      String lable="Loading Image "+img.img.files[img.img.progress]+"("+img.img.progress+"/"+img.img.files.length+")";
      fill(0);
      text(lable,(width-textWidth(lable))/2,20);
      fill(255,0,0);
      rect(width/4,40,(width/2*img.img.progress/(float)img.img.files.length),10);
  }
  //println(img.brush.getSize());
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
boolean SHIFT_DOWN;
boolean CTRL_DOWN;
void keyTyped(){//key type handler, obsolete brush resizing
	if (key=='-'){
		img.brush.decrease(2);
	}else if(key=='+'){
		img.brush.increase(2);
//ok, riddle me this... if the ctrl key is not pressed, pressing z give 'z' (122) and 'Z' (90) if shift is also pressed
//yet if I press the ctrl key pressing z gives 26 regardless of if shift is also pressed...
//who made that decision? I mean sure, I could in theory detect ctrl+z by testing for 26, but take testing for ctrl j, 
//ctrl j is 10, normaly it is (106), now you might not notice a problem, but the return key (without ctrl) is also 10,
//and ctrl enter is also 10... so what this means is that by modifieng key input with ctrl, YOU HAVE 100% DEFEATED ANY HOPE
//OF GOOD KEYBOARD INPUT DAMN IT!!!!!! PICK ONE (THE FIRST ONE) DONT MODIFY KEY VALUES WHEN CTRL IS PRESSED *OR* MODIFY ALL KEY VALUES WHEN CTRL IS PRESSED!!!!!!!!!!!
//the way it is right now makes no sense in any way, and it makes trying to detect a specific combo of keys even harder.
//never mind that I cant easily test if ctrl and shift are held down, but DANM IT you didnt have to make it worse.
//now there is a part of my mind that will always worry that there is an accidental sequence of key presses you can make that
//will trigger undos or redos without you expecting it
	}else if(key==26&&CTRL_DOWN&&!SHIFT_DOWN){//ctrl z
    img.undo();
  }else if(((key==26&&SHIFT_DOWN)||key==25)&&CTRL_DOWN){//ctrl shift z or ctrl y
    img.redo();
  }
  //println(CTRL_DOWN);
  //println((int)key);
}

void mousePressed(){//mouse pressed handler
	boolean onUi=ui.onUi();
	if (mouseButton==LEFT&&!onUi){//theoretically we could also handle button presses here.... but there is no mechanic for it in Ui_Element and button already handles it so there is no need
		img.brush.paint(img);//lay down paint, this would other wise not happen unless the mouse was moved afterwards making placing a single shape hard to imposible
	  PAINTING=true;
    snapFrameCounter=0;//start the snap counter
  }
}

void mouseReleased(){//mouse pressed handler
  //boolean onUi=ui.onUi();
  //if (mouseButton==LEFT&&!onUi){//turn off painter when mouse un pressed
      PAINTING=false;//turns out we wanted to do this even if we where on the ui
      img.snap();
  //}
  
  

}

void keyPressed(){//key press handler
	if(key==CODED&&keyCode==ALT){//eraser set on alt
		((Ui_Button)ui.getId("eraser")).state.set(0,true);
	}else if(key==CODED&&keyCode==SHIFT){
    SHIFT_DOWN=true;
  }else if(key==CODED&&keyCode==CONTROL){
    CTRL_DOWN=true;
    
  }
}

void keyReleased(){//key release handler
	if(key==CODED&&keyCode==ALT){//eraser clear on alt release
		((Ui_Button)ui.getId("eraser")).state.set(0,false);
	}  else if(key==CODED&&keyCode==SHIFT){
    SHIFT_DOWN=false;
  }else if(key==CODED&&keyCode==CONTROL){
    CTRL_DOWN=false;
  }
}

void mouseWheel(MouseEvent event){//mouse scrole handler
	if(event.isControlDown()){//there is this handy function already build for detecting controle pressed :) how nice
		img.brush.changeSize(int(2*event.getAmount()));//change shape size, and rember, keep it even
	}else{
		img.changeLayer(event.getAmount());//change layer
	}
}
