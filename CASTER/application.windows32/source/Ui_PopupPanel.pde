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
  Ui_PopupPanel setDM(PApplet DrawM){
      dm=DrawM;
      for(int i=0; i<elements.size();i++){
        elements.get(i).setDM(dm);
      }
      trigger.setDM(dm);
      return this;
  }
  Ui_Element getId(String s){
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
