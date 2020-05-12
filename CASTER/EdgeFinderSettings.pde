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
      surface.setSize(round(ui.calcWidth()+programSettings.monitorPPI*.1),round(ui.calcHeight()+programSettings.monitorPPI*.1)); 
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
    void run(int x){
      lightest=x; 
    }
  }
  class VariationSlider extends VariableLambda{
    void run(int x){
      variation=x; 
    }
  }
  class RepeatsSlider extends VariableLambda{
    void run(int x){
      repeats=x; 
    }
  }
  class PickerLambda extends Lambda{
    int target;
    PickerLambda(int x){
      target=x;
    }
    void run(){
       picker=target;
    }
  }
  Ui edgeFinderUiBuild(PApplet dm){  
    Ui ui=new Ui(dm);//prep ui
     PImage tImg=new PImage(500,30,ARGB);
      tImg.loadPixels();
      for(int i=0;i<tImg.pixels.length;i++){
        tImg.pixels[i]=tColor(150,150,100); 
      }
      tImg.updatePixels();
    {//lightness slider,
     
      Ui_Slider build=new Ui_ColorSlider(1.3,0.1,5.65, tImg);
      build.onChange=new LightestSlider();
      
      build.setValue(65);
      build.slider.resize(round(build.slider.width*2.2),build.slider.height);
      build.boundValue=lightnessValue;
      ui.add(build);
    }
    {
      Ui_TextPanel build =new Ui_TextPanel(0.3,0.1,.9,.35,tColor(150,150,150));
      build.textColor=0;
      build.size=16;
      build.lable="Average:";
      build.offsetY=.5;
      build.offsetX=.1;
      ui.add(build);
    }
    {//variation slider,

      Ui_Slider build=new Ui_ColorSlider(1.3,.5,5.65, tImg);
      build.onChange=new VariationSlider();
     
      build.setValue(75);
      build.slider.resize(round(build.slider.width*2.2),build.slider.height);
      build.boundValue=variationValue;
      ui.add(build);
    }
    {
      Ui_TextPanel build =new Ui_TextPanel(0.3,0.5,.9,.35,tColor(150,150,150));
      build.textColor=0;
      build.size=16;
      build.lable="Variation:";
      build.offsetY=.5;
      build.offsetX=.1;
      ui.add(build);
    }
    {//reapeats slider,
      Ui_Slider build=new Ui_Slider(1.3,.9,6, tImg);
      build.onChange=new RepeatsSlider();
      build.minV=4;
      build.maxV=100;
      build.slider.resize(round(build.slider.width*2.2),build.slider.height);
      ui.add(build);
    }
    {
      Ui_TextPanel build =new Ui_TextPanel(0.3,0.9,.9,.35,tColor(150,150,150));
      build.textColor=0;
      build.size=16;
      build.lable="Repeats:";
      build.offsetY=.5;
      build.offsetX=.1;
      ui.add(build);
    }
    {
      PImage mask=loadImage("ui/buttonColorMap.png");//... ok processing... I have had enough of you....., what the frick do you call this!
      //why would need to load all images from the main thread????
      Ui_RadioButton buildRadio=new Ui_RadioButton(1);//prep radio button for pickers
      buildRadio.id="pickers";
      {//add buttons to radio button
          Ui_Button build=new Ui_Button(7.25,0.1,.33,"ui/colorPicker.png");
          build.setPressedImg("ui/colorPickerActive.png");
          build.setHighlightedImg("ui/highlight.png");
          //build.c=0;
          build.background=mask;
          build.onActivate=new PickerLambda(1);
          build.onDeactivate=new PickerLambda(0);
          buildRadio.add(build);
      }//lightness color picker
      {//add buttons to radio button
          Ui_Button build=new Ui_Button(7.25,0.5,.33,"ui/colorPicker.png");
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
  PImage loadImage(String path){//because WHY NOT!!!! >:(
   return imgFromFile(path); 
  }

  
  /*All ui files have been moved to the bottom of this file to free up the namespace*/
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
  Ui_TextPanel(float x, float y, float w, float h, color c){super(x,y,w,h,c);}
  Ui_TextPanel(int x, int y, int w, int h, color c){super(x,y,w,h,c);}
  Ui_TextPanel(){super();}
  Ui_TextPanel draw(){
    super.draw();
    if (font!=null) dm.textFont(font);
    dm.textSize(size);
    dm.stroke(textColor);
    dm.text(lable,posX+offsetX*tile.width,posY+offsetY*tile.height+size/4);//executive decision, shift is relative to the left center of the text box
    return this;
  }
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
    dm.translate(slider.width/2*scale,(tile.height-track.height)*scale/2.);
    dm.scale(scale);//prep scale
    
    dm.image(track,0,0);
    dm.translate((pos-slider.width/2),-slider.height/4);
    dm.image(slider,0,0);
    if(textValue){
      //dm.stroke(0);
     // dm.fill(00);
      dm.translate(programSettings.monitorPPI*.02,3*slider.height/4);
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
	
	Ui_RadioButton draw(){//this simply passes draw on to the buttons and also updating its self it needed
		for(int i=0;i<buttons.size();i++){
			boolean current =buttons.get(i).prevState;
			buttons.get(i).draw(); 
			if(current!=buttons.get(i).state.get(0)){//update if the button changes state
				update(i); 
			}
		}
		return this;
	}
	
	boolean mouseOn(){//pass mouse on to buttons
		for(int i=0;i<buttons.size();i++){
			if(buttons.get(i).mouseOn()){
				return true;
			}
		}
		return false;
	}
	
	Ui_RadioButton update(Integer i){//update the button 
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
	
	Ui_RadioButton add(Ui_Button button){//add a new button to the list
    button.setDM(dm);
		buttons.add(button);
		return this;
	}

	Ui_RadioButton setActiveState(boolean set){//untested, I probiably will never use these
		for(int i=0;i<buttons.size();i++){
			buttons.get(i).state.set(3,set);
		} 
		return this;
	}

	Ui_RadioButton setActive(int n){//manual way to activate a button, draw and update should do everything else
		buttons.get(n).state.set(0,true);
		return this;
	}
	
	Ui_RadioButton activate(){//untested, I probiably will never use these
		setActiveState(false);
		return this;
	}
	
	Ui_RadioButton deactivate(){//untested, I probiably will never use these
		setActiveState(false);
		return this;
	}
	Ui_RadioButton hide(){//call when hiding
    for(int i=0;i<buttons.size();i++){
      buttons.get(i).hide();//call hide on children
    }
    active=new ArrayList<Integer>();//clear active buttons
    return this;
  }
  
   Ui_Element getId(String s){//check own id and id of all children, return if match
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
  Ui_RadioButton setDM(PApplet DrawM){
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
  Ui_ColorSlider init(){//this is only here because I can not call a super constructor and a this constructor, so this is the real this constructor
   minV=0;
   maxV=255;
   return this;
  }
 Ui_Slider draw(){
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
}
