class JA_BuffleFill extends Brush{
  float pingSize=0;
  JA_BuffleFill(){
   super(); 
  }
  JA_BuffleFill(color col,EMImage image,int s){
    super(col,image,s); 
  }
  JA_BuffleFill draw(){
    if(pingSize>size){
      pingSize=0;
    }
    
    strokeWeight(10);
    stroke(c);
    noFill();
    ellipse(mouseX,mouseY,pingSize*img.zoom,pingSize*img.zoom);
    pingSize++;
    return this;
  }
  public JA_BuffleFill paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    JA_ProbSphere sphere=new JA_ProbSphere(mouseX,mouseY,img.layer);
    sphere.setScale(1,1,1/14.);
    while(sphere.expand(img)>.5);
    
    return this;
  }
}
