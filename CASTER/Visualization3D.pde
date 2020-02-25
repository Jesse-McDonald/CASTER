import java.util.Arrays;
public class Visulization3D extends PApplet{
  int layerThickness=10;//number of pixels thick each layer is
  void exit(){ this.dispose(); 
     this.noLoop();
     surface.stopThread();
     g.dispose();
     this.stop();
     handleMethods("dispose");
   }
   void close(){ exit();}
  EMOverlay cloud;
  /*
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
  */
  
  void strip(){

    EMOverlay temp=new EMOverlay(cloud.width,cloud.height,cloud.depth);
    for(int z=0;z<cloud.depth;z++){
      if(cloud.exists(z)){
       
      for(int x=0;x<cloud.width;x++){
          for(int y=0;y<cloud.height;y++){
            color c=cloud.get(z,x,y);
              if(c!=0&&(int(cloud.get(z,x-1,y)==c)+int(cloud.get(z,x,y-1)==c)+int(cloud.get(z,x+1,y)==c)+int(cloud.get(z,x,y+1)==c)+int(cloud.get(z+1,x,y)==c)+int(cloud.get(z-1,x,y)==c))>5){
                //if(c!=0)println("removed pixel");
                temp.set(z,x,y,color(0,0,0,0));
              }else {
               temp.set(z,x,y,c);
              }
              
            }
          }
        }
      }
      cloud=null;
      cloud=temp;        
      
  
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
   Vertex connect(Vertex other){
     line(x,y,z,other.x,other.y,other.z);
     return this;
   }
   Vertex mark(PShape target){
     target.vertex(x*10,y*10,z*10*layerThickness); 
     return this;
   }
   Vertex mark(){
     vertex(x*10,y*10,z*10*layerThickness); 
     return this;
   }
   Vertex draw(){
     point(x*10,y*10,z*10*layerThickness); 
     return this;
   }
   String toString(){
     return "("+x+","+y+","+z+")"; 
   }
   String toObj(){
     return x+" "+y+" "+z*layerThickness; 
   }
  }
  class Triangle{
    Vertex p1,p2,p3;
    Triangle(Vertex v1, Vertex v2, Vertex v3){
      p1=v1;
      p2=v2;
      p3=v3;
    }
    Triangle lines(){
      p1.connect(p2);
      p2.connect(p3);
      p3.connect(p1);
      return this;
    }
    Triangle points(){
      p1.draw();
      p2.draw();
      p3.draw();
      return this;
    }
    Triangle draw(){
      beginShape();
      p1.mark();
      p2.mark();
      p3.mark();
      endShape(CLOSE);
      return this;
    }
    Triangle mark(){
      p1.mark();
      p2.mark();
      p3.mark();
      return this;
    }
    PShape buffer(PShape base){
    
     base.beginShape();
     base.noStroke();
     p1.mark(base);
     p2.mark(base);
     p3.mark(base);
     base.endShape();
     return base;
    }
    String toString(){
      return p1.toString()+" "+p2.toString()+" "+p3.toString(); 
    }
    String identify(){
      String[] points=new String[3];
      points[0]=p1.toString();
      points[1]=p2.toString();
      points[2]=p3.toString();
      Arrays.sort(points);
      return points[0]+" "+points[1]+" "+points[2]+" "; 
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
   Node(Vertex v){
     this();
     vertex=v;
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
   
   ArrayList<Triangle> triangles(){
     return triangles(new ArrayList<Triangle>());
   }
   ArrayList<Triangle> triangles(ArrayList<Triangle> append){
     for(int i =0;i<connected.size();i++){
       Vertex self=connected.get(i);
       int index1=-1,index2=-1;
       float distance1=Float.MAX_VALUE,distance2=Float.MAX_VALUE;
       for(int j =0;j<connected.size();j++){
         if(j!=i){
           Vertex target=connected.get(j);
           float distance=sq(self.x-target.x)+sq(self.y-target.y)+sq(self.z-target.z);
           if(distance<=distance1){
             distance2=distance1;
             index2=index1;
             distance1=distance;
             index1=j;
           }else if(distance<distance2){
             distance2=distance;
             index2=j;
           }
         }
       }
       if(index1>0){
       append.add(new Triangle(vertex,self,connected.get(index1)));
         if(index2>0){
         append.add(new Triangle(vertex,self,connected.get(index2)));
         }
       }
     }
     return append;
   }
   String toObj(){
     return vertex.toObj(); 
   }
   String toString(){
     return vertex.toString();
   }
  }
  float minX=Float.MAX_VALUE,minY=Float.MAX_VALUE,minZ=Float.MAX_VALUE,maxX=Float.MIN_VALUE,maxY=Float.MIN_VALUE,maxZ=Float.MIN_VALUE;
  class Web{
    PShape triangelBuffer;
    byte grid[][][];
    float ofx,ofy,ofz;
    int zext,xext,yext;
    ArrayList<Node> nodes;
    ArrayList<Line> lines;
    ArrayList<Triangle> triangles;
    color col;
    PShape triangleBuffer;
    Web(EMOverlay cloud,color c){
      triangleBuffer= createShape(GROUP);
      col=c;
     if(c==0) return;
     triangles=new ArrayList<Triangle>();
     //c alculate zext,xext,yext using minx maxx miny maxy minz maxz from the obverlay then calculate ofx ofy and ofz by the offset required to move the grid into place
     int minx=Integer.MAX_VALUE,miny=Integer.MAX_VALUE,minz=Integer.MAX_VALUE,maxx=Integer.MIN_VALUE,maxy=Integer.MIN_VALUE,maxz=Integer.MIN_VALUE;
     for(int z=0;z<cloud.depth;z++){

       if(cloud.exists(z)){

         for(int x=0;x<cloud.width;x++){
           for(int y=0;y<cloud.height;y++){
             if(cloud.get(z,x,y)==c){
                minx=min(x,minx);
                maxx=max(x,maxx);
                miny=min(y,miny);
                maxy=max(y,maxy);
                minz=min(z,minz);
                maxz=max(z,maxz);
             }
           }
         }           
       }
     }
     ofx=minx;
     ofy=miny;
     ofz=minz;
     xext=maxx-minx+1;
     yext=maxy-miny+1;
     zext=maxz-minz+1;
     maxX=max(maxx,maxX);
     maxY=max(maxy,maxY);
     maxZ=max(maxz,maxZ);
     minX=min(minx,minX);
     minY=min(miny,minY);
     minZ=min(minz,minZ);
     grid=new byte[xext][yext][zext];
     //println(grid.length+" "+grid[0].length+" "+grid[0][0].length);
    // println(minz+" "+minx+" "+miny);
     for(int z=0;z<grid[0][0].length;z++){
       if(cloud.exists(z+minz)){
         for(int x=0;x<grid.length;x++){
            for(int y=0;y<grid[0].length;y++){
              //println(x+" "+y+" "+z+" "+cloud.get(z+minz,x+minx,y+miny));
              grid[x][y][z]=byte(cloud.get(z+minz,x+minx,y+miny)==c);
            }
         }
       }
     }
     nodes =new ArrayList<Node>();
     lines=new ArrayList<Line>();
    }
    void lines(){
      for(int i = 0;i<lines.size();i++){
        line(lines.get(i).p1.x*10,lines.get(i).p1.y*10,lines.get(i).p1.z*10,lines.get(i).p2.x*10,lines.get(i).p2.y*10,lines.get(i).p2.z*10);
      }
    }
    void points(){
      for(int i = 0;i<nodes.size();i++){
        point(nodes.get(i).vertex.x*10,nodes.get(i).vertex.y*10,nodes.get(i).vertex.z*10); 
      }
    }
     void triangles(){
       noStroke();
       fill(color(red(col),green(col),blue(col)));//because of the number of overlapping triangles, any transparrent color looks terable
       for(int i=0;i<triangles.size();i++){
         triangles.get(i).draw(); 
       }
    }
    void drawBuffer(){
      shape(triangleBuffer); 
    }
    void map(){

      triangles=new ArrayList<Triangle>();
      nodes =new ArrayList<Node>();
      if(col==0) return;
      for(int x=0;x<grid.length;x++){
        //println(x);
       for(int y=0;y<grid[0].length;y++){
          for(int z=0;z<grid[0][0].length;z++){
            if(grid[x][y][z]==1){
               grid[x][y][z]=2;
               Vertex thisPoint=new Vertex(x+ofx,y+ofy,z+ofz);
               Node thisNode=new Node(thisPoint);
               for(int xs=-1;xs<=1;xs++){
                 for(int ys=-1;ys<=1;ys++){
                   for(int zs=-1;zs<=1;zs++){
                     
                     if(x-xs<0||x-xs>=grid.length||y-ys<0||y-ys>=grid[0].length||z-zs<0||z-zs>=grid[0][0].length||(xs==0&&ys==0&&zs==0)){
                       
                     }else{
                       
                       //println(grid.length+" "+grid[0].length+" "+grid[0][0].length);
                       if(grid[x-xs][y-ys][z-zs]>0){
                         Vertex connectedPoint=new Vertex(x-xs+ofx,y-ys+ofy,z-zs+ofz);
                         thisNode.connect(connectedPoint);
                         lines.add(new Line(thisPoint,connectedPoint));
                       }
                     }
                   }
                 }
               }
               //if(lines.size()>0){
               triangles=thisNode.triangles(triangles);
               minX=min(minX,thisPoint.x);
               minY=min(minY,thisPoint.y);
               minZ=min(minZ,thisPoint.z);
               maxX=max(maxX,thisPoint.x);
               maxY=max(maxY,thisPoint.y);
               maxZ=max(maxZ,thisPoint.z);
               nodes.add(thisNode);
              
              //}
            }
          }
       }
     } 
               //println(nodes.size());
               //println(triangles.size());
               stripDupeTriangles();
               //println(triangles.size());
               //for(int i=0;i<triangles.size();i++){
               //  println(triangles.get(i).toString());
               //}
        grid=null;//destroy the grid to free up memory, these things can be huge
    }
    Web stripDupeTriangles(){
      HashMap<String,Triangle> map=new HashMap<String,Triangle>();
      for(int i=0;i<triangles.size();i++){
        map.put(triangles.get(i).identify(),triangles.get(i)); 
      }
      
      triangles=new ArrayList<Triangle>();
      for(String i:map.keySet()){
        triangles.add(map.get(i));
      }
      return this;
    }
    Web bufferTriangles(){
      triangleBuffer=createShape(GROUP);
      for(int i=0;i<triangles.size();i++){
        PShape temp=createShape();
         temp.setFill(color(red(col),green(col),blue(col)));
 

        temp=triangles.get(i).buffer(temp);
 
        triangleBuffer.addChild(temp);
      }
      return this;
    }
    Web trianglesToFile(PrintWriter obj, PrintWriter mtl, int vertexOffset ){
     
       HashMap<String,Integer> nodeKey=new HashMap<String,Integer>();
      for(int i=0;i<nodes.size();i++){
        nodeKey.put(nodes.get(i).toString(),i);
      }
      String buffer="";
      for(int i=0;i<triangles.size();i++){

        buffer+="f "+(vertexOffset+nodeKey.get(triangles.get(i).p1.toString()))+" "+(vertexOffset+nodeKey.get(triangles.get(i).p2.toString()))+" "+(vertexOffset+nodeKey.get(triangles.get(i).p3.toString()))+"\n"; 
        if(buffer.length()>1000){
          //println(i+" of "+triangles.size()+" triangles");
          obj.print(buffer); 
          buffer="";

        }
        
      }
      obj.print(buffer);
      obj.flush();
      return this;
    }
    
     
    Web vertecesToFile(PrintWriter obj){
      String buffer="";

      for(int i=0;i<nodes.size();i++){
        buffer+="v "+nodes.get(i).toObj()+"\n";
        if(buffer.length()>1000){
          //println(i+" of "+nodes.size()+" nodes");
          obj.print(buffer); 
          buffer="";
        }
      }

      obj.print(buffer);
      //obj.flush();
      return this;
    }
  }
   ArrayList<Web> web;
   void settings(){
       size(800,800,OPENGL); 
   }
   void center(){
      translate(-(minX+maxX)/2*10,-(minY+maxY)/2*10,-(minZ+maxZ)/2*10);
    }
  void setup(){
 surface.setTitle("3D Visulization"); 
   //square();
   //sphere();
   
   //torus();
    prep();
   
   
   //teapot();
   //web.recursive(0);


   frameRate(60);
  }
  boolean STOP=false;
  
  void prep(){
    STOP=true;
    strip();
    web=new ArrayList<Web>();
    for(int i=1;i<cloud.palette.size();i++){
       web.add(new Web(cloud,cloud.palette.get(i)));
       web.get(i-1).map();
       web.get(i-1).bufferTriangles();
    } 
    STOP=false;
    //odly not only does saveHandler have to be public, but it also has to be part of a public class
    selectFolder("Select a directory to save to","saveHandler");//trigger stack load
    //im not entirely sure how this works, I assumed that the Sidebar thread starts the 3d thread, then the 3d thread starts a file io thread, which calles saveHandler when a file is selected
    //how ever, that would mean that no existing threads would be locked up by the load thread called by file io thread, so maybe it calls back to the previous thread and uses it for the load
    //except, that would lockup 3d visulizer... which does not lock up, which makes me think it instead has its on thread.... but there is a problem with that too,
    //the side bar thread is locked up on save... which is the first ish thread in the chain, to make things worse it does not block the CASTER main thread which called the sidebar thread
    //so I have no idea what is going on
    //to further complicate things, the side bar does not lock durring the rest of prep, only when we receive the callback from selctFolder, but 3d does lock except for not locking on the callback... so I am verry confused about which thread this goes in
    //TLDR: this callback thing is confusing on so many levels
  }
  
  float rad=0;
  float rotX,rotY,posX,posY,posZ;
  void draw(){
    if(!STOP){
      background(0);
    lights();
    fill(255);
    //rect(0,0,100,100);
    translate(width/2,height/2,000);
       
    translate(posX,posY,posZ);
    rotateX(-PI/2);
    rotateZ(rotX);
    rotateX(rotY);
    center();
  
    
  
    //rotate(rad,0,1,0);
    //rad+=.1;
    pushMatrix();
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

    stroke(255);
    noFill();
    fill(100);
    for(int i=0;i<web.size();i++){
      //web.get(i).triangles();
      web.get(i).drawBuffer();
    }
    //box(100,100,100);
    //web.lines();
    stroke(255,0,0);
    
    //for(int i=0;i<web.size();i++){
    //  web.get(i).points();
    //}
    //web.antiCursionFrame();
    popMatrix();
    }else{
      background(255); 
    }
   
  }
  void mouseWheel(processing.event.MouseEvent event){//mouse scrole handler
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
  void keyTyped(){//key type handler, for wacom tablet ease of resizing and layer change and redo
    if (key=='+'){
      layerThickness++;
      for(int i=0;i<web.size();i++){
        //web.get(i).triangles();
        web.get(i).bufferTriangles();
      }
    }else if(key=='-'){
      layerThickness--;
      if (layerThickness<1){
        layerThickness=1;
      }
      for(int i=0;i<web.size();i++){
        //web.get(i).triangles();
        web.get(i).bufferTriangles();
      }
    }
  }
  String rgbToMtl(color c){
    return"\n";
  }
  public void saveHandler(File folder){
    
    String fileName=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();

    PrintWriter mtl =createWriter(folder.getAbsolutePath()+"\\"+fileName+".mtl");

    PrintWriter obj =createWriter(folder.getAbsolutePath()+"\\"+fileName+".obj");
    //println("write started");
    obj.println("#CASTER v"+VERSION+" https://github.com/Jesse-McDonald");
    obj.println("#3D recreation of cell or cells with a layer pixel thickness of "+layerThickness);
    obj.println("mtllib "+fileName+".mtl");
    //println("starting verteces");
    for(int i=0;i<web.size();i++){
       web.get(i).vertecesToFile(obj);
    }
    obj.flush();
    //println("Verteces finished\nstarting triangles");
    int vertexOffset=1;//as we move down the images we can refer to the vertices by web internal order, but only if we track how many total verteces there are before the start of the file
    for(int i=0;i<web.size();i++){
      mtl.println("newmtl Material."+(i+1));
      mtl.print(rgbToMtl(web.get(i).col));
      obj.println("usemtl Material."+(i+1));
      obj.println("s off");
      web.get(i).trianglesToFile(obj,mtl,vertexOffset);
      vertexOffset+=web.get(i).nodes.size();
    }
    //println("triangles Finished\nfinishing");
    obj.flush();
    mtl.flush();
    obj.close();
    mtl.close();
    //println("save finished");

  }
}
