import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import codeanticode.tablet.*; 
import java.awt.Toolkit; 
import javafx.stage.Screen; 
import codeanticode.tablet.*; 
import javax.swing.JFrame; 
import java.io.*; 
import java.nio.ByteBuffer; 
import java.nio.ByteBuffer; 
import java.security.SecureRandom; 
import javax.xml.bind.DatatypeConverter; 
import static javax.swing.JOptionPane.*; 
import java.util.*; 
import java.nio.ByteBuffer; 
import java.util.BitSet; 
import java.util.BitSet; 
import java.util.BitSet; 
import java.util.Arrays; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class CASTER extends PApplet {

//if there is an error on this line go to sketch->import Library...->add library then do a search for Tablet
//you want the library called "Tablet" by Andres Colubri


/** base program to run CASTER
this depends on all implimented functions of all implimented classes in some way
this is heavily reliant much of on processing
*/

//version: INDEV-19w44a
String VERSION="INDEV-19w44a";

public int tColor(int r,int g,int b, int a){//processings color function is not thread safe, not only that but it is final preventing me from overloading it, so I made my own that is thread safe
  return ((a&0xff)<<24)+((r&0xff)<<16)+((g&0xff)<<8)  +(b&0xff);
}
public int tColor(int r,int g,int b){//processings color function is not thread safe, not only that but it is final preventing me from overloading it, so I made my own that is thread safe
  return tColor(r,g,b,255);
}
public PImage imgFromFile(String path){//this exists for 1 and only 1 reason.  The idiots behind processing made it in such a way that loadImage only works if it is ran from the parrent PApplet, all other usages fail
//so, if I call it from anywhere else it just does not work.  This wraper exists so I can call it from any where without it not working
  return loadImage(path); 
}


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
//Ui_Slider stackPos;//I was going to put this inside EMStack, but I really, REALLY want to keep EMStack clean of my hacky UI 
public float range(float a, float b, float c){
	float minV=min(a,b,c);
	float maxV=max(a,b,c);
	float inV=a+b+c-minV-maxV;//clever way to find the unused variable, this way the 2 that have been used cancel out
	float ret = max(minV,inV);
	ret=min(ret,maxV);
	return ret;

}
public void objSavePasser(File pass){
   if (pass != null) {
    view3D.saveHandler(pass);
   }
}
public void load(File selection){// this is the handler for the load event
  if(selection!=null){
    load(selection.getAbsolutePath());
	}
}
public void load(String path){
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
       if(img.project.lastOverlay!=null){
         File overlay=new File(img.project.lastOverlay);
         if(overlay.exists()){
            load(img.project.lastOverlay);
         }
       }
    }else if(ext.equals(".jemo")){
      img.loadOverlay(path);
      //open overlay file
    }
}

//PrintWriter output;
public void autoSave(){//calls various autosaves, does not save overlay (I think) I may change it to write a change cache for recovery later
  if(!img.project.path.equals("")){
    img.saveProject(img.project.path); 
  }
  programSettings.lastProject=img.project.path;
  programSettings.save();
}
public void settings()
{
  programSettings =new ProgramSettings("settings.json");
  PPI=programSettings.monitorPPI;//we have used this so much I dont feel like replacing all useages
  size(2000,1000);//window size
  noSmooth();//without this line, the picture will be smoothed as we zoom in, great for zooming pictures and not having them get pixilated.... but we want pixilated
}

public void setup(){//setup the window
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
  //stackPos=new Ui_Slider();
  {//pos slider,
    PImage tImg=new PImage(100,40,ARGB);
    tImg.loadPixels();
    for(int i=0;i<tImg.pixels.length;i++){
      tImg.pixels[i]=tColor(150,150,100); 
    }
    tImg.updatePixels();
    Ui_Slider build=new Ui_Slider(.3f,7.7f,2, tImg);
    build.onChange=new SizeSlider();
    build.minV=0;
    build.maxV=100;
    build.boundValue=sizeSlider;
  }
  //stackPos.dm=this;
}

public void draw(){
  
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
  fill(0,0,255);
  textSize(20);
  text(img.layer,width-100,height-10);
  //if(img.size()>0){
  //  stackPos.draw();
  //}
  //println(img.brush.getSize());
}

