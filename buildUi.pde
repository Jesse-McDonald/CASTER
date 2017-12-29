//only exists as a way of moving ui construction to its own file
//depends only on fully implimented Ui_ elements
Ui buildUi(){  
  ui=new Ui();//prep ui
  float numButtons=5;//a arbitrary number to help size the the buttons
  float spacing=1/((numButtons+.5)*2.5);//more sizing stuff
  numButtons*=2.5;//and more arbitrary constants
  ui.add(new Ui_ScalePanel(0,1/numButtons/1.1,1/numButtons/1.7,6/numButtons*1.02,color(240,240,240,200)));//add the panel to the ui
  Ui_PopupPanel option=new Ui_PopupPanel();
  {//this is a huge reason the { should always be on the same line as the thing it is extending, other wise there is the confusion of if this is a function called ui.add or something
    //or just the code block it is
    Ui_RadioButton buildRadio=new Ui_RadioButton(1);//prep radio button for brush buttons
    option.add(new Ui_ScalePanel(1/numButtons*.6,1/numButtons/1.1,1/numButtons/1.7,6/numButtons*1.02,color(240,240,240,200)));//add the panel to the popout  
    {//add buttons to radio button
      Ui_Button build=new Ui_Button(1/numButtons*.67,1/numButtons,spacing,"paintBrushRound.png");
      build.setPressedImg("paintBrushRoundActive.png");
      build.setHighlightedImg("highlight.png");
      build.onActivate=new CircleBrush();
      build.onDeactivate=new ClearBrush(1);
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
    {//add buttons to radio button
      Ui_Button build=new Ui_Button(1/numButtons*.67,5/numButtons,spacing,"rayCastBrush.png");
      build.setPressedImg("rayCastBrushActive.png");
      build.setHighlightedImg("highlight.png");
      build.onActivate=new RayCastBrush();
      build.onDeactivate=new ClearBrush(6);
      buildRadio.add(build);
    }//ray cast brush button
    
    option.add(buildRadio);//add the radio button (and all sub buttons) to the ui
  }
  {//add eraser button directly to option
    Ui_Button build=new Ui_Button(1/numButtons*.67,6/numButtons,spacing,"eraser.png");
    build.setPressedImg("eraserActive.png");
    build.setHighlightedImg("highlight.png");
    build.onActivate=new EraserBrush(true);
    build.onDeactivate=new EraserBrush(false);
    build.id="eraser";
    option.add(build);
    
  }//erraser button
  {
    Ui_RadioControler buildRadio=new Ui_RadioControler(1);//prep radio button for panels
    {//add Brush pannel trigger to radio button
      Ui_Button build=new Ui_Button(.005,1/numButtons,spacing,"paintBrush.png");
      build.setPressedImg("paintBrushActive.png");
      build.setHighlightedImg("highlight.png");
      option.changeTrigger(build);
      buildRadio.add(build);
    }
    ui.add(buildRadio);
  }//brush pannel button
  {//add a blank button for testing
    Ui_Button build=new Ui_Button(.005,6/numButtons,spacing,"blank.png");
    build.setPressedImg("blankActive.png");
    build.setHighlightedImg("highlight.png");
    build.onActivate=new BlankButton();

    ui.add(build);
    
  }// blank button
  option.id="Brushes";
  ui.add(option);
  
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
  return ui;
}
