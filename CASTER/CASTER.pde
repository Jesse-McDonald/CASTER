import codeanticode.tablet.*;//if there is an error on this line go to sketch->import Library...->add library then do a search for Tablet
//you want the library called "Tablet" by Andres Colubri
import java.awt.Toolkit;

/** base program to run CASTER
this depends on all implimented functions of all implimented classes in some way
this is heavily reliant much of on processing
*/

//version: INDEV-19w09a
String VERSION="INDEV-19w09a";

int tColor(int r,int g,int b, int a){//processings color function is not thread safe, not only that but it is final preventing me from overloading it, so I made my own that is thread safe
  return ((a&0xff)<<24)+((r&0xff)<<16)+((g&0xff)<<8)  +(b&0xff);
}
int tColor(int r,int g,int b){//processings color function is not thread safe, not only that but it is final preventing me from overloading it, so I made my own that is thread safe
  return tColor(r,g,b,255);
}
PImage imgFromFile(String path){//this exists for 1 and only 1 reason.  The idiots behind processing made it in such a way that loadImage only works if it is ran from the parrent PApplet, all other usages fail
//so, if I call it from anywhere else it just does not work.  This wraper exists so I can call it from any where without it not working
  return loadImage(path); 
}

import codeanticode.tablet.*;
Binding<Integer> sizeSlider;
float PPI=93;//apparently not even your os knows the true value of this number, so we just have to wing it, make this nubmer configurable in settings at some point
Tablet tablet;
//https://github.com/Jesse-McDonald/CASTER
EMImage img;//global because so many things need it
//Ui ui;
boolean PAINTING=false;
boolean usingPenErraser=false;
SideBar sidebar;
Visulization3D view3D;
int snapFrameCounter=0;//counter for the frames
int snapFrames=100;//number of frames before auto saving a snap, in theory at 600 it should save every 10 seconds or so and populate the 100 deep buffer at 16 minutes of continuous drawing
//experimentation showes that 100 frames while drawing is about 4 seconds or so due to frame lag, and should fill the buffer in 8 minutes
//finds the largest number, and the smallest number given to it and returns the number between the two
 //PrintWriter output;
//finds the largest number and the smallest number given to it, then returns the number between the other number
ProgramSettings programSettings;
float range(float a, float b, float c){
	float minV=min(a,b,c);
	float maxV=max(a,b,c);
	float inV=a+b+c-minV-maxV;//clever way to find the unused variable, this way the 2 that have been used cancel out
	float ret = max(minV,inV);
	ret=min(ret,maxV);
	return ret;

}
void objSavePasser(File pass){
   if (pass != null) {
    view3D.saveHandler(pass);
   }
}
void load(File selection){// this is the handler for the load event
  if(selection!=null){
    load(selection.getAbsolutePath());
	}
}
void load(String path){
    int dot=path.lastIndexOf('.');
    String ext="";
    if(dot>=0){
      ext=path.substring(dot ,path.length()).toLowerCase();
    }
    if(ext.equals(".png")){
      img.changeStack(new EMStack(path));
      img.img.launch();//start thread stack 
    }else if(ext.equals(".caster")){
      img.project=new EMProject(path);
       //open project file 
       programSettings.lastProject=path;
       programSettings.save();
       
       //save it for auto load
       //auto load progress if possible
       File dir=new File(img.project.stackPath);
       if(dir.exists()){
         load(img.project.stackPath+"/"+img.project.stackTopName);
       }
       File overlay=new File(img.project.lastOverlay);
       if(overlay.exists()){
          load(img.project.lastOverlay);
       }
    }else if(ext.equals(".jemo")){
      img.loadOverlay(path);
      //open overlay file
    }
}
import javafx.stage.Screen ;
//PrintWriter output;
void autoSave(){//calls various autosaves, does not save overlay (I think) I may change it to write a change cache for recovery later
  if(!img.project.path.equals("")){
    img.saveProject(img.project.path); 
  }
  programSettings.lastProject=img.project.path;
  programSettings.save();
}
void settings()
{
  programSettings =new ProgramSettings("settings.json");
  PPI=programSettings.monitorPPI;//we have used this so much I dont feel like replacing all useages
  size(2000,1000);//window size
  noSmooth();//without this line, the picture will be smoothed as we zoom in, great for zooming pictures and not having them get pixilated.... but we want pixilated
}

