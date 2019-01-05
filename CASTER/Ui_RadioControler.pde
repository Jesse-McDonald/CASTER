//this class is exactly the same as Ui_RadioButtton, except it assumes something else is drawing and updating the individual buttons
class Ui_RadioControler extends Ui_RadioButton{
  Ui_RadioControler(int i){
   super(i); 
  }
  Ui_RadioControler draw(){//this simply does not passes draw on to the buttons and then updates its self it needed
    for(int i=0;i<buttons.size();i++){
      boolean current =buttons.get(i).prevState;
      if(current!=buttons.get(i).state.get(0)){//update if the button changes state
        update(i); 
      }
    }
    return this;
  }
  
  boolean mouseOn(){//also dont pass mouse on to buttons
    return false;
  }
}