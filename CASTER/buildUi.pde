//only exists as a way of moving ui construction to its own file
//depends only on fully implimented Ui_ elements
Ui buildUi(PApplet dm){  
  Ui ui=new Ui(dm);//prep ui
  float numButtons=5;//a arbitrary number to help size the the buttons,it is really quite missnamed
  PImage mask=loadImage("ui/buttonColorMap.png");
  float spacing=1/((numButtons+.5)*2.5);//more sizing stuff
  numButtons*=2.5;//and more arbitrary constants
  Ui_PopupPanel brushPannel=new Ui_PopupPanel();
  ui.add(new Ui_Panel(0,1,1.2,6.7,color(240,240,240,200)));//add the panel to the ui
  {//this is a huge reason the { should always be on the same line as the thing it is extending, other wise there is the confusion of if this is a function called ui.add or something
    //or just the code block it is
    Ui_RadioButton buildRadio=new Ui_RadioButton(1);//prep radio button for brush buttons
    brushPannel.add(new Ui_Panel(1.2,1,1.1,6.7,color(240,240,240,200)));//add the panel to the popout  
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2,1.1,1,"ui/paintBrushRound.png");
      
      build.setPressedImg("ui/paintBrushRoundActive.png");
      build.setHighlightedImg("ui/highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new CircleBrush();
      build.onDeactivate=new ClearBrush(1);//incase you are wonding why this is here, onDeactivate has to be some sort of lambda
      //but it does not need to do something.  All of these where already clearBrush, so I left it clear brush, but now clearBrush does
      //not DO anything, so this line is bascially a do nothing line
      buildRadio.add(build);
    }//round brush button
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2,2.2,1,"ui/paintBrushSquare.png");
      build.setPressedImg("ui/paintBrushSquareActive.png");
      build.setHighlightedImg("ui/highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new SquareBrush();
      build.onDeactivate=new ClearBrush(2);
      buildRadio.add(build);
    }//square brush button
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2,3.3,1,"ui/paintBrushDiamond.png");
      build.setPressedImg("ui/paintBrushDiamondActive.png");
      build.setHighlightedImg("ui/highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new DiamondBrush();
      build.onDeactivate=new ClearBrush(3);
      buildRadio.add(build);
    }//diamond brush button
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2,4.4,1,"ui/blackHoleBrush.png");
      build.setPressedImg("ui/blackHoleBrushActive.png");
      build.setHighlightedImg("ui/highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new BlackHoleBrush();
      build.onDeactivate=new ClearBrush(4);
      buildRadio.add(build);
    }//paint brush button
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2,5.5,1,"ui/paintCan.png");
      build.setPressedImg("ui/paintCanActive.png");
      build.setHighlightedImg("ui/highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new FloodBrush();
      build.onDeactivate=new ClearBrush(4);
      buildRadio.add(build);
    }//paint brush button
    brushPannel.add(buildRadio);//add the radio button (and all sub buttons) to the ui
  }
  {//add eraser button directly to brushPannel
    Ui_PaintButton build=new Ui_PaintButton(1.2,6.6,1,"ui/eraser.png");
    build.setPressedImg("ui/eraserActive.png");
    build.setHighlightedImg("ui/highlight.png");
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
      Ui_PaintButton build=new Ui_PaintButton(1.2,1.1,1,"ui/rayCastBrush.png");
      build.setPressedImg("ui/rayCastBrushActive.png");
      build.setHighlightedImg("ui/highlight.png");
      build.c=0;
      build.mask=mask;
      build.onActivate=new RayCastBrush();
      build.onDeactivate=new ClearBrush(6);
      buildRadio.add(build);
    }//ray cast brush button
    {//add buttons to radio button
      Ui_PaintButton build=new Ui_PaintButton(1.2,2.2,1,"ui/edgeFollower.png");
      build.setPressedImg("ui/edgeFollowerActive.png");
      build.setHighlightedImg("ui/highlight.png");
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
      Ui_Button build=new Ui_Button(.1,1.1,1,"ui/paintBrush.png");
      build.setPressedImg("ui/paintBrushActive.png");
      build.setHighlightedImg("ui/highlight.png");
      brushPannel.changeTrigger(build);

      buildRadio.add(build);
    }
    {//add semi automation pannel trigger
      Ui_Button build=new Ui_Button(0.1,2.2,1,"ui/semiAuto.png");
      build.setPressedImg("ui/SemiAutoActive.png");
      build.setHighlightedImg("ui/highlight.png");
      semiAuto.changeTrigger(build);

      buildRadio.add(build);
    }
    ui.add(buildRadio);
  }//popup window controler
  {//add 3d button
    Ui_Button build=new Ui_MomentaryButton(0.1,3.3,1,"ui/3d.png");
    build.setPressedImg("ui/3dActive.png");
    build.setHighlightedImg("ui/highlight.png");
    build.onActivate=new Create3D();

    ui.add(build);
    
  }// 3d button
  {//add a blank button for testing
    //Ui_Button build=new Ui_Button(.005,6/numButtons,spacing,"ui/blank.png");
   Ui_Button build=new Ui_Button(0.1,6.6,1,"ui/blank.png");
   
    build.setPressedImg("ui/blankActive.png");
    build.setHighlightedImg("ui/highlight.png");
    build.onActivate=new BlankButton();

    ui.add(build);
    
  }// blank button
  brushPannel.id="Brushes";
  ui.add(brushPannel);
  ui.add(semiAuto);
  {//add save button 
    Ui_Button build=new Ui_MomentaryButton(.1,0,1,"ui/save.png");
    build.setPressedImg("ui/saveActive.png");
    build.setHighlightedImg("ui/highlight.png");
    build.onActivate=new Save();

    ui.add(build);
  }//save button
  {//add load button
  Ui_Button build=new Ui_MomentaryButton(1.2,0,1,"ui/load.png");
  build.setPressedImg("ui/loadActive.png");
  build.setHighlightedImg("ui/highlight.png");
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
      Ui_PaintButton build=new Ui_PaintButton(2.3,7.7,1,"ui/colorPicker.png");
      build.setPressedImg("ui/colorPickerActive.png");
      build.setHighlightedImg("ui/highlight.png");
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
