/**
implements a rough lambda concept since processing does not have it by default
the Lambda class is technically abstract, but has been declared otherwise so as a empty Lambda can be created by default
this has been implemented to allow clickable buttons
collectively all implemented lambda functions depend on access to global EMImage img, Brush img.brush, int img.brush, void img.brush.update(), void img.brush.clearBrush(), void img.save(), void img.load()
these also depend on void selectInput(String path, String function, Object this) and void selectOutput(String path, String function,Object this) from processing
*/


class Lambda{
  Lambda(){}//all lambda objects will have a default constructor and run()
  public void run(){}
}
class VariableLambda extends Lambda{
  VariableLambda(){}//all lambda objects will have a default constructor and run()
  public void run(int variable){}
  
}
class SizeSlider extends VariableLambda{
  public void run(int x){
    img.brush.setSize(x*2+1);
  }
}
class EdgeFinderThreshold extends VariableLambda{
  
}
class CircleBrush extends Lambda{//allows for circle brush button
  void run(){
   
    img.brush= new BrushCircle(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)sidebar.ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button
     
  }
}

class SquareBrush extends Lambda{//allows for square brush button
  void run(){
  
            
    img.brush= new BrushSquare(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)sidebar.ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button
     
  }
}
class PickerBrush extends Lambda{//allows for color picker brush button
  void run(){
  
            
    img.brush= new BrushPicker(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)sidebar.ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button
     
  }
}
class RayCastBrush extends Lambda{//allows for raycast brush button
  void run(){
 
       img.brush= new RayCast(img.brush.c,img.brush.img,img.brush.size);
      img.brush.erase=((Ui_Button)sidebar.ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button

  }
}
class DiamondBrush extends Lambda{//allows for diamond brush button
  void run(){
    
    img.brush= new BrushDiamond(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)sidebar.ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button
      
  }
}

class FloodBrush extends Lambda{//allows for flood fill button
  void run(){
         
    img.brush= new BrushFill(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)sidebar.ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button
    
  }
}
class BlackHoleBrush extends Lambda{//allows for flood fill button
  void run(){
         
    img.brush= new BrushBlackHole(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)sidebar.ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button
    
  }
}
/* posibly out dated with new polymorphic Brushes
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
}*/
class LColor extends Lambda{
 color col;
 LColor(){this(0);}
 LColor(color c){
   col=c;
 }
 void run(){
   img.brush.c=col;
   img.brush.update();
 }
}
class ClearBrush extends Lambda{//allows for clear brush button that is tuned to specific brush via constructor
  ClearBrush(){}
  ClearBrush(int in){}//we no longer care which brush it is, that ship has been fixed and retired to a museum
  void run(){img.brush= new Brush(img.brush.c,img.brush.img,img.brush.size);}
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
          if(img.project.path.equals("")){
             selectOutput("Select file to save Project","handler2",null,this);
          }
          selectOutput("Select file to save overlay","handler",null,this);
        
        }
  
  public void handler(File f){//this gets called by selectOutput when the output is selected
    if(f!=null){
       
      img.saveOverlay(f); 
      
    }
    
  }
  public void handler2(File f){//this gets called by selectOutput when the output is selected
    if(f!=null){
      String path=f.getAbsolutePath();
      
      String ext=""; 
      int dot=path.lastIndexOf('.');
      if(dot>=0){
        ext=path.substring(dot,path.length()).toLowerCase();
      }
      if(!ext.equals(".caster")){
        path+=".caster";
      }
      img.project.path=path;
      programSettings.lastProject=img.project.path;
      autoSave();
    }
    
  }
}

public class Load extends Lambda{//allow for overlay load button 
  public void run(){
	  selectInput("Select a file to Load","load");
    //selectInput("Select file to load","handler",new File(""),this);
  }

  //public void handler(File f){//this gets called by selectInput when the input is selected
  //  img.loadOverlay(f);
  //}
}
public class EdgeFollowingBrush extends Lambda{//Edgefollowing trigger
  BrushEdgeFollowing brush;
  boolean first=true;
  public void run(){
    if(first){
      brush=new BrushEdgeFollowing(img.brush.c,img.brush.img,img.brush.size);
    }
    first=false;
    brush.c=img.brush.c;
    brush.size=img.brush.size;
    img.brush= brush;
    img.brush.erase=((Ui_Button)sidebar.ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button
    
    
    
  }
 
}
public class EdgeFollowingBrushDestroy extends Lambda{//I am guessing anti edgefollowing trigger, but I dont know
  public void run(){
    img.brush= new Brush(img.brush.c,img.brush.img,img.brush.size);
    
    
  }
 
}
public class BlankButton extends Lambda{//blank button for testing, hyjack all you want
  public void run(){
    //img.alignLandmarks(5);//hyjacked for stack alignment
    //LayerSeeded.seedFromPrev(img);//hyjack for seeding
    //img.saveProject(new File("D:\\project.json"));//hyjack for saving project
    //img.brush=new BrushBlackHole(img.brush.c,img.brush.img,img.brush.size);
    img.brush=new BrushRuler(img.brush.c,img.brush.img,img.brush.size);

  }

}
public class Create3D extends Lambda{
  boolean window=false;
  
  String[] args={""};
  Create3D(){
   view3D=new Visulization3D();
  }
  void run(){
    view3D.cloud=img.overlay;
    if(!window){
      PApplet.runSketch(args,view3D);
      window=true;
    }else{
      view3D.prep();
    }
  }
  
}
