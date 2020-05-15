//logging not added to this file
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;
import javax.swing.border.*;
int in(float inches){
 return round(programSettings.monitorPPI*inches) ;
}
Ui buildUi(){
 
  Ui ui=new Ui("CASTER "+VERSION);
  ui.root.setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
   
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
    saveP.addActionListener(new LambdaWrap(new SaveProject()));
    saveO.addActionListener(new LambdaWrap(new SaveOverlay()));
    saveasP.addActionListener(new LambdaWrap(new SaveAsProject()));
    saveasO.addActionListener(new LambdaWrap(new SaveAsOverlay()));
    export3D.addActionListener(new LambdaWrap(new Create3D()));
    exportPNG.addActionListener(new LambdaWrap(new ExportPNG()));
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
          slider.setValue(9);
          slider.addChangeListener(new ChangeListener() {
            public void stateChanged(ChangeEvent e) {
              img.brush.setSize(((JSlider)e.getSource()).getValue()*2+1);
             // println(((JSlider)e.getSource()).getValue());
            
            }
        });
           panel.add(slider);
           ui.f.add(panel);
           ui.sizeSlider=slider;
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
      ColorScroll scroll=new ColorScroll(ui,Color,2.3,0,1.2,6.7);
      //scroll.addColor(color(255,100,200,75));
      //scroll.addColor(color(255,0,0,75));
      //scroll.addColor(color(255,128,0,75));
      //scroll.addColor(color(255,255,0,75));
      //scroll.addColor(color(0,255,0,75));
      //scroll.addColor(color(0,0,255,75));
      //scroll.addColor(color(255,0,255,75));
    ui.f.add(main);
  }
   {//Add layer
          Ui_Button button=quickButton(new JButton(),"add",2.3,6.7);
          button.toolTip("Add Color");
          button.addToUi(ui);

          button.setHandler(new LambdaWrap(new AddLayer()));
        }
        
  ui.setColor(new Color(0,0,0,0));
    ui.f.revalidate();//these 2 lines clear up random issues in buttons not showing
    ui.f.repaint();
 
  return ui;
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
