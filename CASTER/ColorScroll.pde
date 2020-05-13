class ColorScroll{
  JPanel colorPanel;
  JScrollPane scroll;
  Ui ui;
   RadioButton Color;
   ArrayList<SegmentationColor> colors;
  ColorScroll(Ui iui, RadioButton col, float posX, float posY, float sizeX, float sizeY){//2.3,0,1.2,6.7
    colors=new ArrayList<SegmentationColor>();
    ui=iui;
    ui.scroll=this;
    Color=col;
    colorPanel=new JPanel();
    //colorPanel.setBounds(in(posX),in(posY),in(sizeX),in(sizeY));
    //colorPanel.setLayout(null);
    //colorPanel.setBackground(new Color(240,240,240));
    
    
    JScrollPane scroll =new JScrollPane(colorPanel,JScrollPane.VERTICAL_SCROLLBAR_ALWAYS,
    JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
    //colorPanel.setLayout(new BoxLayout(colorPanel,BoxLayout.Y_AXIS));
    GridLayout grid=new GridLayout(0,1);
    //grid.setVgap(in(.1));
    colorPanel.setLayout(grid);
    scroll.setBounds(in(posX),in(posY),in(sizeX),in(sizeY));
    scroll.setPreferredSize(new Dimension(in(sizeX), in(sizeY)));
    scroll.getVerticalScrollBar().setUnitIncrement(8);
    ui.f.add(scroll,BorderLayout.CENTER);
    
  }
  ColorScroll addColor(color c){
    return addColor(c,"RGB("+red(c)+","+green(c)+","+blue(c)+")");
  }
  ColorScroll addColor(color c, String name){
    JPanel wraper=new JPanel();
          wraper.setBounds(0,0,in(1),in(1));
         
          Ui_Button button= quickColor(c);
          button.setHandler(Color);
          button.addToUi(ui,wraper);
          colorPanel.add(wraper);
          button.toolTip(name);
          colors.add(new SegmentationColor(c,name));
    return this;
  }
        Ui_Button quickColor(color c){
    Ui_Button button=new Ui_Button(new JToggleButton(),"RGB("+red(c)+","+green(c)+","+blue(c)+")");
    button.setImage("ui/color.png");
    button.setClickImage("ui/colorActive.png");
    button.setMouseOver("ui/highlight.png");
      button.setFill(new Color(round(red(c)),round(green(c)),round(blue(c))));//clear out old button everything
    
    button.setSize(in(1),in(1));
    //button.setPos(in(xin),in(yin));
    
    button.setRadius(in(.5));
    //button.toolTip("RGB("+red(c)+","+green(c)+","+blue(c)+")");
    button.setHandler(new LambdaWrap(new LColor(c), new LColor(0)));
  
    return button;
}
}
class SegmentationColor{
  color c;
  String name;
  SegmentationColor(){
     
  }
  SegmentationColor(color ic, String iname){
   c=ic;
   name=iname;
  }
}
