import java.awt.event.*;  
import javax.swing.*;
import java.awt.*;
import javax.swing.border.Border;
import java.awt.Graphics;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

class Ui{
  JFrame root;
  JPanel f;
  HashMap<String,Ui_Button> buttons;
  ArrayList<Ui_Button> recolor;
  JSlider sizeSlider;
  Ui(){
    this("");
  }
  Ui(String name){
     root=new JFrame(name);
     //datapath required for non processing file access from test
     buttons=new HashMap<String,Ui_Button>();
     recolor=new ArrayList<Ui_Button>();
     root.setSize(400,in(9));
     
     
     root.setLayout(null);
     root.setVisible(true);
     //using no layout managers  
     f=new JPanel();
     f.setBackground(new Color(150,150,150));
     f.setBounds(0,0,400,in(9));
     f.setLayout(null);
     f.setVisible(true);
     root.add(f);
  }
  Ui setColor(Color c){
    for(int i=0;i<recolor.size();i++){
      recolor.get(i).setFill(c); 
    }
    f.revalidate();//these 2 lines clear up random issues in buttons not showing
    f.repaint();
    return this;
  }
  Ui_Button getId(String id){
    return buttons.get(id);
  }
  public void removeMinMaxClose()
{
  Component[] comps = f.getComponents();
    for(int i = 0; i < comps.length; i++)
    {
      if(comps[i] instanceof JButton)
      {
        
        String accName = ((JButton) comps[i]).getAccessibleContext().getAccessibleName();
        System.out.println(accName);
        if(accName.equals("Maximize")|| accName.equals("Iconify")||
           accName.equals("Close")) comps[i].getParent().remove(comps[i]);
      }
  
    
    }
  
  }
}
class Ui_Button{
  AbstractButton b;
  RoundedPanel fill;
  String name="";
  ActionListener callBack;
  int x,y;
  int xs,ys;
  ImageIcon ic;
  Image img;
  ImageIcon cl;
  Image clicked;
  ImageIcon roll;
  ImageIcon clickRoll;
  Image overlay;
  
  PImage mask;
  Ui_Button addToUi(Ui ui, String n){
    n=name;
    return addToUi(ui);
  }
  Ui_Button addToUi(Ui ui){
    fill.add(b);
    ui.f.add(fill);
   // ui.f.add(b);
    ui.buttons.put(name,this);
    ui.f.revalidate();
    ui.f.repaint();
    return this;
  }
  Ui_Button addToUi(Ui ui,JPanel panel){
    fill.add(b);
    panel.add(fill);
   // ui.f.add(b);
    ui.buttons.put(name,this);
    panel.revalidate();
    panel.repaint();
    ui.f.revalidate();
    ui.f.repaint();
    return this;
  }
  Ui_Button(){
    b=new JButton();//creating instance of JButton  
    fill=new RoundedPanel(0);
      
  }
  Ui_Button(AbstractButton button){
    b=button;//creating instance of JButton  
    fill=new RoundedPanel(0);  
      
  }
  Ui_Button(AbstractButton button,String n){
    b=button;//creating instance of JButton  
    name=n;
    fill=new RoundedPanel(0);  
  }
  Ui_Button setCallback(ActionListener handler){
   callBack=handler;
   b.addActionListener(callBack);
   
    return this;
  }
  Ui_Button setImage(String imgPath){
     
     try{
       img= ImageIO.read(new File(dataPath(imgPath)));
     }catch(Exception e){}
     ic=new ImageIcon(img);
      b.setIcon(ic);
    return this;
  }
  Ui_Button setMouseOver(String imgPath){
    try{
       overlay= ImageIO.read(new File(dataPath(imgPath)));
     }catch(Exception e){}
     roll=new ImageIcon(clicked);
     
     clickRoll=roll;
      b.setIcon(roll);
    return this;
  }
  Ui_Button toolTip(String tip){
     b.setToolTipText(tip);
     return this;
  }
  Ui_Button setClickImage(String imgPath){
     try{
       clicked= ImageIO.read(new File(dataPath(imgPath)));
     }catch(Exception e){println(e+"\n"+dataPath(imgPath));}
     cl=new ImageIcon(clicked);

      b.setPressedIcon(cl);
    return this;
  }

