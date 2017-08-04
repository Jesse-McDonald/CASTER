/**
implements a rough lambda concept since processing does not have it by default
the Lambda class is technically abstract, but has been declared otherwise so as a empty Lambda can be created by default
this has been implemented to allow clickable buttons
collectively all implemented lambda functions depend on access to global EMImage img, Brush img.brush, int img.brush.mode, void img.brush.update(), void img.brush.clearBrush(), void img.save(), void img.load()
these also depend on void selectInput(String path, String function, Object this) and void selectOutput(String path, String function,Object this) from processing
*/
class Lambda{
	Lambda(){}//all lambda objects will have a default constructor and run()
	public void run(){}
}

class CircleBrush extends Lambda{//allows for circle brush button
	void run(){
		img.brush.mode=1;
		img.brush.update();
	}
}

class SquareBrush extends Lambda{//allows for square brush button
	void run(){
		img.brush.mode=2;
		img.brush.update();
	}
}
class RayCastBrush extends Lambda{//allows for raycast brush button
  void run(){
    img.brush.mode=6;
    img.brush.update();
  }
}
class DiamondBrush extends Lambda{//allows for diamond brush button
	void run(){
		img.brush.mode=3;
		img.brush.update();
	}
}

class FloodBrush extends Lambda{//allows for flood fill button
	void run(){
		img.brush.mode=4;
		img.brush.update();
	}
}

class ClearBrush extends Lambda{//allows for clear brush button that is tuned to specific brush via constructor
	int n;
	ClearBrush(){//just to be safe
		n=0; 
	}
	
	ClearBrush(int in){//allow specification of brush to clear, helps prevent radio button errors
		n=in;
	}
	
	void run(){
		img.brush.clearBrush(n);
	}
}
class EraserBrush extends Lambda{//allows for erase mode button
	boolean state;
	EraserBrush(boolean b){
		state=b;
	}
	
	void run(){
		img.brush.erase=state;

	}
}

public class Save extends Lambda{//allows for overlay save button
public void run(){
	selectOutput("Select file to save overlay","handler",new File(""),this);

	}
	
	public void handler(File f){//this gets called by selectOutput when the output is selected
		if(f!=null){
		img.save(f); 
		} 
	}
}

public class Load extends Lambda{//allow for overlay load button 
	public void run(){
		selectInput("Select file to load","handler",new File(""),this);
	}

	public void handler(File f){//this gets called by selectInput when the input is selected
		img.load(f);
	}
}
public class BlankBrush extends Lambda{//blank button for testing, hyjack all you want
  public void run(){
    //img.alignLandmarks(5);//hyjacked for stack alignment
    LayerSeeded.seedFromPrev(img);//hyjack for seeding
  }

}