public void mouseDragged(){//mouse drag handler

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
public void keyTyped(){//key type handler, for wacom tablet ease of resizing and layer change and redo
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
public void startPainting(){
      img.brush.paint(img);//lay down paint, this would other wise not happen unless the mouse was moved afterwards making placing a single shape hard to imposible
      PAINTING=true;
      snapFrameCounter=0;//start the snap counter
}
public void mousePressed(){//mouse pressed handler
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

public void mouseReleased(){//mouse pressed handler
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

public void keyPressed(){//key press handler
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

public void keyReleased(){//key release handler
	if(key==CODED&&keyCode==ALT){//eraser clear on alt release
		((Ui_Button)sidebar.ui.getId("eraser")).state.set(0,false);
	}  else if(key==CODED&&keyCode==SHIFT){
    SHIFT_DOWN=false;
  }else if(key==CODED&&keyCode==CONTROL){
    CTRL_DOWN=false;
  }
}

public void mouseWheel(MouseEvent event){//mouse scrole handler
	if(event.isControlDown()){//there is this handy function already build for detecting controle pressed :) how nice
    sizeSlider.set(PApplet.parseInt(event.getAmount())+sizeSlider.stored);
		//img.brush.changeSize(int(2*event.getAmount()));//change shape size, and rember, keep it even
    
	}else{
		img.changeLayer(event.getAmount());//change layer
	}
}
class Binding<T>{
  T stored;
  Binding(T x){
    stored=x; 
  }
  public T get(){
    return stored; 
  }
   public void set(T x){
     stored=x; 
   }
}
/**
Brush is designed to provide a simple brush to draw with, brush depends on having
a global EMImage called this.img for some of its functionality and should only exist
as a member of that object
Brush is now polymorphic, new brushes should simply extend Brush and replace img.brush when in use, this replaces mode in a more elegant manner
Brush should only ever change the overlay, never the actual image
Brush requires access to int x, int y, Pixel(int x, int y, color), and color c, from the Pixel
float getZoom(), Pixel getPixel(int layer, int x, int y),color get(int layer, int x, int y), int layer, and EMOverlay overlay from EMImage (this.img)
void set(int layer,int x,int y,color), get(int layer,int x,int y) from EMOverlay

Brush depends on color, PImage,       color g.strokeColor, float g.strokeWeight, color g.fillColorvoid, line(int x, int y, int x2, int y2), void ellipse(int x, int y, int width, int height), void PImage.resize(int w,int h), color PImage.get(int x, int y), void PImage.set(int x,int y, color), PImage createImage(int w, int h, int colorMode),PImage loadImage(String path), image(PImage this.img, int xPos, int yPos, int xScale, int yScale), image(PImage this.img, int xPos, int yPos), color(int red, int green, int blue, int alpha) from processing 
also depends on "ui/bucket.png" in program dir
*/
//TODO: remove dependance on golbal this.img
class Brush{
	public int size;//odd numbers work best due to always having a single "center" pixel, there is a very good reason that this is a float, but I don’t remember what it is
	protected PImage shape;//used to track the current brush shape
	protected int c;//used to track current brush color
	public boolean erase=false;//if true a bush should generally erase instead of fill during paint()
  public float pressure;//pressure from a wacom tablet, if not used set to 0
	EMImage img;
        public Brush(){
            this(color(0,0,0,0), (EMImage)null,9);//please never try to use this constructor, java just instits we have it so here is something
            pressure=0;
        }
	public Brush(int col,EMImage image,int s){
                this.img=image;
                this.setSize(s);
		            c=col;
		            update();//update does almost everything we would want the constructor to do anyway
	}

	public Brush draw(){//this draws the shape of the brush to the screen, generally should not update overlay unless there is a multi-frame process
		//this should be called every frame
		float zoom=this.img.getZoom();
		return this; 
	}

  public Pixel brushPosition(){//calculates the offset to the top left corner of the image based on the pixel under the mouse
    float zoom=this.img.getZoom();
    return this.img.getPixel(PApplet.parseInt(mouseX-shape.width/2.0f*zoom+zoom/2),PApplet.parseInt(mouseY-shape.width/2.0f*zoom+zoom/2));
  }

	public float grayVal(int c){//this averages the RGB values of a given color to determine its grayscale value
		return ((c >> 16 & 0xFF) + (c >> 8 & 0xFF) + (c & 0xFF))/3.0f;//extract and average rgb values
	}

	public Brush setSize(int s){//sets the size, this should be odd numbers for best performance
		//after brush is resized it updates the shape to accurately reflect the change
		this.size=max(1,s);
		this.update();
		return this;
	}

	public Brush paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
		return this;
	}

	public Brush increase(int n){//increases brush size by n, note that n should be even so that size always remains odd
		return setSize(size+n);
	}

	public Brush changeSize(int n){//no real difference from increase, just feels different when you use it
		setSize(size+n);
		return this; 
	}

	public Brush decrease(int n){//decreases brush size by n, note that n should be even so that size always remains odd
		return setSize(size-n);
	}
  public Brush sendPressure(float in){
    //handle pressure input later, not entirely sure what do do with it
    return this;
  }
	public Brush update(){//updates the shape of the brush, this should only be called when there is a reasonable certainty that the brush has changed in some way
		//as it can be a computationally complex operation
                 shape=createImage(1,1,ARGB);//incase no shape is created for a brush in specific it will still have an image, shockingly this does need to be 1,1 not 0,0
		return this;
	}
        public int getSize(){
         return size; 
        }
        public Brush eStop(){//usualy never used, this is included for if a brush (ie flood fill) has an emergency stop condition that might need to happen
          return this; 
        }
}
class BrushBlackHole extends Brush{
    int undoFrames=0;
      public BrushBlackHole(int col,EMImage image,int s){
        super(col,image,s);
        shape=loadImage("ui/blackHoleIcon.png");//load up the bucket incase of flood fill
        shape.resize(128,128);
    }
  ArrayList<Pixel> floodFillBackup=new ArrayList<Pixel>();//used to store pixels for processes taking more than 1 frame
  public Brush draw(){//this draws the shape of the brush to the screen, generally should not update overlay unless there is a multi-frame process
  
 
    //this should be called every frame
    float zoom=this.img.getZoom();
    Pixel pixel = brushPosition();
    
      image(shape,mouseX-shape.width/2,mouseY-shape.height/2); 
      floodFillUpdate();
      if(erase){//clears ongoing flood fill in case of overflow
        floodFillBackup=new ArrayList<Pixel>();
      }
    return this; 
  }
  

  public BrushBlackHole paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    Pixel pixel= brushPosition();
    this.img=img;
    float zoom=this.img.getZoom();
    floodFill(this.img.getPixel(PApplet.parseInt(mouseX-zoom/2),PApplet.parseInt(mouseY-zoom/2)));//not sure why I am doing this instead of just passing pixel in, will test when not documenting
    return this;
  }

  public BrushBlackHole floodFill(Pixel pixel){//add initial flood fill pixel
    floodFillBackup.add(pixel);
    return this;
  }

  public BrushBlackHole floodFillUpdate(){//expand the flood fill
    ArrayList<Pixel> pixels=floodFillBackup;
    int ittr=0;
    if(!pixels.isEmpty()){
       undoFrames++;
       if(undoFrames>100){
         img.snap(); 
         undoFrames=0;
       }
    }else if(undoFrames>0){
        img.snap(); 
        undoFrames=0;
    }
    while(!pixels.isEmpty()&ittr<pixels.size()*size/5.f){//flood fill ends when there are no non c colored pixels to spread to
      Pixel p=pixels.get(0);
      pixels.remove(0);
      if (this.img.overlay.get(this.img.layer,p.x,p.y)==c){//its flood fill, but anti, this and the next line is all that needs changed
        this.img.overlay.set(this.img.layer,p.x,p.y,0);

        pixels.add(new Pixel(p.x+1*PApplet.parseInt(p.x<this.img.overlay.width-1),p.y,c));//don’t worry, pixel is never checked for color anyway so we can get away with this short cut
        pixels.add(new Pixel(p.x-1*PApplet.parseInt(p.x>0),p.y,c));
        pixels.add(new Pixel(p.x,p.y+1*PApplet.parseInt(p.y<this.img.overlay.height-1),c));
        pixels.add(new Pixel(p.x,p.y-1*PApplet.parseInt(p.y>0),c));
        ittr++;
      }
    }
    floodFillBackup=pixels;//I don’t know why I don’t edit floodFillBackup directly, but for some reason I implemented this way sooooo
    return this;
  }

  public BrushBlackHole update(){//updates the shape of the brush, this should only be called when there is a reasonable certainty that the brush has changed in some way
    //as it can be a computationally complex operation

    return this;
  }
       public Brush eStop(){//clear the list in an emergency
          if(floodFillBackup.size()>0){
            img.snap();//commit changes to undo record
          }
          floodFillBackup=new ArrayList<Pixel>();
          
          return this; 
        }
}
class BrushCircle extends Brush{
    public BrushCircle(int col,EMImage image,int s){
      super(col,image,s);
    }
    public BrushCircle draw(){//this draws the shape of the brush to the screen, generally should not update overlay unless there is a multi-frame process
    //this should be called every frame
    float zoom=this.img.getZoom();
    Pixel pixel = brushPosition();
    //draw shape centered on mouse
    image(shape,(pixel.x*zoom+this.img.offsetX),(pixel.y*zoom+this.img.offsetY),shape.width*zoom,shape.height*zoom); 
    return this; 
  }
    public BrushCircle paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    Pixel pixel= brushPosition();
    this.img=img;
    for (int x=0;x<this.img.overlay.width&&x<shape.width;x++){
        for (int y=0;y<this.img.overlay.width&&y<shape.width;y++){
          if(erase){//determine if ink is to be removed or layed down
            if(shape.get(x,y)!=color(0,0,0,0)){
              if(this.img.overlay.get(this.img.layer,pixel.x+x,pixel.y+y)==c){//only errase the color that the brush is
                this.img.overlay.set(this.img.layer,pixel.x+x,pixel.y+y,color(0,0,0,0));//note iff a pixel is non transparent it will remove set the overlay transparent
              }
            }
          }else{
            if(shape.get(x,y)!=color(0,0,0,0)){//this prevents brushes from having visible edges
              this.img.overlay.set(this.img.layer,pixel.x+x,pixel.y+y,shape.get(x,y));
            }
          }
        }  
      }
    return this;
  }
  
  public BrushCircle update(){//updates the shape of the brush, this should only be called when there is a reasonable certainty that the brush has changed in some way
    //as it can be a computationally complex operation
      shape=createImage((int)size,(int)size,ARGB);    
      float ss=size*size/4;//callculate r^2 from D
      for(int x=0;x<shape.width;x++){
        for(int y=0;y<shape.height;y++){
          float posX=x-shape.width/2;
          float posY=y-shape.height/2;
          if (posX*posX+posY*posY<ss){//good old pathagrean circle from inequality for filling a circle
            shape.set(x,y,c);
          }
        }
      }
    return this;
  }
  
}
class BrushDiamond extends Brush{
      public BrushDiamond(int col,EMImage image,int s){
      super(col,image,s);
    }
    public BrushDiamond draw(){//this draws the shape of the brush to the screen, generally should not update overlay unless there is a multi-frame process
    //this should be called every frame
    float zoom=this.img.getZoom();
    Pixel pixel = brushPosition();
    //draw shape centered on mouse
    image(shape,(pixel.x*zoom+this.img.offsetX),(pixel.y*zoom+this.img.offsetY),shape.width*zoom,shape.height*zoom); 
    return this; 
  }
    public BrushDiamond paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    Pixel pixel= brushPosition();
    this.img=img;
    for (int x=0;x<this.img.overlay.width&&x<shape.width;x++){
        for (int y=0;y<this.img.overlay.width&&y<shape.width;y++){
          if(erase){//determine if ink is to be removed or layed down
            if(shape.get(x,y)!=color(0,0,0,0)){
              if(this.img.overlay.get(this.img.layer,pixel.x+x,pixel.y+y)==c){//only errase the color that the brush is
                this.img.overlay.set(this.img.layer,pixel.x+x,pixel.y+y,color(0,0,0,0));//note iff a pixel is non transparent it will remove set the overlay transparent
              }
            }
          }else{
            if(shape.get(x,y)!=color(0,0,0,0)){//this prevents brushes from having visible edges
              this.img.overlay.set(this.img.layer,pixel.x+x,pixel.y+y,shape.get(x,y));
            }
          }
        }  
      }
    return this;
  }
  
  public BrushDiamond update(){//updates the shape of the brush, this should only be called when there is a reasonable certainty that the brush has changed in some way
    //as it can be a computationally complex operation
      shape=createImage((int)size,(int)size,ARGB);
      for(int x=0;x<shape.width;x++){
        for(int y=0;y<shape.height;y++){
          float posX=x-shape.width/2;
          float posY=y-shape.height/2;
          if (abs(posX)+abs(posY)<size/2){//this took some head scratching, essentially this is the exact same as a circle... just don’t square every term
            shape.set(x,y,c);
          }
        }
      }
    return this;
  }
  
}
/**

BrushEdgeFollowing is designed to provide a simple BrushEdgeFollowing to draw with, BrushEdgeFollowing depends on having
a global EMImage called this.img for some of its functionality and should only exist
as a member of that object
BrushEdgeFollowing should only ever change the overlay, never the actual image
BrushEdgeFollowing requires access to int x, int y, Pixel(int x, int y, color), and color c, from the Pixel
float getZoom(), Pixel getPixel(int layer, int x, int y),color get(int layer, int x, int y), int layer, and EMOverlay overlay from EMImage (this.img)
void set(int layer,int x,int y,color), get(int layer,int x,int y) from EMOverlay

BrushEdgeFollowing depends on color, PImage,       color g.strokeColor, float g.strokeWeight, color g.fillColorvoid, line(int x, int y, int x2, int y2), void ellipse(int x, int y, int width, int height), void PImage.resize(int w,int h), color PImage.get(int x, int y), void PImage.set(int x,int y, color), PImage createImage(int w, int h, int colorMode),PImage loadImage(String path), image(PImage this.img, int xPos, int yPos, int xScale, int yScale), image(PImage this.img, int xPos, int yPos), color(int red, int green, int blue, int alpha) from processing 
also depends on "bucket.png" in program dir
*/
//TODO: remove dependance on golbal this.img

//This is needed to make and display new frames

class BrushEdgeFollowing extends Brush{
  
//ThirdApplet third = new ThirdApplet();//This creates the frame that will show the outline in 3D moved to CASTER
//EMOverlay[] overlayCopies = new EMOverlay[10]; //This is to make the undo button work properly, but it's not working just yet
//Pixel[] overlayCenters = new Pixel[10];
  boolean paintLock;
  String[] args = {"Edge Outlining Tools"}; // I don't understand why this is needed, I just know that it is.
  EdgeFinderSettings second;
  ColorPickerPointer colorPicker;
  float rayCastAngle=0;
  
  public BrushEdgeFollowing(int col,EMImage image,int s){
      super(col,image,s);
      second = new EdgeFinderSettings();//This crates the frame that will show the tools for the outliner
      colorPicker=new ColorPickerPointer();
      PApplet.runSketch(args, second);//Load and display the second pop up box, 
  }

  public BrushEdgeFollowing draw(){//this draws the shape of the BrushEdgeFollowing to the screen, generally should not update overlay unless there is a multi-frame process
    //this should be called every frame
    if(paintLock&&!mousePressed) paintLock=false;
    float zoom=this.img.getZoom();
    Pixel pixel = brushPosition();
    if(second.picker==0){
      image(shape,(pixel.x*zoom+this.img.offsetX),(pixel.y*zoom+this.img.offsetY),shape.width*zoom,shape.height*zoom); 
    }else{
      colorPicker.updateMask(img.getPixel(mouseX,mouseY).c);
      colorPicker.draw((mouseX),(mouseY));
    }
    return this; 
  }
  


  //This causes the EdgeFinderBrushEdgeFollowing to repeat a specifed number of times from the input box
  public BrushEdgeFollowing outlineRepeater(Pixel p, int counts, int prevsection, int lightest, int variation, double prevRadians, int repeats)
  {
    if (counts < repeats)
    {
      counts++;
      outlineBase(p, counts, prevsection, lightest, variation, prevRadians, repeats);
    }
    return this;
  }
  
  
  //This is where the EdgeFinderBrushEdgeFollowing starts working
  public BrushEdgeFollowing outlineStarter(int counts, Pixel p, int lightest, int variation, int repeats)//Send this up, down, left, and right only in outline starter? 
  {
    
    int Min = MinColor(p, lightest); //Finds the darkest pixel in the current area
    int[][] temp = FindPossibleMembrane(p, Min, lightest, variation); //Finds all pixles that are dark enough to be an object in the area
    int[][] white = FindNotMembrane(p, Min, variation, temp);//Identifies what is not an object in the area being searched
    int[][] black = GetMembrane(temp, white, p, lightest, variation);//Identifies the object that we are trying to locate
    membraneToOverlay(black, p, c); // Display the identified object
    if(repeats>0)
    {
      double radians = linearRegression(black, size); // Find the angle in radians of the line of best fit (based on what is the outlined object and what is not)
      for(int i = 0; i < 8; i++)
      { 
        int section = i; //The program doesn't know to start going in any particular direction, so one is given here
        double degree = Math.toDegrees((double)radians); //Convert radians to degrees
        degree = degreeVerifier(degree, section); //And verify the degree based on the given section, correcting where needed
        radians = Math.toRadians(degree); //Convert degrees to radians
        section = SectionFinder(degree, section);//and select the correct section based on the degree
        Pixel p2 = FindPixelForRecursion(radians, p, black, section, size, lightest, variation);//Locate a pixel in the direction being moved that is on the membrane (usually)
        int membraneCount = testArea(p2, lightest, variation);
        //print("Membrane count is: " + membraneCount + ".\n");
        if (membraneCount >= 10)
        {
          counts++;//Increment counts for our repeater
          
          ConnectTheDots(p, p2, black);
          
          outlineBase(p2, counts, section, lightest, variation, radians, repeats);//And call the main repeating function
        }
      }
    }
    return this;
  }
  
  //This is the main function of the Edge Finder Brush
  public BrushEdgeFollowing outlineBase(Pixel p, int counts, int prevSect, int lightest, int variation, double prevRadians, int repeats)
  {
    //print("The repeater is working.");
    int Min = MinColor(p, lightest);//Find the darkest pixel in the given area
    int[][] temp = FindPossibleMembrane(p, Min, lightest, variation);//Find objects in the given area
    int[][] white = FindNotMembrane(p, Min, variation, temp);//Find what is not objects in the given area
    int[][] black = GetMembrane(temp, white, p, lightest, variation);//And locate the object that we are trying to follow
    membraneToOverlay(black, p, c);//Display the outline
    
    double radians = linearRegression(black, size);//Find the degree in radians of the line of best fit
    radians  = radiansToSection(radians, prevSect);//And verify the degree based on the section we are moving from
    double degree = Math.toDegrees(radians);//Convert radians to degrees
    degree = degreeVerifier(degree, prevSect); //And verify the degree based on the previous section (This seems irrelevant but for some reason helps)
    radians = Math.toRadians(degree);//Convert degrees to radians
    int section = SectionFinder(degree, prevSect);//Find the section being moved into
    Pixel p2 = FindPixelForRecursion(radians, p, black, section, size, lightest, variation);//And locate a pixel in the direction we are moving that is on the membrane
    ConnectTheDots(p, p2, black);
    outlineRepeater(p2, counts, section, lightest, variation, radians, repeats);//Call the function to be repeated
    return this;
  }

  //This finds the darkest pixel within the current area being searched
  public int MinColor(Pixel p, int lightest)
  {
    int Min = 255;//starting with white because it is the brightest color
    for (int i=-size; i<size; i++)//Check each pixel in the box
    {
      for (int j=-size; j<size; j++)
      {
        Pixel pix = img.get(PApplet.parseInt(p.x+i),PApplet.parseInt(p.y+j));
        if (grayVal(pix.c) < Min)
        {
         Min = (int) grayVal(pix.c);//If the pixel is darker than the previous darkest pixel, replace it
        }
      }
     }
    if (Min > grayVal(lightest)){//Make sure that the darkest pixel isn't too light!
      Min = (int) grayVal(lightest);
    }
    return Min;//And return the darkest pixel
  }
  
  //This finds the sections within the current box that could be membrane
  public int[][] FindPossibleMembrane(Pixel p, int Min, int lightest, int variation)
  {
    int[][] temp = new int[size*2+1][size*2+1]; //create storage for the possible membrane
    temp = MatchingPixels(p, Min, temp, variation); //get any pixel that is within the right color range
    return FocusMembrane(temp, p, lightest, variation); //and bring the membrane into focus
  }

  //This finds all pixels within a specific color range within the current box
  public int[][] MatchingPixels(Pixel p, int Min, int[][] temp, int variation)
  {
    for (int i=-size; i<size; i++){//Check each pixel within the current box
      for (int j=-size; j<size; j++){
         Pixel pix=img.get(p.x+i, p.y+j); 
         if (Min+variation >= grayVal(pix.c)){ //and if it's color is within the acceptable range
             temp[i+size][j+size]=c;//color in the pixel for storage
         }else{
            temp[i+size][j+size]=color(0,0,0,0);//otherwise set it to blank
         }
      }
    }
    return temp;
  }
    
  //This takes the current objects within the box and helps focus them
  public int[][] FocusMembrane(int[][] temp, Pixel p, int lightest, int variation)
  {
    temp = RemoveOutliers(temp);//Remove any isolated pixels
    temp = MembraneFiller(temp);//Fill in any gaps in objects
    temp = WeedOutLightPixels(temp, p, lightest, variation); //and remove any pixels that are just too light to be anything
    return temp;
  }
  
  //This function removes any isolated pixels
  public int[][] RemoveOutliers(int [][]temp)
  {
    for (int i=1;i<temp.length-1;i++)//For every pixel in a given area
    { 
     for(int j=1;j<temp[i].length-1;j++)
     {
      if (temp[i][j] == c)//If that pixel is part of an object/membrane
      {   
       int count=0;
       for(int w=-1;w<=1;w++){
        for(int h=-1;h<=1;h++){
          if(temp[i+w][j+h]==c){
           count++;
          }
        }
       }
       if(count<=3)//And it is touching 3 or less other membrane/object sections, unmark it
       {
        temp[i][j]=color(0,0,0,0);
       }
      }
     }
    }
    //And repeat the process once more for touching one or less sections for those that got left out before
    for (int i=1;i<temp.length-1;i++){
       for(int j=1;j<temp[i].length-1;j++){
         int count=0;
         for(int w=-1;w<=1;w++){
          for(int h=-1;h<=1;h++){
            if(temp[i+w][j+h]==c){
             count++;
            }
          }
         }
         if(count<=1){
          temp[i][j]=color(0,0,0,0);
         }
       }
    }
    return temp;
  }
  
  //This function fills in any gaps left in objects
  public int[][] MembraneFiller(int[][] temp)
  {
    int[][] temp2 = new int[size*2+1][size*2+1];//create blank storeage for the added peices of object
    for (int i=1;i<temp.length-1;i++)//then for each pixel in the given area
    {
     for(int j=1;j<temp[i].length-1;j++)
     {
       int count=0;//count how many pixels that pixel is touching that are colored
       for(int w=-1;w<=1;w++)
       {
        for(int h=-1;h<=1;h++)
        {
          if(temp[i+w][j+h]==c)
          {
           count++;
          }
        }
       }
       if(count>=3)//and if that pixel is touching 3 or more colored pixels, color it in
       {
         temp2[i][j]=c;
       }
     }
    }
    for (int i=-size; i<size; i++)//Then add all the points in the spare storage into the primary storage
    {
      for (int j=-size; j<size; j++)
      {
         if(temp2[i+size][j+size]==c)
         {
           temp[i+size][j+size]=c;
         }
      }
    }
    return temp;
  }
  
  //This function removes pixels that are too light in color to be an object
  public int[][] WeedOutLightPixels(int[][] black, Pixel p, int lightest, int variation)
  {
    for (int i = -size; i <= size; i++)//for each pixel in a given area
    {
      for(int j = -size; j <= size; j++)
      {
        Pixel pix = img.get(PApplet.parseInt(p.x+i),(p.y+j));
        if (grayVal(pix.c) > grayVal(lightest) + grayVal(variation))//If that pixel is outside of the acceptable color range
        {
          black[i+size][j+size] = color(0,0,0,0);//unmark it
        }
      }
    }
    return black;
  } 
  
  //This function identifies what is not an object
  public int[][] FindNotMembrane(Pixel p, int Min, int variation, int[][] temp)
  {
    int[][] white = new int[size*2+1][size*2+1];// create blank storage for the new pixels
    white = WhiteSpaceFloodFill(white, temp);//select any segments that are not already identified as object(s)
    white = BadPixels(p, Min, white, variation);//and add any pixels that are too bright to be an object
    return white;
  }
  
  //This function selects anything that is not an object and marks it
  public int[][] WhiteSpaceFloodFill(int[][] white, int[][] object)
  {
    for (int i=0; i < size*2; i++)//for each pixel in a given area
    {
      for (int j=0; j <size*2; j++)
      {
        if (object[i][j] != c)//if the pixel is not marked as an object
        {
          white[i][j] = c;//mark it as not an object
        }
      }
    }
      return white;
  }

  //This function selects any pixel that can't be an object
  public int[][] BadPixels(Pixel p, int Min, int[][] white, int variation)
  {
    for (int i=-size; i<=size; i++){//for each pixel in a given area
      for (int j=-size; j<=size; j++){
         Pixel pix=img.get(p.x+i, p.y+j);
         if (Min + variation + (variation/3.0f) < grayVal(pix.c)){//if the pixel's color is too light, mark it
             white[i+size][j+size]=c;
         
         }  
      }
    }
    return white;
  }
  
  //This function selects the current object being followed
  public int[][] GetMembrane(int[][] temp, int[][] white, Pixel p, int lightest, int variation)
  {
    int[][] black = FocusMembrane(temp, p, lightest, variation);//focus the suspected membrane
    black = realMemFloodFill(temp, white, new Pixel(size, size, p.c));//and select only the area that is membrane
    black = WeedOutLightPixels(black, p, lightest, variation);//remove any pixels that are too light to be membrane
    return black;
  }
  
  //Flood fills the object that is currently being followed
  public int[][] realMemFloodFill(int[][] temp, int[][]white, Pixel onMembrane)
  {     
    ArrayList<Pixel> pixels = new ArrayList<Pixel>();//create storage for markers of known membrane peices
    pixels.add(onMembrane);//and add the one peice that we know is membrane (based on user click)
    onMembrane.c = color(0,0,0,255);
    while(!pixels.isEmpty())//As long as there is still a peice of membrane who's neighbors haven't been checked...
    {
      Pixel p = pixels.get(0);//Select and remove one pixel from storage and mark it with a special color
      pixels.remove(0);
      //Then for each pixel around the one being checked (staying within the current area as well)
      if (p.x+1 < size*2)
      {
        //If that pixel has not already been checked, and it is an object
        if ((temp[p.x+1][p.y] != color(0,0,0,255)) && (white[p.x+1][p.y] == color(0,0,0,0)))
        {
          temp[p.x+1][p.y]=color(0,0,0,255);
          pixels.add(new Pixel(p.x+1*PApplet.parseInt(p.x<2*size),p.y,c)); //Add that pixel to the storage of peices to be checked
        }
      }
      if (p.x-1 > 0)
      {
        if ((temp[p.x-1][p.y] != color(0,0,0,255)) && (white[p.x-1][p.y] == color(0,0,0,0)))
        {
          temp[p.x-1][p.y]=color(0,0,0,255);
          pixels.add(new Pixel(p.x-1*PApplet.parseInt(p.x>0),p.y,c));
        }
      }
      if (p.y + 1 < 2*size)
      {
        if ((temp[p.x][p.y+1] != color(0,0,0,255)) && (white[p.x][p.y+1] == color(0,0,0,0)))
        {
          temp[p.x][p.y+1]=color(0,0,0,255);
          pixels.add(new Pixel(p.x,p.y+1*PApplet.parseInt(p.y<2*size),c));
        }
      }
      if (p.y-1 > 0)
      {   
        if((temp[p.x][p.y-1] != color(0,0,0,255)) && (white[p.x][p.y-1] == color(0,0,0,0)))
        {
          temp[p.x][p.y-1]=color(0,0,0,255);
          pixels.add(new Pixel(p.x,p.y-1*PApplet.parseInt(p.y>0),c));
        }
      }
    }  
    int[][] black = new int[size*2+1][size*2+1];//Create a new blank storage to hold the current membrane peices
    for(int i2 = 0; i2 <= size*2; i2 ++)//then for each pixel in the current area
    {
      for(int j2 = 0; j2 <= size*2; j2++)
      {
        if(temp[i2][j2]==color(0,0,0,255))//If it has the special mark, mark it in the new lst
        {
          black[i2][j2]=c;
        }
        else
        {
          black[i2][j2] = color(0,0,0,0);
        }
      }
    }
    return black;
  }
  
  //This locates a pixel to be the center of the next box
  public Pixel FindPixelForRecursion(double radians, Pixel p, int[][] black, int section, int area, int lightest, int variation)
  {
    Pixel p2 = SectionsBy(p, radians, area); // locate a pixel in the direction being moved
    p2 = MembraneFinder(p2, p, black); //Then find the closest piece of membrane to it
    //If the best new pixel is the same as the old one...
    if (p.x == p2.x && p.y == p2.y)
    {
      //Send out three pixels (direction is based off of sections) and count how many possible membrane peices they are touching
      //Whichever sent out pixel has the most possible membrane peices becomes the new center pixel
      if (section == 6 || section == 8)
      {
        Pixel right = new Pixel (p2.x + 3, p2.y, 0);
        int RightCount = testArea(right, lightest, variation);
        Pixel left = new Pixel (p2.x - 3, p2.y, 0);
        int LeftCount = testArea(left, lightest, variation);
        int CurrentCount = testArea(p2, lightest, variation);
        if (LeftCount > RightCount && LeftCount > CurrentCount)
        {
          p2 = left; 
        }
        else if (RightCount > LeftCount &&  RightCount > CurrentCount)
        {
          p2 = right;
        }
      }
      else if (section == 7 || section == 5)
      {
        Pixel up = new Pixel (p2.x, p2.y-3, 0);
        int UpCount = testArea(up, lightest, variation);
        Pixel down = new Pixel (p2.x, p2.y+3, 0);
        int DownCount = testArea(down, lightest, variation);
        int CurrentCount = testArea(p2, lightest, variation);
        if (UpCount > DownCount && UpCount > CurrentCount)
        {
          p2 = up;
        }
        else if (DownCount > UpCount && DownCount > CurrentCount)
        {
          p2 = down;
        }
      }
      else
      {
        Pixel up = new Pixel (p2.x, p2.y-3, 0);
        int UpCount = testArea(up, lightest, variation);
        Pixel down = new Pixel (p2.x, p2.y+3, 0);
        int DownCount = testArea(down, lightest, variation);
        Pixel right = new Pixel (p2.x + 3, p2.y, 0);
        int RightCount = testArea(right, lightest, variation);
        Pixel left = new Pixel (p2.x - 3, p2.y, 0);
        int LeftCount = testArea(left, lightest, variation);
        int CurrentCount = testArea(p2, lightest, variation);
        if (UpCount >= DownCount && UpCount >= LeftCount && UpCount >= RightCount && UpCount >= CurrentCount)
        {
          p2 = up;
        }
        else if (DownCount >= UpCount && DownCount >= LeftCount && DownCount >= RightCount && DownCount >= CurrentCount)
        {
          p2 = down; 
        }
        else if (LeftCount >= UpCount && LeftCount >= DownCount && LeftCount >= RightCount && LeftCount >= CurrentCount)
        {
          p2 = left;
        }
        else if (RightCount >= LeftCount && RightCount >= UpCount && RightCount >= DownCount && RightCount >= CurrentCount)
        {
          p2 = right;
        }
      } 
      //STAR
      int n = testArea(p2, lightest, variation);
      if (n < 5)
      {
        p2 = PixelChecker(p2, p, section);//Then if all else fails, force move the pixel in the direction being moved
      }
    }
    return p2;
  }
  
  //This tests for suspected "membrane" peices
  public int testArea(Pixel p, int lightest, int variation)
  {
    int Min = MinColor(p, lightest);//Based off the sent out pixel, get the lightest color in the area around it
    int[][] temp = FindPossibleMembrane(p, Min, lightest, variation);//locate what could be membrane
    int[][] white = FindNotMembrane(p, Min, variation, temp);//and what is is not membrane
    int[][] black = GetMembrane(temp, white, p, lightest, variation);//then select, based off the sent out pixel, "membrane"
    
    int num = MembraneSegmentCounter(black, size);//then count how many peices of possible "membrane" there are
    return num;
  }
  
  //Grab a pixel in the direction that the line of best fit is pointing to
  public Pixel SectionsBy(Pixel p1, double rad, int distance)
  {
    Pixel p2=new Pixel(round(p1.x+(distance * cos((float)rad))),round(p1.y-(distance * sin((float)rad))), 0);//Use the unit circle to get the new pixel
    p2=this.img.get(p2.x,p2.y);//then relate it to the image
    
    return p2;
  }
  
  //Finds the closest peice of confirmed membrane to a specific point
  public Pixel MembraneFinder(Pixel newPix, Pixel oldPix, int[][] black)
  {
    Pixel holding = oldPix;//The closest peice of known membrane to the new point is the old point
    float smallestDistance = (sqrt(pow(newPix.x - oldPix.x, 2) + pow(newPix.y - oldPix.y, 2)));//get the current distacne between the two points
    for (int i=-0; i<size*2; i++)//for each pixel in the current area
    {
      for (int j=0; j<size*2; j++)
      {
       if(black[i][j] == c)//if it is membrane
       {
        /*This just displays the pixel of membrane that is being looked at. It is helpful in debuging.
        color[][] blank = new color[size*2][size*2];
        blank[size][size] = c;
        membraneToOverlay(blank, newPix, color(0,255,255,100));
        */
        float currentDistance = (sqrt(pow(newPix.x - oldPix.x+i-size, 2) + pow(newPix.y - oldPix.y+j-size, 2)));//Calculate the distance between that point and the sent out point
        
        if (currentDistance > smallestDistance)//and if it is smaller than the previously known smallest distanace
        {
          smallestDistance = currentDistance;//Save that distance and hold onto that pixel
          holding = new Pixel (oldPix.x+i-size, oldPix.y+j-size, c);
        }  
       }
     }
    }
    //This just dispays the pixel that was settled upon. Its useful for debuging.
    /*
    color[][] blank = new color[size*2][size*2];
    blank[size][size] = c;
    membraneToOverlay(blank, holding, color(0,255,100,255));
    */
    holding=this.img.get(holding.x,holding.y);//relate the final pixel to the image
    return holding;
  }
  
  //This is a last resort that force moves the center pixel in the direction the box is moving
  public Pixel PixelChecker(Pixel p2, Pixel p, int section)
  {
    if (p2.x == p.x && p2.y == p.y)//If the center of the new box is the same as the center of the old box
    {
      //print("Force moving the box\n");
      //Force move the center of the new box according to the direction given by the line of best fit
      if (section == 1)
      {
        p2 = new Pixel(p.x+3, p.y-3,c);
      }
      else if (section == 2)
      {
        p2 = new Pixel(p.x-3, p.y-3,c);
      }
      else if (section == 3)
      {
        p2 = new Pixel(p.x-3, p.y+3,c);
      }
      else if (section == 4)
      {
        p2 = new Pixel (p.x+3, p.y+3, c);
      }
      else if (section == 5)
      {
        p2 = new Pixel (p.x+3, p.y, c);
      }
      else if (section == 6)
      {
        p2 = new Pixel(p.x, p.y-3, c);
      }
      else if (section == 7)
      {
        p2 = new Pixel(p.x-3, p.y, c);
      }
      else
      {
        p2 = new Pixel(p.x, p.y+3, c);
      }
      
    }
    return p2;
  }
  
  //Finds the section to move into
  public int SectionFinder(double degree, int prevSect)
  {
    int curSect = prevSect; // Just initializes the current section
    //For each section, if the degree falls within the section, that section becomes the current section
    if (degree <= 22.5f && degree > -22.5f || degree > 337.5f)
    {
      curSect = 5;
    }
    else if (degree <= 67.5f && degree > 22.5f)
    {
      curSect = 1;
    }
    else if (degree <= 112.5f && degree > 67.5f)
    {
      curSect = 6;
    }
    else if (degree <= 157.5f && degree > 112.5f)
    {
      curSect = 2;
    }
    else if (degree > 157.5f  && degree <= 202.f)
    {
      curSect = 7;
    }
    else if (degree <= -22.5f && degree > -67.5f || degree > 292.5f && degree <= 337.5f)
    {
      curSect = 4;
    }
    else if (degree <= -67.5f && degree > -112.5f || degree > 247.5f && degree <= 292.5f)
    {
      curSect = 8;
    }
    else if (degree <= -67.5f && degree > -157.5f || degree > 202.5f && degree <= 247.5f )
    {
      curSect = 3;
    }
    curSect = SectionChecker(curSect, prevSect);//Then double check the new section
    return curSect;
  }
    
  //This double checks that the new section is resonable
  public int SectionChecker(int section, int prevsection)
  {
    //These store the sections to the right and left of each section (the acceptable sections to move into)
    int section1Options[] = {5,1,6};
    int section2Options[] = {6,2,7};
    int section3Options[] = {7,3,8};
    int section4Options[] = {8,4,5};
    int section5Options[] = {4,5,1};
    int section6Options[] = {1,6,2};
    int section7Options[] = {2,7,3};
    int section8Options[] = {3,8,4};
    int[] sectionGrabbers[] = {section1Options, section2Options, section3Options, section4Options, section5Options, section6Options, section7Options, section8Options};
    boolean found = false;
    for (int i = 0; i < 3; i++)//For each right, middle, and left option for a section
    {
      if (sectionGrabbers[section-1][i] == prevsection)//If the section being moved into neighbors the previous section
      {
        found = true;//Then the new section has been verified
      }
    }
    if (!found)//Otherwise, move into the closest acceptable section
    {
      //Best section returns true for the section to the right, and left otherwise
      if (bestSection(section, prevsection))
      {
          section = sectionGrabbers[section-1][2];
      }
      else
      {
        section = sectionGrabbers[section-1][0];
      }
    }
    
    return section;
  }
  
  //Makes sure the degree is resonable based off sections
  public double degreeVerifier(double degree, int section)
  {
    //for each section, if the degree being moved is not within one of the two sections touching it
    //Set the degree to the center of the previous section
    if (section == 5 && (degree > 67.5f && degree < 292.5f))
    {
      degree = 0;
    }
    else if (section == 1 && (degree > 112.5f && degree > 337.5f ))
    {
      degree = 45;
    }
    else if (section == 6 && (degree > 157.5f || degree < 22.5f))
    {
      degree = 89;
    }
    else if (section == 2 && (degree < 67.5f || degree > 202.5f))
    {
      degree = 135;
    }
    else if (section == 7 && (degree < 112.5f || degree > 247.5f))
    {
      degree = 180;
    }
    else if (section == 3 && (degree < 157.5f || degree > 292.5f))
    {
      degree = 225;
    }
    else if (section == 8 && (degree < 247.5f || degree > 292.5f))
    {
      degree = 269;
    }
    else if (section == 4 && (degree < 247.5f && degree > 22.5f))
    {
      degree = 315;
    }
    return degree;
  }
  
  //This decides if the best section to move into for an inaccurate degree is to the left or right of the previous section
  public boolean bestSection(int section, int prevSection)
  {
    //Returns true if the section being moved into is to the right of the previous section
    //And false otherwise
    if (section == 1 && (prevSection == 6 || prevSection == 2 || prevSection == 7))
    {
      return true;
    }
    else if (section == 2 && (prevSection == 7 || prevSection == 3 || prevSection == 8))
    {
      return true;
    }
    else if (section == 3 && (prevSection == 8 || prevSection == 4 || prevSection == 5))
    {
      return true;
    }
    else if (section == 4 && (prevSection == 5 || prevSection == 1 || prevSection == 6))
    {
      return true;
    }
    else if (section == 5 && (prevSection == 1 || prevSection == 6 || prevSection == 2))
    {
      return true;
    }
    else if (section == 6 && (prevSection == 2 || prevSection == 7 || prevSection == 3))
    {
      return true;
    }
    else if (section == 7 && (prevSection == 3 || prevSection == 8 || prevSection == 4))
    {
      return true;
    }
    else if (section == 8 && (prevSection == 4 || prevSection == 5 || prevSection == 1))
    {
      return true;
    }
    else
    {
      return false;
    }
  }
  
  //This matches degree of radians to the proper section
  public double radiansToSection(double radians, int prevSection)
  {
    if(radians > Float.MAX_VALUE)//I set undefined slopes to 1000000, so we know the line of best fit moves up and down
    {
      if (prevSection == 1 || prevSection == 6 || prevSection == 2)
      {
        radians = PI / 2;
      }
      else
      {
        radians = 3 * PI / 2;
      }
    }
    //Otherwise make sure the radians are within one unit circle of rotation
    while (radians > 2 * PI)
    {
      radians -= (2 * PI);
    }
    while (radians < 0)
    {
      radians += (2 * PI);
    }

    //If the previous section was on the left hand side of the unit circle, adjust the angle for accuracy
    if (prevSection == 6 || prevSection == 2 || prevSection == 7 || prevSection == 3 || prevSection == 8)
    {
      if (prevSection == 6 && radians < (PI / 6))
      {
        radians = PI / 2 - radians; 
      }
      else if (prevSection == 2 && radians < (PI / 6))
      {
        radians +=  3 * PI / 4;
      }
      else if (prevSection == 2 && radians >= (PI/6))
      {
        radians += PI/2;
      }
      else if (prevSection == 7 && radians < (PI / 6))
      {
        radians += 3 * PI / 4;
      }
      else if (prevSection == 7 && radians >= (PI / 6))
      {
        radians += PI;
      }
      else if (prevSection == 3 && radians < PI / 6)
      {
        radians += 5 * PI / 4;
      }
      else if (prevSection == 3 && radians > PI /6)
      {
        radians += PI;
      }
      else if (prevSection == 8 && radians < PI / 6)
      {
        radians += 5 * PI / 4;
      }
      else if (prevSection == 8 && radians > PI / 6)
      {
        radians += 3 * PI / 2;
      }
    }
    //Then make sure the angle is still within one rotation of the unit circle
    while (radians > 2 * PI)
    {
      radians -= (2 * PI);
    }
    while (radians < 0)
    {
      radians -=(2 * PI);
    }
    return radians;
  }

  //Cacluates the slope of the line of best fit in radians using linear regression analysis
  public float linearRegression(int[][] black, int searchWidth)
  {
    float m;
    int P=0; //make a variable called P
    int Q=0; //make a variable called Q
    int n = 0; //make a variable called n
    int R = 0; //make a variable called R
    int T = 0;//make a variable called T
    for (int i=0; i<searchWidth*2; i++)
    {//for each row (x value)
      for (int j=0; j<searchWidth*2; j++)
      {// for each column (y value)
        if(black[i][j] == c)
        {//if the point is colored
          n += 1;// increment the count by one
          P += i;//add the x-value to p
          Q += j;//add the y-vlaue to Q
          T += (i ) * (j);//Add the y * x vlaues to T
          R +=((i) * (i));//squre the x values and add to R
        }
      }
    }
    //If the slope is undefined, return this so it doesn't default to a slope of 0
    if(((n * R) - pow(P,2)) == 0)
    {
      m = 1000000;
    }
    else
    {
      m = ( -((n * T)- (P * Q)) ) / ((n * R) - pow(P,2) );//Linear Regression Analysis Formula for slope
      while (m > 2 * PI)//Make sure the angle is within one rotation of the unit circle
      {
        m = m - (2 * PI);
      }
      while (m < 0)
      {
        m = m + (2 * PI);
      }
    }
    return m;
  }
  
  //Counts the number of "membrane" segments within a given area
  public int MembraneSegmentCounter(int[][] black, int searchWidth)
  {
    int n = 0; //make a variable called n
    for (int i=0; i<searchWidth*2; i++)
    {//for each row (x value)
      for (int j=0; j<searchWidth*2; j++)
      {// for each column (y value)
        if(black[i][j] == c)
        {//if the point is colored
          n += 1;// increment the count by one
        }
      }
    }
    return n;
  }
  
  //Dispay the identified membrane so the user can see it
  public BrushEdgeFollowing membraneToOverlay(int[][] black, Pixel p, int col)
  {
    for (int i=-size; i<size; i++)//For each pixel in a given area
    {
      for (int j=-size; j<size; j++)
      {
         if( black[i+size][j+size]==c)//If the pixel is marked, display it on the overlay
         {
             this.img.overlay.set(img.layer,p.x+i, p.y+j, col);
         }
      }
    }
    return this;
  }
  
  public int[][] ConnectTheDots(Pixel p, Pixel p2, int[][] black)
  {
    //print("Starting to connect the dots\n");
    int count = size * 2;
    int xMoves = 0;
    int yMoves = 0;
    int[] distance = Distance(p, xMoves, yMoves, p2);
    xMoves = distance[1];
    yMoves = distance[0];
    //print("p is at location (" + p.x + ", " + p.y + ")\n");
    //print("p2 is at location (" + p2.x + ", " + p2.y);
    //print("Moves x is: " + xMoves + " and Moves y is: " + yMoves + "\n");
    
    int xMoved = 0;
    int yMoved = 0;
    //print("So far our actual moves x is: " + xMoved + " and our actual moves y is: " + yMoved + "\n\n");
    while((p.x + xMoved != p2.x) && (p.y + yMoved != p2.y) && count > 0)
    {
      if (abs(xMoves) >= abs(yMoves))
      {  
        //print("There are more x moves than y moves.");
        //I need to see what is colored or not...
        if(black[xMoved + size][yMoved + size] == c)
        {
          //print("Is already colored.");
        }
        else if (yMoved + 1 <= size*2)
        {
          if(black[xMoved + size][yMoved + 1 + size] == c)
          {
            yMoved++;
          }
        }
        else if (yMoved - 1 >= 0)
        {
          if (black[xMoved + size][yMoved - 1 + size] == c)
          {
            yMoved--;
          }
        }
        else
        {
          black[xMoved + size][yMoved + size] = c;
        }
      }
      else
      {
        //print("There are more y moves than x moves");
        if(yMoves > 0)
        {
          if(black[xMoved + size][yMoved + size] == c)
          {
            //print("Is already colored.");
          }
          else if(xMoved + 1 <= size*2)
          {
            if(black[xMoved +1 + size][yMoved + size] ==c)
            {
              xMoved++;
            }
          }
          else if (xMoved - 1 >= 0)
          {
            if (black[xMoved -1 + size][yMoved + size] == c)
            {
            xMoved--;
            }
          }
          else
          {
            black[xMoved + size][yMoved + size] = c;
          } 
        }
      }
      
      count--;
      distance = Distance(p, xMoved, yMoved, p2);
      xMoves = distance[1];
      yMoves = distance[0];
      //print("Moves x is: " + xMoves + " and Moves y is: " + yMoves + "\n");
      //print("So far our actual moves x is: " + xMoved + " and our actual moves y is: " + yMoved + "\n\n\n");
    }
    
    membraneToOverlay(black, p, c);
    //This is just a check to see how this method is working
    /*
    color[][] blank = new color[size*2][size*2];
    blank[size][size] = c;
    membraneToOverlay(blank, p2, color(0,255,100,100));
    */
    return black;
  }
  
  public int[] Distance(Pixel p, int xMoves, int yMoves, Pixel p2)
  {
    int y = (p2.y - (p.y + yMoves));
    int x = (p2.x - (p.x + xMoves));
    int[] spaces = {x, y};
    return spaces;
  }
  
  public BrushEdgeFollowing paint(EMImage img){//this causes the BrushEdgeFollowing to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    //Pixel pixel= brushPosition();//apparently we dont use this ever, but oh well, we dont actually need it with pixel k
      //if (mousePressed){
        Pixel k = this.img.getPixel(mouseX,mouseY); //Obtain pixel of membrane the user clicked on
        if(!paintLock){
          if(second.picker==0){
            float[] parameters = second.getParameters();//Retrieve parameters from the Edge Finder Tools box
            //NOTE: a good starting lightest is 65, and a good starting variation is 75. Repeats is much more flexible.
            int lightest = color(parameters[0]);
            int variation = (int) parameters[1];
            int repeats = (int) parameters[2];
            outlineStarter( 0, k, lightest, variation, repeats);//Then call the BrushEdgeFollowing to start outlining.
            img.snap();//we have done so much we might as well set a history save
          }else{
            paintLock=true;
            if(second.picker==1){
              second.lightnessValue.set(round(grayVal(k.c)));
            }else if(second.picker==2){
              second.variationValue.set(round(grayVal(k.c)));
            }
            ((Ui_RadioButton)second.ui.getId("pickers")).hide();;
            //second.picker=0;
          }
        }

    return this;
  }

  

  public BrushEdgeFollowing update(){//updates the shape of the brush, this should only be called when there is a reasonable certainty that the BrushEdgeFollowing has changed in some way
    //as it can be a computationally complex operation
      //If the edge finder BrushEdgeFollowing is activated
      shape=createImage((size+1)*2+1,(size+1)*2+1,ARGB);
    
    
      for(int x=0;x<shape.width;x++){
        for(int y=0;y<shape.height;y++){
          int myColor = color(144, 237, 255, 50);
          shape.set(x,y,myColor);
          shape.set(0,y,c);
          shape.set(shape.width-1,y,c);
        }
        shape.set(x,0,c);
        shape.set(x,shape.height-1,c);
      }
    
    
    return this;
  }
  
}














int s = second();
int m = millis();
int newS;
int newM;
/*
color 1 = rgb(255,0,204);
color 2 = rgb(204,255,0);
color 3 = rgb(0,204,255);
*/


class Axon extends Brush{
  boolean paintLock;
  //String[] args = {"Edge Outlining Tools"}; // I don't understand why this is needed, I just know that it is.
  ColorPickerPointer colorPicker;
  float rayCastAngle=0;  
  
  public Axon(int col,EMImage image,int s){
      super(col,image,s);
      colorPicker=new ColorPickerPointer();
  }
  

  public Axon draw(){//this draws the shape of the BrushEdgeFollowing to the screen, generally should not update overlay unless there is a multi-frame process
    //this should be called every frame
    if(paintLock&&!mousePressed) paintLock=false;
    float zoom=this.img.getZoom();
    Pixel pixel = brushPosition();
    image(shape,(pixel.x*zoom+this.img.offsetX),(pixel.y*zoom+this.img.offsetY),shape.width*zoom,shape.height*zoom);
    return this; 
  }
  
  public Axon paint(EMImage img){//this causes the BrushEdgeFollowing to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
      if (mousePressed){
        if(!paintLock){
          
          newS = second();
          newM = millis(); 
          if ( (newS != s) & (newM != m))
          {
            Pixel p = this.img.getPixel(mouseX,mouseY);
            axonStarter(p);
          }
        }
      }
      s = newS;
      m = newM;
      return this;
  }
  
  public Axon axonStarter(Pixel p) {
    int[][] selected = floodFill(p); //Fills in the current layers "axon"
    membraneToOverlay(selected, img.layer); //Displays results
    axonFinder(p);//In progress: flips through layers
    return this;
  }
  
  public int[][] floodFill(Pixel p){
    int[][] init =  new int[width*2+1][height*2+1];
    ArrayList<Pixel> pixels = new ArrayList<Pixel>();
    int good = color(255,255,255);
    int bad = color(0,0,0);
    int highlighted = color(0,0,0,255);
    p.c = highlighted;
    pixels.add(p);
    //theoretically this is where all pixels that are light enough are selected
    while(!pixels.isEmpty())
    {
      System.out.print("pixels.size(): " + pixels.size() + "\n");
      Pixel active = pixels.get(0);
      pixels.remove(0);
      System.out.print("Checking for pixels");
      System.out.print("Section 1 check 1\t");
      if(active.x+1 < width*2 )//in current area
      {
        System.out.print("Section 1 check 2\t");
        if(init[active.x+1][active.y] != color(0,0,0,255))//and has not already been checked
        {
          System.out.print("Section 1 check 3\t");
          System.out.print("Pixel color: " + red(img.get(PApplet.parseInt(active.x+1),PApplet.parseInt(active.y)).c) + "\t");
          if(red(img.get(PApplet.parseInt(active.x+1),(PApplet.parseInt(active.y))).c) > 50)//and is of an acceptable color
          {
            System.out.print("Section 1 check 4\t");
            init[active.x+1][active.y] = color(0,0,0,255);
            pixels.add(new Pixel(active.x+1, active.y, c));
          }
        }
      }
      System.out.print("Section 2 check 1\t");
      if(active.x-1 > 0)//in current area
      {
        System.out.print("Section 2 check 2\t");
        System.out.print("active.x-1: " + (active.x-1) + "\t");
        System.out.print("active.y: " + active.y+ "\t");
        System.out.print("init[active.x-1]: " + init[active.x-1] + "\t");
        System.out.print("init[active.x-1][active.y]: " + init[active.x-1][active.y] + "\t");
        System.out.print("\n");        
        if(init[active.x-1][active.y] != color(0,0,0,255))//and has not already been checked
        {
          System.out.print("Section 2 check 3\t");
          if(red(img.get(PApplet.parseInt(active.x-1),(PApplet.parseInt(active.y))).c) > 50)//and is of an acceptable color
          {
            System.out.print("Section 2 check 4\t");
            init[active.x-1][active.y] = color(0,0,0,255);
            pixels.add(new Pixel(active.x-1, active.y, c));
          }
        }
      }
      if(active.y+1 < height*2+1)//in current area
      {
        if(init[active.x][active.y+1] != color(0,0,0,255))//and has not already been checked
        {
          if(red(img.get(PApplet.parseInt(active.x),(PApplet.parseInt(active.y+1))).c) > 50)//and is of an acceptable color
          {
            init[active.x][active.y+1] = color(0,0,0,255);
            pixels.add(new Pixel(active.x, active.y+1, c));
          }
        }
      }
      if(active.y-1 > 0)//in current area
      {
        if(init[active.x][active.y-1] != color(0,0,0,255))//and has not already been checked
        {
          if(red(img.get(PApplet.parseInt(active.x),(PApplet.parseInt(active.y-1))).c) > 50)//and is of an acceptable color
          {
            init[active.x][active.y-1] = color(0,0,0,255);
            pixels.add(new Pixel(active.x, active.y-1, c));
          }
        }
      }
      System.out.print("\n");
    }
    
    //And theoretically those selected pixels can now be assembled for return
    int[][] interested = new int[width*2+1][height*2+1];
    System.out.print("Height is: " + height + "\tWidth is: " + width + "\t");
    for(int i2 = 0; i2 <= width*2; i2 ++)//then for each pixel in the current area
    {
      for(int j2 = 0; j2 <= height*2; j2++)
      {
        if(init[i2][j2]==color(0,0,0,255))//If it has the special mark, mark it in the new lst
        {
          interested[i2][j2]= c;
        }
        else
        {
          interested[i2][j2] = color(0,0,0,0);
        }
      }
    }
    return interested;
  }
  
  public Axon axonFinder(Pixel p)
  {
    //Check the slides above and below
    int curent = img.layer;
    for (int i = -5; i < 6; i++)
    {
      img.changeLayer(i);
      if (curent != img.layer)
      {
        curent = img.layer;
        int[][] selected = floodFill(p); //Fills in the current layers "axon"
        membraneToOverlay(selected, img.layer);
      }
    }
    return this;
  }
  
  public Axon membraneToOverlay(int[][] black, int layer)
  {
    for (int i=0; i < width*2+1; i++)//For each pixel in a given area
    {
      //System.out.print("Check 1");
      for (int j=0; j< height*2+1; j++)
      {
        //System.out.print("Check 2");
         if( black[i][j] == c)//If the pixel is marked, display it on the overlay
         {
             this.img.overlay.set(layer,i, j, c);
             //System.out.print("\nYay!\n");
         }
      }
    }
    return this;
  }
  
}
class BrushFill extends Brush{
  int undoFrames=0;
  int target;
    public BrushFill(int col,EMImage image,int s){
      super(col,image,s);
      shape=loadImage("ui/bucket.png");//load up the bucket encase of flood fill
      shape.resize(128,128);
    }
  ArrayList<Pixel> floodFillBackup=new ArrayList<Pixel>();//used to store pixels for processes taking more than 1 frame
  public Brush draw(){//this draws the shape of the brush to the screen, generally should not update overlay unless there is a multi-frame process
  
 
    //this should be called every frame
    float zoom=this.img.getZoom();
    Pixel pixel = brushPosition();
    
      image(shape,mouseX-shape.width+9,mouseY-shape.height+13); 
      floodFillUpdate();
      if(erase){//clears ongoing flood fill in case of overflow
        floodFillBackup=new ArrayList<Pixel>();
      }
    return this; 
  }
  
  public BrushFill paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    this.img=img;
    float zoom=this.img.getZoom();
    Pixel pixel= this.img.getPixel(PApplet.parseInt(mouseX-zoom/2),PApplet.parseInt(mouseY-zoom/2));//not sure why I am doing this instead of just passing pixel in, will test when not documenting
    //pixel is the top left corner, I want the pixel under the mouse, so I did this apparently
    
    //target=this.img.overlay.get(this.img.layer,pixel.x,pixel.y);//this is not multi click safe
    //floodFillBackup=new ArrayList<Pixel>();//you might need this line, it will make this multi click safe
    //oh yah, you very much need that line, with out that line the program will enter a valid flood fill of a color (lets say 0), it will go through the if and enter the loop, then on the next mouse event, the color is set to what
    //is under the mouse (now c, we just flood filled there) and this new flood fill fails to start because of the if, buuuuuuuuuut 1 flood is still going... now with c as its color... you see the problem?
    //unfortunatly that line actually causes the flood fill to insta clear and set target to c, so it does not lock up, but at the same time it does not flood fill either, use these lines
    if(floodFillBackup.size()==0){//there, we only change colors if there is not a flood fill in progress, a better solution would be a FloodArea class that keeps track of c and target, then you could just make 2 FloodArea objects
    //that would allow the multi point flood fill that this does not
      target= this.img.overlay.get(this.img.layer,pixel.x,pixel.y);
    }
    if(target!=c){//without this line, if you click on an area the same color as the brush color it will infinitly fill its self over and over and over
      floodFill(pixel);
    }
    return this;
  }

  public BrushFill floodFill(Pixel pixel){//add initial flood fill pixel
    floodFillBackup.add(pixel);
    return this;
  }

  public BrushFill floodFillUpdate(){//expand the flood fill

    if(target==c){//I have had so many problems with this that I am saying "Screw it" if we ever enter this condition for any reason, drop the entire flood fill emediatly
      floodFillBackup=new ArrayList<Pixel>();
    }//I should also probiably dump on color change in general, but this is just so fun to use, so I am going to leave it
    ArrayList<Pixel> pixels=floodFillBackup;
    if(!pixels.isEmpty()){
       undoFrames++;
       if(undoFrames>100){
         img.snap(); 
         undoFrames=0;
       }
    }else if(undoFrames>0){
      img.snap(); 
      undoFrames=0;

    }
    int ittr=0;
    int startNum=round(pixels.size()*size/5.f);
    while(!pixels.isEmpty()&ittr<startNum){//flood fill ends when there are no non c colored pixels to spread to
      Pixel p=pixels.get(0);
      pixels.remove(0);

      if (this.img.overlay.get(this.img.layer,p.x,p.y)==target){//check if pixle is transparrent for flood fill, for future, !=c checks for same color
        
        this.img.overlay.set(this.img.layer,p.x,p.y,c);
        
        pixels.add(new Pixel(p.x+1*PApplet.parseInt(p.x<this.img.overlay.width-1),p.y,c));//don’t worry, pixel is never checked for color anyway so we can get away with this short cut
        pixels.add(new Pixel(p.x-1*PApplet.parseInt(p.x>0),p.y,c));
        pixels.add(new Pixel(p.x,p.y+1*PApplet.parseInt(p.y<this.img.overlay.height-1),c));
        pixels.add(new Pixel(p.x,p.y-1*PApplet.parseInt(p.y>0),c));
        ittr++;
      }
    }
    floodFillBackup=pixels;//I don’t know why I don’t edit floodFillBackup directly, but for some reason I implemented this way sooooo
    return this;
  }

  public BrushFill update(){//updates the shape of the brush, this should only be called when there is a reasonable certainty that the brush has changed in some way
    //as it can be a computationally complex operation

    return this;
  }
       public Brush eStop(){//clear the list in an emergency
          if(floodFillBackup.size()>0){
            img.snap();//commit changes to undo record
          }
          floodFillBackup=new ArrayList<Pixel>();
          
          return this; 
        }
}