  Ui_Button setSize(int ixs, int iys){
     xs=ixs;ys=iys;
    // b.setBounds(x,y,xs, ys);
     if(ic!=null){

      ic.setImage(img.getScaledInstance(xs, ys, Image.SCALE_DEFAULT));
      b.setIcon(ic);
     }
     if(cl!=null){
       cl.setImage(clicked.getScaledInstance(xs, ys, Image.SCALE_DEFAULT));
        b.setSelectedIcon(cl);
     }
     if(roll!=null){
        
        
        if(ic!=null){
          roll.setImage(composite(img,overlay).getScaledInstance(xs, ys, Image.SCALE_DEFAULT));
        }else{
          roll.setImage(overlay.getScaledInstance(xs, ys, Image.SCALE_DEFAULT));
        }
        b.setRolloverIcon(roll);
        
        if(ic!=null){
          clickRoll.setImage(composite(clicked,overlay).getScaledInstance(xs, ys, Image.SCALE_DEFAULT));
        }else{
          clickRoll.setImage(overlay.getScaledInstance(xs, ys, Image.SCALE_DEFAULT));
        }
        b.setRolloverSelectedIcon(clickRoll);
        
     }
     fill.setBounds(x,y,xs,ys);
    return this;
  }
  Ui_Button setPos(int ix, int iy){
     x=ix;y=iy;
    // b.setBounds(x,y,xs, ys);
     fill.setBounds(x,y,xs,ys);
    return this;
  }
  Ui_Button setRadius(int rad){
    fill.cornerRadius=rad;
    return this;
  }
  Ui_Button setFill(Color c){
    if(b instanceof JRadioButton){
      fill.setBorder(BorderFactory.createEmptyBorder(-9,  0, 0,0));//apparently, radio buttons are 1 pixel differnt from all other buttons... oh joy
  
    }else{
      fill.setBorder(BorderFactory.createEmptyBorder(-10,  0, 0,0));//Not entirly sure why this line works, but without it the button is not centered on the lable
  
    }
    b.setBorderPainted(false);
b.setFocusPainted(false);
b.setContentAreaFilled(false);
fill.backgroundColor=c;
fill.revalidate();//these 2 lines clear up random issues in buttons not showing
    fill.repaint();
    return this;
  }
  Ui_Button setHandler(ActionListener action){
    b.addActionListener(action);
    return this;
  }
  Ui_Button setClick(boolean state){
    if(b.isSelected()!=state){//toggle state
      b.doClick();//this feels like such a hack, but its the only way I can find to easily fire the action listeners
    }
    return this;
  }
  boolean selected(){
    return b.isSelected();
  }

}
class RoundedPanel extends JPanel
    {
        Color backgroundColor;
        int cornerRadius = 15;

        public RoundedPanel(LayoutManager layout, int radius) {
            super(layout);
            cornerRadius = radius;
        }

        public RoundedPanel(LayoutManager layout, int radius, Color bgColor) {
            super(layout);
            cornerRadius = radius;
            backgroundColor = bgColor;
        }

        public RoundedPanel(int radius) {
            super();
            cornerRadius = radius;
        }

        public RoundedPanel(int radius, Color bgColor) {
            super();
            cornerRadius = radius;
            backgroundColor = bgColor;
        }

        @Override
        protected void paintComponent(Graphics g) {
            super.paintComponent(g);
            Dimension arcs = new Dimension(cornerRadius, cornerRadius);
            int width = getWidth();
            int height = getHeight();
            Graphics2D graphics = (Graphics2D) g;
            graphics.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

            //Draws the rounded panel with borders.
            if (backgroundColor != null) {
                graphics.setColor(backgroundColor);
            } else {
                graphics.setColor(getBackground());
            }
            graphics.fillRoundRect(0, 0, width-1, height-1, arcs.width, arcs.height); //paint background
            graphics.setColor(getForeground());
            graphics.drawRoundRect(0, 0, width-1, height-1, arcs.width, arcs.height); //paint border
        }
    }
    