void setup(){//setup the window
 //output = createWriter("log.txt");//not sure we need a log file right now
	frameRate(60);
  tablet = new Tablet(this);
	img=new EMImage();//build an EMImage
	surface.setResizable(true);//allow the window to be resized
	if(programSettings.autoOpen){
    
    if(!programSettings.lastProject.equals("")){
      File temp=new File(programSettings.lastProject);
      if(temp.exists()){
        load(programSettings.lastProject);
      }
    }
  }//selectInput("Select an image in the Stack","load");//trigger stack load
  //img=new EMImage(new EMStack("D:\\B1run02_png\\B1_Run02_BSED_slice_0000.png"));//temp speed load
	//ui=buildUi(this);
  String[] args={""};
  sizeSlider=new Binding<Integer>(9);
  sidebar=new SideBar();
  PApplet.runSketch(args,sidebar);
  
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
  strokeWeight(1);
	line(width/2,0,width/2,height);//draw center lines
	line(width,height/2,0,height/2); 
	//ui.draw();//draw ui on top
  //text(frameRate,width/2,height/2);
   if(img.img.files!=null&&img.img.progress<img.img.files.length){//hard code in file loading bar because I didnt feel like trying to shove it somewhere
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

  if(tablet.getPenKind()==Tablet.STYLUS){
    if(tablet.isRightDown()){//move
      img.move(mouseX-pmouseX,mouseY-pmouseY);
    }else if(tablet.isCenterDown()){//zoom
      img.zoom(pmouseY-mouseY);
    }else if(tablet.isLeftDown()){//paint
      img.brush.paint(img);
    }
  }else if(tablet.getPenKind()==Tablet.ERASER){
      img.brush.erase=true;//go directly to the brush, we dont need a button indicator
      usingPenErraser=true;
      img.brush.paint(img);
  }else{//no pen tablet or user is using a mouse	
    boolean onUi=false;//ui.onUi();//the UI has been moved to a different window so this is not a thing anymore
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
}
boolean SHIFT_DOWN;
boolean CTRL_DOWN;
void keyTyped(){//key type handler, for wacom tablet ease of resizing and layer change and redo
	if (key=='-'){
    sizeSlider.set(sizeSlider.stored-1);
		//img.brush.decrease(2);
	}else if(key=='+'){
    sizeSlider.set(sizeSlider.stored+1);
		//img.brush.increase(2);
  
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
void startPainting(){
      img.brush.paint(img);//lay down paint, this would other wise not happen unless the mouse was moved afterwards making placing a single shape hard to imposible
      PAINTING=true;
      snapFrameCounter=0;//start the snap counter
}
void mousePressed(){//mouse pressed handler
	boolean onUi=false;//ui.onUi();//the UI has been moved to a different window so this is not a thing anymore
  if(tablet.getPenKind()==Tablet.STYLUS){
    if(tablet.isRightDown()||tablet.isCenterDown()){//we dont do anything with these, but we dont want to paint in this case
  
    }else if(tablet.isLeftDown()){//paint
      img.brush.sendPressure(tablet.getPressure());
      startPainting();
    }
  }else if(tablet.getPenKind()==Tablet.ERASER){
    img.brush.erase=true;//go directly to the brush, we dont need a button indicator
    usingPenErraser=true;
  }else{//no pen tablet or user is using a mouse
  	if (mouseButton==LEFT&&!onUi){//theoretically we could also handle button presses here.... but there is no mechanic for it in Ui_Element and button already handles it so there is no need
  		img.brush.sendPressure(1);
      startPainting();
    }
  }
}

void mouseReleased(){//mouse pressed handler
  //boolean onUi=ui.onUi();
  //if (mouseButton==LEFT&&!onUi){//turn off painter when mouse un pressed
      PAINTING=false;//turns out we wanted to do this even if we where on the ui
      img.snap();
  //}
  if(usingPenErraser){
    img.brush.erase=false;
    usingPenErraser=false;
    ((Ui_Button)sidebar.ui.getId("eraser")).state.set(0,false);
  }
  

}

void keyPressed(){//key press handler
	if(key==CODED&&keyCode==ALT){//eraser set on alt
		((Ui_Button)sidebar.ui.getId("eraser")).state.set(0,true);
	}else if(key==CODED&&keyCode==SHIFT){
    SHIFT_DOWN=true;
  }else if(key==CODED&&keyCode==CONTROL){
    CTRL_DOWN=true;
  }else if (key==CODED&&keyCode==UP){
    img.changeLayer(1);
  }else if(key==CODED&&keyCode==DOWN){
    img.changeLayer(-1);  
  }
}

void keyReleased(){//key release handler
	if(key==CODED&&keyCode==ALT){//eraser clear on alt release
		((Ui_Button)sidebar.ui.getId("eraser")).state.set(0,false);
	}  else if(key==CODED&&keyCode==SHIFT){
    SHIFT_DOWN=false;
  }else if(key==CODED&&keyCode==CONTROL){
    CTRL_DOWN=false;
  }
}

void mouseWheel(MouseEvent event){//mouse scrole handler
	if(event.isControlDown()){//there is this handy function already build for detecting controle pressed :) how nice
    sizeSlider.set(int(event.getAmount())+sizeSlider.stored);
		//img.brush.changeSize(int(2*event.getAmount()));//change shape size, and rember, keep it even
    
	}else{
		img.changeLayer(event.getAmount());//change layer
	}
}
