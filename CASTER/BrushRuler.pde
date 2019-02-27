//this is not technically a brush, but it fills the slot so I am calling it a brush
class BrushRuler extends Brush{
  Pixel mark1;
  int layer1;
  Pixel mark2;
  int layer2;
  int clickToggle;
  public BrushRuler(color col,EMImage image,int s){
      super(col,image,s);
      shape=loadImage("ui/ruler.png");//load up the bucket encase of flood fill
      shape.resize(128,128);
      
  }
  public BrushRuler draw(){//this draws the shape of the brush to the screen, generally should not update overlay unless there is a multi-frame process
    //this should be called every frame
    float zoom=this.img.getZoom();
    int xDistance=0;
    int layerDistance=0;
    int yDistance=0;
    float distance=0;
    strokeWeight(2);
    fill(0);
    stroke(color(red(c),green(c),blue(c)));
    fill(color(red(c),green(c),blue(c)));
    if(mark1!=null&&mark2==null){
     Pixel temp=this.img.getPixel(int(mouseX),int(mouseY));
     xDistance=abs(mark1.x-temp.x);
     yDistance=abs(mark1.y-temp.y);
     layerDistance=abs(layer1-this.img.layer);
     
     ellipse(this.img.screenX(mark1),this.img.screenY(mark1),5,5);
     line(this.img.screenX(mark1),this.img.screenY(mark1),mouseX,mouseY);
    }else if(mark1!=null&&mark2!=null){
     xDistance=abs(mark1.x-mark2.x);
     yDistance=abs(mark1.y-mark2.y);
     layerDistance=abs(layer1-layer2);
     ellipse(this.img.screenX(mark1),this.img.screenY(mark1),5,5);
     ellipse(this.img.screenX(mark2),this.img.screenY(mark2),5,5);
     line(this.img.screenX(mark1),this.img.screenY(mark1),this.img.screenX(mark2),this.img.screenY(mark2));
    }
    distance=sqrt(xDistance*xDistance+yDistance*yDistance+layerDistance*layerDistance);
    Pixel pixel = brushPosition();
    noStroke();
    fill(255,200);
    textSize(16);
    String info="X Distance: "+xDistance+"\nY Distance: "+yDistance+"\nLayer Distance: "+layerDistance+"\nAbsolute Distance: "+distance;
    rect(mouseX,mouseY-textAscent()*7,textWidth(info)+10,textAscent()*7);

    image(shape,mouseX-shape.width+9,mouseY-shape.height+13);
    fill(0);
    
    text(info, mouseX+10,mouseY-textAscent()*6);
    if(clickToggle==1&&!mousePressed){
      clickToggle=0; 
    } 
    if(erase){
      mark1=null;
      mark2=null;
    }
    return this; 
  }
  
  public BrushRuler paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    Pixel pixel= brushPosition();
    this.img=img;
    float zoom=this.img.getZoom();
    if(clickToggle==0&&mousePressed){
      clickToggle=1;
      if(mark1==null){
        mark1=this.img.getPixel(int(mouseX),int(mouseY));
        layer1=this.img.layer;
      }else if(mark2==null){
        mark2=this.img.getPixel(int(mouseX),int(mouseY));
        layer2=this.img.layer;
      }else{
        mark1=this.img.getPixel(int(mouseX),int(mouseY));
        layer1=this.img.layer;
        mark2=null;
      }
    }if(clickToggle==1&&!mousePressed){
      clickToggle=0; 
    }
    
    return this;
  }
  BrushRuler update(){
    return this; 
  }
}