Image composite(Image base, Image overlay){
        MediaTracker mt=new MediaTracker(new Container());
      mt.addImage(base, 0);
      mt.addImage(overlay, 1);
      try {
        mt.waitForAll();
      }
      catch (Exception e) {println("exception "+e);}
        BufferedImage newImage = new BufferedImage(base.getWidth(null),base.getHeight(null), BufferedImage.TYPE_INT_ARGB);//wtf does get width/height require an imageObserver?  Just use a blocking load and give me my image size!
        Graphics g2 = newImage.createGraphics();
        Color oldColor = g2.getColor();
        //fill background
            //draw image
        g2.setColor(oldColor);
        g2.drawImage(base, 0, 0,null);
        g2.drawImage(overlay, 0, 0,null);
        g2.dispose();
        return newImage; 
}

class LambdaWrap implements ActionListener{//this is a wraper for existing lambda objects so they all work fine with no modification.  For future use use ActionListener callbacks, this class will eventually be depreciated
  Lambda lam;
  Lambda onRelease;
  LambdaWrap(Lambda ilam){
    lam=ilam; 
    onRelease=null;
  }
  LambdaWrap(Lambda ilam,Lambda release){
    lam=ilam; 
    onRelease=release;
  }
  public void actionPerformed(ActionEvent e){  
     AbstractButton abstractButton =  
                (AbstractButton)e.getSource(); 
      
                // return true or false according 
                // to the selection or deselection 
                // of the button 

    if(abstractButton.getModel().isSelected()||abstractButton instanceof JMenuItem){//menu buttons dont report selected when clicked.... for some reason
      lam.run();
    }else{
      if(onRelease!=null){
       onRelease.run(); 
      }
    }
   }  
}

class RadioButton implements ActionListener{
   AbstractButton selected;//this is the activly selected button
   
   public void actionPerformed(ActionEvent e){  
     if(selected!=null){
      selected.setSelected(false);//clear old selecton
     }
     AbstractButton button = (AbstractButton)e.getSource(); 
     
     if(button.getModel().isSelected()){
       selected=button; //set self as active button
     }else{
       selected=null; //clear out our self as active button
     }
     
   }
   
}
class DualEdgeRadio extends RadioButton{

   public void actionPerformed(ActionEvent e){  

     AbstractButton button = (AbstractButton)e.getSource(); 
     
     if(button.getModel().isSelected()){
      if(selected!=null){
        //selected.setSelected(false);//clear old selecton
        selected.doClick();//I hope this does not come back to bite me
       }
       selected=button; //set self as active button
     }else{
       selected=null; //clear out our self as active button
     }
     
   }
   
}

class PopupPanel implements ActionListener{
   JPanel panel;//this is the activly selected button
   PopupPanel(JPanel in){
     panel=in; 
   }
   public void actionPerformed(ActionEvent e){  
     AbstractButton button = (AbstractButton)e.getSource(); 
     panel.setVisible(button.getModel().isSelected());
     
   }
   
}
public class NoneSelectedButtonGroup extends ButtonGroup {

  @Override
  public void setSelected(ButtonModel model, boolean selected) {
    if (selected) {
      super.setSelected(model, selected);
    } else if (getSelection() != model) {
      clearSelection();
    }
  }
}
//
//new ActionListener(){  
//public void actionPerformed(ActionEvent e){  
//            println("you clicked the button didn tyou");
//        }  
//    }); 
