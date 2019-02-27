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
}