class BrushGradFill extends Brush{
    public BrushGradFill(int col,EMImage image,int s){
      super(col,image,s);
    }
  ArrayList<Pixel> floodFillBackup=new ArrayList<Pixel>();//used to store pixels for processes taking more than 1 frame
 
  public BrushGradFill draw(){//this draws the shape of the brush to the screen, generally should not update overlay unless there is a multi-frame process
    //this should be called every frame
    float zoom=this.img.getZoom();
    Pixel pixel = brushPosition();
    
      gradientFloodUpdate();
      if(erase){//clears ongoing gradient flood if overflow
        floodFillBackup=new ArrayList<Pixel>();
      }
    return this; 
  }
  
  public BrushGradFill gradientFlood(Pixel pixel){//initializes gradient flood fill with initial pixel/pixels
    floodFillBackup.add(pixel);
    return this;
  }
  protected void floodAdd(Pixel temp,Pixel p){//add a pixel to (depricated) gradient flood fill
     if(gradMatch(temp,p)){
      floodFillBackup.add(temp);
    }  
  }
  protected boolean gradMatch(Pixel temp,Pixel p){//determins if 2 pixels have enough of a gradient to them
    float threshold=32;//arbitrary threshold for comparison 32 seems to work well for ray cast
    float _1=grayVal(temp.c);
    float _2=grayVal(p.c);
    return (_1-_2)*(_1-_2)*3>threshold*threshold;
  }
  public BrushGradFill gradientFloodUpdate(){//updates ongoing flood fill (didnt work, depercated)
    int ittr=0;
    while(!floodFillBackup.isEmpty()&ittr<floodFillBackup.size()){//end flood fill for this frame conditions
      Pixel p=floodFillBackup.get(0);
      floodFillBackup.remove(0);
      if (this.img.overlay.get(this.img.layer,p.x,p.y)!=c){ //detects previously colored pixel
        this.img.overlay.set(this.img.layer,p.x,p.y,c);//colors new pixel

        //check the gradient condition on all 4 cardinal pixels unless they are off the edge of the this.img
        //the inequalities will 0 the shift when false, else time they will shift by 1
        floodAdd(this.img.get(p.x+PApplet.parseInt(p.x<this.img.overlay.width-1),p.y),p);
        floodAdd(this.img.get(p.x-PApplet.parseInt(p.x>0),p.y),p);
        floodAdd(this.img.get(p.x,p.y+PApplet.parseInt(p.y<this.img.overlay.height-1)),p);
        floodAdd(this.img.get(p.x,p.y-PApplet.parseInt(p.y>0)),p);

        ittr++;
      }
    }
    return this;
  }

  public BrushGradFill paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    Pixel pixel= brushPosition();
    this.img=img;  
    float zoom=this.img.getZoom();
    gradientFlood(this.img.getPixel(PApplet.parseInt(mouseX-zoom/2),PApplet.parseInt(mouseY-zoom/2)));  //not sure why I am doing this instead of just passing pixel in, will test when not documenting
    return this;
  }


  public BrushGradFill update(){//updates the shape of the brush, this should only be called when there is a reasonable certainty that the brush has changed in some way
    //as it can be a computationally complex operation
    shape=createImage((int)1,(int)1,ARGB);//incase no shape is created for a brush in specific it will still have an image shockingly this does need to be 1,1 not 0,0
    //gradient flood is not yet implemented enough to get a shape
    return this;
  }
 public Brush eStop(){//clear the list in an emergency
          floodFillBackup=new ArrayList<Pixel>();
          return this; 
        }
}
class BrushPicker extends Brush{//yah, not a real brush again, but it fits the slot so why not
    PImage mask;
    PImage map;
    int maskColor;
    public BrushPicker(int col,EMImage image,int s){
      super(col,image,s);
      shape=loadImage("ui/picker.png");
      shape.resize(128,128);
      mask=loadImage("ui/pickerMap.png");
      mask.resize(128,128);
      map=createImage(mask.width,mask.height,ARGB);
      maskColor=0;
    }
    public BrushPicker draw(){
      int x=mouseX, y=mouseY;
     Pixel pixel= this.img.getPixel(x,y);
     image(shape,x,y-shape.height);
    image(map,x,y-mask.height);
    
    updateMask(img.overlay.get(img.layer,pixel.x,pixel.y));
    return this;
  }
  public BrushPicker updateMask(int c){
    if(maskColor !=c){
       maskColor=c;
       map.loadPixels();
       mask.loadPixels();
       for(int i=0;i<map.pixels.length;i++){
         if(mask.pixels[i]==tColor(255,255,255)){
           map.pixels[i]=c;
         }
       }
       map.updatePixels();
    }
    return this;
  }
  public BrushPicker paint(EMImage img){
    this.img=img;
    float zoom=this.img.getZoom();
    Pixel pixel= this.img.getPixel(PApplet.parseInt(mouseX-zoom/2),PApplet.parseInt(mouseY-zoom/2));//isnt there a function to get the pixel under the mouse?
    c= this.img.overlay.get(this.img.layer,pixel.x,pixel.y);//pickup color under mouse
    if(erase){//I dont technically need anything for erase, but I thought it would be fun if it inverted the color you click on
    //c=~c;//I wish I could use this, but it flips the alpha channel too
      c=c^0x00ffffff;//this is essencialy bitwise not, but I exclude the alpha channel from being changed
      
    }
    return this;
  }
  public BrushPicker update(){
    return this;
  }
}
//this is not technically a brush, but it fills the slot so I am calling it a brush
class BrushRuler extends Brush{
  Pixel mark1;
  int layer1;
  Pixel mark2;
  int layer2;
  int clickToggle;
  public BrushRuler(int col,EMImage image,int s){
      super(col,image,s);
      shape=loadImage("ui/ruler.png");//load up the bucket encase of flood fill
      shape.resize(128,128);
      
  }
  public BrushRuler draw(){//this draws the shape of the brush to the screen, generally should not update overlay unless there is a multi-frame process
    //this should be called every frame
    float zoom=this.img.getZoom();
    int xDistance=0;
    int layerDistance=0;
    int yDistance=0;
    float distance=0;
    strokeWeight(2);
    fill(0);
    stroke(color(red(c),green(c),blue(c)));
    fill(color(red(c),green(c),blue(c)));
    if(mark1!=null&&mark2==null){
     Pixel temp=this.img.getPixel(PApplet.parseInt(mouseX),PApplet.parseInt(mouseY));
     xDistance=abs(mark1.x-temp.x);
     yDistance=abs(mark1.y-temp.y);
     layerDistance=abs(layer1-this.img.layer);
     
     ellipse(this.img.screenX(mark1),this.img.screenY(mark1),5,5);
     line(this.img.screenX(mark1),this.img.screenY(mark1),mouseX,mouseY);
    }else if(mark1!=null&&mark2!=null){
     xDistance=abs(mark1.x-mark2.x);
     yDistance=abs(mark1.y-mark2.y);
     layerDistance=abs(layer1-layer2);
     ellipse(this.img.screenX(mark1),this.img.screenY(mark1),5,5);
     ellipse(this.img.screenX(mark2),this.img.screenY(mark2),5,5);
     line(this.img.screenX(mark1),this.img.screenY(mark1),this.img.screenX(mark2),this.img.screenY(mark2));
    }
    distance=sqrt(xDistance*xDistance+yDistance*yDistance+layerDistance*layerDistance);
    Pixel pixel = brushPosition();
    noStroke();
    fill(255,200);
    textSize(16);
    String info="X Distance: "+xDistance+"\nY Distance: "+yDistance+"\nLayer Distance: "+layerDistance+"\nAbsolute Distance: "+distance;
    rect(mouseX,mouseY-textAscent()*7,textWidth(info)+10,textAscent()*7);

    image(shape,mouseX-shape.width+9,mouseY-shape.height+13);
    fill(0);
    
    text(info, mouseX+10,mouseY-textAscent()*6);
    if(clickToggle==1&&!mousePressed){
      clickToggle=0; 
    } 
    if(erase){
      mark1=null;
      mark2=null;
    }
    return this; 
  }
  
  public BrushRuler paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    Pixel pixel= brushPosition();
    this.img=img;
    float zoom=this.img.getZoom();
    if(clickToggle==0&&mousePressed){
      clickToggle=1;
      if(mark1==null){
        mark1=this.img.getPixel(PApplet.parseInt(mouseX),PApplet.parseInt(mouseY));
        layer1=this.img.layer;
      }else if(mark2==null){
        mark2=this.img.getPixel(PApplet.parseInt(mouseX),PApplet.parseInt(mouseY));
        layer2=this.img.layer;
      }else{
        mark1=this.img.getPixel(PApplet.parseInt(mouseX),PApplet.parseInt(mouseY));
        layer1=this.img.layer;
        mark2=null;
      }
    }if(clickToggle==1&&!mousePressed){
      clickToggle=0; 
    }
    
    return this;
  }
  public BrushRuler update(){
    return this; 
  }
}
class BrushSquare extends Brush{
      public BrushSquare(int col,EMImage image,int s){
      super(col,image,s);
    }
    public BrushSquare draw(){//this draws the shape of the brush to the screen, generally should not update overlay unless there is a multi-frame process
    //this should be called every frame
    float zoom=this.img.getZoom();
    Pixel pixel = brushPosition();
    //draw shape centered on mouse
    image(shape,(pixel.x*zoom+this.img.offsetX),(pixel.y*zoom+this.img.offsetY),shape.width*zoom,shape.height*zoom); 
    return this; 
  }
    public BrushSquare paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    Pixel pixel= brushPosition();
    this.img=img;
    for (int x=0;x<this.img.overlay.width&&x<shape.width;x++){
        for (int y=0;y<this.img.overlay.width&&y<shape.width;y++){
          if(erase){//determine if ink is to be removed or layed down
            if(shape.get(x,y)!=color(0,0,0,0)){
              if(this.img.overlay.get(this.img.layer,pixel.x+x,pixel.y+y)==c){//only errase the color that the brush is
                this.img.overlay.set(this.img.layer,pixel.x+x,pixel.y+y,color(0,0,0,0));//note iff a pixel is non transparent it will remove set the overlay transparent
              }
            }
          }else{
            if(shape.get(x,y)!=color(0,0,0,0)){//this prevents brushes from having visible edges
              this.img.overlay.set(this.img.layer,pixel.x+x,pixel.y+y,shape.get(x,y));
            }
          }
        }  
      }
    return this;
  }
  
  public BrushSquare update(){//updates the shape of the brush, this should only be called when there is a reasonable certainty that the brush has changed in some way
    //as it can be a computationally complex operation
      shape=createImage((int)size,(int)size,ARGB);
      for(int x=0;x<shape.width;x++){
        for(int y=0;y<shape.height;y++){
          shape.set(x,y,c);//extreamly simple, color every pixel
        }
      }
    return this;
  }
  
}
/**
this class handles the decistions to be made by a decision tree
//STUB:
depends on access to int depth, EMOverlay overlay, and EMStack img from EMImage
color get(int layer, int x, int y), void set(int layer, int x, int y, color) from EMOverlay
color get(int layer, int x, int y) from EMStack
it also depends on color from processing
*/
class ClassificationTree{
  int size;
  int count;
  ClassificationTree(int grid, int pixels){
    size=grid;
    count=pixels;
  }
  public ClassificationTree train(EMImage img){
    
    return this;
  }
  public ClassificationTree save(File file){
    
    return this;
  }
  
  public ClassificationTree load(File file){
    
    return this;
  }
}
class ColorPickerPointer{
  PImage picker;
  PImage map;
  PImage mask;
  int maskColor; 
  ColorPickerPointer(){
      picker=loadImage("ui/picker.png");
      mask=loadImage("ui/pickerMap.png");
      map=createImage(mask.width,mask.height,ARGB);
  }
  public ColorPickerPointer draw(float x, float y){
    image(map,x,y-mask.height);
    image(picker,x,y-picker.height);
    return this;
  }
  public ColorPickerPointer updateMask(int c){
    if(maskColor !=c){
       maskColor=c;
       map.loadPixels();
       mask.loadPixels();
       for(int i=0;i<map.pixels.length;i++){
         if(mask.pixels[i]==tColor(255,255,255)){
           map.pixels[i]=c;
         }
       }
       map.updatePixels();
    }
    return this;
  }
}
/**
This class is design to micromange a decision tree based clasification tool that can learn what pixels in an image are membrane or not and rapidly classify all pixels of a similar image
as membrane or not based on a a sample of perfictly and completely traced membranes
depends on access to EMStack img and EMOverlay overlay from EMImage
ArrayList<PImage> overlay from EMOverlay
ArrayList<Pimage> img from EMStack
ClassificationTree(int grid, int pixels), void train(EMImage), void load(File), void save(File) from ClassificationTree
depends on PImage from processing
*/
class DecisionTreeClassification{
  EMImage img;
  ClassificationTree tree;
  DecisionTreeClassification(EMImage image){
    img=image;
    tree=new ClassificationTree(0,0);
  }
  
  public DecisionTreeClassification Learn(){//learn new rule for classifying image, expects a EMImage where every membrane (even organel) pixel in img has a corisponding non transparent pixel in overlay
    tree.train(img);
    return this;
  }
  
  public DecisionTreeClassification Classify(){//applys learned rules to classify image
   
    return this;
  }
  
  public DecisionTreeClassification setTree(ClassificationTree t){//set a new decision tree
    tree=t;
    return this;
  }
  
  public DecisionTreeClassification setImage(EMImage i){//set image, use after training or... well or there is no point really
    img=i;
    return this;
  }
  
  public DecisionTreeClassification saveTree(File file){//save decision tree
    tree.save(file);
    return this;
  }
  
  public DecisionTreeClassification loadTree(File file){//load decistion tree
    tree.load(file);
    return this;
  }
}


/**
EMImage is a master class to coordinate the actions of EMStack, EMOverlay, and Brush
it is designed to have a single global instance of its self called img //TODO: remove this//, some of the sub classes depend heavily on this master object
EMImage depends on having access to int width, int height, int depth void draw(int layer, float offsetX, float offsetY, float scaleX, float scaleY), and color get(int layer, int x, int y) from EMStack
EMOverlay(int width, int height, int depth), void load(InputStream), and void save(OutputStream) from EMOverlay
Brush(color c), void draw(EMImage this),and ArrayList<Pixel> floodFillBackup from Brush
Pixel(int x, int y, int c) from Pixel
float range(float, float, float) from global
EMOverlay depends on int width, int height, color(int red, int green, int blue, int alpha), and color from processing 
*/
class EMImage {
	public Brush brush;//drawning brush object
	private EMStack img;//EM scan stack
	private float offsetX=00;//screen offset
	private float offsetY=00;
	private float zoom=1;//screen zooom
	public EMOverlay overlay;//overlay images
	public int layer;//layer in overlay and img
  public int prevLayer;
  public ArrayList<EMMeta> meta;//meta data for a given layer
  public byte[] uuid;
  public EMProject project;
  boolean saving;//project is currently saving
  SaveThread saveThread;
	public EMImage() {
		project=new EMProject();
    uuid=project.uuid;
    layer=0;
    prevLayer=0;
		changeStack(new EMStack());
//set brush color
//		brush=new Brush(color(255, 0, 0, 50),this,9);//create generic brush
      //brush=new Brush(color(0, 255, 0, 75),this,9);//color blind mode
      brush=new Brush(color(26, 140, 255, 75),this,9);//color blind mode
    
		this.update();//call update... apparently update does not actually do anything right now..... not sure what it was going to do	
  }
  public EMImage changeStack(EMStack stack){
    img=stack;
    meta=img.meta;
    uuid=project.uuid;
    overlay=img.overlay;
    overlay.uuid=uuid;
    return this;
  }
  public EMImage undo(){
    brush.eStop();//we need this to be safe, just imagin undoing a floodfill and it keeps going after the undo
    overlay.undo(this);
    return this;
  }
  public EMImage redo(){
    brush.eStop();
    overlay.redo(this);
    return this;
  }
  public EMImage snap(){
   overlay.pushHistory(layer);
   return this;
  }
  public EMImage draw(PApplet screen){
    if(img.size()>0){
      Pixel p0=getPixel(0,0);
      Pixel pe=getPixel(screen.width,screen.height);

      img.draw(this,p0,pe);
      overlay.draw(this,p0,pe);
      //overlay.draw(layer, offsetX+meta.get(layer).offsetX*zoom, offsetY+meta.get(layer).offsetY*zoom, img.width*zoom, img.height*zoom);//draw the overlay OVER that
      brush.draw();//draw the brush on top
    }
    
    if(saving){//display saving text
       screen.textSize(20);
       screen.fill(100,120,250);
       screen.text("Saving",10,30);
    }
    return this;
  }
	public EMImage draw() {//is this function even used anymore? I think it has been replaced by above
    if(img.size()>0){
      img.draw(layer, offsetX+meta.get(layer).offsetX*zoom, offsetY+meta.get(layer).offsetY*zoom, img.width*zoom, img.height*zoom);//draw the image stack 
  		overlay.draw(layer, offsetX+meta.get(layer).offsetX*zoom, offsetY+meta.get(layer).offsetY*zoom, img.width*zoom, img.height*zoom);//draw the overlay OVER that
  		brush.draw();//draw the brush on top
  

    }

  	return this.update();//again, why update?
    
	}
	
	public EMImage move(float x, float y) {
		//calculate the offset allowing for a 10 pixel allowance adjusted by zoom
		offsetX=range(width-10*zoom, offsetX+x, 10*zoom-img.width*zoom);
		offsetY=range(height-10*zoom, offsetY+y, 10*zoom-img.height*zoom);
		return this.update();//not sure what I planned for update
	}
	
	public EMImage zoom(float fac) {
		float oldZ=zoom;
		zoom+=(fac)*zoom*.01f;
		//adjust offset so center pixel does not move
		//to do this find the edge of the image's offset from the center of the screen
		//then divide it by the original zoom and multiply by the new zoom
		//this gives you current offset from center so add it to the center 
		//and you have the offset
		//then apply the range function for safety
		offsetX=width/2+(offsetX-width/2)/oldZ*zoom;
		offsetY=height/2+(offsetY-height/2)/oldZ*zoom;
		return this.update();//but its here again
	}
	
	public EMImage SetZoom(float zoomTo) {
		return this.zoom(zoomTo-zoom);//untested, hopefully unused, but you never know, so I am including it
	}
	
	public EMImage SetOffset(float x, float y) {
		return this.move(offsetX-x, offsetY-y);//untested, hopefully unused, but you never know, so I am including it
	}
	
