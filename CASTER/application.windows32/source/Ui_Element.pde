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
