/**
this class is rather simple for how powerful it is
in short Ui is a UI manager, it holds and handles all elements of the ui
to add a new Ui_Element just run add(element)
Ui depends on the existence of an Ui_Element class and access to its void draw(), and boolean mouseOn methods
Ui does not depend on any processing specific elements
*/
class Ui{
	private ArrayList<Ui_Element> elements;//track every element on the ui
  public PApplet drawManager;
	Ui(){//create empty ui
		elements=new ArrayList<Ui_Element>();
	}
  Ui(PApplet dm){
   this();
   drawManager=dm; 
  }

	public boolean onUi(){//used to determin if the mouse is on the ui, redirct internaly
		for(int i=0; i<elements.size();i++){
			if(elements.get(i).mouseOn()){
				return true;//notice that you can not depend on mouseOn being called in your element as this will return as soon as the mouse is on any element
				//so dont put too much important processing in mouseOn unless you call it from else ware
			}
		}
		return false;
	}

	public Ui draw(){//draw all elements in the order they where created
		for(int i=0; i<elements.size();i++){
				elements.get(i).draw();
		}
		return this;
	}
  public Ui setDM(PApplet target){
    drawManager=target;
    for(int i=0; i<elements.size();i++){
        elements.get(i).setDM(drawManager);
    }  
    return this;
  }
	public Ui add(Ui_Element e){//add new element to the ui, new elements always appear over older one
    e.setDM(drawManager);
		elements.add(e);
		return this;
	}

	public Ui_Element get(int i){//get a specific element, obfuscates ui.elements.get(i) to ui.get(i)
		return elements.get(i); 
	}
  public int calcHeight(){
    int max=0;
    for(int i=0; i<elements.size();i++){
      max=max(max,elements.get(i).calcHeight());
    }   
    return max;
  }
  public int calcWidth(){
    int max=0;
    for(int i=0; i<elements.size();i++){
      max=max(max,elements.get(i).calcWidth());
 
    }
    return max;
  }
  public Ui_Element getId(final String id){
   for(int i=0;i<elements.size();i++){
      Ui_Element temp=elements.get(i).getId(id);
      //println(id);
      if (temp!=null){
        //println(temp);
       return temp; 
      }
   }
   //println("Returning nul");
   return null;
  }
  
}
