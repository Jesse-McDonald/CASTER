public class EdgeFinderSettings extends PApplet 
  {

    Ui_Button undo;
    float lightest;
    float variation;
    float repeats;
   
    public void settings() {
      size(600, 130);//Set the size of the pop up window
      // init them: (xPos, yPos, width, height)
      //colorRangeSliders[0] = new Colors(80, 20, 40, 20, 65, 255); //and the location, width, and height of each slider and button
      //colorRangeSliders[1] = new Colors(80, 60, 40, 20, 75, 255);
      //repeatSliders[0] = new Repeats(80, 100, 40, 20);
      //newWindowButtons[0] = new Buttons(660, 30, 75, 75);
      //undo = Ui_Button//new Undo(750, 30, 75, 75);//I have added undo to the keyboard so im not sure if we need it here naymore
    }
    
    public void draw() 
    {
      //Use no outlines for the drawings, with a neutral gray background color, and create the sliders
      //Because this is repeatedly called, this is also where we collect the slider numbers
      this.noStroke();
      background(100);
      
    }
    
    //This is how the parameters are passed back to the main form
    public float[] getParameters()
    {
      float[] parameters = new float[]{lightest, variation, repeats};
      return parameters;
    }
    
}