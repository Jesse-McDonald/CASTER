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