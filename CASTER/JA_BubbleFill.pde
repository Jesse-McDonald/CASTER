class JA_BuffleFill extends Brush{
  float pingSize=0;
  JA_ProbSphere sphere;
  
  JA_BuffleFill(){
   super(); 
   sphere=new JA_ProbSphere();
   sphere.setScale(1,1,7);
  }
  JA_BuffleFill(color col,EMImage image,int s){
    super(col,image,s); 
    sphere=new JA_ProbSphere();
   
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
    for(Float key: sphere.probs.keySet()){
       float prob=sphere.probs.get(key);
        
       Point c=sphere.getCenter(key);
        
       if(key-pow((img.layer-c.z),2)>0){
         float r=key*(sqrt(key-pow((img.layer-c.z),2)));

         Pixel p=new Pixel(round(c.x/sphere.xs),round(c.y/sphere.ys),0);
         stroke((1-prob)*511,0,(prob-.5)*511,100);
         //if(r*img.zoom>.1){

           ellipse(img.screenX(p),img.screenY(p),r*img.zoom*2,r*img.zoom*2);
         //}
       }
    }
    return this;
  }
  public JA_BuffleFill paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    Pixel p=img.getPixel(mouseX,mouseY);
    this.sphere=new JA_ProbSphere(p.x,p.y,img.layer);
    sphere.setScale(1,1,7);
    sphere.minThresh=64;
    sphere.maxThresh=32;
    while(this.sphere.expand(img)>.5&&sphere.r<size);

    return this;
  }
}