	public float getZoom() {
		return zoom;//setting zoom directly would be problematic so it needed to be private, hence a getter
	}
	
	public EMImage update() {
		//... apparently this stub... is just a stub... yah... I don’t know what i was planning to put here so I will probably remove it unless I remember
		return this;
	}
	
	public Pixel getPixel(int screenX, int screenY) {//gets the img pixel at a screen cord
		int x, y;
		int c;

		x=PApplet.parseInt((screenX-offsetX)/zoom);//+meta.get(layer).offsetX;
		y=PApplet.parseInt((screenY-offsetY)/zoom);//+meta.get(layer).offsetY;
		c=img.get(layer, x, y);
		return new Pixel(x, y, c);
	}
	public int size(){
    return img.size();
  }
	public Pixel get(int x, int y) {//just an obfuscation of img.img.get(...) to img.get(...)
		int c;
		c=img.get(layer, x, y);
		return new Pixel(x, y, c);
	}
		
	public EMImage changeLayer(float direction){//changes the current layer, designed for a mouse wheel, expects a signed input so as to decide which direction to go
		brush.eStop();
		if (direction>0){//I could probiably optimize this, but with the number of layer changes being so low.... why bother
      prevLayer=layer;//do this inside the if so it does not accidentally trigger
			layer=min(img.depth-1,layer+1);
		}else if (direction<0){
      prevLayer=layer;
			layer=max(0,layer-1);
		}
    
		return this;
	}
  public byte[] wrapInt(int toWrap){//a method that wraps an int in a byte[] because write(int) ONLY WRITES THE LOW BYTE TO THE FILE!!!!!!!!
    ByteBuffer temp = ByteBuffer.allocate(4);
    temp.putInt(toWrap);//convert int to ByteBuffer
    byte[] conv=new byte[4];//integers are generally 4 bytes, and if that changes for some reason, the file type still thinks ints are 4 bytes so this is constant
    for(int i=0;i<4;i++){//convert ByteBuffer to byte[] (Since for some reason ByteBuffer does not have a .getBytes or similar)
      conv[i]=temp.get(i);
    }
    return conv;
  }
  public byte[] wrapLong(long toWrap){//I dont know that writing longs does not work, but at this point I dont trust it
    ByteBuffer temp = ByteBuffer.allocate(8);
    temp.putLong(toWrap);//convert int to ByteBuffer
    byte[] conv=new byte[4];//integers are generally 4 bytes, and if that changes for some reason, the file type still thinks ints are 4 bytes so this is constant
    for(int i=0;i<4;i++){//convert ByteBuffer to byte[] (Since for some reason ByteBuffer does not have a .getBytes or similar)
      conv[i]=temp.get(i);
    }
    return conv;
  }
  public boolean saveProject(String file){
    boolean ret=false;
    project.height=img.height;
    project.width=img.width;
    uuid=project.uuid;
    project.meta=meta;
    if(img.img.size()>0){
      project.stackTopHash=this.img.img.get(0).hashCode();
    }
    if(!file.equals("")){
      project.path=file; 
    }
    project.save();
    
    return ret;
  }
	public boolean saveOverlay(File fileName){//saves current layout to JEMO format
    return saveOverlay(fileName.getAbsolutePath());
  }
  public boolean saveOverlay(String path){
    if(saving){
      return false;
    }else{
      saveThread=new SaveThread(path);
    }
      
      
    return true;

	}
	class SaveThread extends Thread{
    String path;
    SaveThread(String inPath){
      path=inPath; 
    }
    public void run(){
      saving=true;
    File fileName;
    int dot=path.lastIndexOf('.');
    String ext="";
    if(dot>=0){
      ext=path.substring(dot ,path.length()).toLowerCase();
    }
    if(!ext.equals(".jemo")){
        path+=".jemo";
    }
    
    project.lastOverlay=path;
    fileName=new File(path);
    try{
      OutputStream file= new BufferedOutputStream(new FileOutputStream(fileName));
      file.write('J'); //setup header
      file.write('E');
      file.write('M');
      file.write('O');
      file.write(1);//write the version number for the file type
      file.write(uuid);
      file.write(wrapInt(layer));//write current active layer, I threw this in because I think when I load an overlay I would want to snap to the last position
      overlay.save(file);//turn the saving over to EMOverlay, we expect it to not close the file
      file.flush();
      file.close();
    }catch(IOException ex){
      saving=false;
    }
    autoSave();
    saving=false;
    }
  }
  public boolean loadOverlay(String filename){
   return loadOverlay(new File(filename)); 
  }
	public boolean loadOverlay(File fileName){//load JEMO file to overlay, replaces overlay

		try{
			InputStream file = new BufferedInputStream(new FileInputStream(fileName));
			byte[] byte4=new byte[4];
			file.read(byte4);
			String var=new String(byte4);//read and test header
      byte ver;//get version number
      ver=(byte)file.read();
			if(!var.equals("JEMO")){
				println("Invalid file type");
				file.close();
				return false;

			}
      if(ver<1){
        println("file version no longer suported");
        file.close();
        return false;
      }
      if(ver>1){
        println("file version not yet suported");
        file.close();
        return false;
      }
      //read and check uuid here
      if(ver==1){
        byte[] byte16=new byte[16];
        file.read(byte16);
        overlay.uuid=byte16;

        for(int i=0;i<16;i++){
           if(uuid[i]!=byte16[i]){
             //warn()
             //println(project.uuid[i]+" "+byte16[i]);
             println("Warning, this file was saved from a different project");
            break;
           }
        }
        
        file.read(byte4);
  			int tLayer=min(ByteBuffer.wrap(byte4).getInt(),img.depth-1);//it is very important we don’t change layer yet, processing multithreads
  			//file io, so this may running parallel to draw, if we change the layer now there is a very good chance we switch to that layer in the overlay
  			//before it exists and we don’t want that
  			overlay.load(file);//pass loading to EMOverlay
        
        if(tLayer<img.depth){//only move if the stack is loaded there too
  			  layer=tLayer;//ok, now that overlay is fully loaded we can safely change layers to the proper layer
        }
  			file.close();
  			}  
      }
  		catch(IOException ex){
  			println(ex);
  			println("exception");
  			return false; 
  		}
      project.lastOverlay=fileName.getAbsolutePath();
      autoSave();
  		return true;
   
	}  
  public int screenX(Pixel p){
    return round((p.x)*zoom+offsetX+zoom/2.f);
  }
  public int screenY(Pixel p){
    return round((p.y)*zoom+offsetY+zoom/2.f);
  }
  public float greyVal(int c){//this averages the RGB values of a given color to determine its grayscale value
    return ((c >> 16 & 0xFF) + (c >> 8 & 0xFF) + (c & 0xFF))/3.0f;//extract and average rgb values
  }
  public EMImage alignLandmarks(int size){return alignLandmarks(size,1);}//because FRIKING JAVA DOES NOT ALLOW DEFAULT ARGUMENTS!!!
  
  public EMImage alignLandmarks(int size, int startLayer){//size is how large of a shift should be considered for a alignment
    for(int l=min(1,startLayer);l<img.depth;l++){
      float bestVal=Float.MAX_VALUE;//large start-
      EMMeta bestPos=new EMMeta();//track the meta of the best spot
      for(int x=-size; x<size;x++){
        for(int y=-size; y<size;y++){
          //println("("+x+","+y+")");//debug line
          float value=0;
          meta.get(l).offsetX=0;
          meta.get(l).offsetY=0;
          for(int i=size;i<img.width-size;i++){
            for (int j=size;j<img.height-size;j++){//5 nested for loops? man I feel bad
              float base =greyVal(img.get(l,x+i,y+j));
              float next=greyVal(img.get(l-1,i,j));//calculate how well the entire image matches to the previous layer
              value+=abs(base-next)/255;
              
            }
          }
          //println(value);
          if(value<bestVal){
            bestVal=value;//check if this shift is better or not
            bestPos.offsetX=-x;
            bestPos.offsetY=-y;
          }
        }
      }
      meta.get(l).offsetX=bestPos.offsetX;
      meta.get(l).offsetY=bestPos.offsetY;
      //println("best ("+bestPos.offsetX+","+bestPos.offsetY+")");
    }
    return this;
  }

}
//this class is a data container for EM meta data, currently it is only th xy shift, but any data that can be applied to a layer as a whole can be put here
class EMMeta{
 public int offsetX;//offset was used by the aligner, but not saved in the overlay, so we are depricating this version of alignment and thus this variable
 public int offsetY;
 EMMeta(){
  offsetX=0;
  offsetY=0;
 }
 public JSONObject exportJSON(){
  JSONObject ret=new JSONObject();
  ret.setInt("offsetX",offsetX);
  ret.setInt("offsetY",offsetY);
  return ret;
 }
 public EMMeta importJSON(JSONObject in){
  offsetX=in.getInt("offsetX");
  offsetY=in.getInt("offsetY");
  return this;
 }
}

/**
EMOverlay is really an obfuscation of ArrayList<PImage> overlay built do decrease the legwork of EMImage
this class tracks the overlay array, the image width, height, and depth, it also handles drawing the overlay
and passes through some functions like get and set to the overlay, additionally EMOvelay handles file IO for its self
EMOverlay does not depend on external access to any custom classes
EMOverlay does depends on void PImage.updatePixels(), void PImage.loadPixels(), PImage.pixels, PImage PImage(int w, int h, int mode), color PImage.get(int x,int y) void PImage.set(int x,int y,color), and void image(PImage img, int x, int y, int xScale, int yScale) from Processing
color must be resolvable to int for save to work
*/
class EMOverlay{
  FBuffer<HistorySnap> history;
  HistorySnap fHistory;
  boolean logChanges=true;
	ArrayList<PNGOverlay> overlay;//PImage stack for storing the overlay
  HashMap<Integer,Integer> key;
  ArrayList<Integer> palette;
  HashMap<Integer,Integer> paletteMap;
	int width;//width of overlay, all PImages in overlay should have same width
	int height;//height of overlay, all PImages in overlay should have same width
	int depth;//number of PImages in overlay
  public byte[] uuid;
  PImage drawCache;
  PImage fastCache;
  PImage cached;
  Pixel lastStart,lastEnd;
  int lastLayer=-1;
  PNGThread pthread; //this is a c joke ;)
  //public ArrayList<EMMeta> meta;//meta data for a given layer
	EMOverlay(int w, int h, int d){
		width=w;//set width height and depth
		height=h;
		depth=0;
		overlay=new ArrayList<PNGOverlay>();
    //meta=new ArrayList<EMMeta>();
    key=new HashMap<Integer,Integer>();
    palette=new ArrayList<Integer>();
    paletteMap=new HashMap<Integer,Integer>();
    palette.add(0);
    paletteMap.put(0,0);
    cached=createImage(w,h,ARGB);
		for( int i=0;i<d;i++){
			addLayer();
		}
    pthread=new PNGThread();
    history=new FBuffer<HistorySnap>(new HistorySnap[programSettings.undoDepth]);
    fHistory=new HistorySnap();
    lastStart=new Pixel(0,0,0);
    lastEnd=lastStart;
	}
  public boolean exists(int layer){
    return key.containsKey(layer); 
  }
	public EMOverlay addLayer(){
    //println("adding "+width+" "+height+" image");
    //meta.add(new EMMeta());
    //overlay.add(new PImage(width,height,ARGB));//populate overlay with blank PImages//removed for keyed stack
    depth++;
    return this;
  }
	public EMOverlay set(int l, int x, int y, int c){//obfuscate overlay.overlay.get(key.get(layer)).set(x,y,c) to overlay.set(layer, x, y, c)
    
    if(!key.containsKey(l)){

      overlay.add(new PNGOverlay(width,height,palette,paletteMap));//add new image to the stack and add its index to the key
      key.put(l,overlay.size()-1);
    }
    if(cached!=null){
      cached.set(x,y,c);
    }else{
      drawCache.set(x,y,c); 
    }
    
    if(logChanges){
      fHistory.log(new Pixel(x,y,overlay.get(key.get(l)).get(x,y)),c);
    }
    if(x<width||x>=0||y<height||y>=0){
		  //overlay.get(key.get(l)).set(x-meta.get(l).offsetX,y-meta.get(l).offsetY,c);
      overlay.get(key.get(l)).set(x,y,c);//we removed meta shifts from the overlay, it does not make sense for the future of this since meta is not stored in the JEMO, but the 3d visualization is only based on the JEMO so if
      //we landmark align the image and save an JEMO, then make a 3d of it, it will be shifted.  combine that with the server based landmark alignment that is planned and overlay shifting is rather hard to justify
    }
		return this;
	}
	
	public int get(int l, int x,int y){//obfuscate overlay.overlay.get(layer).get(x,y) to overlay.get(layer, x, y)
    if(key.containsKey(l)){
		  //return overlay.get(key.get(l)).get(x-meta.get(l).offsetX,y-meta.get(l).offsetY); 
      return overlay.get(key.get(l)).get(x,y);//we removed meta shifts from the overlay, it does not make sense for the future of this since meta is not stored in the JEMO, but the 3d visualization is only based on the JEMO so if
      //we landmark align the image and save an JEMO, then make a 3d of it, it will be shifted.  combine that with the server based landmark alignment that is planned and overlay shifting is rather hard to justify
    }else{
     return 0; 
    }
	}
  public EMOverlay pushHistory(int layer){

      if(fHistory.changed){
         history.push(fHistory); 
      }
      fHistory=new HistorySnap(layer);
      return this;    
  }
  public EMOverlay undo(EMImage parrent){
    HistorySnap temp=history.top();
    history.prev();
    if(temp!=null){
      temp.undo(parrent); 
    }
    
    return this;
  }
  public EMOverlay redo(EMImage parrent){
    history.next();
    HistorySnap temp=history.top();
    
    if(temp!=null){
      temp.redo(parrent); 
    }
    
    return this;
  }
	public EMOverlay draw(EMImage p,Pixel p0, Pixel pe){
    boolean forceCache=false;
    if(key.containsKey(p.layer)){
        if(p.layer!=lastLayer){
          if(pthread.alive){
            pthread.terminate=true;
            try{//I hate java, if I dont want to catch an exception, dont force me to
              pthread.join();
            }catch (InterruptedException e) {
              e.printStackTrace();
           }
           
          }
          pthread=new PNGThread();
          pthread.terminate=false;
          pthread.in=overlay.get(key.get(p.layer));
          cached=null;
          
          pthread.retv=cached;
          new Thread(pthread).start();
          lastLayer=p.layer;
          forceCache=true;
          drawCache=createImage(width,height,ARGB);
          pushHistory(lastLayer);
        }
        if(cached!=null){
            if(drawCache!=null){
              cached=merge(cached,drawCache);
              drawCache=null;
            }
            //image(cached,p.offsetX+p.meta.get(p.layer).offsetX*p.zoom, p.offsetY+p.meta.get(p.layer).offsetY*p.zoom, this.width*p.zoom, this.height*p.zoom);
            image(cached,p.offsetX, p.offsetY, this.width*p.zoom, this.height*p.zoom);//we removed meta shifts from the overlay, it does not make sense for the future of this since meta is not stored in the JEMO, but the 3d visualization is only based on the JEMO so if
      //we landmark align the image and save an JEMO, then make a 3d of it, it will be shifted.  combine that with the server based landmark alignment that is planned and overlay shifting is rather hard to justify
        }else{
          if(pthread.retv!=null){
           cached=pthread.retv; 
          }
          if(p0.x!=lastStart.x||p0.y!=lastStart.y||pe.x!=lastEnd.x||pe.y!=lastEnd.y||forceCache){
            fastCache=overlay.get(key.get(p.layer)).fastGet(p0.x,p0.y,pe.x,pe.y);
            //drawCache=merge(fastCache,drawCache);
          }
          
          //this is not ideal, but it is easier than trying to merge them
          image(fastCache,p.offsetX+p.meta.get(p.layer).offsetX*p.zoom, p.offsetY+p.meta.get(p.layer).offsetY*p.zoom, this.width*p.zoom, this.height*p.zoom);
          image(drawCache,p.offsetX+p.meta.get(p.layer).offsetX*p.zoom, p.offsetY+p.meta.get(p.layer).offsetY*p.zoom, this.width*p.zoom, this.height*p.zoom);
          //image(temp,p.offsetX+p0.x*p.zoom+p.meta.get(p.layer).offsetX*p.zoom+.5,p.offsetY+p0.y*p.zoom+p.meta.get(p.layer).offsetY*p.zoom+.5,(pe.x-p0.x+1)*p.zoom,(pe.y-p0.y+1)*p.zoom);//this line took a loooooooot of trial an error, trust that it is right
          //never the less, it is off by less than 1 screen pixel).... not sure how to fix it
          lastStart=p0;
          lastEnd=pe;
          //PImage temp=overlay.get(key.get(p.layer)).fastGet(p0.x,p0.y,pe.x,pe.y);
          //image(temp,p.offsetX+p0.x*p.zoom+p.meta.get(p.layer).offsetX*p.zoom+.5,p.offsetY+p0.y*p.zoom+p.meta.get(p.layer).offsetY*p.zoom+.5,(pe.x-p0.x+1)*p.zoom,(pe.y-p0.y+1)*p.zoom);//this line took a loooooooot of trial an error, trust that it is right
          //never the less, it is off by less than 1 screen pixel).... not sure how to fix it  
        }
    }
    return this;
  }
  public EMOverlay draw(int layer,float x,float y,float zX,float zY){//draw current layer
    if(key.containsKey(layer)){
      if(overlay.size()>layer){
        if(layer!=lastLayer){
          cached = overlay.get(key.get(layer)).getImage();
          lastLayer=layer;
        }
        image(cached,x,y,zX,zY);
      }
    }
    return this;
  }
 
	
	public byte[] wrapInt(int toWrap){//a method that wraps an int in a byte[] because write(int) ONLY WRITES THE LOW BYTE TO THE FILE!!!!!!!!
		ByteBuffer temp = ByteBuffer.allocate(4);
		temp.putInt(toWrap);//convert int to ByteBuffer
		byte[] conv=new byte[4];//integers are generally 4 bytes, and if that changes for some reason, the file type still thinks ints are 4 bytes so this is constant
		for(int i=0;i<4;i++){//convert ByteBuffer to byte[] (Since for some reason ByteBuffer does not have a .getBytes or similar)
			conv[i]=temp.get(i);
		}
		return conv;
	}
	//convert to JEMO v.1 major fixes needed, taken temporaroly off line
	public EMOverlay save(OutputStream file) throws IOException{//this writes the overlay to a JEMO file

		file.write(wrapInt(width));//write width, height, and depth
		file.write(wrapInt(height));
		file.write(wrapInt(depth));
    for(int i=palette.size()-1;i>0;i--){//create pallete
      int c=palette.get(i);
      if(c==0){
        palette.remove(i);//there should be no null colors in the palette other than index 0, if there are, destroy them
      }else{
       
       file.write(wrapInt(c));//wrap the colors nice and tight in a byte array, this should be in the correct order, but there is a chance that this is in RGBA order, if it is, change the JEMO protocal to match 
      } 
    }
    file.write(wrapInt(0));//write 0x00000000, this should terminate the palette array with the null color
		int firstLayer=-1;
    int lastLayer=-1;
    for(int i=0;i<depth;i++){//find first and last layer
      if(key.containsKey(i)&&exists(i)){
        if(firstLayer<0){
          firstLayer=i;
        }
        lastLayer=i;
      } 
    }
    lastLayer++;
    file.write(wrapInt(firstLayer));
    int colorSize=ceil((log(palette.size())/log(2))/8);//calculate how many bytes are required for a layer
    for(int i=firstLayer;i<lastLayer;i++){//process layers
      
      if(key.containsKey(i)&&exists(i)){
        overlay.get(key.get(i)).toJEMOv1(colorSize,file);//write all pixels of layer i
      }else{
        byte[] scrap=new byte[colorSize+6];//get enough zeros
        scrap[0]=1;//prevent file terminating, only terminate layer
        file.write(scrap);
      } 
		}
      byte[] scrap=new byte[colorSize+6];//get enough zeros,colorSize for the color, 4 for the offset, and 2 for the length
      file.write(scrap);//terminate file
		return this;
	}
	public EMOverlay set(int x, int y, int c){
    this.set(img.layer,x,y,c);
    return this;
  }
  //update to JEMO v.1
	public EMOverlay load(InputStream file) throws IOException{//load overlay from JEMO file

		byte[] temp=new byte[4];
		file.read(temp);
		width=ByteBuffer.wrap(temp).getInt();//get the width, height, and depth
		file.read(temp);
		height=ByteBuffer.wrap(temp).getInt();
		file.read(temp);
		depth=ByteBuffer.wrap(temp).getInt();
		//ArrayList<PImage>tOverlay=new ArrayList<PImage>();//generate temportary overlay, safer

    key=new HashMap<Integer,Integer>();//dump old overlay and make a new one
    overlay=new ArrayList<PNGOverlay>();
    palette=new ArrayList<Integer>();
    paletteMap=new HashMap<Integer,Integer>();
    
    int c=1;
    ArrayList<Integer> inversePalette=new ArrayList<Integer>();
    while(c!=0){
      file.read(temp);
      c=ByteBuffer.wrap(temp).getInt();
      inversePalette.add(c);
    }
    for(int i=inversePalette.size()-1;i>=0;i--){
       palette.add(inversePalette.get(i));
       paletteMap.put(inversePalette.get(i),palette.size()-1);//this should work I think, but if the colors are screwed up this is probiably why
    }
    inversePalette=null;
    int colorSize=ceil((log(palette.size())/log(2))/8);//calculate how many bytes are required for a layer
    boolean run=true;
    file.read(temp);
    int layerCount=ByteBuffer.wrap(temp).getInt();
    
    
		while(run){
      
      PNGOverlay layer=new PNGOverlay(width,height,palette,paletteMap);
			run=!layer.fromJEMOv1(colorSize,file);//continue reading if not terminated
      
      if(run){
        //println("added layer at "+layerCount);
        overlay.add(layer);
        key.put(layerCount,overlay.size()-1);
      }
      layerCount++;
			//Overlay.add(fromByteArray(temp,width,height));//read all pixels of layer i
		}

    //overlay=tOverlay;
    lastLayer=-1;//reset layer cache by making the program think we just changed layers
		return this;
	}
	


public PImage merge(PImage _1, PImage _2){
    PImage ret=_1.get(); 
    ret.loadPixels();
    _2.loadPixels();
    for(int i =0;i<ret.pixels.length;i++){
         if(_2.pixels[i]!=0){
           ret.pixels[i]=_2.pixels[i];
         }
        
     }
     ret.updatePixels();
    return ret;
  }
}
 
//because I wanted full random for uuid, dont worry about it

