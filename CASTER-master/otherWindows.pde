//most of this code has been left for legacy reasons (read I dont want to refactor existing code to not use this)
//but many of its features have been moved to other places on the main UI
//for example, 3d view has been moved to a stand alone button on the main ui
//and undo/redo have been moved to control z, control shift z, and control y
//this code still has unique sliders that controle the Edge Finder Tool
//This is the code for the second pop up box (The Edge Finder tools)
public class SecondApplet extends PApplet 
  {
    Colors[] colorRangeSliders =  new Colors[2]; //Create two instances of color sliders
    Repeats[] repeatSliders = new Repeats[1]; //One instance of a regular slider
    //Buttons[] newWindowButtons = new Buttons[1]; //One button to display the 3D object
    //Undo undo;//and one button to undo the last move (up to 10 times)
    Ui_Button undo;
    float lightest;
    float variation;
    float repeats;
   
    public void settings() {
      size(600, 130);//Set the size of the pop up window
      
      // init them: (xPos, yPos, width, height)
      colorRangeSliders[0] = new Colors(80, 20, 40, 20, 65, 255); //and the location, width, and height of each slider and button
      colorRangeSliders[1] = new Colors(80, 60, 40, 20, 75, 255);
      repeatSliders[0] = new Repeats(80, 100, 40, 20);
      //newWindowButtons[0] = new Buttons(660, 30, 75, 75);
      //undo = Ui_Button//new Undo(750, 30, 75, 75);//I have added undo to the keyboard so im not sure if we need it here naymore
    }
    
    public void draw() 
    {
      //Use no outlines for the drawings, with a neutral gray background color, and create the sliders
      //Because this is repeatedly called, this is also where we collect the slider numbers
      this.noStroke();
      background(100);
      
      colorRangeSliders[0].run();
      lightest = colorRangeSliders[0].getLightestAndVariation();
      
      colorRangeSliders[1].run();
      variation = colorRangeSliders[1].getLightestAndVariation();
      
      repeatSliders[0].run();
      repeats = repeatSliders[0].getRepeats();
      
      //newWindowButtons[0].run();
      
      //undo.run();
    }
    
    //This is how the parameters are passed back to the main form
    public float[] getParameters()
    {
      float[] parameters = new float[]{lightest, variation, repeats};
      return parameters;
    }
    
    //Only move the sliders/press the buttons if the mouse is over the slider or button
    void mousePressed() 
    {
      for (Colors t:colorRangeSliders)
      {
        if (t.isOver())
          t.lock = true;
      }
      for (Repeats t:repeatSliders)
      {
        if(t.isOver())
          t.lock = true;
      }
      //for (Buttons t:newWindowButtons)
      //{
      //  if (t.isOver())
      //  {
      //    t.lock = true;
      //  }
      //}
      //if (undo.isOver())
      //{
      //  undo.lock = true;
      //}
    }
     
    void mouseReleased() 
    {
      for (Colors t:colorRangeSliders)
      {
        t.lock = false;
      }
      for (Repeats t:repeatSliders)
      {
        t.lock = false;
      }
      //for (Buttons t:newWindowButtons)
      //{
      //  t.lock = false;
      //}
      //undo.lock = false;
    }
    void dispose(){
      g.dispose(); 
    }
    void exit(){//I cant figure this out, when called this should join the thread drawing the window, and it should also close that window
    //after exploring the processing source I found out that the way they appear do to it is calling System.exit(1); this closes the entire JVM
    //which is not what we want.  After some hunting I was not able to find the java.awt.window we need to target to destroy this window.
    //this needs fixed, without this we get window leeks where extra windows can just pile up
     this.dispose(); 
     this.noLoop();
     surface.stopThread();
     g.dispose();
     this.stop();
     handleMethods("dispose");
    }

class Colors {//code for the color sliders
  //class vars
  float x;
  float y;
  float w, h;
  float initialY;
  float initialX;
  float startX;
  boolean lock = false;
  float value;
  float start;
  float lightest;
  float place;
 
  //This is pretty self explaitory, the coordinates, width, and height of the slider are read in.
  Colors (float _x, float _y, float _w, float _h, int _s, int _l) 
  {
    x=_x;
    y=_y;
    initialX = x - 127;
    startX = x;
    w=_w;
    h=_h;
    start = _s;
    lightest = _l;
    x = map(start, 0, 255, initialX, 373 + w);
  }
 
 
  void run() {
    // map value to change color..
    value = map(x, initialX, 373 + w, 0, lightest);
    
    //set color as it changes
    fill(color(value));
 
    // draw base line
    rect(startX, y, 500, 4);
 
    // draw knob
    fill(#858289); //This is the color of the slider
    //rect(x, y-8, w, h, 5);
    rect(x+127, y-8, w, h, 5); //This is the size of the slider and start location 
 
    // display text
    fill(0);
    text(int(value), x+135, y+6); // text(int(value), x+10, y+6);
    
    //display lables
    fill(0);
    text("Lightest:", 10, 25);
    fill(0);
    text("Variation:", 10, 65);
 
    //get mouseInput and relate it to the sliders position
    //float my = constrain(mouseX, initialX, 500 + w);
    float my = constrain(mouseX-127, initialX, 373 + w );
    if (lock)
    {
      x = my;
    }
  }
  
  //This is where the knob's color value is returned 
  public float getLightestAndVariation()
  {
    return value;
  }
  // is mouse over knob?
  boolean isOver()
  {
    return (x+w+127 >= mouseX) && (mouseX >= x+127) && (y+h >= mouseY) && (mouseY >= y);
    //return (x+w >= mouseX) && (mouseX >= x) && (y+h >= mouseY) && (mouseY >= y);
  }
}
  
//This creates and controls the slider for the repeat value
class Repeats {
  float x, y;
  float w, h;
  float initialX;
  boolean lock = false;
  float value;
  
  //Read in the x and y location of the slider, the width, and the height
  Repeats(float _x, float _y, float _w, float _h)
  {
    x = _x;
    y = _y;
    initialX = x;
    w = _w;
    h = _h;
  }
  
  void run()
  {
    //Then draw the slider
    value = map(x, initialX, 500+w, 0, 1000);//places the slider's current x value between the beginning and end of the slider and assigns a corresponding number, 0-1000
    fill(#3D3C3E); //fills the knob's color in and sets it's location
    rect(initialX, y, 500, 4);
    
    fill(#858289);//fills the bar's color in and sets it's location
    rect (x, y-8, w, h, 5);
    
    fill(0);//Fills the knob's text color in and shows the text
    text(int(value), x+10, y+6);
    
    fill(0);//Sets the color of the repeat lable and places it
    text("Repeats: ", 10, 105);
    
    float my = constrain(mouseX, initialX, 500 + w);//Keeps the slider's knob on the bar
    if (lock) x = my;
  }
  
  //This is where the slider's number is returned
  public float getRepeats()
  {
    return int(value);
  }
  
  //tells if the mouse is over the knob or not
  boolean isOver()
  {
    return (x+w >= mouseX) && (mouseY >= x) && (y+h > mouseY) && (mouseY >= y);
  }
}
/*
class Undo//REFACTOR
{
  //This button isn't working yet but the idea is to store everything needed to restore the overlay to a pervious state in an array
  //And then to push the array around so that it can be used as a stack, storing the last 10 copies of the overlay
  //If the user tries to undo more then 10 moves, nothing will happen
  //but it doesn't work quite yet. Any ideas? 
  float x;
  float y;
  float w, h;
  float initialY, initialX;
  boolean lock = false;
  
  Undo (float _x, float _y, float _w, float _h) {
    x=_x;
    y=_y;
    initialY = y;
    initialX = x;
    w=_w;
    h=_h;
  }
  
  void run() {
    fill(color(255,0,0,255)); //Create the button
    rect(x, y, w, h, 5);
    fill(0);//Create the text for the button
    text("Undo", x+(w/3), y+(h/2));
    //get mouseInput and map it
    if (lock)
    {
      //img.setOverlay(overlayCopies[9]);
      //img.overlay.set(img.layer, overlayCenters[9].x, overlayCenters[9].y);
      
      lock = false;
    }
  }
  
  boolean isOver()//This tells if the mouse if above the button when it is clicked
  {
    return (x+w >= mouseX) && (mouseX >= x) && (y+h >= mouseY) && (mouseY >= y);
  }
  
}

//This class opens up a new window that displays the 3D outlining
  class Buttons
{
  float x;
  float y;
  float w, h;
  float initialY, initialX;
  boolean lock = false;
  
  Buttons (float _x, float _y, float _w, float _h) {
    x=_x;
    y=_y;
    initialY = y;
    initialX = x;
    w=_w;
    h=_h;
  }
  
  void run() {
    fill(color(255,0,0,255));//Create the button
    rect(x, y, w, h, 5);
    fill(0);//Create the text for the button
    text("View in 3D", x+(w/8), y+(h/2));
    if (lock)//If the mouse is over the button
    {
      PApplet.runSketch(args, third);//Open the new window
      lock = false;
    }
  }
  
  boolean isOver()//Tells if the mouse is over the window
  {
    return (x+w >= mouseX) && (mouseX >= x) && (y+h >= mouseY) && (mouseY >= y);
  }
  
}

//This is the coding for the 3D viewing window
public class ThirdApplet extends PApplet 
{
  float rotX, rotY, x = 250, y = 250;//This allows for rotation of the x and y axis
  float scaleFactor = 1.0, translateX = 0.0, translateY = 0.0;//And this allows the 3D to be zoomed in and out
  color[][] locations;//Theoretically, this will store the locations of the membrane sections
  JFrame frame = new JFrame();//This so far is unimportant. I was trying to get a proper heading on the window
  
  
  void settings()
  {
    size(500,500, OPENGL);//this sets the size of the window and allows for 3D viewing
    frame.setTitle("View in 3D");//See, this is the attempt at a proper window title
  }
  
  void setup()
  {
     locations = new color [width][height];//And this creates a blank array the size of the image
  }
  
  void draw()//This is where the inside of the window box is filled in
  {  
     background(32);//A neutral background color
     smooth();
     lights();
     
     fill(color(255, 20, 147, 255));//A kinda pretty color that won't actually be shown
     noStroke();
     rotateX(rotX); //Display based on X and Y rotations and zoom level
     rotateY(-rotY); 
     scale(scaleFactor);
     for(int i = 0; i < width; i++)//Then for each section of image, regardless of color, display the section in that color
     {
       for(int j = 0; j < height; j++)
       {
         if (img.overlay.get(img.layer, i, j) != color(0))
         {
           locations[i][j] = img.overlay.get(img.layer,i,j);
           fill(color(255,0,0,255));
           translate(x+i, y+j);
           box(50);
         }
       }
     }
  }
  //I like these mouse controles
  void mouseDragged(){
    if (mouseButton == RIGHT)//Controlls the rotation of the image
    {
      rotY -= (mouseX - pmouseX) * 0.01;
      rotX -= (mouseY - pmouseY) * 0.01;
    }
    else if (mouseButton == LEFT)//Controls the location of the image
    {
      x += (mouseX - pmouseX) * 0.5;
      y += (mouseY - pmouseY) * 0.5;
    }
  }
  
  void mouseWheel(MouseEvent event){//Controlls the zoom of the image
    translateX -= mouseX;
    translateY -= mouseY;
    float delta = event.getCount() > 0 ? 1.05 : event.getCount() < 0 ? 1.0/1.05 : 1.0;
    scaleFactor *= delta;
    translateX *= delta;
    translateY *= delta;
    translateX += mouseX;
    translateY += mouseY;
  }
  
}
*/
  }
