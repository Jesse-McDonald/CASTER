
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;
int in(float inches){
 return round(programSettings.monitorPPI*inches) ;
}
Ui buildUi(){
 
  Ui ui=new Ui("CASTER "+VERSION);
 
   
  {
    JMenuBar bar=new JMenuBar();
    JMenu file=new JMenu("File");
    JMenu save=new JMenu("Save");
    JMenu saveAs=new JMenu("Save as");
    JMenuItem load = new JMenuItem("Load");
    JMenu export=new JMenu("Export");
    JMenuItem pref = new JMenuItem("Prefferences");
    JMenuItem saveAll= new JMenuItem("Save All");
    JMenuItem saveP = new JMenuItem("Save Project");
    JMenuItem saveO = new JMenuItem("Save Overlay");
    JMenuItem saveasP = new JMenuItem("Save Project As...");
    JMenuItem saveasO = new JMenuItem("Save Overlay As...");
    JMenuItem export3D = new JMenuItem("Export 3D");
    JMenuItem exportPNG = new JMenuItem("Export PNG");
    load.addActionListener(new LambdaWrap(new Load()));
    pref.addActionListener(new LambdaWrap(new OpenPref()));
    saveAll.addActionListener(new LambdaWrap(new Save()));
    saveP.addActionListener(new LambdaWrap(new NotSupported()));
    saveO.addActionListener(new LambdaWrap(new NotSupported()));
    saveasP.addActionListener(new LambdaWrap(new NotSupported()));
    saveasO.addActionListener(new LambdaWrap(new NotSupported()));
    export3D.addActionListener(new LambdaWrap(new Create3D()));
    exportPNG.addActionListener(new LambdaWrap(new NotSupported()));
    export.add(export3D);
    export.add(exportPNG);
    saveAs.add(saveasP);
    saveAs.add(saveasO);
    save.add(saveAll);
    save.add(saveP);
    save.add(saveO);
    file.add(save);
    file.add(saveAs);
    file.add(load);
    file.add(export);
    file.add(pref);
    bar.add(file);
    
      
    ui.root.setJMenuBar(bar);
    }
    RadioButton Color=new RadioButton();
    {
      JPanel main=new JPanel();
      main.setBounds(in(0),in(0),in(1.2),in(5.6));//with pack this is now irrelevent :)
      main.setLayout(null);
      main.setBackground(new Color(240,240,240));
      RadioButton brushes=new RadioButton();
      RadioButton sections=new DualEdgeRadio();
      {//global erraser
          Ui_Button button=quickButton(new JToggleButton(),"eraser",1.2,5.6);
          ui.recolor.add(button);
          button.toolTip("Eraser");
          button.addToUi(ui);
          button.setHandler(new LambdaWrap(new EraserBrush(true), new EraserBrush(false)));
        }
        {//global color picker
          Ui_Button button=quickButton(new JToggleButton(),"colorPicker",1.2,6.7);
          ui.recolor.add(button);
          button.toolTip("Color Picker");
          button.addToUi(ui);
          button.setHandler(brushes);
          button.setHandler(Color);
          button.setHandler(new LambdaWrap(new PickerBrush(), new ClearBrush()));
        }
       {
          JPanel panel = new JPanel(new GridLayout());
          panel.setBounds(0,in(7.8),in(2.2),in(.5));
          
          JSlider slider = new JSlider();
          slider.addChangeListener(new ChangeListener() {
            public void stateChanged(ChangeEvent e) {
              img.brush.setSize(((JSlider)e.getSource()).getValue()*2+1);
              println(((JSlider)e.getSource()).getValue());
            
            }
        });
           panel.add(slider);
           ui.f.add(panel);
           
        }
      {//manual brushes
        JPanel brushPanel=new JPanel();
        brushPanel.setBounds(in(1.1),in(0),in(1.2),in(5.6));
        brushPanel.setLayout(null);
        brushPanel.setBackground(new Color(240,240,240));
        
        
        {
          Ui_Button button=quickButton(new JToggleButton(),"paintBrushRound",.1,.1);//this makes a toggle able button with the name of paintbrush at .1 inch and .1 inch
          ui.recolor.add(button);//this adds the button to the recolor list
          button.addToUi(ui,brushPanel);//this puts it on the panel, it also adds it to a list in UI
          button.toolTip("Round Brush");//this adds a mouse over tip
          button.setHandler(brushes);//this connects the button to the brushes radio
          button.setHandler(new LambdaWrap(new CircleBrush(), new ClearBrush()));//this sets the normal click handlers
        }
        {
          Ui_Button button=quickButton(new JToggleButton(),"paintBrushSquare",.1,1.2);
          ui.recolor.add(button);
          button.addToUi(ui,brushPanel);
          button.toolTip("Square Brush");
          button.setHandler(brushes);
          button.setHandler(new LambdaWrap(new SquareBrush(), new ClearBrush()));
        }
        {
          Ui_Button button=quickButton(new JToggleButton(),"paintBrushDiamond",.1,2.3);
          ui.recolor.add(button);
          button.addToUi(ui,brushPanel);
          button.toolTip("Diamond Brush");
          button.setHandler(brushes);
          button.setHandler(new LambdaWrap(new DiamondBrush(), new ClearBrush()));
        }   
        {
          Ui_Button button=quickButton(new JToggleButton(),"paintCan",.1,3.4);
          ui.recolor.add(button);
          button.addToUi(ui,brushPanel);
          button.toolTip("Flood Fill (Overlay Bounded)");
          button.setHandler(brushes);
          button.setHandler(new LambdaWrap(new FloodBrush(), new ClearBrush()));
        }
        {
          Ui_Button button=quickButton(new JToggleButton(),"blackHoleBrush",.1,4.5);
          ui.recolor.add(button);
          button.addToUi(ui,brushPanel);
          button.toolTip("Flood Erase (Color Specific)");
          button.setHandler(brushes);
          button.setHandler(new LambdaWrap(new BlackHoleBrush(), new ClearBrush()));
        }
        
        brushPanel.setVisible(false);
        ui.f.add(brushPanel);
        {
          Ui_Button button=quickButton(new JToggleButton(),"paintBrush",.1,.1);
          
          button.addToUi(ui,main);
          button.toolTip("Manual Brushes");
          button.setHandler(sections);
          button.setHandler(new PopupPanel(brushPanel));
        }
        
      
        
        
        
      }
       {//semi auto brushes
        JPanel brushPanel=new JPanel();
        brushPanel.setBounds(in(1.1),in(0),in(1.2),in(5.6));
        brushPanel.setLayout(null);
        brushPanel.setBackground(new Color(240,240,240));
        
        
        {
          Ui_Button button=quickButton(new JToggleButton(),"rayCastBrush",.1,.1);//this makes a toggle able button with the name of paintbrush at .1 inch and .1 inch
          ui.recolor.add(button);//this adds the button to the recolor list
          button.addToUi(ui,brushPanel);//this puts it on the panel, it also adds it to a list in UI
          button.toolTip("Round Brush");//this adds a mouse over tip
          button.setHandler(brushes);//this connects the button to the brushes radio
          button.setHandler(new LambdaWrap(new RayCastBrush(), new ClearBrush()));//this sets the normal click handlers
        }
        {
          Ui_Button button=quickButton(new JToggleButton(),"edgeFollower",.1,1.2);
          ui.recolor.add(button);
          button.addToUi(ui,brushPanel);
          button.toolTip("Linear Regression Edge Follower");
          button.setHandler(brushes);
          button.setHandler(new LambdaWrap(new EdgeFollowingBrush(), new EdgeFollowingBrushDestroy()));
        }
       

        brushPanel.setVisible(false);
        ui.f.add(brushPanel);
        {
          Ui_Button button=quickButton(new JToggleButton(),"semiAuto",.1,1.2);
          
          button.addToUi(ui,main);
          button.toolTip("Semi Auto Brushes");
          button.setHandler(sections);
          button.setHandler(new PopupPanel(brushPanel));
        }
       }
      {///colors

      
      
        JPanel colorPanel=new JPanel();
        colorPanel.setBounds(in(2.3),in(0),in(1.2),in(6.7));
        colorPanel.setLayout(null);
        colorPanel.setBackground(new Color(240,240,240));
        
        
        
        {
          Ui_Button button= quickColor(color(255,100,200,75),.1,.1);
          button.setHandler(Color);
          button.addToUi(ui,colorPanel);
        }
        {
          Ui_Button button= quickColor(color(255,0,0,75),.1,1.2);
          button.setHandler(Color);
          button.addToUi(ui,colorPanel);
        }
        {
          Ui_Button button= quickColor(color(255,150,0,75),.1,2.3);
          button.setHandler(Color);
          button.addToUi(ui,colorPanel);
        }
        {
          Ui_Button button= quickColor(color(255,255,0,75),.1,3.4);
          button.setHandler(Color);
          button.addToUi(ui,colorPanel);
        }
        {
          Ui_Button button= quickColor(color(0,255,0,75),.1,4.5);
          button.setHandler(Color);
          button.addToUi(ui,colorPanel);
        }
        {
          Ui_Button button= quickColor(color(26,140,255,75),.1,5.6);
          button.setHandler(Color);
          button.addToUi(ui,colorPanel);
        }
        {
          Ui_Button button= quickColor(color(255,0,255,75),.1,6.7);
          button.setHandler(Color);
          button.addToUi(ui,colorPanel);
        }



        ui.f.add(colorPanel);
      }
    ui.f.add(main);
  }
   
  ui.setColor(new Color(255,0,0));
    ui.f.revalidate();//these 2 lines clear up random issues in buttons not showing
    ui.f.repaint();
 
  return ui;
}
Ui_Button quickColor(color c,float xin, float yin){
    Ui_Button button=new Ui_Button(new JToggleButton(),"RGB("+red(c)+","+green(c)+","+blue(c)+")");
    button.setImage("ui/color.png");
    button.setClickImage("ui/colorActive.png");
    button.setMouseOver("ui/highlight.png");
    button.setSize(in(1),in(1));
    button.setPos(in(xin),in(yin));
    
    button.setRadius(in(.5));
    button.toolTip("RGB("+red(c)+","+green(c)+","+blue(c)+")");
    button.setHandler(new LambdaWrap(new LColor(c), new LColor(0)));
    button.setFill(new Color(round(red(c)),round(green(c)),round(blue(c))));//clear out old button everything
    
    return button;
}
Ui_Button quickButton(AbstractButton src, String name, float xin, float yin){
  Ui_Button button=new Ui_Button(src,name);
    button.setFill(null);//clear out old button everything
    button.setImage("ui/"+name+".png");
    button.setClickImage("ui/"+name+"Active.png");
    button.setMouseOver("ui/highlight.png");
    button.setSize(in(1),in(1));
    button.setPos(in(xin),in(yin));
    button.setRadius(in(.5));
    return button;
}
