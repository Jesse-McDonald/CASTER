/**
implements a rough lambda concept since processing does not have it by default
the Lambda class is technically abstract, but has been declared otherwise so as a empty Lambda can be created by default
this has been implemented to allow clickable buttons
collectively all implemented lambda functions depend on access to global EMImage img, Brush img.brush, int img.brush, void img.brush.update(), void img.brush.clearBrush(), void img.save(), void img.load()
these also depend on void selectInput(String path, String function, Object this) and void selectOutput(String path, String function,Object this) from processing
*/

import static javax.swing.JOptionPane.*;
class Lambda{
  Lambda(){}//all lambda objects will have a default constructor and run()
  public void run(){}
}
class VariableLambda extends Lambda{
  VariableLambda(){}//all lambda objects will have a default constructor and run()
  public void run(int variable){}
  
}
class OpenPref extends VariableLambda{
public void run(){
      println("Open pref file");
      try{
      File file=new File(dataPath("settings.json"));
      try{
      if (Desktop.isDesktopSupported()) {
        Desktop.getDesktop().edit(file);
      } else {
          // dunno, up to you to handle this
      }
      }catch(Exception e){//edit faileld
        try{
          if (Desktop.isDesktopSupported()) {
            Desktop.getDesktop().open(file);
          } else {
              // dunno, up to you to handle this
              
          }
          }catch(Exception ee){//open faileld
            JOptionPane.showMessageDialog(null, "Please open \""+file.getAbsolutePath()+"\" to change settings.");
        }
      }
}catch(Exception e){}//file dne
    }
}
public class NotSupported extends Lambda{
public void run(){
      println("This button not yet supported");
      showMessageDialog (null, "This button not yet supported");
    }
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
                img.brush.erase=((Ui_Button)sidebar.getId("eraser")).b.isSelected();//change eraser state to the right one based on the button
     
  }
}

class SquareBrush extends Lambda{//allows for square brush button
  void run(){
  
            
    img.brush= new BrushSquare(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)sidebar.getId("eraser")).selected();//change eraser state to the right one based on the button
     
  }
}
class PickerBrush extends Lambda{//allows for color picker brush button
  void run(){
  
            
    img.brush= new BrushPicker(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)sidebar.getId("eraser")).selected();//change eraser state to the right one based on the button
     
  }
}
class RayCastBrush extends Lambda{//allows for raycast brush button
  void run(){
 
       img.brush= new RayCast(img.brush.c,img.brush.img,img.brush.size);
      img.brush.erase=((Ui_Button)sidebar.getId("eraser")).selected();//change eraser state to the right one based on the button

  }
}
class DiamondBrush extends Lambda{//allows for diamond brush button
  void run(){
    
    img.brush= new BrushDiamond(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)sidebar.getId("eraser")).selected();//change eraser state to the right one based on the button
      
  }
}

class FloodBrush extends Lambda{//allows for flood fill button
  void run(){
         
    img.brush= new BrushFill(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)sidebar.getId("eraser")).selected();//change eraser state to the right one based on the button
    
  }
}
class BlackHoleBrush extends Lambda{//allows for flood fill button
  void run(){
         
    img.brush= new BrushBlackHole(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)sidebar.getId("eraser")).selected();//change eraser state to the right one based on the button
    
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
   sidebar.setColor(new Color(round(red(col)),round(green(col)),round(blue(col))));

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
public class SaveAsOverlay extends Lambda{
  public void run(){
            selectOutput("Select file to save overlay","handler",null,this);
  }
  public void handler(File f){//this gets called by selectOutput when the output is selected
    if(f!=null){
       
      img.saveOverlay(f); 
      
    }
    
  }
}
public class SaveProject extends Lambda{
    public void run(){
      if(img.project.path.equals("")){
             (new SaveAsProject()).run();
          }else{
     img.saveProject(img.project.path);
          }
  }
}
public class SaveAsProject extends Lambda{
  public void run(){
    selectOutput("Select file to save Project","handler2",null,this);
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
public class SaveOverlay extends Lambda{
  public void run(){
    if(img.overlay.path.equals("")){
            (new SaveAsOverlay()).run();
          }else{
            
    img.saveOverlay(img.overlay.path); 
          }
  }
}
public class Save extends Lambda{//allows for overlay save button
        public void run(){
          
          (new SaveProject()).run();
          (new SaveOverlay()).run();
          
        
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
    img.brush.erase=((Ui_Button)sidebar.getId("eraser")).selected();//change eraser state to the right one based on the button
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
    if(YES_OPTION==showConfirmDialog (null, "WARNING! 3D view is a slow process, Are you sure you want to continue? (Saving first is recomended)","Warning",YES_NO_OPTION)){
      view3D.cloud=img.overlay;
      if(!window){
        PApplet.runSketch(args,view3D);
        window=true;
      }else{
        view3D.prep();
      }
    }
  }
  
}
public class ExportPNG extends Lambda{
  ArrayList<Integer> layers;
  void run(){
   String s=null;
    boolean goodInput=false;
    String invalid="";
    while(!goodInput){
      layers=new ArrayList<Integer>();
    s = (String)JOptionPane.showInputDialog(
                    frame,
                    invalid+"Layers to Export (ie '1,2,5-8')\n",
                    "Customized Dialog",
                    JOptionPane.PLAIN_MESSAGE,
                    null,
                    null,
                    img.layer);
    goodInput=true;
    if(s!=null){
      String[] sec;
      if(s.contains(",")){
        sec=s.split(",");
      }else{
        sec=new String[]{""};
        sec[0]=s;
      }
      try{
      for(int i=0;i<sec.length ;i++){
        if(sec[i].contains("-")){
          String[] range=sec[i].split("-");
          if (range.length>2){
            goodInput=false;
          }
          int start=Integer.parseInt(range[0]);
          int end=Integer.parseInt(range[1]);
          for(;start<=end;start++){
            layers.add(start); 
          }
        }else{
           layers.add(Integer.parseInt(sec[i]));
        }
      }
      }catch(Exception e){
        goodInput=false;
     }
      if(goodInput==false){
      invalid="Invalid input given\n"; 
    }
    
    
         if(s.equals("")){
           layers.add(img.layer); 
           goodInput=true;
         }
         
    }

  }
  if(s!=null&&layers.size()>0){
  boolean abort=false;
  if(layers.size()>1||layers.get(0)!=img.layer){
    abort=YES_OPTION!=showConfirmDialog (null, "WARNING! Exporting layers other than the active layer may take some time/nand could crash the program in certain circumstances, continue? (Saving first is recomended)","Warning",YES_NO_OPTION);
   
  }
  if(!abort){
  selectOutput("Select file to export first selection to","exportHandler",null,this);
  }
  }
  }
  public void exportHandler(File f){
    if(f!=null){
       String path=f.getAbsolutePath();
      String file="";
      String ext=""; 
      int dot=path.lastIndexOf('.');
      if(dot>=0){
        ext=path.substring(dot,path.length()).toLowerCase();
        file=path.substring(0,dot);
      }
      if(!ext.equals(".png")){
        file+=ext;
        ext=".png";
        
      }
      if(layers.size()>1){
        for(int i=0;i<layers.size();i++){
          img.exportPNG(path+layers.get(i)+ext,layers.get(i)); 
        }
      }else{
        img.exportPNG(path+ext,layers.get(0)); 
      }
    }
  }
  
}