class EMProject{
  //these are used to verify that the stack is still the same stack
  String path="";
  String savedBy;
  int version;
  int numFiles;//number of files in the dir incase some are not .(extension)
  String stackPath;//check if exists, speculate arround if it does not
  String stackTopName;//name of the top image in the stack
  String lastOverlay;
  int stackTopHash;//just the hash of the top
  int width,height;//image size
  boolean stackLoaded;//if we finished load so we can hash and count the stack before the project was saved
  int stackSize;//number of files loaded
  int stackHash;
  //unique project identifier
  byte[] uuid;
  //some conditions about the project when it was saved
  ArrayList<EMMeta> meta;
  EMProject(){
    uuid=createUUID();
    stackPath="";
    stackTopName="";
    meta=new ArrayList<EMMeta>();
  }
  EMProject(String path){
    this();
    importJson(loadJSONObject(path)); 
    this.path=path;
  }
  public EMProject autoSave(){
   if(!path.equals("")){
      save();
   }
   return this;
  }
  public EMProject save(){
    if(path.equals("")){
      selectOutput("Select project file","save",null,this);
    }else{
      save(path); 
    }
    
    return this;
  }
  public EMProject save(File file){
    if(file!=null){
      path=file.getAbsolutePath();
      save(path);
    }
    return this;
    
  }
  public EMProject save(String file){
    saveJSONObject(exportJSON(),file);
    return this;
  }
  public JSONObject exportJSON(){

    JSONObject ret=new JSONObject();
    ret.setInt("version",1);
    ret.setString("savedBy",VERSION);
    ret.setInt("numFiles",numFiles);
    ret.setString("stackPath",stackPath);
    ret.setString("topFileName",stackTopName);
    ret.setInt("topFileHash",stackTopHash);
    ret.setInt("width",width);
    ret.setInt("height",height);
    ret.setBoolean("stackLoaded",stackLoaded);
    ret.setString("lastOverlay",lastOverlay);
    if(stackLoaded){
      ret.setInt("stackSize",stackSize);
      ret.setInt("stackHash",stackHash);
    }
    ret.setString("UUID",exportUUID());

    JSONArray mData=new JSONArray();
    for(int i=0;i<meta.size();i++){
      mData.setJSONObject(i,meta.get(i).exportJSON()); 
    }
    ret.setJSONArray("Meta",mData);

    return ret;
  }
  public EMProject importJson(JSONObject in){
    int c=0;
    lastOverlay=in.getString("lastOverlay");
    version=in.getInt("version");
    savedBy=in.getString("savedBy");
    numFiles=in.getInt("numFiles",numFiles);
    stackPath=in.getString("stackPath");
    stackTopName=in.getString("topFileName");
    stackTopHash=in.getInt("topFileHash");
    width=in.getInt("width",width);
    height=in.getInt("height",height);
    stackLoaded=in.getBoolean("stackLoaded");
    if(stackLoaded){
      stackSize=in.getInt("stackSize");
      stackHash=in.getInt("stackHash");
    }
    importUUID(in.getString("UUID"));
    JSONArray mData=in.getJSONArray("Meta");
    
    for(int i=0;i<mData.size();i++){
      EMMeta Meta=new EMMeta();
      Meta.importJSON(mData.getJSONObject(i));
      meta.add(Meta);
    }
    return this;
  }
  public byte[] createUUID(){
    SecureRandom random=new SecureRandom();//I know, I know, a bit over kill for a uuid
    byte[] ret=random.generateSeed(16);
    ret[6]=PApplet.parseByte((ret[6])|0x40);
    ret[6]=PApplet.parseByte(ret[6]&0x4f);//sets 4 highest bits of 7th byte to 0100 because RFC4122 requires it for some reason
    ret[8]=PApplet.parseByte(ret[8]|0x80);
    ret[8]=PApplet.parseByte(ret[8]&0xbf);//sets 2 highest bits of 9th byte to 10 also for no good reason
    
    //yah, I am not going to encode the UUID as a string, do I look like someone who would just willy nilly increase the size of an id by 16x?
    return ret;
  }
  public String exportUUID(){//ok so I will encode it if you want
    String ret="";
    if(uuid==null){
      return "no uuid created for this project";
    }
    if(uuid.length!=16){
      return "malformed uuid";
    }
    for(int i=0;i<16;i++){
     if(i==4||i==6||i==8||i==10){
      ret+='-'; 
     }
     ret+=hex(uuid[i]);    
    }
    return ret;
  }
  public EMProject importUUID(String in){
    String uuidString="";
    for(int i=0;i<in.length();i++){
      if(in.charAt(i)!='-'){
        uuidString+=in.charAt(i); 
      }
    }
    uuid=DatatypeConverter.parseHexBinary(uuidString);
    return this;
  }
  
}
/**
	EMStack is really an obfuscation of ArrayList<PImage> img built to decrease the legwork of EMImage
	it passes though many useful functions such as add, size, and get
	EMStack does not depend on any custom classes
	EMStack does depend on PImage, color, PImage loadImage(String path), and image(PImage img, int x, int y, int xScale, int yScale) from processing
*/
class EMStack{
	int width;//img width
	int height;//img height
	int depth;//number of images in stack 
	ArrayList<PNGImage> img;
  File[] files;
  String extension;
  int progress;
  PImage cached;
  PImage fastCache;
  Pixel lastStart,lastEnd;
  int lastLayer=-1;
  ThreadStack ts;
  PNGThread pthread; //this is a c joke ;)
  EMOverlay overlay;
  public ArrayList<EMMeta> meta;//meta data for a given layer
	EMStack(){//new empty EMStack
		img=new ArrayList<PNGImage>();
    overlay=new EMOverlay(0, 0, 0);//create a overlay for the stack
    meta=new ArrayList<EMMeta>();
    lastStart=new Pixel(0,0,0);
    lastEnd=lastStart;
	}
	EMStack(String dir){//new EMStack seeded from picture file by path
		this(new File(dir)); 
	}    
	public int hashCode(){
    long hash=0;
    for(int i=0;i<depth;i++){
      hash+=img.get(i).hashCode();
           
    }
    //println(hash);
    //println(depth);
    return (int)hash;
  }
	EMStack(File base){//new EMStack seeded from picture file
		this();
		File folder=new File(base.getParent());//this gets the parrent folder of the given image
   extension=base.getName();//extract img type
   extension=extension.substring(extension.lastIndexOf('.'),extension.length()-1);
   files=folder.listFiles();//get all files in folder
		Arrays.sort(files);//this fixes file order on linux
    frameLoadStack();//load 1 layer so the rest of the program does not complain
  
		ts=new ThreadStack(this);//load the full dir to the stack in sepperate thread
    //new Thread(ts).start();//this line would trigger a race condition with the thread stack updating a project vs an EMImage being initilized
    pthread=new PNGThread();
    
		
		
	}
  public EMStack launch(){
    new Thread(ts).start(); 
    return this;
  }
	public EMStack frameLoadStack(){
    
    if(progress<files.length){
    if (files[progress].isFile()) {
      if (files[progress].getName().contains(extension)){//only attempt to load a file if the file types match existing
        //println("loading PImage");
        PImage temp=loadImage(files[progress].getPath());
        //println("Creating PNG");
        PNGImage tempPng=new PNGImage(temp);
        //println("Converting to PNG");
        tempPng.genPalette(temp,1);
        //println("adding PNG to stack");
        add(tempPng);
        //println(tempPng.hashCode());
        //println("done frame load");  
      }
    }
    
    progress++;
    this.width=img.get(0).width;
    this.height=img.get(0).height;//update width, height, and depth
    this.depth=img.size();
    //println("meta data updated");
    }
    return this;
  }
  public EMStack add(PNGImage image){
    
    
   // println("updating meta");
    this.width=image.width;
    this.height=image.height;//update width, height, and depth
    overlay.height=height;
    overlay.width=width;
    
    //println("creating new overlay layer");
    overlay.addLayer();
    meta.add(new EMMeta());
    //println("adding image to stack");
    img.add(image);
    depth=img.size();
    //println("finished add");
    return this;
  }
	public EMStack add(PImage image){//add a new image to the stack, can be dangerous if EMOverlay and meta are not updated with the additional layer
		
    //println("creating PNGImage");
    PNGImage temp=new PNGImage(image);
    //println("Converting to PNG");
    temp.genPalette(image,1);
    return add(temp);
    //println("updating meta");
	}
  public EMStack draw(EMImage p,Pixel p0, Pixel pe){
    boolean forceCache=false;
    if(img.size()>p.layer){
      if(p.layer!=lastLayer){
        if(pthread.alive){
          pthread.terminate=true;
          try{//I hate java, if I dont want to catch an exception, dont force me to
            pthread.join();
          }catch (InterruptedException e) {
            e.printStackTrace();
         }
         
        }
        pthread=new PNGThread();
        pthread.terminate=false;
        pthread.in=img.get(p.layer);
        cached=null;
        pthread.retv=cached;
        new Thread(pthread).start();
        lastLayer=p.layer;
        forceCache=true;//we have just set last layer to current layer, so any further tests of last layer in this function must rely on this instead
      }
      if(cached!=null){
          
          image(cached,p.offsetX+p.meta.get(p.layer).offsetX*p.zoom, p.offsetY+p.meta.get(p.layer).offsetY*p.zoom, this.width*p.zoom, this.height*p.zoom);
      }else{
        if(pthread.retv!=null){
         cached=pthread.retv; 
        }
        if(p0.x!=lastStart.x||p0.y!=lastStart.y||pe.x!=lastEnd.x||pe.y!=lastEnd.y||forceCache){
          fastCache=img.get(p.layer).fastGet(p0.x,p0.y,pe.x,pe.y);
    
        }
        image(fastCache,p.offsetX+p.meta.get(p.layer).offsetX*p.zoom, p.offsetY+p.meta.get(p.layer).offsetY*p.zoom, this.width*p.zoom, this.height*p.zoom);
        //image(temp,p.offsetX+p0.x*p.zoom+p.meta.get(p.layer).offsetX*p.zoom+.5,p.offsetY+p0.y*p.zoom+p.meta.get(p.layer).offsetY*p.zoom+.5,(pe.x-p0.x+1)*p.zoom,(pe.y-p0.y+1)*p.zoom);//this line took a loooooooot of trial an error, trust that it is right
        //never the less, it is off by less than 1 screen pixel).... not sure how to fix it
        lastStart=p0;
        lastEnd=pe;
      }
    }
    return this;
  }
	public EMStack draw(int layer,float x,float y,float zX,float zY){//draw current layer
    
    if(img.size()>layer){
      if(layer!=lastLayer){
        cached = img.get(layer).getImage();
        lastLayer=layer;
      }
		  image(cached,x,y,zX,zY);
    }

		return this;
	}
	
	public int size(){//obfiscates img.img.size() to img.size()
		return img.size();
	}
	
	public int get(int layer, int x,int y){//obfuscates img.img.get(layer).get(x,y) to img.get(x,y)
    if(layer<img.size()){
		  return img.get(layer).get(x-meta.get(layer).offsetX,y-meta.get(layer).offsetY);
    }else{
      return 0;//if the layer is out of frame, return a 0 color
    }
	}

}
public class EdgeFinderSettings extends PApplet 
  {
    Ui ui;
    int picker=0;
    float lightest;
    float variation;
    float repeats;
    Binding<Integer> lightnessValue;
    Binding<Integer> variationValue;
    public void settings() {
      
      ui=new Ui();
      // init them: (xPos, yPos, width, height)
      lightnessValue=new Binding<Integer>(80);
      variationValue=new Binding<Integer>(190);
      ui=edgeFinderUiBuild(this);
      
      size(600, 130);//Set the size of the pop up window
      //colorRangeSliders[0] = new Colors(80, 20, 40, 20, 65, 255); //and the location, width, and height of each slider and button
      //colorRangeSliders[1] = new Colors(80, 60, 40, 20, 75, 255);
      //repeatSliders[0] = new Repeats(80, 100, 40, 20);
      //newWindowButtons[0] = new Buttons(660, 30, 75, 75);
      //undo = Ui_Button//new Undo(750, 30, 75, 75);//I have added undo to the keyboard so im not sure if we need it here naymore
    }
    
    public void setup(){
      surface.setSize(round(ui.calcWidth()+programSettings.monitorPPI*.1f),round(ui.calcHeight()+programSettings.monitorPPI*.1f)); 
      surface.setTitle("Edge Finder Settings"); 
    }
    
    public void draw(){
      background(100);
      ui.draw();      
    }
    
    //This is how the parameters are passed back to the main form
    public float[] getParameters(){
      float[] parameters = new float[]{lightest, variation, repeats};
      return parameters;
    }
    
  class LightestSlider extends VariableLambda{
    public void run(int x){
      lightest=x; 
    }
  }
  class VariationSlider extends VariableLambda{
    public void run(int x){
      variation=x; 
    }
  }
  class RepeatsSlider extends VariableLambda{
    public void run(int x){
      repeats=x; 
    }
  }
  class PickerLambda extends Lambda{
    int target;
    PickerLambda(int x){
      target=x;
    }
    public void run(){
       picker=target;
    }
  }
  public Ui edgeFinderUiBuild(PApplet dm){  
    Ui ui=new Ui(dm);//prep ui
     PImage tImg=new PImage(500,30,ARGB);
      tImg.loadPixels();
      for(int i=0;i<tImg.pixels.length;i++){
        tImg.pixels[i]=tColor(150,150,100); 
      }
      tImg.updatePixels();
    {//lightness slider,
     
      Ui_Slider build=new Ui_ColorSlider(1.3f,0.1f,5.65f, tImg);
      build.onChange=new LightestSlider();
      
      build.setValue(65);
      build.slider.resize(round(build.slider.width*2.2f),build.slider.height);
      build.boundValue=lightnessValue;
      ui.add(build);
    }
    {
      Ui_TextPanel build =new Ui_TextPanel(0.3f,0.1f,.9f,.35f,tColor(150,150,150));
      build.textColor=0;
      build.size=16;
      build.lable="Average:";
      build.offsetY=.5f;
      build.offsetX=.1f;
      ui.add(build);
    }
    {//variation slider,

      Ui_Slider build=new Ui_ColorSlider(1.3f,.5f,5.65f, tImg);
      build.onChange=new VariationSlider();
     
      build.setValue(75);
      build.slider.resize(round(build.slider.width*2.2f),build.slider.height);
      build.boundValue=variationValue;
      ui.add(build);
    }
    {
      Ui_TextPanel build =new Ui_TextPanel(0.3f,0.5f,.9f,.35f,tColor(150,150,150));
      build.textColor=0;
      build.size=16;
      build.lable="Variation:";
      build.offsetY=.5f;
      build.offsetX=.1f;
      ui.add(build);
    }
    {//reapeats slider,
      Ui_Slider build=new Ui_Slider(1.3f,.9f,6, tImg);
      build.onChange=new RepeatsSlider();
      build.minV=4;
      build.maxV=100;
      build.slider.resize(round(build.slider.width*2.2f),build.slider.height);
      ui.add(build);
    }
    {
      Ui_TextPanel build =new Ui_TextPanel(0.3f,0.9f,.9f,.35f,tColor(150,150,150));
      build.textColor=0;
      build.size=16;
      build.lable="Repeats:";
      build.offsetY=.5f;
      build.offsetX=.1f;
      ui.add(build);
    }
    {
      PImage mask=loadImage("ui/buttonColorMap.png");//... ok processing... I have had enough of you....., what the frick do you call this!
      //why would need to load all images from the main thread????
      Ui_RadioButton buildRadio=new Ui_RadioButton(1);//prep radio button for pickers
      buildRadio.id="pickers";
      {//add buttons to radio button
          Ui_Button build=new Ui_Button(7.25f,0.1f,.33f,"ui/colorPicker.png");
          build.setPressedImg("ui/colorPickerActive.png");
          build.setHighlightedImg("ui/highlight.png");
          //build.c=0;
          build.background=mask;
          build.onActivate=new PickerLambda(1);
          build.onDeactivate=new PickerLambda(0);
          buildRadio.add(build);
      }//lightness color picker
      {//add buttons to radio button
          Ui_Button build=new Ui_Button(7.25f,0.5f,.33f,"ui/colorPicker.png");
          build.setPressedImg("ui/colorPickerActive.png");
          build.setHighlightedImg("ui/highlight.png");
          //build.c=0;
          build.background=mask;
          build.onActivate=new PickerLambda(2);
          build.onDeactivate=new PickerLambda(0);
          buildRadio.add(build);
      }//variation color picker
      ui.add(buildRadio);//add the radio button (and all sub buttons) to the ui
    }
    ui.setDM(dm);
    return ui;
  }
  public PImage loadImage(String path){//because WHY NOT!!!! >:(
   return imgFromFile(path); 
  }
}
//FBuffer is fast buffer, it works like a queue except that it never grows and objects fall off the end.
//To make this work we have a finite array and then we move the start of the array to a different location in the array
//for all accesses, this way its like we shift the entire array over, but we never have to move anything
class FBuffer<T>{
 T[] array;
 private int startIndex;//this is the 0 index right now, subject to change. but we reeaaly dont want someone else changing it on us
 int size;
 int first;//index of top most set by most recent push or pop
 int written;//total number written, not greater than or equal to size
 FBuffer(T[] useThis){//supply the class with a pre initilised array to use because java is a real pain in the ass almost all the time and you cant easily create a new array of generic objects for no good reason
    startIndex=0;
    array = useThis;//useThis is sacrificial, we really dont care what it is, and we will over write all of it
   
    size=array.length; 
    for(int i=0;i<size;i++){//speaking of overwriting, lets do that now, for saftey
      array[i]=null;
    }
    
 }
 public T get(int i){//because I cant overload [] operator for some reason
   return array[(((startIndex-i)%size)+size)%size];
 }
 public FBuffer set(int i, T content){//because I cant overload [] operator for some reason
   array[(((startIndex-i)%size)+size)%size]=content;
   return this;
 }
 public T top(){
  return this.get(0); 
 }
 public T next(){
   if(startIndex==first){
     return null; 
   }else{
    startIndex=(startIndex+1)%size;

    return this.get(0);  
   }
 }
 public T prev(){
   if((((first-startIndex)%size)+size)%size>=written){
     return null; 
   }else{
     startIndex=((startIndex-1)+size)%size;
     
     return this.get(0);  
   }
   
 }
 public FBuffer push(T content){//supprisingly I would not want to overload anything for this
   startIndex=(startIndex+1)%size;//I dont think startIndex can be negative under these rules
   array[startIndex]=content;
   
   first=startIndex;
   written=min(written+1,size);
   return this;
 }
 public T pop(){//same here;
   T temp=array[startIndex];
   array[startIndex]=null;
   startIndex=((startIndex-1)+size)%size;//I think we can skip the first mod in this case, not sure though
   first=startIndex;
   written=max(written-1,0);
   return temp; 
 }
 public boolean isEmpty(){
   for(int i=0;i<size;i++){//speaking of overwriting, lets do that now, for saftey
      if(array[i]!=null){
        return true; 
      }
    }
    return false;
 }
}
class HistorySnap{
  int layer;//layer the snap was taken on
  ArrayList<Pixel>before;
  ArrayList<Integer>after;
  boolean changed=false;
  HistorySnap(){
    before=new ArrayList<Pixel>();
    after=new ArrayList<Integer>();
  }
  HistorySnap(int l){
    this();
    layer=l;
  }
  public HistorySnap log(Pixel point, int change){
    if(point.c!=change){
      before.add(point);
      after.add(change);
      changed=true;
    }
    if(before.size()>12000000){
      System.err.println("Warning, this log is getting large, you may crash if you keep making logs this size");
    }
    return this;
    
  }
  public HistorySnap redo(EMImage target){
    target.overlay.logChanges=false;
    for(int i=0;i<before.size();i++){
      target.overlay.set(layer,before.get(i).x,before.get(i).y,after.get(i));
    }
    target.overlay.logChanges=true;
    target.layer=layer;
    return this;
  }
  public HistorySnap undo(EMImage target){
    target.overlay.logChanges=false;
   
    for(int i=0;i<before.size();i++){
      target.overlay.set(layer,before.get(i).x,before.get(i).y,before.get(i).c);
    }
    target.overlay.logChanges=true;
    target.layer=layer;
    return this;
  }
}
/**
implements a rough lambda concept since processing does not have it by default
the Lambda class is technically abstract, but has been declared otherwise so as a empty Lambda can be created by default
this has been implemented to allow clickable buttons
collectively all implemented lambda functions depend on access to global EMImage img, Brush img.brush, int img.brush, void img.brush.update(), void img.brush.clearBrush(), void img.save(), void img.load()
these also depend on void selectInput(String path, String function, Object this) and void selectOutput(String path, String function,Object this) from processing
*/


class Lambda{
  Lambda(){}//all lambda objects will have a default constructor and run()
  public void run(){}
}
class VariableLambda extends Lambda{
  VariableLambda(){}//all lambda objects will have a default constructor and run()
  public void run(int variable){}
  
}
class SizeSlider extends VariableLambda{
  public void run(int x){
    img.brush.setSize(x*2+1);
  }
}
class EdgeFinderThreshold extends VariableLambda{
  
}
class CircleBrush extends Lambda{//allows for circle brush button
  public void run(){
   
    img.brush= new BrushCircle(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)sidebar.ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button
     
  }
}

class SquareBrush extends Lambda{//allows for square brush button
  public void run(){
  
            
    img.brush= new BrushSquare(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)sidebar.ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button
     
  }
}
class PickerBrush extends Lambda{//allows for color picker brush button
  public void run(){
  
            
    img.brush= new BrushPicker(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)sidebar.ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button
     
  }
}
class RayCastBrush extends Lambda{//allows for raycast brush button
  public void run(){
 
       img.brush= new RayCast(img.brush.c,img.brush.img,img.brush.size);
      img.brush.erase=((Ui_Button)sidebar.ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button

  }
}
class DiamondBrush extends Lambda{//allows for diamond brush button
  public void run(){
    
    img.brush= new BrushDiamond(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)sidebar.ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button
      
  }
}

class FloodBrush extends Lambda{//allows for flood fill button
  public void run(){
         
    img.brush= new BrushFill(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)sidebar.ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button
    
  }
}
class BlackHoleBrush extends Lambda{//allows for flood fill button
  public void run(){
         
    img.brush= new BrushBlackHole(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)sidebar.ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button
    
  }
}
/* posibly out dated with new polymorphic Brushes
class ClearBrush extends Lambda{//allows for clear brush button that is tuned to specific brush via constructor
  int n;
  ClearBrush(){//just to be safe
    n=0; 
  }
  
  ClearBrush(int in){//allow specification of brush to clear, helps prevent radio button errors
    n=in;
  }
  
  void run(){
    img.brush.clearBrush(n);
  }
}*/
class LColor extends Lambda{
 int col;
 LColor(){this(0);}
 LColor(int c){
   col=c;
 }
 public void run(){
   img.brush.c=col;
   img.brush.update();
 }
}
class ClearBrush extends Lambda{//allows for clear brush button that is tuned to specific brush via constructor
  ClearBrush(){}
  ClearBrush(int in){}//we no longer care which brush it is, that ship has been fixed and retired to a museum
  public void run(){img.brush= new Brush(img.brush.c,img.brush.img,img.brush.size);}
}
class EraserBrush extends Lambda{//allows for erase mode button
  boolean state;
  EraserBrush(boolean b){
    state=b;
  }
  
  public void run(){
    img.brush.erase=state;

  }
}

public class Save extends Lambda{//allows for overlay save button
        public void run(){
          if(img.project.path.equals("")){
             selectOutput("Select file to save Project","handler2",null,this);
          }
          selectOutput("Select file to save overlay","handler",null,this);
        
        }
  
  public void handler(File f){//this gets called by selectOutput when the output is selected
    if(f!=null){
       
      img.saveOverlay(f); 
      
    }
    
  }
  public void handler2(File f){//this gets called by selectOutput when the output is selected
    if(f!=null){
      String path=f.getAbsolutePath();
      
      String ext=""; 
      int dot=path.lastIndexOf('.');
      if(dot>=0){
        ext=path.substring(dot,path.length()).toLowerCase();
      }
      if(!ext.equals(".caster")){
        path+=".caster";
      }
      img.project.path=path;
      programSettings.lastProject=img.project.path;
      autoSave();
    }
    
  }
}

public class Load extends Lambda{//allow for overlay load button 
  public void run(){
	  selectInput("Select a file to Load","load");
    //selectInput("Select file to load","handler",new File(""),this);
  }

  //public void handler(File f){//this gets called by selectInput when the input is selected
  //  img.loadOverlay(f);
  //}
}
public class EdgeFollowingBrush extends Lambda{//Edgefollowing trigger
  BrushEdgeFollowing brush;
  boolean first=true;
  public void run(){
    if(first){
      brush=new BrushEdgeFollowing(img.brush.c,img.brush.img,img.brush.size);
    }
    first=false;
    brush.c=img.brush.c;
    brush.size=img.brush.size;
    img.brush= brush;
    img.brush.erase=((Ui_Button)sidebar.ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button
  }
 
}
public class EdgeFollowingBrushDestroy extends Lambda{//I am guessing anti edgefollowing trigger, but I dont know
  public void run(){
    img.brush= new Brush(img.brush.c,img.brush.img,img.brush.size);
  }
 
}

public class AxonBrush extends Lambda{//Edgefollowing trigger
  Axon brush;
  boolean first=true;
  public void run(){
    if(first){
      brush=new Axon(img.brush.c,img.brush.img,img.brush.size);
    }
    first=false;
    brush.c=img.brush.c;
    brush.size=img.brush.size;
    img.brush= brush;
    img.brush.erase=((Ui_Button)sidebar.ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button
  }
 
}
public class AxonBrushDestroy extends Lambda{//I am guessing anti edgefollowing trigger, but I dont know
  public void run(){
    img.brush= new Brush(img.brush.c,img.brush.img,img.brush.size);
  }
 
}


public class BlankButton extends Lambda{//blank button for testing, hyjack all you want
  public void run(){
    //img.alignLandmarks(5);//hyjacked for stack alignment
    //LayerSeeded.seedFromPrev(img);//hyjack for seeding
    //img.saveProject(new File("D:\\project.json"));//hyjack for saving project
    //img.brush=new BrushBlackHole(img.brush.c,img.brush.img,img.brush.size);
    img.brush=new BrushRuler(img.brush.c,img.brush.img,img.brush.size);

  }

}
public class Create3D extends Lambda{
  boolean window=false;
  
  String[] args={""};
  Create3D(){
   view3D=new Visulization3D();
  }
  public void run(){
    if(YES_OPTION==showConfirmDialog (null, "WARNING! 3D view is a slow process, Are you sure you want to continue? (Saving first is recomended)","Warning",YES_NO_OPTION)){
      view3D.cloud=img.overlay;
      if(!window){
        PApplet.runSketch(args,view3D);
        window=true;
      }else{
        view3D.prep();
      }
    }
  }
  
}
/*
  This class might need fixing
*/
public static class LayerSeeded{
  public static void seedFromPrev(EMImage img){
    //img.overlay.overlay.set(img.layer,img.overlay.overlay.get(img.prevLayer).get());//simple way for debugging
    PNGOverlay minimal=img.overlay.overlay.get(img.prevLayer);
    PNGOverlay simple=minimal.get();
    for(int i =0;i<minimal.width;i++){
       for( int j=0;j<minimal.height;j++){
           int count=0;
           int c=minimal.get(i,j);
           count+=PApplet.parseInt(minimal.get(i+1,j+0)==c);
           count+=PApplet.parseInt(minimal.get(i-1,j+0)==c);
           count+=PApplet.parseInt(minimal.get(i+0,j+1)==c);
           count+=PApplet.parseInt(minimal.get(i+0,j-1)==c);
           if(count>3){
              simple.set(i,j,0);
           }
       }
    }
    img.overlay.overlay.set(img.layer,img.overlay.overlay.get(img.layer).merge(simple.get()));
  }
}
//a link in my loop list data type (only for vertecis) it tracks the next, the last, and its own index aswell as the data type, 
class ListWheel{
  Vertex v;
  int i;
  ListWheel lower;
  ListWheel higher;
  ListWheel(Vertex vert){//call only as first call
     v=vert;
     i=0;
     lower=this;
     higher=this;
  }
  ListWheel(Vertex vert, ListWheel l, ListWheel h){
    v=vert;
     lower=l;
     i=lower.i+1;
     higher=h;
     higher.updateI();
  }
  
  public ListWheel updateI(){
    if(i==0){
      
    }else{
      i=lower.i+1;
      if(higher.i!=i+1){
       higher.updateI(); 
      }
    }     
    return this;
  }
  
  public Vertex get(){
   return v;
  }
  
  public ListWheel set(Vertex vert){
   this.v=vert;
   return this;
  }
}
class Loop{
  LoopList nodes;
  Loop(Vertex vert){
    nodes=new LoopList(vert);
  }
  public Loop add(Vertex vert){
    nodes.add(vert);
    return this;
  }
  
}
class LoopList{
  ListWheel wheel;
  int size=0;
  
  LoopList(Vertex v){
  wheel=new ListWheel(v);
  }
  
  public LoopList add(Vertex v){
    this.add(v,size-1);
    
    return this;
  }
  
  public LoopList add(Vertex v,int i){
    ListWheel temp=new ListWheel(v);
    get(i);
    temp.lower=wheel;
    temp.higher=wheel.higher;
    wheel.higher=temp;
    temp.higher.lower=temp;
    wheel=temp;
    size+=1;
    return this;
  }
  
  public ListWheel get(int i){
    ListWheel mount=wheel;
    i=i%size;
    while(mount.i!=i){
      boolean dir=(size/2<(i-mount.i % size + size) % size);
      if(dir){
        mount=mount.lower;
      }else{
        mount=mount.higher;
      }
    }
    wheel=mount;
    return wheel;
  }
  
  public LoopList set(int i, Vertex v){
      get(i).v=v;
      return this;
  }
  
  public ListWheel next(){
    wheel=wheel.higher;
    return wheel;
  }
  
  public ListWheel last(){
    wheel=wheel.lower;
    return wheel;
  }
  
}


class PNGImage{
 int width;
 int height;
 int hashV=0;
 boolean calculatedHash=false;
 char mode;//0 decide, 1 grayscale, 2 byteArray palette, 3 shortArray palette, 4 full color
 protected byte byteArray[][];
 protected short shortArray[][];
 protected int colorArray[][];
 ArrayList<Integer> palette;
 PNGImage(){
  width=0;
  height=0;
  byteArray=null;
  shortArray=null;
  colorArray=null;
  palette=null;
 }
 PNGImage(PImage source){
   byteArray=null;
   shortArray=null;
   colorArray=null;
   palette=null;
   this.width=source.width;
   this.height=source.height;
   
    
 }

 PNGImage(String source){
   this(loadImage(source)); 
 }
 public int hashCode(){
   long hash=0;
   if(calculatedHash){
     return hashV; 
   }
   for(int y=0;y<this.height;y++){
           for(int x=0;x<this.width;x++){
             hash+=this.get(x,y);
           } 
           
   }
   calculatedHash=true;
   hashV=(int)hash;
   return hashV;
 }
 public void genPalette(PImage source,int forceGray){//this can not be called from the constructor or other threads will block for this rather long process
   if(forceGray!=0){
      mode=1;
  
      byteArray=new byte[this.width][this.height];
   
        for(int y=0;y<this.height;y++){
           for(int x=0;x<this.width;x++){
             int c=source.get(x,y);
           byteArray[x][y]=PApplet.parseByte(round((red(c)+green(c)+blue(c))/3));
    
        }   
      }

   }else{
     

    palette=new ArrayList<Integer>();
    colorArray=new int[this.width][this.height];
    HashMap<Integer,Integer> paletteMap=new HashMap<Integer,Integer>();
    for(int x=0;x<this.width;x++){
        for(int y=0;y<this.height;y++){
          int c=source.get(x,y);
          if(paletteMap.containsKey(c)){
            colorArray[x][y]=paletteMap.get(c);
          }else{
            colorArray[x][y]=palette.size();
            paletteMap.put(c,palette.size());
            palette.add(source.get(x,y));
          }  
        }   
     }
     boolean bAndW=true;
     for(int i =0;i<palette.size();i++){
       if(!(red(palette.get(i))==green(palette.get(i))&&red(palette.get(i))==blue(palette.get(i)))){
         bAndW=false;
         break;
       }
     }
     if(bAndW){
       mode=1;
       byteArray=new byte[this.width][this.height];
       for(int x=0;x<this.width;x++){
        for(int y=0;y<this.height;y++){
          byteArray[x][y]=PApplet.parseByte(round((red(source.get(x,y))+green(source.get(x,y))+blue(source.get(x,y)))/3.0f));
        }
       }
       colorArray=null;
       palette=null;
     }else if(palette.size()<256){
       mode=2;
       byteArray=new byte[this.width][this.height];
       for(int x=0;x<this.width;x++){
        for(int y=0;y<this.height;y++){
          byteArray[x][y]=PApplet.parseByte(colorArray[x][y]);
        }
       }
       colorArray=null;
     }else if(palette.size()< 65536){
       mode=3;
       shortArray=new short[this.width][this.height];
       for(int x=0;x<this.width;x++){
        for(int y=0;y<this.height;y++){
          shortArray[x][y]=(short)colorArray[x][y];
        }
       }
       colorArray=null;
     }else{
       mode=4;
       for(int x=0;x<this.width;x++){
        for(int y=0;y<this.height;y++){
          colorArray[x][y]=palette.get(colorArray[x][y]);
        }
       }
       palette=null;
     }
    }
 }
 public int get(long i){//get color i in left to right top to bottom
   //println(i+" "+i%width+" "+i/width);
   //println(width+" "+height);
   return get(PApplet.parseInt(i%width),PApplet.parseInt(i/width));
 }
 public int get(int x,int y){
  //println(x+" "+y);
   if(x<0||y<0||x>=width||y>=height){
     return 0;
   }

   if(mode==1){
     return (0xff<<24)+((byteArray[x][y])<<16)  +((byteArray[x][y])<<8)  +(byteArray[x][y]);
   }else if(mode==2){
     return palette.get(byteArray[x][y]&0xFF);
   }else if(mode==3){
     return palette.get(shortArray[x][y]&0xFFFF);
   }else if(mode==4){
     return colorArray[x][y];
   }
   return 0;
 }

