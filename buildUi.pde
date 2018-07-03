//only exists as a way of moving ui construction to its own file
//depends only on fully implimented Ui_ elements
Ui buildUi(PApplet dm){  
  Ui ui=new Ui(dm);//prep ui
  float numButtons=5;//a arbitrary number to help size the the buttons,it is really quite missnamed
  
  float spacing=1/((numButtons+.5)*2.5);//more sizing stuff
  numButtons*=2.5;//and more arbitrary constants
  Ui_PopupPanel brushPannel=new Ui_PopupPanel();
  ui.add(new Ui_ScalePanel(0,1/numButtons/1.1,1/numButtons/1.7,6/numButtons*1.02,color(240,240,240,200)));//add the panel to the ui
  {//this is a huge reason the { should always be on the same line as the thing it is extending, other wise there is the confusion of if this is a function called ui.add or something
    //or just the code block it is
    Ui_RadioButton buildRadio=new Ui_RadioButton(1);//prep radio button for brush buttons
    brushPannel.add(new Ui_ScalePanel(1/numButtons*.6,1/numButtons/1.1,1/numButtons/1.7,5/numButtons*1.02,color(240,240,240,200)));//add the panel to the popout  
    {//add buttons to radio button
      Ui_Button build=new Ui_Button(1/numButtons*.67,1/numButtons,spacing,"paintBrushRound.png");
      build.setPressedImg("paintBrushRoundActive.png");
      build.setHighlightedImg("highlight.png");
      build.onActivate=new CircleBrush();
      build.onDeactivate=new ClearBrush(1);//incase you are wonding why this is here, onDeactivate has to be some sort of lambda
      //but it does not need to do something.  All of these where already clearBrush, so I left it clear brush, but now clearBrush does
      //not DO anything, so this line is bascially a do nothing line
      buildRadio.add(build);
    }//round brush button
    {//add buttons to radio button
      Ui_Button build=new Ui_Button(1/numButtons*.67,2/numButtons,spacing,"paintBrushSquare.png");
      build.setPressedImg("paintBrushSquareActive.png");
      build.setHighlightedImg("highlight.png");
      build.onActivate=new SquareBrush();
      build.onDeactivate=new ClearBrush(2);
      buildRadio.add(build);
    }//square brush button
    {//add buttons to radio button
      Ui_Button build=new Ui_Button(1/numButtons*.67,3/numButtons,spacing,"paintBrushDiamond.png");
      build.setPressedImg("paintBrushDiamondActive.png");
      build.setHighlightedImg("highlight.png");
      build.onActivate=new DiamondBrush();
      build.onDeactivate=new ClearBrush(3);
      buildRadio.add(build);
    }//diamond brush button
    {//add buttons to radio button
      Ui_Button build=new Ui_Button(1/numButtons*.67,4/numButtons,spacing,"paintCan.png");
      build.setPressedImg("paintCanActive.png");
      build.setHighlightedImg("highlight.png");
      build.onActivate=new FloodBrush();
      build.onDeactivate=new ClearBrush(4);
      buildRadio.add(build);
    }//paint brush button

    brushPannel.add(buildRadio);//add the radio button (and all sub buttons) to the ui
  }
  {//add eraser button directly to brushPannel
    Ui_Button build=new Ui_Button(1/numButtons*.67,5/numButtons,spacing,"eraser.png");
    build.setPressedImg("eraserActive.png");
    build.setHighlightedImg("highlight.png");
    build.onActivate=new EraserBrush(true);
    build.onDeactivate=new EraserBrush(false);
    build.id="eraser";
    brushPannel.add(build);
    
  }//erraser button
  
  
   Ui_PopupPanel semiAuto=new Ui_PopupPanel();
    {//this is a huge reason the { should always be on the same line as the thing it is extending, other wise there is the confusion of if this is a function called ui.add or something
    //or just the code block it is
    Ui_RadioButton buildRadio=new Ui_RadioButton(1);//prep radio button for brush buttons
   semiAuto.add(new Ui_ScalePanel(1/numButtons*.6,1/numButtons/1.1,1/numButtons/1.7,2/numButtons*1.02,color(240,240,240,200)));//add the panel to the popout  
    {//add buttons to radio button
      Ui_Button build=new Ui_Button(1/numButtons*.67,1/numButtons,spacing,"rayCastBrush.png");
      build.setPressedImg("rayCastBrushActive.png");
      build.setHighlightedImg("highlight.png");
      build.onActivate=new RayCastBrush();
      build.onDeactivate=new ClearBrush(6);
      buildRadio.add(build);
    }//ray cast brush button
    {//add buttons to radio button
      Ui_Button build=new Ui_Button(1/numButtons*.67,2/numButtons,spacing,"edgeFollower.png");
      build.setPressedImg("edgeFollowerActive.png");
      build.setHighlightedImg("highlight.png");
      build.onActivate=new EdgeFollowingBrush();
      build.onDeactivate=new EdgeFollowingBrushDestroy();
      
      buildRadio.add(build);
    }//Edge follow brush
    
    semiAuto.add(buildRadio);//add the radio button (and all sub buttons) to the ui
  }//automation
  {
    Ui_RadioControler buildRadio=new Ui_RadioControler(1);//prep radio button for panels
    {//add Brush pannel trigger to radio button
      Ui_Button build=new Ui_Button(.005,1/numButtons,spacing,"paintBrush.png");
      build.setPressedImg("paintBrushActive.png");
      build.setHighlightedImg("highlight.png");
      brushPannel.changeTrigger(build);

      buildRadio.add(build);
    }
    {//add semi automation pannel trigger
      Ui_Button build=new Ui_Button(0.005,2/numButtons,spacing,"semiAuto.png");
      build.setPressedImg("SemiAutoActive.png");
      build.setHighlightedImg("highlight.png");
      semiAuto.changeTrigger(build);

      buildRadio.add(build);
    }
    ui.add(buildRadio);
  }//popup window controler
  {//add 3d button
    Ui_Button build=new Ui_MomentaryButton(.005,3/numButtons,spacing,"3d.png");
    build.setPressedImg("3dActive.png");
    build.setHighlightedImg("highlight.png");
    build.onActivate=new Create3D();

    ui.add(build);
    
  }// 3d button
  {//add a blank button for testing
    Ui_Button build=new Ui_Button(.005,6/numButtons,spacing,"blank.png");
    build.setPressedImg("blankActive.png");
    build.setHighlightedImg("highlight.png");
    build.onActivate=new BlankButton();

    ui.add(build);
    
  }// blank button
  brushPannel.id="Brushes";
  ui.add(brushPannel);
  ui.add(semiAuto);
  {//add save button 
    Ui_Button build=new Ui_MomentaryButton(.005,0,spacing,"save.png");
    build.setPressedImg("saveActive.png");
    build.setHighlightedImg("highlight.png");
    build.onActivate=new Save();

    ui.add(build);
  }//save button
  {//add load button
  Ui_Button build=new Ui_MomentaryButton(1/numButtons*.6,0,spacing,"load.png");
  build.setPressedImg("loadActive.png");
  build.setHighlightedImg("highlight.png");
  build.onActivate=new Load();

  ui.add(build);
  }//load button
  ui.setDM(dm);
  return ui;
}