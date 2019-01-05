class SideBar extends PApplet{
  int reqWidth,reqHeight;
  public Ui ui;
  void settings(){
    size(200,1000);

  }

  void setup(){
    surface.setResizable(false);
    surface.setTitle("Settings");
    ui=buildUi(this);
    surface.setAlwaysOnTop(true);
  }
  int stablizeTimer=0;
  void draw(){
    reqWidth=ui.calcWidth();
    reqHeight=ui.calcHeight();
    if(width!=reqWidth||height!=reqHeight){

      reqWidth=max(200,reqWidth);
      reqHeight=max(0,reqHeight);
      stablizeTimer=0;
      surface.setSize(reqWidth,reqHeight); 
      background(150);//when the surface changes size it does this freeky weird thing where it stretches the current content to fill the new window, it looks terable so I just get rid of it all
    }

     
     //println("Changin size");
    
    if(stablizeTimer<0){//if you let this draw as much as you would think would be fine, it freeks out and draws some weird stuff the first frame after resizing
      background(150);
    //println(reqWidth);
      
      ui.draw();
      stablizeTimer=0;
    }
    stablizeTimer--;
  }

}