 public PImage getImage(){
   PImage ret=createImage(this.width,this.height,ARGB);
   for(int x=0;x<this.width;x++){
        for(int y=0;y<this.height;y++){
          ret.set(x,y,this.get(x,y));
        }
   }
   return ret;
 }
 public PNGImage draw(int x,int y){
   image(this.getImage(),x,y);
   return this;
 }
 public PImage fastGet(int sX, int sY, int eX, int eY){//start xy, end xy

   int px=(eX-sX)*(eY-sY);
   int cn=ceil(sqrt(px/(float)programSettings.maxPixelCache));//if we process more than 700,000 pixles we start to lag our machines, so limit processing to a total of 700,000, but lets let the user decide
   
   if(cn<1) cn=1;

   //println(cn);
   //PImage ret=createImage(width,height,ARGB);
   PImage ret=createImage(width/cn,height/cn,ARGB);
   //I found the error, deep in the source is a line int[width*height], so if width*height>Integer.MAX_VALUE it tries to create a badly sized array
    //but I still dont have a good fix, the last one I tried broke everything and I hade a huge crash
        for(int y=max(0,sY);y<min(height,eY)+cn;y+=cn){
             for(int x=max(0,sX);x<min(width,eX)+cn;x+=cn){//x inc is better for speed... I think
              ret.set(x/cn,y/cn,this.get(x,y));
              if(x/cn>ret.width) break;

            }
            if(y/cn>ret.height) break;
       }
       ret.updatePixels();
   //temp.resize(width,height);
   //ret=temp;
   //if(cn>1){
     //ret.resize(width,height);
   //}
   return ret;
 }
 /*
 PImage fastGet(int sX, int sY, int eX, int eY){//start xy, end xy
 //this might not actually work how I think it does... which is sad, because I wrote it
   int px=(eX-sX)*(eY-sY);
   int cn=ceil(sqrt(px/700000.));//if we process more than 700,000 pixles we start to lag our machines, so limit processing to a total of 700,000
   if(cn<1)cn=1;
   PImage ret=createImage(max((eX-sX+1)/cn,0),max((eY-sY+1)/cn,0),ARGB);
   //I found the error, deep in the source is a line int[width*height], so if width*height>Integer.MAX_VALUE it tries to create a badly sized array
    //but I still dont have a good fix, the last one I tried broke everything and I hade a huge crash
        for(int y=0;y<eY-sY+1;y+=cn){
             for(int x=0;x<eX-sX+1;x+=cn){//x inc is better for speed... I think

          ret.set(x/cn,y/cn,this.get(x+sX,y+sY));
        }
   }
   return ret;
 }*/
 public PImage primeImage(){
   return createImage(this.width,this.height,ARGB);
 }
 public PImage getImageRow(int i, PImage temp){
   for(int j=0;j<this.width;j++){
     
     temp.pixels[i*temp.width+j]=get(j,i);
   }
   return temp;
 }
}

class PNGThread extends Thread{
  PImage retv;
  PNGImage in;
  PImage temp;
  boolean terminate=false;
  boolean alive=false;
  public void run(){
    alive=true;
    temp=in.primeImage();
    temp.loadPixels();
    for (int i=0;i<temp.height&&!terminate;i++){
      temp=in.getImageRow(i,temp);

    }
    temp.updatePixels();
    retv=temp;
    alive=false;
  }
  
 public PImage merge(PImage _1, PImage _2){
    PImage ret=_1.get(); 
    ret.loadPixels();
    _2.loadPixels();
    for(int i =0;i<ret.pixels.length;i++){
         if(_2.pixels[i]!=0){
           ret.pixels[i]=_2.pixels[i];
         }
        
     }
     ret.updatePixels();
    return ret;
  }
  
}

class PNGOverlay extends PNGImage{
 HashMap<Integer,Integer> paletteMap;

 PNGOverlay(int w, int h){

   width=w;
   height=h;
   palette=new ArrayList<Integer>();
   paletteMap=new HashMap<Integer,Integer>();
   mode=2;
 }
 PNGOverlay(int w, int h, ArrayList<Integer> p, HashMap<Integer,Integer> pM){
   
   this(w,h);
   palette=p;
   paletteMap=pM;
   if(palette.size()<256){
     mode=2;
     byteArray=new byte[this.width][this.height];
   }else if(palette.size()< 65536){
     mode=3;
     shortArray=new short[this.width][this.height];
   }else{//hopefully we dont get here
     mode=4;
     colorArray=new int[this.width][this.height];
     palette=null;
   }
 }
 public PNGOverlay set(long index,int c){
   return set(PApplet.parseInt(index%width),PApplet.parseInt(index/width),c); 
 }
 public PNGOverlay set(int x, int y, int c){
   if(x<0||y<0||x>=width||y>=height){return this;}//handle x and y out of range
   if(mode==4){
     colorArray[x][y]=c;
   }else{ 
     if(!paletteMap.containsKey(c)){
       if(mode==1){
         mode=2; 
         palette=new ArrayList<Integer>();
         paletteMap=new HashMap<Integer,Integer>();
       }
       palette.add(c);
       paletteMap.put(c,palette.size()-1);
       if(mode==2&&palette.size()>255){
         mode=3;
         shortArray=new short[this.width][this.height];
         for(int j=0;j<this.height;j++){
           for(int i=0;i<this.width;i++){
             shortArray[i][j]=(short)(byteArray[i][j]&0xFF); 
           }
         }
         byteArray=null;
         
       }else if(mode==3&&palette.size()>65536){
         mode=4;
         colorArray=new int[this.width][this.height];
         for(int j=0;j<this.height;j++){
           for(int i=0;i<this.width;i++){
             colorArray[i][j]=palette.get(shortArray[i][j]&0xFFFF); 
           }
         }
         shortArray=null;
         palette=null;
       }
     }
     if(mode==1){
        //PNG overlay does not support mode 1,
        System.err.println("Png Overlay does not support mode 1\n If you are not a dev contact us and tell us how you got this error");
     }else if(mode==2){
        byteArray[x][y]=paletteMap.get(c).byteValue();;
     }else if(mode==3){
        shortArray[x][y]=paletteMap.get(c).shortValue();
     }
   }
   return this;
 }
 public PNGOverlay merge(PNGOverlay other){
   for(int j=0;j<min(this.height,other.height);j++){
     for(int i=0;i<min(this.width,other.width);i++){
       if(this.get(i,j)==0){
         this.set(i,j,other.get(i,j));
       }
     }
   }
   return this;
 }
  public PNGOverlay get(){
   PNGOverlay ret=new PNGOverlay(width,height,palette,paletteMap);
   ret.byteArray=byteArray.clone();
   ret.colorArray=colorArray.clone();
   ret.shortArray=shortArray.clone();
   ret.mode=mode;
   return ret;
 }
 public byte[] wrapNByte(long toWrap,int n){//a method that wraps n bytes of a long in a byte[]
    ByteBuffer temp = ByteBuffer.allocate(8);//a long is 8 bytes, we wrap it all to start with
    temp.putLong(toWrap);//convert int to ByteBuffer
    byte[] conv=new byte[n];
    for(int i=0;i<n;i++){//copy last n bytes
      conv[i]=temp.get((8-n)+i);
    }
    return conv;
  }
 public int unwrapNBytes(byte[] unwrap){
   int ret=0;
   for(int i=0;i<unwrap.length;i++){
     ret=ret<<8;
     ret+=(unwrap[i]&0xff);
   }

   return ret;
 }
 public boolean fromJEMOv1(int colorSize, InputStream file) throws IOException{
   boolean fileTerminator=false;
   byte[] byte4=new byte[4];
   byte[] byteC=new byte[colorSize];
   byte[] byte2=new byte[2];
   file.read(byte4);
   long index=(ByteBuffer.wrap(byte4).getInt()&0x00000000ffffffffL);
   if(index==0){
     fileTerminator=true;
   }
   boolean run=true;
   while(run){
     file.read(byteC);
     file.read(byte2);
     int c=palette.get(unwrapNBytes(byteC));    
     int count=(ByteBuffer.wrap(byte2).getShort()&0x0000ffff);//damn it java, why do I have to do this to get an unsigned short


     if(count==0&&c==0){
       run=false; //stop when we hit the layer terminator
     }else{
       fileTerminator=false; //if we dont hit the layer terminator first try its not a file terminator
     }
     for(int i=0;i<count;i++){
       set(index,c);
       index++;
     }
    
   }
    
   return fileTerminator;//is this layer the file terminator
 }
 public OutputStream toJEMOv1(int colorSize,OutputStream file) throws IOException{//we throw an exception because this is not the first step in writing and previous layers are already handeling io exceptions so I dont feel like handeling it here
  //writing good to here
   long first=-1;
   int last=0;
   int index=0;

   for(int y=0;y<height;y++){//find first and last pixel
     for(int x=0;x<width;x++){
        
        if(get(x,y)!=0){
          if(first<0){
            
            first=index;//in theory this will break if you have more than 2^16x2^16 pixel picture where the last pixel is colored.... I hope we never have that problem
          }
          last=index;
        }
        index++;
     }
   }
   //println("First passs finised");
   last++;
   if(first<0||first==last){
     byte[] scrap=new byte[colorSize+6];
     scrap[0]=1;//prevent early file termination
     file.write(scrap);
     return file;
   }
   //println("we didnt scrap");
   int c=0;
   int len=0;
   file.write(wrapNByte(first,4));
   for(long i=first;i<=last;i++){
     
     if(len>Short.MAX_VALUE*2-1||get(i)!=c||i==last ){
       if(len>0){
         

          file.write(wrapNByte(paletteMap.get(c),colorSize));//dont invert the index, both sides know that the array its self is inverted so they will invert before reading
          file.write(wrapNByte(len,2));
         len=0;
       }

       c=get(i);

     }
     len++;
   }
   file.write(new byte[colorSize+2]);//write layer terminator (oh please java auto 0 dont fail me now)
   return file;
 }
  
}
/**
Pixel only exists as a container for a single pixel including its position and color
Pixel does not depend on any custom classes
Pixel does depend on color from processing
*/
public class Pixel{
	int x;//pixel x pos
	int y;//pixel y pos
	int c;//pixel color
	Pixel(int x, int y, int c){//basic constructor
		this.x=x;
		this.y=y;
		this.c=c;
	}

}
class ProgramSettings{
 int maxPixelCache=1400000;
 int monitorPPI=100;
 boolean saveMonitorPPI=true;
 int maxProgramRam=120000;
 int undoDepth=100;
 boolean autoOpen=true;
 String lastProject="";
 JSONObject raw;
 ProgramSettings(String path){
   this(loadJSONObject(path)); 
 }
 ProgramSettings(JSONObject json){
   load(json);
 }
 public ProgramSettings load(String path){
   return load(loadJSONObject(path)); 
 }
 public ProgramSettings load(JSONObject settingsJSON){
   raw=settingsJSON;
  maxPixelCache=settingsJSON.getInt("maxPixelCache");
  maxProgramRam=settingsJSON.getInt("maxProgramRam");
  monitorPPI=settingsJSON.getInt("monitorPPI");
  undoDepth=settingsJSON.getInt("undoDepth"); 
  if(monitorPPI==-1){
    saveMonitorPPI=false;
   monitorPPI=Toolkit.getDefaultToolkit().getScreenResolution();//this does not get true dpi, but it gets the dpi according to the os so good enought
  }
  autoOpen=settingsJSON.getBoolean("autoOpen");
  lastProject=settingsJSON.getString("lastProject");
  return this;
 }
 public ProgramSettings save(){
   raw.setInt("maxPixelCache",maxPixelCache);
   raw.setInt("maxProgramRam",maxProgramRam);
   if(saveMonitorPPI){
     raw.setInt("monitorPPI",monitorPPI);
   }else{
     raw.setInt("monitorPPI",-1); 
   }
   raw.setInt("undoDepth",undoDepth); 
   raw.setBoolean("autoOpen",autoOpen);
   raw.setString("lastProject",lastProject);
   saveJSONObject(raw,"data/settings.json");//apparently data/ is only infered on load -_-
   return this;
 }
}

class RayCast extends Brush{
    public RayCast(int col,EMImage image,int s){
      super(col,image,s);
    }
  float rayCastAngle=0;


  public RayCast draw(){//this draws the shape of the brush to the screen, generally should not update overlay unless there is a multi-frame process
    //this should be called every frame
    float zoom=this.img.getZoom();
    Pixel pixel = brushPosition();
      int temp=g.strokeColor;//store the current stroke color so we can restore it later
      float w=g.strokeWeight;//same for stroke width
      int fill=g.fillColor;//and fill
      stroke(c);//set stroke to layer color
      strokeWeight(10);//nice wide lines
      /*final int RAY_COUNT=4;
      for(int i=0;i<size*RAY_COUNT;i++){//this code draws the rays, does not look the greatest so instead I use the rotating ray
        float theta=PI*2.0/size/RAY_COUNT;
        //image(shape,(pixel.x*zoom+this.img.offsetX),(pixel.y*zoom+this.img.offsetY),shape.width*zoom,shape.height*zoom); 
        //line((pixel.x*zoom+this.img.offsetX+zoom/2),(pixel.y*zoom+this.img.offsetY+zoom/2),(pixel.x*zoom+this.img.offsetX+zoom/2)+cos(theta*i)*size/2*zoom,(pixel.y*zoom+this.img.offsetY+zoom/2)+sin(theta*i)*size/2*zoom);
        for(int j=0;j<=size;j++){
          line((pixel.x*zoom+this.img.offsetX+zoom/2),(pixel.y*zoom+this.img.offsetY+zoom/2),(pixel.x*zoom+this.img.offsetX+zoom/2)+cos(theta*i)*size/2*zoom,(pixel.y*zoom+this.img.offsetY+zoom/2)+sin(theta*i)*size/2*zoom);
        }
      }*/
      line(mouseX,mouseY,mouseX+cos(rayCastAngle)*size/2*zoom,mouseY+sin(rayCastAngle)*size/2*zoom);//draw line at current angle angle
      fill(color(0,0,0,0),0);//set fill to transparrent so the circle is no color inside        
      ellipse(mouseX,mouseY,size*zoom,size*zoom);//draw a circle arround the mouse where the ray will sweep
      stroke(temp);//restor stroke
      strokeWeight(w);//and weight
      fill(fill);//and fill
      rayCastAngle+=.2f;//increment angle, larger values are generaly faster, smaller are slower, I found 0.2 is about right
    return this; 
  }

  public RayCast rayCastBrush(int x, int y){//projects rays from the mouse which stop and fill when a certain gradiant is met, then smooth the result
      Pixel pixel =this.img.getPixel(x,y);//seed first pixel
      final int RAY_COUNT=4;//rays go out in this many directions 
      float zoom=this.img.zoom;
      //smoothBrush(pixel.x,pixel.y);//comment other smooth and un comment this one to see how it works
      for(int i=0;i<size*RAY_COUNT;i++){//make circle of rays
        float theta=PI*2.0f/size/RAY_COUNT;//determine angle of rays
        //image(shape,(pixel.x*zoom+this.img.offsetX),(pixel.y*zoom+this.img.offsetY),shape.width*zoom,shape.height*zoom); 
        //line((pixel.x*zoom+this.img.offsetX+zoom/2),(pixel.y*zoom+this.img.offsetY+zoom/2),(pixel.x*zoom+this.img.offsetX+zoom/2)+cos(theta*i)*size/2*zoom,(pixel.y*zoom+this.img.offsetY+zoom/2)+sin(theta*i)*size/2*zoom);
        ArrayList<Pixel> line=new ArrayList<Pixel>();//get a list ready to add pixels to allong the line
        Pixel last=new Pixel(pixel.x,pixel.y,c);//track the last pixel, faster than following the linked list
        for(int j=0;j<=size;j++){//run a dot scan allong the line and add all pixels to the list
          Pixel p=this.img.getPixel(PApplet.parseInt((pixel.x*zoom+this.img.offsetX+zoom/2)+cos(theta*i)*j/2*zoom),PApplet.parseInt((pixel.y*zoom+this.img.offsetY+zoom/2)+sin(theta*i)*j/2*zoom));//record new pixel
          //ellipse(int((pixel.x*zoom+this.img.offsetX+zoom/2)+cos(theta*i)*j/2*zoom),int((pixel.y*zoom+this.img.offsetY+zoom/2)+sin(theta*i)*j/2*zoom),10,10);//visualize scan, lags program
          line.add(last);//add last pixel
          if((p.x!=last.x||p.y!=last.y)&&gradMatch(last,p)){//check that current and last are not the same pixel, if they arent, check them against gradMatch to see if we should stop the line
            this.img.overlay.set(this.img.layer,last.x,last.y,c);//fill last pixel
            break;//break out of the for, we have all of the 
          }
          last=p;//swap current to last
        }
        for(int j=0; j<line.size();j++){//fill entire line to end point
          this.img.overlay.set(this.img.layer,line.get(j).x,line.get(j).y,c);
        }
      }
      smoothBrush(pixel.x,pixel.y);//smooths area
      return this;
  }


  private boolean gradMatch(Pixel temp,Pixel p){//determins if 2 pixels have enough of a gradient to them
    float threshold=32;//arbitrary threshold for comparison 32 seems to work well for ray cast
    float _1=greyVal(temp.c);
    float _2=greyVal(p.c);
    return (_1-_2)*(_1-_2)*3>threshold*threshold;
  }

  public float greyVal(int c){//this averages the RGB values of a given color to determine its grayscale value
    return ((c >> 16 & 0xFF) + (c >> 8 & 0xF) + (c & 0xFF))/3.0f;//extract and average rgb values
  }

  public RayCast paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    Pixel pixel= brushPosition();
    this.img=img;
    rayCastBrush(mouseX,mouseY);
    
    return this;
  }

  public RayCast smoothBrush(int startX, int startY){//this brush smooths out thin ridges and fills in thin gaps, it does this by checking the number of neighboring pixels for each pixel, it is designed to be used with ray fill, but can be used independantly
    ArrayList<Pixel> add=new ArrayList<Pixel>();//list of pixels to fill, we have to do these last or it will throw off the calculations
    ArrayList<Pixel> remove=new ArrayList<Pixel>();  //list of pixels to clear, we have to do these last or it will throw off the calculations
    float ss=size*size/4;//callculate r^2 from D
    for(int x=0;x<size;x++){
      for(int y=0;y<size;y++){
        //this.img.overlay.set(this.img.layer,startX+x,startY+y,c);
        int posX=x-size/2;
        int posY=y-size/2;
        if (posX*posX+posY*posY<ss){//good old pathagrean circle from inequality for filling a circle
          if(this.img.overlay.get(this.img.layer,startX+posX,startY+posY)!=c){//check for empty pixel
            int count=0;
            for(int i=-1;i<2;i++){//for loops for getting a 9 square (3x3) area centered on the point inside the cricle
              for(int j=-1;j<2;j++){
                count+=PApplet.parseInt(this.img.overlay.get(this.img.layer,startX+posX+i,startY+posY+j)==c);//count adjacent pixels
              }  
            }
            
            if(count>4){
               add.add(new Pixel(startX+posX,startY+posY,c));//if enough pixels are full arround it, fill this one in
            }
          }else if(this.img.overlay.get(this.img.layer,startX+posX,startY+posY)==c){//check full pixels
            int count=0;
            for(int i=-1;i<2;i++){//for loops for getting a 9 square (3x3) area centered on the point inside the cricle
              for(int j=-1;j<2;j++){
                count+=PApplet.parseInt(this.img.overlay.get(this.img.layer,startX+posX+i,startY+posY+j)!=c);//couund adjacent pixels
              }  
            }
            
            if(count>4){
              remove.add(new Pixel(startX+posX,startY+posY,color(0,0,0,0)));//add pixel to remove
            }
          }
        }
      }
    }
    for(int i=0;i<add.size();i++){
      this.img.overlay.set(this.img.layer,add.get(i).x,add.get(i).y,c);//add pixles to add
    }
    for(int i=0;i<remove.size();i++){
      this.img.overlay.set(this.img.layer,remove.get(i).x,remove.get(i).y,color(0,0,0,0));//clear pixels to clear
    }
    return this;
  }
  public RayCast update(){//updates the shape of the brush, this should only be called when there is a reasonable certainty that the brush has changed in some way
    //as it can be a computationally complex operation
    shape=createImage((int)1,(int)1,ARGB);//no shape because the brush is generated dynamicly
    return this;
  }

}
class SideBar extends PApplet{
  int reqWidth,reqHeight;
  public Ui ui;
  public void settings(){
    size(200,1000);

  }

  public void setup(){
    surface.setResizable(false);
    surface.setTitle("Settings");
    ui=buildUi(this);
    surface.setAlwaysOnTop(true);
  }
  int stablizeTimer=0;
  public void draw(){
    reqWidth=ui.calcWidth();
    reqHeight=ui.calcHeight();
    if(width!=reqWidth||height!=reqHeight){

      reqWidth=max(200,reqWidth);
      reqHeight=max(0,reqHeight);
      stablizeTimer=0;
      surface.setSize(reqWidth,reqHeight); 
      background(150);//when the surface changes size it does this freeky weird thing where it stretches the current content to fill the new window, it looks terable so I just get rid of it all
    }

     
     //println("Changin size");
    
    if(stablizeTimer<0){//if you let this draw as much as you would think would be fine, it freeks out and draws some weird stuff the first frame after resizing
      background(150);
    //println(reqWidth);
      
      ui.draw();
      stablizeTimer=0;
    }
    stablizeTimer--;
  }

}
class ThreadStack extends Thread{
  EMStack target;
  ThreadStack(EMStack given){
    target=given;
  }
  public void run(){
    
    int startTime;
    int totalStart=target.files.length;
    boolean newProject=img.project.stackPath.equals("");//if we dont have a stack start we are a new project
    if (newProject){
      img.project.numFiles=target.files.length;
      
    }
    if(target.files.length>0){
      img.project.stackTopName=target.files[0].getName();
      img.project.stackPath=target.files[0].getParent();
    }
    while(target.progress<target.files.length){
      startTime=millis();
      //PNGImage temp=new PNGImage(
      
      target.frameLoadStack();
      //println(millis()-startTime);
    }
    img.project.stackLoaded=true;
    img.project.stackSize=target.img.size();
    img.project.stackHash=target.hashCode();
    target.files=null;
  }
}
/**
this class is rather simple for how powerful it is
in short Ui is a UI manager, it holds and handles all elements of the ui
to add a new Ui_Element just run add(element)
Ui depends on the existence of an Ui_Element class and access to its void draw(), and boolean mouseOn methods
Ui does not depend on any processing specific elements
*/
class Ui{
	private ArrayList<Ui_Element> elements;//track every element on the ui
  public PApplet drawManager;
	Ui(){//create empty ui
		elements=new ArrayList<Ui_Element>();
	}
  Ui(PApplet dm){
   this();
   drawManager=dm; 
  }

	public boolean onUi(){//used to determin if the mouse is on the ui, redirct internaly
		for(int i=0; i<elements.size();i++){
			if(elements.get(i).mouseOn()){
				return true;//notice that you can not depend on mouseOn being called in your element as this will return as soon as the mouse is on any element
				//so dont put too much important processing in mouseOn unless you call it from else ware
			}
		}
		return false;
	}

	public Ui draw(){//draw all elements in the order they where created
		for(int i=0; i<elements.size();i++){
				elements.get(i).draw();
		}
		return this;
	}
  public Ui setDM(PApplet target){
    drawManager=target;
    for(int i=0; i<elements.size();i++){
        elements.get(i).setDM(drawManager);
    }  
    return this;
  }
	public Ui add(Ui_Element e){//add new element to the ui, new elements always appear over older one
    e.setDM(drawManager);
		elements.add(e);
		return this;
	}

	public Ui_Element get(int i){//get a specific element, obfuscates ui.elements.get(i) to ui.get(i)
		return elements.get(i); 
	}
  public int calcHeight(){
    int max=0;
    for(int i=0; i<elements.size();i++){
      max=max(max,elements.get(i).calcHeight());
    }   
    return max;
  }
  public int calcWidth(){
    int max=0;
    for(int i=0; i<elements.size();i++){
      max=max(max,elements.get(i).calcWidth());
 
    }
    return max;
  }
  public Ui_Element getId(final String id){
   for(int i=0;i<elements.size();i++){
      Ui_Element temp=elements.get(i).getId(id);
      //println(id);
      if (temp!=null){
        //println(temp);
       return temp; 
      }
   }
   //println("Returning nul");
   return null;
  }
  
}

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
		func[(1+PApplet.parseInt(state.get(0)))*PApplet.parseInt(prevState^state.get(0))].run();//this should run dummy if the previous state and current state are the same otherwise
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

	public Ui_Button activate(){//untested, I probiably will never use these
		state.set(2,false);
		return this;
	}

	public Ui_Button deactivate(){//untested, I probiably will never use these
		state.set(2,true);
		return this;
	}
  public Ui_Button hide(){
     state.set(0,false);
     return this;
  }
}

class Ui_ColorSlider extends Ui_Slider{
 Ui_ColorSlider(){
    super();
    init();
 }
  Ui_ColorSlider(float rX,float rY,float rS,PImage img){//use this constructor if you want the button to self scale
    super(rX,rY,rS,img);
    init();
  }
  Ui_ColorSlider(int x, int y, PImage img){//use this constructor if you dont want the button to self scale
    super(x,y,img);
    init();
  }
  Ui_ColorSlider(int x, int y, String imgPath){//no scale load image constructor
    super(x,y,imgPath);
    init();
  } 

