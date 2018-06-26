public class Visulization3D extends PApplet 
{
  float rotX, rotY, x = 250, y = 250;//This allows for rotation of the x and y axis
  float scaleFactor = 1.0, translateX = 0.0, translateY = 0.0;//And this allows the 3D to be zoomed in and out
  color[][] locations;//Theoretically, this will store the locations of the membrane sections
  JFrame frame = new JFrame();//This so far is unimportant. I was trying to get a proper heading on the window
  
  
  void settings()
  {
    size(500,500, OPENGL);//this sets the size of the window and allows for 3D viewing
    frame.setTitle("View in 3D");//See, this is the attempt at a proper window title
  }
  
  //I like these mouse controles
  void mouseDragged(){
    if (mouseButton == RIGHT)//Controlls the rotation of the image
    {
      rotY -= (mouseX - pmouseX) * 0.01;
      rotX -= (mouseY - pmouseY) * 0.01;
    }
    else if (mouseButton == LEFT)//Controls the location of the image
    {
      x += (mouseX - pmouseX) * 0.5;
      y += (mouseY - pmouseY) * 0.5;
    }
  }
  
  void mouseWheel(MouseEvent event){//Controlls the zoom of the image
    translateX -= mouseX;
    translateY -= mouseY;
    float delta = event.getCount() > 0 ? 1.05 : event.getCount() < 0 ? 1.0/1.05 : 1.0;
    scaleFactor *= delta;
    translateX *= delta;
    translateY *= delta;
    translateX += mouseX;
    translateY += mouseY;
  }
  
boolean cloud[][][];

void square(){
  cloud=new boolean[10][10][10];
  for(int x=0;x<cloud.length;x++){
      for(int y=0;y<cloud[x].length;y++){
          for(int z=0;z<cloud[x][y].length;z++){
            cloud[x][y][z]=true;
          }
      }
  }
  
}
void sphere(){
  cloud=new boolean[40][40][40];
  for(int x=-cloud.length/2;x<cloud.length/2;x++){
      for(int y=-cloud[0].length/2;y<cloud[0].length/2;y++){
          for(int z=-cloud[0][0].length/2;z<cloud[0][0].length/2;z++){
            cloud[x+20][y+20][z+20]=(x*x+y*y+z*z)<20*20;
          }
      }
  }
  
}
void torus(){
  cloud=new boolean[400][400][400];
  for(int x=-cloud.length/2;x<cloud.length/2;x++){
      for(int y=-cloud[0].length/2;y<cloud[0].length/2;y++){
          for(int z=-cloud[0][0].length/2;z<cloud[0][0].length/2;z++){
            cloud[x+200][y+200][z+200]=sq(30-sqrt(x*x+y*y))+z*z<200;
          }
      }
  }
}


void strip(){
  boolean[][][] temp=new boolean[cloud.length][cloud[0].length][cloud[0][0].length];
  for(int z=1;z<cloud[0][0].length-1;z++){
    for(int x=1;x<cloud.length-1;x++){
        for(int y=1;y<cloud[0].length-1;y++){
            if(cloud[x][y][z]&&cloud[x-1][y][z]&&cloud[x][y-1][z]&&cloud[x+1][y][z]&&cloud[x][y+1][z]&&cloud[x][y][z+1]&&cloud[x][y][z-1]){
              temp[x][y][z]=false;
            }else {
             temp[x][y][z]=cloud[x][y][z];
            }
            
          }
      }
    }
    for(int z=1;z<cloud[0][0].length-1;z++){
      for(int x=1;x<cloud.length-1;x++){
        for(int y=1;y<cloud[0].length-1;y++){
          cloud[x][y][z]=temp[x][y][z]; 
        }
      }
    }        
       

}


class Vertex{
 float x;
 float y;
 float z;
 Vertex(float fx, float fy, float fz){
  x=fx;
  y=fy;
  z=fz;
 }
}
class Line{
  Vertex p1;
  Vertex p2;
  Line(Vertex _1, Vertex _2){
   p1=_1;
   p2=_2;
  }
}
class Node{
 Vertex vertex;
 ArrayList<Vertex> connected;
 ArrayList<Line> lines;
 Node(){
  connected=new ArrayList<Vertex>();
  lines=new ArrayList<Line>();
 }
 Node connect(Vertex point){
    connected.add(point);
    lines.add(new Line(vertex,point));
    return this;
 }
 Node sortConnections(){
   if(connected.size()>0){
   ArrayList<Vertex> sorted=new ArrayList<Vertex>();
   ArrayList<Line> sortedLines=new ArrayList<Line>();
   Vertex temp=connected.get(0);
   sortedLines.add(lines.get(0));
   lines.remove(0);
   connected.remove(0);
   while(connected.size()>0){
    
    
    int index=-1;
    float distance=Float.MAX_VALUE;
    for(int i =0;i< connected.size();i++){
       float tempDist=sq(temp.x-connected.get(i).x)+sq(temp.y-connected.get(i).y)+sq(temp.z-connected.get(i).z);
       if(tempDist<distance){
        index=i;
        distance=tempDist;
       }
       
    }
    sorted.add(temp);
    temp=connected.get(index);
    connected.remove(index);
    sortedLines.add(lines.get(index));
    lines.remove(index);
   }
   sorted.add(temp);
   connected=sorted;
   lines=sortedLines;
   }
   return this;
 }
 
}
class Web{
  ArrayList<Vertex> vertices;
  ArrayList<Node> nodes;
  ArrayList<Line> lines;
  ArrayList<Integer> antiCursionIndex;
  Web(){
   vertices=new ArrayList<Vertex>();
   nodes =new ArrayList<Node>();
   lines=new ArrayList<Line>();
   antiCursionIndex= new ArrayList<Integer>();
  }
  void lines(){
    for(int i = 0;i<lines.size();i++){
      line(lines.get(i).p1.x,lines.get(i).p1.y,lines.get(i).p1.z,lines.get(i).p2.x,lines.get(i).p2.y,lines.get(i).p2.z);
    }
  }
  void points(){
    for(int i = 0;i<nodes.size();i++){
      point(nodes.get(i).vertex.x,nodes.get(i).vertex.y,nodes.get(i).vertex.z); 
    }
  }
   void triangles(){
     noStroke();
     for(int i = 0;i<nodes.size();i++){
       
       for(int j=0;j<nodes.get(i).lines.size()-1;j++){
         beginShape();
         vertex(nodes.get(i).vertex.x,nodes.get(i).vertex.y,nodes.get(i).vertex.z);
         vertex(nodes.get(i).lines.get(j).p2.x,nodes.get(i).lines.get(j).p2.y,nodes.get(i).lines.get(j).p2.z);
         vertex(nodes.get(i).lines.get(j+1).p2.x,nodes.get(i).lines.get(j+1).p2.y,nodes.get(i).lines.get(j+1).p2.z);
         endShape(CLOSE);
       }
        vertex(nodes.get(i).vertex.x,nodes.get(i).vertex.y,nodes.get(i).vertex.z);
         vertex(nodes.get(i).lines.get(0).p2.x,nodes.get(i).lines.get(0).p2.y,nodes.get(i).lines.get(0).p2.z);
         vertex(nodes.get(i).lines.get(nodes.get(i).lines.size()-1).p2.x,nodes.get(i).lines.get(nodes.get(i).lines.size()-1).p2.y,nodes.get(i).lines.get(nodes.get(i).lines.size()-1).p2.z);
     
     }
   }
  int vertexCount=8;
  void antiCursion(){//its recursion, but its not
    int percent=-1;

    while(antiCursionIndex.size()>0){
      int temp=antiCursionIndex.get(antiCursionIndex.size()-1);
      
      antiCursionIndex.remove(antiCursionIndex.size()-1);
      recursive(temp);
      
      //count++;
      if(percent!=round(nodes.size()/(float)vertices.size()/(vertexCount*2)*100)){
        percent=round(nodes.size()/(float)vertices.size()/(vertexCount*2)*100);
        println(percent);
      }
    }
  }int percent=-1;
  void antiCursionFrame(){//its recursion, but its not
    

    if(antiCursionIndex.size()>0){
      int temp=antiCursionIndex.get(antiCursionIndex.size()-1);
      
      antiCursionIndex.remove(antiCursionIndex.size()-1);
      recursive(temp);
      
      //count++;
      if(percent!=round(nodes.size()/(vertices.size()*100))){
        percent=round(nodes.size()/(vertices.size()*100));
        //println(percent);
      }
    }
  }
  HashMap<Integer,Boolean> beenThere;
  void recursive(int index){
       if(beenThere.containsKey(index)){
        return;
       }else{
         beenThere.put(index,true);
       ArrayList<Integer> indeces=new ArrayList<Integer>();
       boolean noRecursion=false;
       Vertex start=vertices.get(index);
       Node newNode=new Node();  
       newNode.vertex=start;
       
       {
         
         for(int i =0;i<nodes.size()&&!noRecursion;i++){
           if(nodes.get(i).vertex==start){
             for(int j=0;j<nodes.get(i).connected.size();j++){
                 if(start==nodes.get(i).connected.get(j)){
                  noRecursion=true;  
                 }
             }
             
           }
         }
         
         //vertices.remove(vertices.size()-1);
         
         ArrayList<Float> distances=new ArrayList<Float>();
         for(int i=0;i< vertices.size();i++){
           Vertex end=vertices.get(i);
           distances.add(sq(end.x-start.x)+sq(end.y-start.y)+sq(end.z-start.z));
           
         }
         
         float average=0;
         float max=0;
         while(indeces.size()<=vertexCount){//tune
           float min=Float.MAX_VALUE;
          
           int target=-1;
           for(int i=0;i<distances.size();i++){
             boolean repeat=false;
             for(int j =0;j<indeces.size()&&!repeat;j++){
               if(indeces.get(j)==i){
                 repeat=true;
               }
             }
              if(min>distances.get(i)&&!repeat){
                min =distances.get(i);
                target=i;
              }
           }
           //if(distances.get(target)<(average/indeces.size())+max||indeces.size()<6){
             indeces.add(target);
             average+=min;
             max=min;
           //}else{
            //break; 
           //}
           
         }
    }
    //newNode.sortConnections();
    nodes.add(newNode);
    stroke(255,0,0);
    for(int i=0;i<indeces.size();i++){
      newNode.connect(vertices.get(indeces.get(i)));
      lines.add(new Line(vertices.get(indeces.get(i)),start));
     
      line(vertices.get(indeces.get(i)).x,vertices.get(indeces.get(i)).y,vertices.get(indeces.get(i)).z,start.x,start.y,start.z);
      if(!noRecursion){
        antiCursionIndex.add(indeces.get(i));
        //recursive(indeces.get(i));
       
      }
    }
       
       
  }
  }
}
void teapot(){
  String[] lines=loadStrings("teapot.points");
  for(int i=0;i<lines.length;i++){
    String[] temp =lines[i].split("  ");

    web.vertices.add(new Vertex(Float.parseFloat(temp[0])*100,Float.parseFloat(temp[1])*100,Float.parseFloat(temp[2])*100));
  }
}
 Web web;
void setup(){
web=new Web();
 //square();
 //sphere();
 
 torus();

 strip();
 
 
 for(int x=0;x<cloud.length;x++){
    for(int y=0;y<cloud[0].length;y++){
      for(int z=0;z<cloud[0][0].length;z++){
        if(cloud[x][y][z]){
          web.vertices.add(new Vertex(x*10,y*10,z*10));
        }
      }
    }
 }
 
 //teapot();
 //web.recursive(0);
 web.antiCursionIndex.add(0);
 web.beenThere=new HashMap<Integer,Boolean>();
// web.antiCursion();
  //for(int i=0;i<web.nodes.size();i++){
   // web.nodes.get(i).sortConnections(); 
 //}
 frameRate(60);
}
int prevReps=100;
float rad=0;
void draw(){
  background(32);//A neutral background color
  pushMatrix();
   
    translate(-cloud.length/2*10,-cloud[0].length/2*10,-cloud[0][0].length/2*10);
  rotateX(rotX); //Display based on X and Y rotations and zoom level
     rotateY(-rotY); 
 translate(x,y);
 
     smooth();
     lights();
     
     fill(color(255, 20, 147, 255));//A kinda pretty color that won't actually be shown
     
     scale(scaleFactor);
     

  //translate(width/2,height/2,000);

  //rotate(rad,0,1,0);
  //rad+=.1;
  
  
  
  
  stroke(255);
  noFill();
  fill(100);
  //web.lines();
  web.triangles();
  
  stroke(255,0,0);
  //web.points();
  /*
  for(int z=0;z<cloud[0][0].length;z++){
    for(int x=0;x<cloud.length;x++){
        for(int y=0;y<cloud[0].length;y++){
         
            if(cloud[x][y][z]){
              
              point((x)*10,(y)*10,(z)*10);
            }
          }
      }
  }*/
  for(int i=0;i<prevReps;i++){
  web.antiCursionFrame();
  web.nodes.get(web.nodes.size()-1).sortConnections(); }
  prevReps*=(frameRate/30.0);
  prevReps+=1;

  popMatrix();
}

}