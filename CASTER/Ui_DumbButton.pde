//extends button, state is completly not managed by the button, and it does not draw
class Ui_DumbButton extends Ui_Button{
  Ui_DumbButton(boolean v){
      super(0,0,createImage(0,0,ARGB));//create invisible image
      state.set(0,v);
  }
  Ui_DumbButton draw(){return this;}//do  nothing
  boolean mouseOn(){return false;}//do nothing
  
}