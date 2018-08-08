public class EdgeFinderSettings extends PApplet 
  {
    Ui ui;
    int picker=1;
    float lightest;
    float variation;
    float repeats;
    Binding<Integer> lightnessValue;
    Binding<Integer> variationValue;
    public void settings() {
      size(600, 130);//Set the size of the pop up window
      ui=new Ui();
      // init them: (xPos, yPos, width, height)
      ui=edgeFinderUiBuild(this);
      lightnessValue=new Binding<Integer>(65);
      variationValue=new Binding<Integer>(75);
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
  
  Ui edgeFinderUiBuild(PApplet dm){  
    Ui ui=new Ui(dm);//prep ui
     PImage tImg=new PImage(500,30,ARGB);
      tImg.loadPixels();
      for(int i=0;i<tImg.pixels.length;i++){
        tImg.pixels[i]=tColor(150,150,100); 
      }
      tImg.updatePixels();
    {//lightness slider,
     
      Ui_Slider build=new Ui_ColorSlider(1.3,0.1,6, tImg);
      build.onChange=new LightestSlider();
      build.boundValue=lightnessValue;
      build.setValue(65);
      build.slider.resize(round(build.slider.width*2.2),build.slider.height);
      ui.add(build);
    }
    {
      Ui_TextPanel build =new Ui_TextPanel(0.3,0.1,.9,.35,tColor(150,150,150));
      build.textColor=0;
      build.size=16;
      build.lable="Lightest:";
      build.offsetY=.5;
      build.offsetX=.1;
      ui.add(build);
    }
    {//variation slider,

      Ui_Slider build=new Ui_ColorSlider(1.3,.5,6, tImg);
      build.onChange=new VariationSlider();
      build.boundValue=variationValue;
      build.setValue(75);
      build.slider.resize(round(build.slider.width*2.2),build.slider.height);
      
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
      build.minV=0;
      build.maxV=1000;
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
    ui.setDM(dm);
    return ui;
  }
}