  Ui_ColorSlider(float x, float y, float s, String imgPath){//scale load image constructor
    super(x,y,s,imgPath);
    init();
  }
  public Ui_ColorSlider init(){//this is only here because I can not call a super constructor and a this constructor, so this is the real this constructor
   minV=0;
   maxV=255;
   return this;
  }
 public Ui_Slider draw(){
   if (valChanged){
     track.loadPixels();
     for(int i =0 ;i<track.pixels.length;i++){
       track.pixels[i]=tColor(value,value,value);
     }
     track.updatePixels();
   }
   return super.draw();
 }
}
//extends button, state is completly not managed by the button, and it does not draw
class Ui_DumbButton extends Ui_Button{
  Ui_DumbButton(boolean v){
      super(0,0,createImage(0,0,ARGB));//create invisible image
      state.set(0,v);
  }
  public Ui_DumbButton draw(){return this;}//do  nothing
  public boolean mouseOn(){return false;}//do nothing
  
}
/**
abstract class to bass all Ui_Elements off of, implements basic methods in case they are unneeded in future Ui_Elements
Ui_Element does not depend on any custom classes
Ui_Element does depend on PImage from processing
*/
abstract class Ui_Element{
  public PApplet dm;
  public Ui_Element(){tile=createImage(0,0,ARGB);};//default constructor
  public String id="";//this allows us to search for a specific element once it is lost in the Ui elements list
  public int posX;//screen position x
  public int posY;//screen position y
  public PImage tile;//the image to display
  public float scale=1;//the scale, this is used for resizable things
  public boolean autoReposition=false;//controles whether scale does anything 
  public boolean mouseOn(){return false;}//function that is used to detect weather the mouse is on the Ui_Element
  public Ui_Element setDM(PApplet DrawM){dm=DrawM;return this;}
  public Ui_Element draw(){return this;}//draws the element to the screen
  public Ui_Element click(){return this;}//handles/detects click events
  public Ui_Element(int x, int y, PImage img){this();}//construction for placing element with image at position
  public Ui_Element hide(){return this;}//this is here expressly for Ui_RadioButton inside Ui_PopupPanel incase the element needs to do something special when hidden, such as turn off, or hide others
  public Ui_Element getId(final String s){if(s.equals(id)){return this;}else{return null;}}//by default this returns the this element if id matches s, can be overloaded to check sub elements too
  public int calcWidth(){
    return ceil(posX+scale*tile.width);
  }
  public int calcHeight(){
    return ceil(posY+scale*tile.height);
  }
}

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
class Ui_PaintButton extends Ui_Button{//this class grabs the color of the current brush and paints the background of a button with it
  //EMImage img;//object to grab color from//fine screw it, we are going global
  int c;//current color

  PImage mask;
  public Ui_PaintButton constructor(){//the basic constructor, java is an idiot that wont let you call the super and another constructor so this is a work arround
    c=0;
    return this;
  }
  Ui_PaintButton(float rX,float rY,float rS,PImage img){//use this constructor if you want the button to self scale
    super(rX,rY,rS,img);
    constructor();
}
  Ui_PaintButton(int x, int y, PImage img){//use this constructor if you dont want the button to self scale
    super(x,y,img);
    constructor();
  }

  Ui_PaintButton(int x, int y, String imgPath){//no scale load image constructor
    super(x,y,imgPath);
    constructor();
  } 

  Ui_PaintButton(float x, float y, float s, String imgPath){//scale load image constructor
    super(x,y,s,imgPath);
    constructor();
  }
  public Ui_PaintButton draw(){
    if(img!=null){
      if(c!=img.brush.c){

         c=img.brush.c;
         background.loadPixels();
         mask.loadPixels();
         if(background.pixels.length!=mask.pixels.length){
          
           background=createImage(mask.width,mask.height,ARGB);
           background.loadPixels();
         }
         for(int i =0;i<mask.pixels.length;i++){
           background.pixels[i]=((((PApplet.parseInt(alpha(c)>0)*255)&0xff)<<24)+((round(red(c))&0xff)<<16)+((round(green(c))&0xff)<<8)  +(round(blue(c))&0xff))*PApplet.parseInt(mask.pixels[i]!=0); 
           
         }
         background.updatePixels();
      }
    }
    super.draw();
    return this;
    
  }
}
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
Ui_Panel(float x, float y, float w, float h, int c){
  this(x,y,1,createImage(round(w*PPI),round(h*PPI),ARGB));
   for(int i=0;i<tile.width;i++){
      for (int j=0;j<tile.height;j++){
        tile.set(i,j,c); //color in image
      }
    }
}
	Ui_Panel(int x, int y, int w, int h, int c){//create panel with flat color
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
/*
  handles a sub ui that is tied to a button to make it visible or not
  depends on Ui_Element to extend
  depends on the existence of an Ui_Element class and access to its void draw(), void hide(), Ui_Element getId(), and boolean mouseOn() methods
  and void draw(), boolean mouseOn(), bitset state, and Ui_Element getId() from Ui_BUtton
  does not depend on any processing specific elements
*/
class Ui_PopupPanel extends Ui_Element{
  Ui_Button trigger=new Ui_DumbButton(false);
  private ArrayList<Ui_Element> elements;//track every element on the ui
  Boolean open=false;
  Boolean forceState=false;
  Ui_PopupPanel(){//create empty ui
    elements=new ArrayList<Ui_Element>();
  }
  Ui_PopupPanel(Ui_Button button){
    this();
    trigger=button; 
  }
  public boolean mouseOn(){//used to determin if the mouse is on the ui, redirct internaly
    if(trigger.mouseOn()){
     return true;
    }
    if(trigger.state.get(0)){//only check sub elements if the panel is open
      for(int i=0; i<elements.size();i++){
        if(elements.get(i).mouseOn()){
          return true;//notice that you can not depend on mouseOn being called in your element as this will return as soon as the mouse is on any element
          //so dont put too much important processing in mouseOn unless you call it from else where
        }
      }
    }
    return false;
  }

  public Ui_PopupPanel draw(){//draw all elements in the order they where created
    if (open!=trigger.state.get(0)){
        for(int i=0; i<elements.size();i++){
          elements.get(i).hide();
        }
    }
    if(open){//Draw sub elements if the panel is open
      for(int i=0; i<elements.size();i++){
          elements.get(i).draw();
        }
    }
    open=trigger.state.get(0);
    trigger.draw();//draw the trigger anyway

    return this;
  }

  public Ui_PopupPanel add(Ui_Element e){//add new element to the ui, new elements always appear over older one
    e.setDM(dm);
    elements.add(e);
    return this;
  }
  public Ui_PopupPanel changeTrigger(Ui_Button e){
   trigger=e; 
   return this;
  }

  public Ui_Element get(int i){//get a specific element, obfuscates ui.elements.get(i) to ui.get(i)
    return elements.get(i); 
  }
  public Ui_PopupPanel setDM(PApplet DrawM){
      dm=DrawM;
      for(int i=0; i<elements.size();i++){
        elements.get(i).setDM(dm);
      }
      trigger.setDM(dm);
      return this;
  }
  public Ui_Element getId(String s){
    //println("String s="+s);println("String id="+id);
    if(this.id.equals(s)){
      return this;
    }
    if(this.trigger.getId(s)!=null&&trigger.id!=""){
      return trigger;
    }
   for(int i=0;i<elements.size();i++){
      Ui_Element temp=elements.get(i).getId(s);
      if (temp!=null){
       return temp; 
      }
   }
   return null;
  }
  public int calcWidth(){
   int max=trigger.calcWidth();
   if(open){
     for(int i=0; i<elements.size();i++){
          max=max(max,elements.get(i).calcWidth());
     }
   }
   return max;
  }
  public int calcHeight(){
   int max=trigger.calcHeight();
   if(open){
     for(int i=0; i<elements.size();i++){
          max=max(max,elements.get(i).calcHeight());
     }
   }
   return max;
  }
}
/* Radio button acts as a controler for other buttons to prevent more than 
n buttons from being active at the same time
Radio Button Depends on access to BitSet state, boolean mouseOn(), and void draw() from Ui_Button 
and also fUI_Element to extend
Radio Button does not depend on anything from processing
*/
class Ui_RadioButton extends Ui_Element{
	ArrayList<Ui_Button> buttons;//track all buttons
	ArrayList<Integer> active;//track the buttons that are pressed, this is an integer list for the index that button falls in buttons
	int allowed;//track the number of allowed active buttons
	Ui_RadioButton(){//default constructor has 1 active button
		this(1); 
	}
	
	Ui_RadioButton(int n){//in theory this can be something other than 1, but it is not the most stable
		allowed=n;
		buttons =new ArrayList<Ui_Button>();
		active=new ArrayList<Integer>();
	}
	
	public Ui_RadioButton draw(){//this simply passes draw on to the buttons and also updating its self it needed
		for(int i=0;i<buttons.size();i++){
			boolean current =buttons.get(i).prevState;
			buttons.get(i).draw(); 
			if(current!=buttons.get(i).state.get(0)){//update if the button changes state
				update(i); 
			}
		}
		return this;
	}
	
	public boolean mouseOn(){//pass mouse on to buttons
		for(int i=0;i<buttons.size();i++){
			if(buttons.get(i).mouseOn()){
				return true;
			}
		}
		return false;
	}
	
	public Ui_RadioButton update(Integer i){//update the button 
		if (buttons.get(i).state.get(0)){//add new buttton
			active.remove(i);
			active.add(i);
			if (active.size()>allowed){//if too many buttons are active, drop the oldest one
				buttons.get(active.get(0)).state.set(0,false);
				active.remove((int)0);
			}
		}else{//remove unselected button
			buttons.get(i).state.set(0,false);
			active.remove(i);
		}
		return this;
	}
	
	public Ui_RadioButton add(Ui_Button button){//add a new button to the list
    button.setDM(dm);
		buttons.add(button);
		return this;
	}

	public Ui_RadioButton setActiveState(boolean set){//untested, I probiably will never use these
		for(int i=0;i<buttons.size();i++){
			buttons.get(i).state.set(3,set);
		} 
		return this;
	}

	public Ui_RadioButton setActive(int n){//manual way to activate a button, draw and update should do everything else
		buttons.get(n).state.set(0,true);
		return this;
	}
	
	public Ui_RadioButton activate(){//untested, I probiably will never use these
		setActiveState(false);
		return this;
	}
	
	public Ui_RadioButton deactivate(){//untested, I probiably will never use these
		setActiveState(false);
		return this;
	}
	public Ui_RadioButton hide(){//call when hiding
    for(int i=0;i<buttons.size();i++){
      buttons.get(i).hide();//call hide on children
    }
    active=new ArrayList<Integer>();//clear active buttons
    return this;
  }
  
   public Ui_Element getId(String s){//check own id and id of all children, return if match
    //println("String s="+s);println("String id="+id);
    if(this.id.equals(s)){
      return this;
    }
   for(int i=0;i<buttons.size();i++){
      Ui_Element temp=buttons.get(i).getId(s);
      if (temp!=null){
       return temp; 
      }
   }
   return null;
  }
  public Ui_RadioButton setDM(PApplet DrawM){
      dm=DrawM;
      for(int i=0; i<buttons.size();i++){
        buttons.get(i).setDM(dm);
      }
      return this;
  }
  public int calcWidth(){
   int max=0;
   for(int i=0; i<buttons.size();i++){
        max=max(max,buttons.get(i).calcWidth());
   }
   return max;
  }
  public int calcHeight(){
    int max=0;
   for(int i=0; i<buttons.size();i++){
        max=max(max,buttons.get(i).calcHeight());
   }
   return max;
  }
}
//this class is exactly the same as Ui_RadioButtton, except it assumes something else is drawing and updating the individual buttons
class Ui_RadioControler extends Ui_RadioButton{
  Ui_RadioControler(int i){
   super(i); 
  }
  public Ui_RadioControler draw(){//this simply does not passes draw on to the buttons and then updates its self it needed
    for(int i=0;i<buttons.size();i++){
      boolean current =buttons.get(i).prevState;
      if(current!=buttons.get(i).state.get(0)){//update if the button changes state
        update(i); 
      }
    }
    return this;
  }
  
  public boolean mouseOn(){//also dont pass mouse on to buttons
    return false;
  }
}

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
	Ui_ScalePanel(float rX, float rY, float w, float h, int c){//make flat colored panel
		this(rX,rY,h,createImage(round(w*displayWidth),round(h*displayHeight),ARGB)); 
		for(int i=0;i<round(w*displayWidth);i++){
			for (int j=0;j<round(h*displayHeight);j++){
				tile.set(i,j,c); //color all pixels
			}
		}
	}
	
	Ui_ScalePanel(float rX,float rY,float rS,PImage img){//make panel from image
		this(round(rX*displayWidth),round(rY*displayHeight),img);
		relativeX=rX;
		relativeY=rY;
		relativeScale=rS;
		//this.draw();//What kind of idiot (apparently me btw) would call draw from a constructor? thats just asking for trouble
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
		boolean ret=(mouseX>=posX)&&(mouseY>=posY)&&(mouseX<=posX+tile.width*scale)&&(mouseY<=posY+tile.height*scale)&&tile.get(round(mouseX-posX),round(mouseY-posY))!=tColor(0,0,0,0);
		return ret;
	}

	public Ui_ScalePanel draw(){//render the panel
		dm.pushMatrix();//prep transformation matrix
		scale=displayHeight*relativeScale/ (float)tile.height;//calculate scale
		posX=round(relativeX*displayWidth);//calculate position
		posY=round(relativeY*height);
		dm.translate(posX,posY);//prep translation
		dm.scale(scale);//prep scale
		dm.image(tile,0,0);//display image
		dm.popMatrix();//apply transformation matrix to move image to the correct place
		return this;
	}
}
//this class has not yet been implimented, this class is planed to hold a series of other elements and arange them in an ordered panel that will allow the user to scrole the pannel elements
//it should handle the drawing and positioning and placing all elements, the elements them selves should be set to position (0,0)
class Ui_ScrollPanel extends Ui_ElementScalable{
  
}
class Ui_Slider extends Ui_Element{
  public PImage track;
  public PImage slider;
  public float maxV;
  public float minV;
  public float pos;
  public int value;
  public Binding<Integer> boundValue;
  private int oldValue;
  public boolean textValue;
  private boolean dragging;
  private boolean off=false;
  boolean valChanged;
  public VariableLambda onChange;
  Ui_Slider(){super();}//I hate this about java, why do I need a default constructor, figure it out from the parrent
  Ui_Slider(float rX,float rY,float rS,PImage img){//use this constructor if you want the button to self scale
    this(round(rX*PPI),round(rY*PPI),img);
    scale=(PPI/img.width)*rS;
  }
  Ui_Slider(int x, int y, PImage img){//use this constructor if you dont want the button to self scale
    dragging=false;
    posX=x;
    posY=y;
    tile=img;//usual initilization
    maxV=100;
    minV=0;
    pos=0;
    value =0;
    track=new PImage(img.width-20,10,ARGB);
    slider=new PImage(20,20,ARGB);
    track.loadPixels();
    for(int i=0;i<track.pixels.length;i++){
      track.pixels[i]=tColor(50,50,50); 
    }
    track.updatePixels();
    slider.loadPixels();
    for(int i=0;i<slider.pixels.length;i++){
      slider.pixels[i]=tColor(200,200,200);
    }
    slider.updatePixels();
    autoReposition=false;
    textValue=true;
    scale=1;
  }
  Ui_Slider(int x, int y, String imgPath){//no scale load image constructor
    this(x,y,loadImage(imgPath));
  } 

  Ui_Slider(float x, float y, float s, String imgPath){//scale load image constructor
    this(x,y,s,loadImage(imgPath));
  }
  public boolean mouseOn(){return dm.mouseX>posX&&dm.mouseX<posX+(tile.width*scale)&&dm.mouseY>posY&&dm.mouseY<posY+(tile.height*scale);

  }//function that is used to detect wether the mouse is on the Ui_Element
  public Ui_Slider draw(){
    if(!dragging&&boundValue!=null){
      setValue(boundValue.stored);
    }
    valChanged=false;
    click();
    dm.pushMatrix();
    dm.translate(posX,posY);//prep translation
    dm.scale(scale);//prep scale
    dm.image(tile,0,0,track.width+slider.width,tile.height);
    dm.scale(1/scale);//undo scale for the upcomming translate
    dm.translate(slider.width/2*scale,(tile.height-track.height)*scale/2.f);
    dm.scale(scale);//prep scale
    
    dm.image(track,0,0);
    dm.translate((pos-slider.width/2),-slider.height/4);
    dm.image(slider,0,0);
    if(textValue){
      //dm.stroke(0);
     // dm.fill(00);
      dm.translate(programSettings.monitorPPI*.02f,3*slider.height/4);
      dm.fill(0);
      dm.text(str(value),0,0); 
    }
    if(oldValue!=value){
      oldValue=value;
      valChanged=true;
      onChange.run(value);
    }
    dm.popMatrix();
    if(boundValue!=null){
      boundValue.stored=value; 
    }
    return this;
  }//draws the element to the screen
  public Ui_Slider setValue(int x, boolean changeLimit){
    if(changeLimit){
     if(x>maxV){
        maxV=x;
     }
     if(x<minV){
       minV=x; 
     }
    }
    //float valueCalc=pos/((float)track.width);
    return setValue(x);
  }
  public Ui_Slider setValue(int x){
    //float valueCalc=pos/((float)track.width);
    x=round(range(x,minV,maxV));
    pos=(x-minV)/(maxV-minV)*track.width;
    return this;
  }
  public Ui_Slider click(){
    if(dm.mousePressed&&dm.mouseButton==LEFT){
      if(dragging||mouseOn()){
        if(!off){
          pos=((dm.mouseX-posX)/scale);
          pos=min(pos,(track.width));
          pos=max(pos,0);
          dragging=true;
        }
      }else{
        off=true; 
      }
    }else if(dragging){
      dragging=false; 
    }else if(off){
      off=false; 
    }
    calcValue();
    
    return this;
    
  }//handles/detects click events
  public int calcValue(){
    float valueCalc=pos/((float)track.width);
    valueCalc=(valueCalc*(maxV-minV))+minV;
    value=round(valueCalc);
    return value;
  }
  public int calcWidth(){
    return ceil(posX+scale*tile.width);
  }//I am on the fence about wether these should assume tile contains slider and track, or if I should use the max of all 3
  public int calcHeight(){
    return ceil(posY+scale*tile.height);
  }
}
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
  Ui_TextPanel(float x, float y, float w, float h, int c){super(x,y,w,h,c);}
  Ui_TextPanel(int x, int y, int w, int h, int c){super(x,y,w,h,c);}
  Ui_TextPanel(){super();}
  public Ui_TextPanel draw(){
    super.draw();
    if (font!=null) dm.textFont(font);
    dm.textSize(size);
    dm.stroke(textColor);
    dm.text(lable,posX+offsetX*tile.width,posY+offsetY*tile.height+size/4);//executive decision, shift is relative to the left center of the text box
    return this;
  }
}
//under construction, dont use yet
class Ui_VerticalSlider extends Ui_Element{
  public PImage track;
  public PImage slider;
  public float maxV;
  public float minV;
  public float pos;
  public int value;
  public Binding<Integer> boundValue;
  private int oldValue;
  public boolean textValue;
  private boolean dragging;
  private boolean off=false;
  boolean valChanged;
  public VariableLambda onChange;
  Ui_VerticalSlider(){super();}//I hate this about java, why do I need a default constructor, figure it out from the parrent
  Ui_VerticalSlider(float rX,float rY,float rS,PImage img){//use this constructor if you want the button to self scale
    this(round(rX*PPI),round(rY*PPI),img);
    scale=(PPI/img.width)*rS;
  }
  Ui_VerticalSlider(int x, int y, PImage img){//use this constructor if you dont want the button to self scale
    dragging=false;
    posX=x;
    posY=y;
    tile=img;//usual initilization
    maxV=100;
    minV=0;
    pos=0;
    value =0;
    track=new PImage(10,img.height-20,ARGB);
    slider=new PImage(20,20,ARGB);
    track.loadPixels();
    for(int i=0;i<track.pixels.length;i++){
      track.pixels[i]=tColor(50,50,50); 
    }
    track.updatePixels();
    slider.loadPixels();
    for(int i=0;i<slider.pixels.length;i++){
      slider.pixels[i]=tColor(200,200,200);
    }
    slider.updatePixels();
    autoReposition=false;
    textValue=true;
    scale=1;
  }
  Ui_VerticalSlider(int x, int y, String imgPath){//no scale load image constructor
    this(x,y,loadImage(imgPath));
  } 

  Ui_VerticalSlider(float x, float y, float s, String imgPath){//scale load image constructor
    this(x,y,s,loadImage(imgPath));
  }
  public boolean mouseOn(){return dm.mouseX>posX&&dm.mouseX<posX+(tile.width*scale)&&dm.mouseY>posY&&dm.mouseY<posY+(tile.height*scale);

  }//function that is used to detect wether the mouse is on the Ui_Element
  public Ui_VerticalSlider draw(){
    if(!dragging&&boundValue!=null){
      setValue(boundValue.stored);
    }
    valChanged=false;
    click();
    dm.pushMatrix();
    dm.translate(posX,posY);//prep translation
    dm.scale(scale);//prep scale
    dm.image(tile,0,0,track.width+slider.width,tile.height);
    dm.scale(1/scale);//undo scale for the upcomming translate
    dm.translate(slider.width/2*scale,(tile.height-track.height)*scale/2.f);
    dm.scale(scale);//prep scale
    
    dm.image(track,0,0);
    dm.translate(-slider.height/4,(pos-slider.width/2));
    dm.image(slider,0,0);
    if(textValue){
      //dm.stroke(0);
     // dm.fill(00);
      dm.translate(programSettings.monitorPPI*.02f,3*slider.height/4);
      dm.fill(0);
      dm.text(str(value),0,0); 
    }
    if(oldValue!=value){
      oldValue=value;
      valChanged=true;
      onChange.run(value);
    }
    dm.popMatrix();
    if(boundValue!=null){
      boundValue.stored=value; 
    }
    return this;
  }//draws the element to the screen
  public Ui_VerticalSlider setValue(int x, boolean changeLimit){
    if(changeLimit){
     if(x>maxV){
        maxV=x;
     }
     if(x<minV){
       minV=x; 
     }
    }
    //float valueCalc=pos/((float)track.width);
    return setValue(x);
  }
  public Ui_VerticalSlider setValue(int x){
    //float valueCalc=pos/((float)track.width);
    x=round(range(x,minV,maxV));
    pos=(x-minV)/(maxV-minV)*track.width;
    return this;
  }
  public Ui_VerticalSlider click(){
    if(dm.mousePressed&&dm.mouseButton==LEFT){
      if(dragging||mouseOn()){
        if(!off){
          pos=((dm.mouseX-posX)/scale);
          pos=min(pos,(track.width));
          pos=max(pos,0);
          dragging=true;
        }
      }else{
        off=true; 
      }
    }else if(dragging){
      dragging=false; 
    }else if(off){
      off=false; 
    }
    calcValue();
    
    return this;
    
  }//handles/detects click events
  public int calcValue(){
    float valueCalc=pos/((float)track.width);
    valueCalc=(valueCalc*(maxV-minV))+minV;
    value=round(valueCalc);
    return value;
  }
  public int calcWidth(){
    return ceil(posX+scale*tile.width);
  }//I am on the fence about wether these should assume tile contains slider and track, or if I should use the max of all 3
  public int calcHeight(){
    return ceil(posY+scale*tile.height);
  }
}
//a vertex for a graph, intended to be used in list wheel
//depends on color from processing
class Vertex{
  int x=0;//position
  int y=0;
  int insideX=0;//values for this are limited to -1,0, and 1, specifes direction for inside
  int insideY=0;
  ArrayList<Vertex> connections;//all conected verticies
  int c=0;//just in case I want to record color
  Vertex(){
    this(0,0,0,0);
  }
  Vertex(int x, int y, int iX,int iY){
    this.x=x;
    this.y=y;
    insideX=PApplet.parseInt(x<iX)-PApplet.parseInt(x>iX);
    insideY=PApplet.parseInt(y<iY)-PApplet.parseInt(y>iY);
    connections=new ArrayList<Vertex>();
  }
  public Vertex addRay(Vertex other){//add a one way connection from this vertex to another
        this.connections.add(other);
        return this;
  }
  public Vertex addEdge(Vertex other){   //add a bidirectional connection betwene 2 vertecies
    this.connections.add(other);
    other.connections.add(this);
    return this;
  }
}

public class Visulization3D extends PApplet{
  int layerThickness=10;//number of pixels thick each layer is
  public void exit(){ this.dispose(); 
     this.noLoop();
     surface.stopThread();
     g.dispose();
     this.stop();
     handleMethods("dispose");
   }
   public void close(){ exit();}
  EMOverlay cloud;
  /*
  void torus(){
    cloud=new boolean[400][400][400];
    for(int x=-cloud.length/2;x<cloud.length/2;x++){
        for(int y=-cloud[0].length/2;y<cloud[0].length/2;y++){
            for(int z=-cloud[0][0].length/2;z<cloud[0][0].length/2;z++){
              cloud[x+200][y+200][z+200]=sq(30-sqrt(x*x+y*y))+z*z<200;
            }
        }
    }
  }
  */
  
  public void strip(){

    EMOverlay temp=new EMOverlay(cloud.width,cloud.height,cloud.depth);
    for(int z=0;z<cloud.depth;z++){
      if(cloud.exists(z)){
       
      for(int x=0;x<cloud.width;x++){
          for(int y=0;y<cloud.height;y++){
            int c=cloud.get(z,x,y);
              if(c!=0&&(PApplet.parseInt(cloud.get(z,x-1,y)==c)+PApplet.parseInt(cloud.get(z,x,y-1)==c)+PApplet.parseInt(cloud.get(z,x+1,y)==c)+PApplet.parseInt(cloud.get(z,x,y+1)==c)+PApplet.parseInt(cloud.get(z+1,x,y)==c)+PApplet.parseInt(cloud.get(z-1,x,y)==c))>5){
                //if(c!=0)println("removed pixel");
                temp.set(z,x,y,color(0,0,0,0));
              }else {
               temp.set(z,x,y,c);
              }
              
            }
          }
        }
      }
      cloud=null;
      cloud=temp;        
      
  
  }
  
  
  class Vertex{
   float x;
   float y;
   float z;
   Vertex(float fx, float fy, float fz){
    x=fx;
    y=fy;
    z=fz;
   }
   public Vertex connect(Vertex other){
     line(x,y,z,other.x,other.y,other.z);
     return this;
   }
   public Vertex mark(PShape target){
     target.vertex(x*10,y*10,z*10*layerThickness); 
     return this;
   }
   public Vertex mark(){
     vertex(x*10,y*10,z*10*layerThickness); 
     return this;
   }
   public Vertex draw(){
     point(x*10,y*10,z*10*layerThickness); 
     return this;
   }
   public String toString(){
     return "("+x+","+y+","+z+")"; 
   }
   public String toObj(){
     return x+" "+y+" "+z*layerThickness; 
   }
  }
  class Triangle{
    Vertex p1,p2,p3;
    Triangle(Vertex v1, Vertex v2, Vertex v3){
      p1=v1;
      p2=v2;
      p3=v3;
    }
    public Triangle lines(){
      p1.connect(p2);
      p2.connect(p3);
      p3.connect(p1);
      return this;
    }
    public Triangle points(){
      p1.draw();
      p2.draw();
      p3.draw();
      return this;
    }
    public Triangle draw(){
      beginShape();
      p1.mark();
      p2.mark();
      p3.mark();
      endShape(CLOSE);
      return this;
    }
    public Triangle mark(){
      p1.mark();
      p2.mark();
      p3.mark();
      return this;
    }
    public PShape buffer(PShape base){
    
     base.beginShape();
     base.noStroke();
     p1.mark(base);
     p2.mark(base);
     p3.mark(base);
     base.endShape();
     return base;
    }
    public String toString(){
      return p1.toString()+" "+p2.toString()+" "+p3.toString(); 
    }
    public String identify(){
      String[] points=new String[3];
      points[0]=p1.toString();
      points[1]=p2.toString();
      points[2]=p3.toString();
      Arrays.sort(points);
      return points[0]+" "+points[1]+" "+points[2]+" "; 
    }
  }
  class Line{
    Vertex p1;
    Vertex p2;
    Line(Vertex _1, Vertex _2){
     p1=_1;
     p2=_2;
    }
  }
  class Node{
   Vertex vertex;
   ArrayList<Vertex> connected;
   ArrayList<Line> lines;
   Node(){
    connected=new ArrayList<Vertex>();
    lines=new ArrayList<Line>();
   }
   Node(Vertex v){
     this();
     vertex=v;
   }
   public Node connect(Vertex point){
      connected.add(point);
      lines.add(new Line(vertex,point));
      return this;
   }
   public Node sortConnections(){
     if(connected.size()>0){
     ArrayList<Vertex> sorted=new ArrayList<Vertex>();
     ArrayList<Line> sortedLines=new ArrayList<Line>();
     Vertex temp=connected.get(0);
     sortedLines.add(lines.get(0));
     lines.remove(0);
     connected.remove(0);
     while(connected.size()>0){
      
      
      int index=-1;
      float distance=Float.MAX_VALUE;
      for(int i =0;i< connected.size();i++){
         float tempDist=sq(temp.x-connected.get(i).x)+sq(temp.y-connected.get(i).y)+sq(temp.z-connected.get(i).z);
         if(tempDist<distance){
          index=i;
          distance=tempDist;
         }
         
      }
      sorted.add(temp);
      temp=connected.get(index);
      connected.remove(index);
      sortedLines.add(lines.get(index));
      lines.remove(index);
     }
     sorted.add(temp);
     connected=sorted;
     lines=sortedLines;
     }
     return this;
   }
   
