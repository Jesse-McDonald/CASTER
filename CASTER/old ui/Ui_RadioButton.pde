/* Radio button acts as a controler for other buttons to prevent more than 
n buttons from being active at the same time
Radio Button Depends on access to BitSet state, boolean mouseOn(), and void draw() from Ui_Button 
and also fUI_Element to extend
Radio Button does not depend on anything from processing
*/
class Ui_RadioButton extends Ui_Element{
	ArrayList<Ui_Button> buttons;//track all buttons
	ArrayList<Integer> active;//track the buttons that are pressed, this is an integer list for the index that button falls in buttons
	int allowed;//track the number of allowed active buttons
	Ui_RadioButton(){//default constructor has 1 active button
		this(1); 
	}
	
	Ui_RadioButton(int n){//in theory this can be something other than 1, but it is not the most stable
		allowed=n;
		buttons =new ArrayList<Ui_Button>();
		active=new ArrayList<Integer>();
	}
	
	Ui_RadioButton draw(){//this simply passes draw on to the buttons and also updating its self it needed
		for(int i=0;i<buttons.size();i++){
			boolean current =buttons.get(i).prevState;
			buttons.get(i).draw(); 
			if(current!=buttons.get(i).state.get(0)){//update if the button changes state
				update(i); 
			}
		}
		return this;
	}
	
	boolean mouseOn(){//pass mouse on to buttons
		for(int i=0;i<buttons.size();i++){
			if(buttons.get(i).mouseOn()){
				return true;
			}
		}
		return false;
	}
	
	Ui_RadioButton update(Integer i){//update the button 
		if (buttons.get(i).state.get(0)){//add new buttton
			active.remove(i);
			active.add(i);
			if (active.size()>allowed){//if too many buttons are active, drop the oldest one
				buttons.get(active.get(0)).state.set(0,false);
				active.remove((int)0);
			}
		}else{//remove unselected button
			buttons.get(i).state.set(0,false);
			active.remove(i);
		}
		return this;
	}
	
	Ui_RadioButton add(Ui_Button button){//add a new button to the list
    button.setDM(dm);
		buttons.add(button);
		return this;
	}

	Ui_RadioButton setActiveState(boolean set){//untested, I probiably will never use these
		for(int i=0;i<buttons.size();i++){
			buttons.get(i).state.set(3,set);
		} 
		return this;
	}

	Ui_RadioButton setActive(int n){//manual way to activate a button, draw and update should do everything else
		buttons.get(n).state.set(0,true);
		return this;
	}
	
	Ui_RadioButton activate(){//untested, I probiably will never use these
		setActiveState(false);
		return this;
	}
	
	Ui_RadioButton deactivate(){//untested, I probiably will never use these
		setActiveState(false);
		return this;
	}
	Ui_RadioButton hide(){//call when hiding
    for(int i=0;i<buttons.size();i++){
      buttons.get(i).hide();//call hide on children
    }
    active=new ArrayList<Integer>();//clear active buttons
    return this;
  }
  
   Ui_Element getId(String s){//check own id and id of all children, return if match
    //println("String s="+s);println("String id="+id);
    if(this.id.equals(s)){
      return this;
    }
   for(int i=0;i<buttons.size();i++){
      Ui_Element temp=buttons.get(i).getId(s);
      if (temp!=null){
       return temp; 
      }
   }
   return null;
  }
  Ui_RadioButton setDM(PApplet DrawM){
      dm=DrawM;
      for(int i=0; i<buttons.size();i++){
        buttons.get(i).setDM(dm);
      }
      return this;
  }
  public int calcWidth(){
   int max=0;
   for(int i=0; i<buttons.size();i++){
        max=max(max,buttons.get(i).calcWidth());
   }
   return max;
  }
  public int calcHeight(){
    int max=0;
   for(int i=0; i<buttons.size();i++){
        max=max(max,buttons.get(i).calcHeight());
   }
   return max;
  }
}