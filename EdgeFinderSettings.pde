public class EdgeFinderSettings extends PApplet 
  {
    Ui ui;
    float lightest;
    float variation;
    float repeats;
   
    public void settings() {
      size(600, 130);//Set the size of the pop up window
      ui=new Ui();
      // init them: (xPos, yPos, width, height)
      ui=edgeFinderUiBuild(this);
      //colorRangeSliders[0] = new Colors(80, 20, 40, 20, 65, 255); //and the location, width, and height of each slider and button
      //colorRangeSliders[1] = new Colors(80, 60, 40, 20, 75, 255);
      //repeatSliders[0] = new Repeats(80, 100, 40, 20);
      //newWindowButtons[0] = new Buttons(660, 30, 75, 75);
      //undo = Ui_Button//new Undo(750, 30, 75, 75);//I have added undo to the keyboard so im not sure if we need it here naymore
    }
    
    public void draw() 
    {
      background(100);
      ui.draw();      
    }
    
    //This is how the parameters are passed back to the main form
    public float[] getParameters()
    {
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
     
      Ui_Slider build=new Ui_ColorSlider(.3,0.1,6, tImg);
      build.onChange=new LightestSlider();
      build.setValue(65);
      ui.add(build);
    }
    {//lightness slider,

      Ui_Slider build=new Ui_ColorSlider(.3,.5,6, tImg);
      build.onChange=new VariationSlider();
      build.setValue(75);
      ui.add(build);
    }
    {//lightness slider,
      Ui_Slider build=new Ui_Slider(.3,.9,6, tImg);
      build.onChange=new RepeatsSlider();
      build.minV=0;
      build.maxV=1000;
      build.slider.resize(build.slider.width*2,build.slider.height);
      ui.add(build);
    }
    ui.setDM(dm);
    return ui;
  }
}