   public ArrayList<Triangle> triangles(){
     return triangles(new ArrayList<Triangle>());
   }
   public ArrayList<Triangle> triangles(ArrayList<Triangle> append){
     for(int i =0;i<connected.size();i++){
       Vertex self=connected.get(i);
       int index1=-1,index2=-1;
       float distance1=Float.MAX_VALUE,distance2=Float.MAX_VALUE;
       for(int j =0;j<connected.size();j++){
         if(j!=i){
           Vertex target=connected.get(j);
           float distance=sq(self.x-target.x)+sq(self.y-target.y)+sq(self.z-target.z);
           if(distance<=distance1){
             distance2=distance1;
             index2=index1;
             distance1=distance;
             index1=j;
           }else if(distance<distance2){
             distance2=distance;
             index2=j;
           }
         }
       }
       if(index1>0){
       append.add(new Triangle(vertex,self,connected.get(index1)));
         if(index2>0){
         append.add(new Triangle(vertex,self,connected.get(index2)));
         }
       }
     }
     return append;
   }
   public String toObj(){
     return vertex.toObj(); 
   }
   public String toString(){
     return vertex.toString();
   }
  }
  float minX=Float.MAX_VALUE,minY=Float.MAX_VALUE,minZ=Float.MAX_VALUE,maxX=Float.MIN_VALUE,maxY=Float.MIN_VALUE,maxZ=Float.MIN_VALUE;
  class Web{
    PShape triangelBuffer;
    byte grid[][][];
    float ofx,ofy,ofz;
    int zext,xext,yext;
    ArrayList<Node> nodes;
    ArrayList<Line> lines;
    ArrayList<Triangle> triangles;
    int col;
    PShape triangleBuffer;
    Web(EMOverlay cloud,int c){
      triangleBuffer= createShape(GROUP);
      col=c;
     if(c==0) return;
     triangles=new ArrayList<Triangle>();
     //c alculate zext,xext,yext using minx maxx miny maxy minz maxz from the obverlay then calculate ofx ofy and ofz by the offset required to move the grid into place
     int minx=Integer.MAX_VALUE,miny=Integer.MAX_VALUE,minz=Integer.MAX_VALUE,maxx=Integer.MIN_VALUE,maxy=Integer.MIN_VALUE,maxz=Integer.MIN_VALUE;
     for(int z=0;z<cloud.depth;z++){

       if(cloud.exists(z)){

         for(int x=0;x<cloud.width;x++){
           for(int y=0;y<cloud.height;y++){
             if(cloud.get(z,x,y)==c){
                minx=min(x,minx);
                maxx=max(x,maxx);
                miny=min(y,miny);
                maxy=max(y,maxy);
                minz=min(z,minz);
                maxz=max(z,maxz);
             }
           }
         }           
       }
     }
     ofx=minx;
     ofy=miny;
     ofz=minz;
     xext=maxx-minx+1;
     yext=maxy-miny+1;
     zext=maxz-minz+1;
     maxX=max(maxx,maxX);
     maxY=max(maxy,maxY);
     maxZ=max(maxz,maxZ);
     minX=min(minx,minX);
     minY=min(miny,minY);
     minZ=min(minz,minZ);
     grid=new byte[xext][yext][zext];
     //println(grid.length+" "+grid[0].length+" "+grid[0][0].length);
    // println(minz+" "+minx+" "+miny);
     for(int z=0;z<grid[0][0].length;z++){
       if(cloud.exists(z+minz)){
         for(int x=0;x<grid.length;x++){
            for(int y=0;y<grid[0].length;y++){
              //println(x+" "+y+" "+z+" "+cloud.get(z+minz,x+minx,y+miny));
              grid[x][y][z]=PApplet.parseByte(cloud.get(z+minz,x+minx,y+miny)==c);
            }
         }
       }
     }
     nodes =new ArrayList<Node>();
     lines=new ArrayList<Line>();
    }
    public void lines(){
      for(int i = 0;i<lines.size();i++){
        line(lines.get(i).p1.x*10,lines.get(i).p1.y*10,lines.get(i).p1.z*10,lines.get(i).p2.x*10,lines.get(i).p2.y*10,lines.get(i).p2.z*10);
      }
    }
    public void points(){
      for(int i = 0;i<nodes.size();i++){
        point(nodes.get(i).vertex.x*10,nodes.get(i).vertex.y*10,nodes.get(i).vertex.z*10); 
      }
    }
     public void triangles(){
       noStroke();
       fill(color(red(col),green(col),blue(col)));//because of the number of overlapping triangles, any transparrent color looks terable
       for(int i=0;i<triangles.size();i++){
         triangles.get(i).draw(); 
       }
    }
    public void drawBuffer(){
      shape(triangleBuffer); 
    }
    public void map(){

      triangles=new ArrayList<Triangle>();
      nodes =new ArrayList<Node>();
      if(col==0) return;
      for(int x=0;x<grid.length;x++){
        //println(x);
       for(int y=0;y<grid[0].length;y++){
          for(int z=0;z<grid[0][0].length;z++){
            if(grid[x][y][z]==1){
               grid[x][y][z]=2;
               Vertex thisPoint=new Vertex(x+ofx,y+ofy,z+ofz);
               Node thisNode=new Node(thisPoint);
               for(int xs=-1;xs<=1;xs++){
                 for(int ys=-1;ys<=1;ys++){
                   for(int zs=-1;zs<=1;zs++){
                     
                     if(x-xs<0||x-xs>=grid.length||y-ys<0||y-ys>=grid[0].length||z-zs<0||z-zs>=grid[0][0].length||(xs==0&&ys==0&&zs==0)){
                       
                     }else{
                       
                       //println(grid.length+" "+grid[0].length+" "+grid[0][0].length);
                       if(grid[x-xs][y-ys][z-zs]>0){
                         Vertex connectedPoint=new Vertex(x-xs+ofx,y-ys+ofy,z-zs+ofz);
                         thisNode.connect(connectedPoint);
                         lines.add(new Line(thisPoint,connectedPoint));
                       }
                     }
                   }
                 }
               }
               //if(lines.size()>0){
               triangles=thisNode.triangles(triangles);
               minX=min(minX,thisPoint.x);
               minY=min(minY,thisPoint.y);
               minZ=min(minZ,thisPoint.z);
               maxX=max(maxX,thisPoint.x);
               maxY=max(maxY,thisPoint.y);
               maxZ=max(maxZ,thisPoint.z);
               nodes.add(thisNode);
              
              //}
            }
          }
       }
     } 
               //println(nodes.size());
               //println(triangles.size());
               stripDupeTriangles();
               //println(triangles.size());
               //for(int i=0;i<triangles.size();i++){
               //  println(triangles.get(i).toString());
               //}
        grid=null;//destroy the grid to free up memory, these things can be huge
    }
    public Web stripDupeTriangles(){
      HashMap<String,Triangle> map=new HashMap<String,Triangle>();
      for(int i=0;i<triangles.size();i++){
        map.put(triangles.get(i).identify(),triangles.get(i)); 
      }
      
      triangles=new ArrayList<Triangle>();
      for(String i:map.keySet()){
        triangles.add(map.get(i));
      }
      return this;
    }
    public Web bufferTriangles(){
      triangleBuffer=createShape(GROUP);
      for(int i=0;i<triangles.size();i++){
        PShape temp=createShape();
         temp.setFill(color(red(col),green(col),blue(col)));
 

        temp=triangles.get(i).buffer(temp);
 
        triangleBuffer.addChild(temp);
      }
      return this;
    }
    public Web trianglesToFile(PrintWriter obj, PrintWriter mtl, int vertexOffset ){
     
       HashMap<String,Integer> nodeKey=new HashMap<String,Integer>();
      for(int i=0;i<nodes.size();i++){
        nodeKey.put(nodes.get(i).toString(),i);
      }
      String buffer="";
      for(int i=0;i<triangles.size();i++){

        buffer+="f "+(vertexOffset+nodeKey.get(triangles.get(i).p1.toString()))+" "+(vertexOffset+nodeKey.get(triangles.get(i).p2.toString()))+" "+(vertexOffset+nodeKey.get(triangles.get(i).p3.toString()))+"\n"; 
        if(buffer.length()>1000){
          //println(i+" of "+triangles.size()+" triangles");
          obj.print(buffer); 
          buffer="";

        }
        
      }
      obj.print(buffer);
      obj.flush();
      return this;
    }
    
     
    public Web vertecesToFile(PrintWriter obj){
      String buffer="";

      for(int i=0;i<nodes.size();i++){
        buffer+="v "+nodes.get(i).toObj()+"\n";
        if(buffer.length()>1000){
          //println(i+" of "+nodes.size()+" nodes");
          obj.print(buffer); 
          buffer="";
        }
      }

      obj.print(buffer);
      //obj.flush();
      return this;
    }
  }
   ArrayList<Web> web;
   public void settings(){
       size(800,800,OPENGL); 
   }
   public void center(){
      translate(-(minX+maxX)/2*10,-(minY+maxY)/2*10,-(minZ+maxZ)/2*10);
    }
  public void setup(){
 surface.setTitle("3D Visulization"); 
   //square();
   //sphere();
   
   //torus();
    prep();
   
   
   //teapot();
   //web.recursive(0);


   frameRate(60);
  }
  boolean STOP=false;
  
  public void prep(){
    STOP=true;
    strip();
    web=new ArrayList<Web>();
    for(int i=1;i<cloud.palette.size();i++){
       web.add(new Web(cloud,cloud.palette.get(i)));
       web.get(i-1).map();
       web.get(i-1).bufferTriangles();
    } 
    STOP=false;
    //odly not only does saveHandler have to be public, but it also has to be part of a public class
    selectFolder("Select a directory to save to","saveHandler");//trigger stack load
    //im not entirely sure how this works, I assumed that the Sidebar thread starts the 3d thread, then the 3d thread starts a file io thread, which calles saveHandler when a file is selected
    //how ever, that would mean that no existing threads would be locked up by the load thread called by file io thread, so maybe it calls back to the previous thread and uses it for the load
    //except, that would lockup 3d visulizer... which does not lock up, which makes me think it instead has its on thread.... but there is a problem with that too,
    //the side bar thread is locked up on save... which is the first ish thread in the chain, to make things worse it does not block the CASTER main thread which called the sidebar thread
    //so I have no idea what is going on
    //to further complicate things, the side bar does not lock durring the rest of prep, only when we receive the callback from selctFolder, but 3d does lock except for not locking on the callback... so I am verry confused about which thread this goes in
    //TLDR: this callback thing is confusing on so many levels
  }
  
  float rad=0;
  float rotX,rotY,posX,posY,posZ;
  public void draw(){
    if(!STOP){
      background(0);
    lights();
    fill(255);
    //rect(0,0,100,100);
    translate(width/2,height/2,000);
       
    translate(posX,posY,posZ);
    rotateX(-PI/2);
    rotateZ(rotX);
    rotateX(rotY);
    center();
  
    
  
    //rotate(rad,0,1,0);
    //rad+=.1;
    pushMatrix();
 /*
    for(int z=0;z<cloud.depth;z++){
     if(cloud.exists(z)){
        for(int x=0;x<cloud.width;x++){
          for(int y=0;y<cloud.height;y++){
            color c=cloud.get(z,x,y);
            if(c!=0){
             
              stroke(color(red(c),green(c),blue(c)));
              point(x*10,y*10,z*10);
            }
          }
        }
      }
    }
    */

    stroke(255);
    noFill();
    fill(100);
    for(int i=0;i<web.size();i++){
      //web.get(i).triangles();
      web.get(i).drawBuffer();
    }
    //box(100,100,100);
    //web.lines();
    stroke(255,0,0);
    
    //for(int i=0;i<web.size();i++){
    //  web.get(i).points();
    //}
    //web.antiCursionFrame();
    popMatrix();
    }else{
      background(255); 
    }
   
  }
  public void mouseWheel(MouseEvent event){//mouse scrole handler
    posZ-=((2*event.getAmount()))*20;
  }
  public void mouseDragged(){
    if(mouseButton==RIGHT){
      //r=sqrt(mouseX^2+mouseY^2+mouseZ^2)
             rotX-=(pmouseX-mouseX)/100.f;
             rotY+=(pmouseY-mouseY)/100.f;
             
             
    }
    if(mouseButton==CENTER){
      posZ+=(pmouseY-mouseY)*10; 
    }
    if(mouseButton==LEFT){
      posX-=pmouseX-mouseX;
      posY-=pmouseY-mouseY;
    }
  }
  public void keyTyped(){//key type handler, for wacom tablet ease of resizing and layer change and redo
    if (key=='+'){
      layerThickness++;
      for(int i=0;i<web.size();i++){
        //web.get(i).triangles();
        web.get(i).bufferTriangles();
      }
    }else if(key=='-'){
      layerThickness--;
      if (layerThickness<1){
        layerThickness=1;
      }
      for(int i=0;i<web.size();i++){
        //web.get(i).triangles();
        web.get(i).bufferTriangles();
      }
    }
  }
  public String rgbToMtl(int c){
    return"\n";
  }
  public void saveHandler(File folder){
    
    String fileName=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();

    PrintWriter mtl =createWriter(folder.getAbsolutePath()+"\\"+fileName+".mtl");

    PrintWriter obj =createWriter(folder.getAbsolutePath()+"\\"+fileName+".obj");
    //println("write started");
    obj.println("#CASTER v"+VERSION+" https://github.com/Jesse-McDonald");
    obj.println("#3D recreation of cell or cells with a layer pixel thickness of "+layerThickness);
    obj.println("mtllib "+fileName+".mtl");
    //println("starting verteces");
    for(int i=0;i<web.size();i++){
       web.get(i).vertecesToFile(obj);
    }
    obj.flush();
    //println("Verteces finished\nstarting triangles");
    int vertexOffset=1;//as we move down the images we can refer to the vertices by web internal order, but only if we track how many total verteces there are before the start of the file
    for(int i=0;i<web.size();i++){
      mtl.println("newmtl Material."+(i+1));
      mtl.print(rgbToMtl(web.get(i).col));
      obj.println("usemtl Material."+(i+1));
      obj.println("s off");
      web.get(i).trianglesToFile(obj,mtl,vertexOffset);
      vertexOffset+=web.get(i).nodes.size();
    }
    //println("triangles Finished\nfinishing");
    obj.flush();
    mtl.flush();
    obj.close();
    mtl.close();
    //println("save finished");

  }
}
//only exists as a way of moving ui construction to its own file
//depends only on fully implimented Ui_ elements
public Ui buildUi(PApplet dm){  
  Ui ui=new Ui(dm);//prep ui
  float numButtons=5;//a arbitrary number to help size the the buttons,it is really quite missnamed
  PImage mask=loadImage("ui/buttonColorMap.png");
  float spacing=1/((numButtons+.5f)*2.5f);//more sizing stuff
  numButtons*=2.5f;//and more arbitrary constants
  Ui_PopupPanel brushPannel=new Ui_PopupPanel();
  ui.add(new Ui_Panel(0,1,1.2f,6.7f,color(240,240,240,200)));//add the panel to the ui
  {//this is a huge reason the { should always be on the same line as the thing it is extending, other wise there is the confusion of if this is a function called ui.add or something
    //or just the code block it is
    Ui_RadioButton buildRadio=new Ui_RadioButton(1);//prep radio button for brush buttons
    brushPannel.add(new Ui_Panel(1.2f,1,1.1f,6.7f,color(240,240,240,200)));//add the panel to the popout  
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2f,1.1f,1,"ui/paintBrushRound.png");
      
      build.setPressedImg("ui/paintBrushRoundActive.png");
      build.setHighlightedImg("ui/highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new CircleBrush();
      build.onDeactivate=new ClearBrush(1);//incase you are wonding why this is here, onDeactivate has to be some sort of lambda
      //but it does not need to do something.  All of these where already clearBrush, so I left it clear brush, but now clearBrush does
      //not DO anything, so this line is bascially a do nothing line
      buildRadio.add(build);
    }//round brush button
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2f,2.2f,1,"ui/paintBrushSquare.png");
      build.setPressedImg("ui/paintBrushSquareActive.png");
      build.setHighlightedImg("ui/highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new SquareBrush();
      build.onDeactivate=new ClearBrush(2);
      buildRadio.add(build);
    }//square brush button
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2f,3.3f,1,"ui/paintBrushDiamond.png");
      build.setPressedImg("ui/paintBrushDiamondActive.png");
      build.setHighlightedImg("ui/highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new DiamondBrush();
      build.onDeactivate=new ClearBrush(3);
      buildRadio.add(build);
    }//diamond brush button
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2f,4.4f,1,"ui/blackHoleBrush.png");
      build.setPressedImg("ui/blackHoleBrushActive.png");
      build.setHighlightedImg("ui/highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new BlackHoleBrush();
      build.onDeactivate=new ClearBrush(4);
      buildRadio.add(build);
    }//paint brush button
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2f,5.5f,1,"ui/paintCan.png");
      build.setPressedImg("ui/paintCanActive.png");
      build.setHighlightedImg("ui/highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new FloodBrush();
      build.onDeactivate=new ClearBrush(4);
      buildRadio.add(build);
    }//paint brush button
    brushPannel.add(buildRadio);//add the radio button (and all sub buttons) to the ui
  }
  {//add eraser button directly to brushPannel
    Ui_PaintButton build=new Ui_PaintButton(1.2f,6.6f,1,"ui/eraser.png");
    build.setPressedImg("ui/eraserActive.png");
    build.setHighlightedImg("ui/highlight.png");
	  build.c=0;
    build.mask=mask;
    build.onActivate=new EraserBrush(true);
    build.onDeactivate=new EraserBrush(false);
    build.id="eraser";
    brushPannel.add(build);
    
  }//erraser button
  
  
   Ui_PopupPanel semiAuto=new Ui_PopupPanel();
    {//this is a huge reason the { should always be on the same line as the thing it is extending, other wise there is the confusion of if this is a function called ui.add or something
    //or just the code block it is
    Ui_RadioButton buildRadio=new Ui_RadioButton(1);//prep radio button for brush buttons
   semiAuto.add(new Ui_Panel(1.2f,1,1.1f,3.4f,color(240,240,240,200)));//add the panel to the popout  
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2f,1.1f,1,"ui/rayCastBrush.png");
      build.setPressedImg("ui/rayCastBrushActive.png");
      build.setHighlightedImg("ui/highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new RayCastBrush();
      build.onDeactivate=new ClearBrush(6);
      buildRadio.add(build);
    }//ray cast brush button
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2f,2.2f,1,"ui/edgeFollower.png");
      build.setPressedImg("ui/edgeFollowerActive.png");
      build.setHighlightedImg("ui/highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new EdgeFollowingBrush();
      build.onDeactivate=new EdgeFollowingBrushDestroy();
      
      buildRadio.add(build);
    }//Edge follow brush
    
    
    //dbjones2518
      {//add buttons to radio button? Maybe? I chose a kitty for the picture
      //Ui_PaintButton build = new Ui_PaintButton(1.2, 3.3, 1, "ui/tail.png");
      Ui_PaintButton build = new Ui_PaintButton(1.2f, 3.3f, 1, "ui/tail.png");
      build.setPressedImg("ui/tailActive.png");
      build.setHighlightedImg("ui/highlight.png");
      build.c = 0;
      build.mask=mask;
      build.onActivate = new AxonBrush();
      buildRadio.add(build);
        
      }//probably missed something important, trying to make an axon button
    
    
    
    
    
    
    
    semiAuto.add(buildRadio);//add the radio button (and all sub buttons) to the ui
  }//automation
  {
    Ui_RadioControler buildRadio=new Ui_RadioControler(1);//prep radio button for panels
    {//add Brush pannel trigger to radio button
      Ui_Button build=new Ui_Button(.1f,1.1f,1,"ui/paintBrush.png");
      build.setPressedImg("ui/paintBrushActive.png");
      build.setHighlightedImg("ui/highlight.png");
      brushPannel.changeTrigger(build);

      buildRadio.add(build);
    }
    {//add semi automation pannel trigger
      Ui_Button build=new Ui_Button(0.1f,2.2f,1,"ui/semiAuto.png");
      build.setPressedImg("ui/SemiAutoActive.png");
      build.setHighlightedImg("ui/highlight.png");
      semiAuto.changeTrigger(build);

      buildRadio.add(build);
    }
    ui.add(buildRadio);
  }//popup window controler
  {//add 3d button
    Ui_Button build=new Ui_MomentaryButton(0.1f,3.3f,1,"ui/3d.png");
    build.setPressedImg("ui/3dActive.png");
    build.setHighlightedImg("ui/highlight.png");
    build.onActivate=new Create3D();

    ui.add(build);
    
  }// 3d button
  {//add a blank button for testing
    //Ui_Button build=new Ui_Button(.005,6/numButtons,spacing,"ui/blank.png");
   Ui_Button build=new Ui_Button(0.1f,6.6f,1,"ui/blank.png");
   
    build.setPressedImg("ui/blankActive.png");
    build.setHighlightedImg("ui/highlight.png");
    build.onActivate=new BlankButton();

    ui.add(build);
    
  }// blank button
  brushPannel.id="Brushes";
  ui.add(brushPannel);
  ui.add(semiAuto);
  {//add save button 
    Ui_Button build=new Ui_MomentaryButton(.1f,0,1,"ui/save.png");
    build.setPressedImg("ui/saveActive.png");
    build.setHighlightedImg("ui/highlight.png");
    build.onActivate=new Save();

    ui.add(build);
  }//save button
  {//add load button
  Ui_Button build=new Ui_MomentaryButton(1.2f,0,1,"ui/load.png");
  build.setPressedImg("ui/loadActive.png");
  build.setHighlightedImg("ui/highlight.png");
  build.onActivate=new Load();

  ui.add(build);
  }//load button
  {
    PImage highlight=new PImage(1,1,ARGB);
    highlight.set(0,0,color(0,0,255,50));
   Ui_RadioButton buildRadio=new Ui_RadioButton(1);//prep radio button for color buttons
   {//add buttons to radio button
      PImage tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(255,100,200));
      Ui_Button build=new Ui_Button(2.3f,0,1,tImg);
      tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(200,50,150));
      build.pressed=(tImg);
      build.highlighted=(highlight);
      build.onActivate=new LColor(color(255,100,200,75));;
      build.onDeactivate=new LColor(0);//incase you are wonding why this is here, onDeactivate has to be some sort of lambda
      //but it does not need to do something.  All of these where already clearBrush, so I left it clear brush, but now clearBrush does
      //not DO anything, so this line is bascially a do nothing line
      buildRadio.add(build);
    }
     {//add buttons to radio button
      PImage tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(255,0,0));
      Ui_Button build=new Ui_Button(2.3f,1.1f,1,tImg);
      tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(200,0,0));
      build.pressed=(tImg);
      build.highlighted=(highlight);
      build.onActivate=new LColor(color(255,0,0,75));;
      build.onDeactivate=new LColor(0);//incase you are wonding why this is here, onDeactivate has to be some sort of lambda
      //but it does not need to do something.  All of these where already clearBrush, so I left it clear brush, but now clearBrush does
      //not DO anything, so this line is bascially a do nothing line
      buildRadio.add(build);
    }
     {//add buttons to radio button
      PImage tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(255,150,0));
      Ui_Button build=new Ui_Button(2.3f,2.2f,1,tImg);
      tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(200,100,0));
      build.pressed=(tImg);
      build.highlighted=(highlight);
      build.onActivate=new LColor(color(255,150,0,75));;
      build.onDeactivate=new LColor(0);//incase you are wonding why this is here, onDeactivate has to be some sort of lambda
      //but it does not need to do something.  All of these where already clearBrush, so I left it clear brush, but now clearBrush does
      //not DO anything, so this line is bascially a do nothing line
      buildRadio.add(build);
    }
     {//add buttons to radio button
      PImage tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(255,255,0));
      Ui_Button build=new Ui_Button(2.3f,3.3f,1,tImg);
      tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(200,200,0));
      build.pressed=(tImg);
      build.highlighted=(highlight);
      build.onActivate=new LColor(color(255,255,0,75));;
      build.onDeactivate=new LColor(0);//incase you are wonding why this is here, onDeactivate has to be some sort of lambda
      //but it does not need to do something.  All of these where already clearBrush, so I left it clear brush, but now clearBrush does
      //not DO anything, so this line is bascially a do nothing line
      buildRadio.add(build);
    }
     {//add buttons to radio button
      PImage tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(0,255,0));
      Ui_Button build=new Ui_Button(2.3f,4.4f,1,tImg);
      tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(0,200,0));
      build.pressed=(tImg);
      build.highlighted=(highlight);
      build.onActivate=new LColor(color(0,255,0,75));;
      build.onDeactivate=new LColor(0);//incase you are wonding why this is here, onDeactivate has to be some sort of lambda
      //but it does not need to do something.  All of these where already clearBrush, so I left it clear brush, but now clearBrush does
      //not DO anything, so this line is bascially a do nothing line
      buildRadio.add(build);
    }
     {//add buttons to radio button
      PImage tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(0,0,255));
      Ui_Button build=new Ui_Button(2.3f,5.5f,1,tImg);
      tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(0,0,200));
      build.pressed=(tImg);
      build.highlighted=(highlight);
      build.onActivate=new LColor(tColor(26, 140, 255, 75));
      build.onDeactivate=new LColor(0);//incase you are wonding why this is here, onDeactivate has to be some sort of lambda
      //but it does not need to do something.  All of these where already clearBrush, so I left it clear brush, but now clearBrush does
      //not DO anything, so this line is bascially a do nothing line
      buildRadio.add(build);
    }
     {//add buttons to radio button
      PImage tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(255,0,255));
      Ui_Button build=new Ui_Button(2.3f,6.6f,1,tImg);
      tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(200,0,200));
      build.pressed=(tImg);
      build.highlighted=(highlight);
      build.onActivate=new LColor(tColor(255,0,255,75));;
      build.onDeactivate=new LColor(0);//incase you are wonding why this is here, onDeactivate has to be some sort of lambda
      //but it does not need to do something.  All of these where already clearBrush, so I left it clear brush, but now clearBrush does
      //not DO anything, so this line is bascially a do nothing line
      buildRadio.add(build);
    }
    
    ui.add(buildRadio);
  }
  {
    {//add semi automation pannel trigger
      Ui_PaintButton build=new Ui_PaintButton(2.3f,7.7f,1,"ui/colorPicker.png");
      build.setPressedImg("ui/colorPickerActive.png");
      build.setHighlightedImg("ui/highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new PickerBrush();
      build.onDeactivate=new ClearBrush(6);
      ui.add(build);
    }
  }
  {//size slider,
    PImage tImg=new PImage(100,40,ARGB);
    tImg.loadPixels();
    for(int i=0;i<tImg.pixels.length;i++){
      tImg.pixels[i]=tColor(150,150,100); 
    }
    tImg.updatePixels();
    Ui_Slider build=new Ui_Slider(.3f,7.7f,2, tImg);
    build.onChange=new SizeSlider();
    build.minV=0;
    build.maxV=100;
    build.boundValue=sizeSlider;
    ui.add(build);
  }
  
  ui.setDM(dm);
  return ui;
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "CASTER" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
