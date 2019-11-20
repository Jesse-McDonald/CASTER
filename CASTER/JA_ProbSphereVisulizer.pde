import java.util.Arrays;
public class JA_ProbSphereVisulizer extends PApplet{
   void exit(){ this.dispose(); 
     this.noLoop();
     surface.stopThread();
     g.dispose();
     this.stop();
     handleMethods("dispose");
   }
   void close(){ exit();}
  ArrayList<JA_ProbSphere> spheres;
  void settings(){
       size(800,800,OPENGL); 
   }
  void setup(){
 surface.setTitle("3D Visulization"); 
   //square();
   //sphere();
   
   //torus();

   
   //teapot();
   //web.recursive(0);

  spheres=new ArrayList<JA_ProbSphere>();
   frameRate(60);
  }
  boolean STOP=false;
  
  
  
  float rad=0;
  float rotX,rotY,posX,posY,posZ;
  
  void displaySpheres(ArrayList<JA_ProbSphere> ispheres){

    Point p=ispheres.get(0).getCenter(ispheres.get(0).bestRad);
    posX=p.x*10;
    posY=p.y*10;
    posZ=p.z*10;
    spheres=ispheres;
  }
  int layer=0;
  void draw(){
    pushMatrix();
    if(!STOP){
      background(0);
    lights();
    fill(255);
    //rect(0,0,100,100);
    translate(width/2,height/2,000);
        rotateZ(rotX);
    rotateX(rotY);
    translate(posX,posY,posZ);

    //rotateX(-PI/2);

    
  
    
  
    //rotate(rad,0,1,0);
    //rad+=.1;
    pushMatrix();
    for(int i=0;i<spheres.size();i++){
       float rad=spheres.get(i).bestRad;
       Point p=spheres.get(i).getCenter(rad);
       float freq=2*PI*(1.0/spheres.size());
       fill(cos(freq*i)*128+127,cos(freq*i+4*PI/3)*128+127,cos(freq*i+2*PI/3)*128+127,100);
       
       translate(-p.x*10,-p.y*10,-p.z*10);
       //println(rad);
       noStroke();
       sphere(rad*10);
       translate(p.x*10,p.y*10,p.z*10);
        }
        fill(255,255,0,100);
        popMatrix();
        beginShape();
       vertex(-100000,-100000,-img.layer*10);
       vertex(10000,-100000,-img.layer*10);
       vertex(100000,100000,-img.layer*10);
       vertex(-100000,100000,-img.layer*10);
       endShape();
    
 /*
    for(int z=0;z<cloud.depth;z++){
     if(cloud.exists(z)){
        for(int x=0;x<cloud.width;x++){
          for(int y=0;y<cloud.height;y++){
            color c=cloud.get(z,x,y);
            if(c!=0){
             
              stroke(color(red(c),green(c),blue(c)));
              point(x*10,y*10,z*10);
            }
          }
        }
      }
    }
    */
    }
    popMatrix();
  }
  void mouseWheel(MouseEvent event){//mouse scrole handler
    posZ-=((2*event.getAmount()))*20;
  }
  void mouseDragged(){
    if(mouseButton==RIGHT){
      //r=sqrt(mouseX^2+mouseY^2+mouseZ^2)
             rotX-=(pmouseX-mouseX)/100.;
             rotY+=(pmouseY-mouseY)/100.;
             
             
    }
    if(mouseButton==CENTER){
      posZ+=(pmouseY-mouseY)*10; 
    }
    if(mouseButton==LEFT){
      posX-=pmouseX-mouseX;
      posY-=pmouseY-mouseY;
    }
  }

 
}
