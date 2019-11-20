class JA_BuffleFill extends Brush{
  float pingSize=0;
  boolean displayShells=false;
  ArrayList<JA_ProbSphere> allSpheres;
  JA_ProbSphere sphere;
  //Point v;
  
  
JA_ProbSphereVisulizer view;
  JA_BuffleFill(){
   super(); 
   sphere=new JA_ProbSphere();
   sphere.setScale(1,1,7);
   //v=new Point(0,0,0);
   allSpheres=new ArrayList<JA_ProbSphere>();
   String[] args={""};
   view=new JA_ProbSphereVisulizer();
   PApplet.runSketch(args,view);
  }
  JA_BuffleFill(color col,EMImage image,int s){
    super(col,image,s); 
    sphere=new JA_ProbSphere();
    sphere=new JA_ProbSphere();
    sphere.setScale(1,1,7);
    //v=new Point(0,0,0);
    allSpheres=new ArrayList<JA_ProbSphere>();
    view=new JA_ProbSphereVisulizer();
    String[] args={""};
    PApplet.runSketch(args,view);
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
     Point c=sphere.getCenter(sphere.getBestRad());
      Pixel p=new Pixel(round(c.x/sphere.xs),round(c.y/sphere.ys),0);
    for(int i=0;i<allSpheres.size();i++){
      JA_ProbSphere sphere=allSpheres.get(i);
      c=sphere.getCenter(sphere.bestRad);
      if(displayShells&&i==allSpheres.size()-1){
        for(Float key: sphere.probs.keySet()){
           float prob=sphere.probs.get(key);
            
           c=sphere.getCenter(key);
            
           if(key-pow((img.layer-c.z),2)>0){
             float r=key*(sqrt(key-pow((img.layer-c.z),2)));
    
             p=new Pixel(round(c.x/sphere.xs),round(c.y/sphere.ys),0);
             
             stroke((1-prob)*511,0,(prob-.5)*511,100);
             //if(r*img.zoom>.1){
             if(key==sphere.bestRad){
               stroke(255,255,0,100);  
    
             }
               ellipse(img.screenX(p),img.screenY(p),r*img.zoom*2,r*img.zoom*2);
             //}
             }
        }
      }else{
        
        if((sphere.bestRad*sphere.bestRad)-pow((img.layer-c.z),2)>0){
          Point v=sphere.vectorizeShell();
          float freq=2*PI*(1.0/allSpheres.size());
          stroke(cos(freq*i)*128+127,cos(freq*i+4*PI/3)*128+127,cos(freq*i+2*PI/3)*128+127,100);
           float r=sphere.bestRad-abs(img.layer-c.z);
           p=new Pixel(round(c.x/sphere.xs),round(c.y/sphere.ys),0);
           
           ellipse(img.screenX(p),img.screenY(p),r*img.zoom,r*img.zoom);
           line(img.screenX(p.x+v.x*100),img.screenY(p.y+v.y*100),img.screenX(p.x),img.screenY(p.y));
           
        }
     }
    }
      
    return this;
  }
  public JA_BuffleFill paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    allSpheres=new ArrayList<JA_ProbSphere>();
    Pixel t=img.getPixel(mouseX,mouseY);
    Point p=new Point(t.x,t.y,img.layer);
    this.sphere=new JA_ProbSphere(p.x,p.y,p.z);
    for(int i=0;i<10;i++){
      Point v;
      sphere.setScale(1,1,7);
      sphere.minThresh=128;
      sphere.maxThresh=64;
      while(this.sphere.expand(img)>.5&&sphere.r<size);
  
      sphere.generateProbShell(sphere.getBestRad(),allSpheres);
      
      v=sphere.vectorizeShell();
      p=sphere.getCenter(sphere.bestRad);
      if(Double.isNaN(p.x)||Double.isNaN(p.y)||Double.isNaN(p.z)) break;
      allSpheres.add(sphere);
      
      //p.print();

      //v.print();
      JA_ProbSpherePinned nextSphere=new JA_ProbSpherePinned(p.x,p.y,p.z);
      
      nextSphere.setDir(v);
      //println(v.r);
      sphere=nextSphere;
      
    }
    view.displaySpheres(allSpheres);
    return this;
  }
}
