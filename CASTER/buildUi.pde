//only exists as a way of moving ui construction to its own file
//depends only on fully implimented Ui_ elements
Ui buildUi(PApplet dm){  
  Ui ui=new Ui(dm);//prep ui
  float numButtons=5;//a arbitrary number to help size the the buttons,it is really quite missnamed
  PImage mask=loadImage("buttonColorMap.png");
  float spacing=1/((numButtons+.5)*2.5);//more sizing stuff
  numButtons*=2.5;//and more arbitrary constants
  Ui_PopupPanel brushPannel=new Ui_PopupPanel();
  ui.add(new Ui_Panel(0,1,1.2,6.7,color(240,240,240,200)));//add the panel to the ui
  {//this is a huge reason the { should always be on the same line as the thing it is extending, other wise there is the confusion of if this is a function called ui.add or something
    //or just the code block it is
    Ui_RadioButton buildRadio=new Ui_RadioButton(1);//prep radio button for brush buttons
    brushPannel.add(new Ui_Panel(1.2,1,1.1,6.7,color(240,240,240,200)));//add the panel to the popout  
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2,1.1,1,"paintBrushRound.png");
      
      build.setPressedImg("paintBrushRoundActive.png");
      build.setHighlightedImg("highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new CircleBrush();
      build.onDeactivate=new ClearBrush(1);//incase you are wonding why this is here, onDeactivate has to be some sort of lambda
      //but it does not need to do something.  All of these where already clearBrush, so I left it clear brush, but now clearBrush does
      //not DO anything, so this line is bascially a do nothing line
      buildRadio.add(build);
    }//round brush button
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2,2.2,1,"paintBrushSquare.png");
      build.setPressedImg("paintBrushSquareActive.png");
      build.setHighlightedImg("highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new SquareBrush();
      build.onDeactivate=new ClearBrush(2);
      buildRadio.add(build);
    }//square brush button
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2,3.3,1,"paintBrushDiamond.png");
      build.setPressedImg("paintBrushDiamondActive.png");
      build.setHighlightedImg("highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new DiamondBrush();
      build.onDeactivate=new ClearBrush(3);
      buildRadio.add(build);
    }//diamond brush button
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2,4.4,1,"blackHoleBrush.png");
      build.setPressedImg("blackHoleBrushActive.png");
      build.setHighlightedImg("highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new BlackHoleBrush();
      build.onDeactivate=new ClearBrush(4);
      buildRadio.add(build);
    }//paint brush button
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2,5.5,1,"paintCan.png");
      build.setPressedImg("paintCanActive.png");
      build.setHighlightedImg("highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new FloodBrush();
      build.onDeactivate=new ClearBrush(4);
      buildRadio.add(build);
    }//paint brush button
    brushPannel.add(buildRadio);//add the radio button (and all sub buttons) to the ui
  }
  {//add eraser button directly to brushPannel
    Ui_PaintButton build=new Ui_PaintButton(1.2,6.6,1,"eraser.png");
    build.setPressedImg("eraserActive.png");
    build.setHighlightedImg("highlight.png");
	  build.c=0;
    build.mask=mask;
    build.onActivate=new EraserBrush(true);
    build.onDeactivate=new EraserBrush(false);
    build.id="eraser";
    brushPannel.add(build);
    
  }//erraser button
  
  
   Ui_PopupPanel semiAuto=new Ui_PopupPanel();
    {//this is a huge reason the { should always be on the same line as the thing it is extending, other wise there is the confusion of if this is a function called ui.add or something
    //or just the code block it is
    Ui_RadioButton buildRadio=new Ui_RadioButton(1);//prep radio button for brush buttons
   semiAuto.add(new Ui_Panel(1.2,1,1.1,2.3,color(240,240,240,200)));//add the panel to the popout  
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2,1.1,1,"rayCastBrush.png");
      build.setPressedImg("rayCastBrushActive.png");
      build.setHighlightedImg("highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new RayCastBrush();
      build.onDeactivate=new ClearBrush(6);
      buildRadio.add(build);
    }//ray cast brush button
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2,2.2,1,"edgeFollower.png");
      build.setPressedImg("edgeFollowerActive.png");
      build.setHighlightedImg("highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new EdgeFollowingBrush();
      build.onDeactivate=new EdgeFollowingBrushDestroy();
      
      buildRadio.add(build);
    }//Edge follow brush
    
    semiAuto.add(buildRadio);//add the radio button (and all sub buttons) to the ui
  }//automation
  {
    Ui_RadioControler buildRadio=new Ui_RadioControler(1);//prep radio button for panels
    {//add Brush pannel trigger to radio button
      Ui_Button build=new Ui_Button(.1,1.1,1,"paintBrush.png");
      build.setPressedImg("paintBrushActive.png");
      build.setHighlightedImg("highlight.png");
      brushPannel.changeTrigger(build);

      buildRadio.add(build);
    }
    {//add semi automation pannel trigger
      Ui_Button build=new Ui_Button(0.1,2.2,1,"semiAuto.png");
      build.setPressedImg("SemiAutoActive.png");
      build.setHighlightedImg("highlight.png");
      semiAuto.changeTrigger(build);

      buildRadio.add(build);
    }
    ui.add(buildRadio);
  }//popup window controler
  {//add 3d button
    Ui_Button build=new Ui_MomentaryButton(0.1,3.3,1,"3d.png");
    build.setPressedImg("3dActive.png");
    build.setHighlightedImg("highlight.png");
    build.onActivate=new Create3D();

    ui.add(build);
    
  }// 3d button
  {//add a blank button for testing
    //Ui_Button build=new Ui_Button(.005,6/numButtons,spacing,"blank.png");
   Ui_Button build=new Ui_Button(0.1,6.6,1,"blank.png");
   
    build.setPressedImg("blankActive.png");
    build.setHighlightedImg("highlight.png");
    build.onActivate=new BlankButton();

    ui.add(build);
    
  }// blank button
  brushPannel.id="Brushes";
  ui.add(brushPannel);
  ui.add(semiAuto);
  {//add save button 
    Ui_Button build=new Ui_MomentaryButton(.1,0,1,"save.png");
    build.setPressedImg("saveActive.png");
    build.setHighlightedImg("highlight.png");
    build.onActivate=new Save();

    ui.add(build);
  }//save button
  {//add load button
  Ui_Button build=new Ui_MomentaryButton(1.2,0,1,"load.png");
  build.setPressedImg("loadActive.png");
  build.setHighlightedImg("highlight.png");
  build.onActivate=new Load();

  ui.add(build);
  }//load button
  {
    PImage highlight=new PImage(1,1,ARGB);
    highlight.set(0,0,color(0,0,255,50));
   Ui_RadioButton buildRadio=new Ui_RadioButton(1);//prep radio button for color buttons
   {//add buttons to radio button
      PImage tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(255,100,200));
      Ui_Button build=new Ui_Button(2.3,0,1,tImg);
      tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(200,50,150));
      build.pressed=(tImg);
      build.highlighted=(highlight);
      build.onActivate=new LColor(color(255,100,200,75));;
      build.onDeactivate=new LColor(0);//incase you are wonding why this is here, onDeactivate has to be some sort of lambda
      //but it does not need to do something.  All of these where already clearBrush, so I left it clear brush, but now clearBrush does
      //not DO anything, so this line is bascially a do nothing line
      buildRadio.add(build);
    }
     {//add buttons to radio button
      PImage tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(255,0,0));
      Ui_Button build=new Ui_Button(2.3,1.1,1,tImg);
      tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(200,0,0));
      build.pressed=(tImg);
      build.highlighted=(highlight);
      build.onActivate=new LColor(color(255,0,0,75));;
      build.onDeactivate=new LColor(0);//incase you are wonding why this is here, onDeactivate has to be some sort of lambda
      //but it does not need to do something.  All of these where already clearBrush, so I left it clear brush, but now clearBrush does
      //not DO anything, so this line is bascially a do nothing line
      buildRadio.add(build);
    }
     {//add buttons to radio button
      PImage tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(255,150,0));
      Ui_Button build=new Ui_Button(2.3,2.2,1,tImg);
      tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(200,100,0));
      build.pressed=(tImg);
      build.highlighted=(highlight);
      build.onActivate=new LColor(color(255,150,0,75));;
      build.onDeactivate=new LColor(0);//incase you are wonding why this is here, onDeactivate has to be some sort of lambda
      //but it does not need to do something.  All of these where already clearBrush, so I left it clear brush, but now clearBrush does
      //not DO anything, so this line is bascially a do nothing line
      buildRadio.add(build);
    }
     {//add buttons to radio button
      PImage tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(255,255,0));
      Ui_Button build=new Ui_Button(2.3,3.3,1,tImg);
      tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(200,200,0));
      build.pressed=(tImg);
      build.highlighted=(highlight);
      build.onActivate=new LColor(color(255,255,0,75));;
      build.onDeactivate=new LColor(0);//incase you are wonding why this is here, onDeactivate has to be some sort of lambda
      //but it does not need to do something.  All of these where already clearBrush, so I left it clear brush, but now clearBrush does
      //not DO anything, so this line is bascially a do nothing line
      buildRadio.add(build);
    }
     {//add buttons to radio button
      PImage tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(0,255,0));
      Ui_Button build=new Ui_Button(2.3,4.4,1,tImg);
      tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(0,200,0));
      build.pressed=(tImg);
      build.highlighted=(highlight);
      build.onActivate=new LColor(color(0,255,0,75));;
      build.onDeactivate=new LColor(0);//incase you are wonding why this is here, onDeactivate has to be some sort of lambda
      //but it does not need to do something.  All of these where already clearBrush, so I left it clear brush, but now clearBrush does
      //not DO anything, so this line is bascially a do nothing line
      buildRadio.add(build);
    }
     {//add buttons to radio button
      PImage tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(0,0,255));
      Ui_Button build=new Ui_Button(2.3,5.5,1,tImg);
      tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(0,0,200));
      build.pressed=(tImg);
      build.highlighted=(highlight);
      build.onActivate=new LColor(tColor(26, 140, 255, 75));
      build.onDeactivate=new LColor(0);//incase you are wonding why this is here, onDeactivate has to be some sort of lambda
      //but it does not need to do something.  All of these where already clearBrush, so I left it clear brush, but now clearBrush does
      //not DO anything, so this line is bascially a do nothing line
      buildRadio.add(build);
    }
     {//add buttons to radio button
      PImage tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(255,0,255));
      Ui_Button build=new Ui_Button(2.3,6.6,1,tImg);
      tImg=new PImage(1,1,ARGB);
      tImg.set(0,0,color(200,0,200));
      build.pressed=(tImg);
      build.highlighted=(highlight);
      build.onActivate=new LColor(tColor(255,0,255,75));;
      build.onDeactivate=new LColor(0);//incase you are wonding why this is here, onDeactivate has to be some sort of lambda
      //but it does not need to do something.  All of these where already clearBrush, so I left it clear brush, but now clearBrush does
      //not DO anything, so this line is bascially a do nothing line
      buildRadio.add(build);
    }
    
    ui.add(buildRadio);
  }
  {
    {//add semi automation pannel trigger
      Ui_PaintButton build=new Ui_PaintButton(2.3,7.7,1,"colorPicker.png");
      build.setPressedImg("colorPickerActive.png");
      build.setHighlightedImg("highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new PickerBrush();
      build.onDeactivate=new ClearBrush(6);
      ui.add(build);
    }
  }
  {//testing slider,
    PImage tImg=new PImage(100,40,ARGB);
    tImg.loadPixels();
    for(int i=0;i<tImg.pixels.length;i++){
      tImg.pixels[i]=tColor(150,150,100); 
    }
    tImg.updatePixels();
    Ui_Slider build=new Ui_Slider(.3,7.7,2, tImg);
    build.onChange=new SizeSlider();
    build.minV=0;
    build.maxV=100;
    build.boundValue=sizeSlider;
    ui.add(build);//we are only testing the slider, we dont want it actually on the ui yet
  }
  
  ui.setDM(dm);
  return ui;
}
