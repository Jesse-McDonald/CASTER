import java.util.Arrays;
import java.util.Stack;
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
  
  EMOverlay strip(EMOverlay cloud){

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
      //cloud=null;
      //cloud=temp;        
      return temp;
  
  }
  
  
  class Vertex{
   int x;
   int y;
   int z;
   int insideX=0;//values for this are limited to -1,0, and 1, specifes direction for inside
   int insideY=0;
   int insideZ=0;
   Vertex(int fx, int fy, int fz){
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
   boolean equals(Vertex o){
    return  o!=null&&x==o.x&&y==o.y&&z==o.z;
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
  class LayerPoint{
    int x, y;
    int ix,iy;
    LayerPoint(){}
    LayerPoint(int xi,int yi){
        x=xi;
        y=yi;
    }
    LayerPoint internal(int xi, int yi){
      ix=xi;
      iy=yi;
      return this;
    }
  }
  
  class Web{
    PShape triangelBuffer;
    EMOverlay grid;
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
     //println(grid.length+" "+grid[0].length+" "+grid[0][0].length);
    // println(minz+" "+minx+" "+miny);

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
    PNGOverlay merge(PNGOverlay top, PNGOverlay bottom){//creates deep copy
      PNGOverlay mask=new PNGOverlay(top.width,top.height);
      color black=tColor(0,0,0);
      for(int x=0;x<mask.width;x++){
        for(int y=0;y<mask.height;y++){
           if((top.get(x,y)==col)||(bottom.get(x,y)==col)){
             mask.set(x,y,black);
           }
        }
      }
      return mask;
    }
    PNGOverlay floodFill(PNGOverlay source, int x, int y,color c){
      color black=tColor(0,0,0);
      Stack<Pixel> frountier=new Stack<Pixel>();
      frountier.add(new Pixel(x,y,source.get(x,y)));
      while(!frountier.empty()){
         Pixel p=frountier.pop();
         if(p.c==black){
            source.set(p.x,p.y,c);
            if(p.x+1<source.width){
                frountier.add(new Pixel(x+1,y,source.get(x+1,y)));
            }
            if(p.x-1>0){
                frountier.add(new Pixel(x-1,y,source.get(x-1,y)));
            }
            if(p.y+1<source.height){
                frountier.add(new Pixel(x,y+1,source.get(x,y+1)));
            }
            if(p.y-1>0){
                frountier.add(new Pixel(x,y-1,source.get(x,y-1)));
            }
         }         
      }
      return source;
    }
    color niceColor(int k, int n){
      float freq=2*PI*(1.0/n);//this is magic, basicly cut a circle in to l parts and tell me how big each is
      return tColor(round(cos(freq*k)*127+128),round(cos(freq*k +4*PI/3)*127+128),round(cos(freq*k +2*PI/3)*127+128),255);//at this point a magic unicorns leap out of the circle and make colors appear
  }
    PNGOverlay fillStamp(PNGOverlay mask,boolean recolor){
      color black=tColor(0,0,0);
      int colors=1;//track which colors we have used
      for(int x=0;x<mask.width;x++){
        for(int y=0;y<mask.height;y++){
          if(mask.get(x,y)==black){
            mask=floodFill(mask,x,y,black+colors);
          }
        }
      }
      if(recolor){
         for(int i=0;i<mask.palette.size();i++){
            color c=0x00ffffff&mask.palette.get(i);
            c=niceColor(c,colors);
            mask.palette.set(key,c);
          }
        }
      
      return mask;
    }
    PNGOverlay[] reverseStamping(PNGOverlay top, PNGOverlay bottom){
      PNGOverlay[] ret=new PNGOverlay[3];
      PNGOverlay mask=merge(top,bottom);
      mask=fillStamp(mask,false);
      ret[1]=new PNGOverlay(top.width,top.height);
      ret[2]=new PNGOverlay(bottom.width,bottom.height);
      for(int x=0;x<mask.width;x++){
        for(int y=0;y<mask.height;y++){
           if((mask.get(x,y)!=0)&&(top.get(x,y)==col)){
             ret[1].set(x,y,mask.get(x,y));
           }
           if((mask.get(x,y)!=0)&&(bottom.get(x,y)==col)){
             ret[2].set(x,y,mask.get(x,y));
           }
        }
      }
      
      ret[0]=mask;
      return ret;
    }
    PNGOverlay strip(PNGOverlay full, color c){
     PNGOverlay ret=new PNGOverlay(full.width,full.height);
     for(int x=0;x<full.width;x++){
       for(int y=0;y<full.width;y++){
         if(full.get(x,y)==c&&
          !((x-1>0        &&full.get(x-1,y)==c)&&
            (x+1<full.width &&full.get(x+1,y)==c)&&
            (y-1>0          &&full.get(x-1,y)==c)&&
            (y+1<full.height&&full.get(x,y+y)==c))){//the pixel is the right color and is not surounded completely by said color
            ret.set(x,y,c);
         }
          
       }  
     }
     return ret;
    }
    ArrayList<LoopList<Vertex>> buildLoops(PNGOverlay full,int l, color c){
      PNGOverlay reduced=strip(full,c);
      ArrayList<LoopList<Vertex>>thisLayer=new ArrayList<LoopList<Vertex>>();
         for(int x=0;x<grid.width;x++){
            for(int y=0;y<grid.width;y++){
              
              if(reduced.get(x,y)==col){
                 Vertex start=new Vertex(x,y,l);
                 reduced.set(x,y,0);
                 Vertex last=start;
                 LoopList<Vertex> loop=new LoopList<Vertex>();
                 loop.set(start);
                 do{
                   boolean selected=false;
                   if(selected||full.get(last.x+1,last.y)!=col){
                     if(reduced.get(last.x+1,last.y-1)==col){
                       selected=true;
                       last=new Vertex(last.x+1,last.y-1,l);
                       reduced.set(last.x,last.y,0);
   
                     }else if(reduced.get(last.x,last.y-1)==col){
                       selected=true;
                       last=new Vertex(last.x,last.y-1,l);
                       reduced.set(last.x,last.y,0);
                       
                     }
                  
                   }
                   if(selected||full.get(last.x-1,last.y)!=col){
                     if(reduced.get(last.x-1,last.y+1)==col){
                       selected=true;
                       last=new Vertex(last.x-1,last.y+1,l);
                       reduced.set(last.x,last.y,0);
                       
                     }else if(reduced.get(last.x,last.y-1)==col){
                       selected=true;
                       last=new Vertex(last.x,last.y-1,l);
                       reduced.set(last.x,last.y,0);
                       
                     }
                   }
                   if(selected||full.get(last.x,last.y-1)!=col){
                     if(reduced.get(last.x-1,last.y-1)==col){
                       selected=true;
                       last=new Vertex(last.x-1,last.y-1,l);
                       reduced.set(last.x,last.y,0);
                       
                     }else if(reduced.get(last.x,last.y-1)==col){
                       selected=true;
                       last=new Vertex(last.x-1,last.y,l);
                       reduced.set(last.x,last.y,0);
                       
                     }
                   }
                   if(selected||full.get(last.x,last.y+1)!=col){
                     if(reduced.get(last.x+1,last.y+1)==col){
                       selected=true;
                       last=new Vertex(last.x,last.y+1,l);
                       reduced.set(last.x,last.y,0);
                       
                     }else if(reduced.get(last.x+1,last.y)==col){
                       selected=true;
                       last=new Vertex(last.x+1,last.y,l);
                       reduced.set(last.x,last.y,0);
                       
                     }
                   }
                   if(selected&&!start.equals(last)){
                     loop.set(last); 
                   }
                 }while(!start.equals(last));
                 loop.loop();
                 thisLayer.add(loop);
                 
                 
                 
              }
              
            }
          }
          return thisLayer;
  }
  int [] extractLayers(EMOverlay source){
      int[] keys=new int[source.key.size()];
      {
        int i=0;
        for(Integer key:source.key.keySet()){
          keys[i]=key.intValue();
          i++;
        }
      }
      Arrays.sort(keys);
      ArrayList<Integer> pad=new ArrayList<Integer>();
      for(int i=0;i<keys.length;i++){
        if(i-1<0||keys[i-1]+1!=keys[i]){
         pad.add(-1);//pull blank layer 
        }
        pad.add(keys[i]);
      }
      pad.add(-1);//last pad
      keys=new int[pad.size()];//can we all agree to just use length() for all arrays? then we can use size for allocated size
      for(int i=0;i<pad.size();i++){
        keys[i]=pad.get(i).intValue(); 
      }
      return keys;
  }
  ArrayList<Triangle> stitch(ArrayList<Triangle> list, ArrayList<LoopList<Vertex>> lastLayer, ArrayList<LoopList<Vertex>> thisLayer){
    //TODO build stitch
    
    return list;
  }
  ArrayList<Triangle> face(ArrayList<Triangle> list, ArrayList<LoopList<Vertex>> layer){
    //TODO build face
    
    return list;
  }
  ListNode<Vertex> getTopNode(LoopList<Vertex> loop){
             ListNode<Vertex> start=loop.get();
             ListNode<Vertex> top=loop.get();
             for(ListNode<Vertex> current=start.next;current!=start;current=current.next){
               if(top.data.x<current.data.x){
                 top=current;
               }
             }
            return top;
  }
  LoopList<Vertex> mergeLoops(ArrayList<LoopList<Vertex>> loops){
    Vertex commonCenter=new Vertex(0,0,0);
    
    for(int i=0;i<loops.size();i++){
       Vertex center=new Vertex(0,0,0);
       int count=0;
       ListNode<Vertex> start=loops.get(i).get();
       for(ListNode<Vertex> current=start.next;current!=start;current=current.next){
         center.x+=current.data.x;
         center.y+=current.data.y;
         center.z+=current.data.z;
         count++;
       }
       
       center.x/=count;
       center.y/=count;
       center.z/=count;
       
       commonCenter.x+=center.x;
       commonCenter.y+=center.y;
       commonCenter.z+=center.z;
    }
    commonCenter.x/=loops.size();
    commonCenter.y/=loops.size();
    commonCenter.z/=loops.size();
    
    
    LoopList<Vertex> loop=loops.get(0);
    
   return loop;
  }
  ArrayList<ArrayList<LoopList<Vertex>>[]> linkLoops(ArrayList<LoopList<Vertex>> lastLayer,ArrayList<LoopList<Vertex>> thisLayer){
     ArrayList<ArrayList<LoopList<Vertex>>[]> loopLinks=new ArrayList<ArrayList<LoopList<Vertex>>[]>();//this rather anoying data type is an arraylist of all loop pairs. 
           //the basic array is the top and bottom loop in each pair
           //the first element of the list is the outer most shell
           LoopList<Vertex> outer;//build outer shell
           if(lastLayer.size()>1){
             ArrayList<LoopList<Vertex>> outerShells=new ArrayList<LoopList<Vertex>>();
             for(int i=0;i<lastLayer.size();i++){//locate the highest node
               ListNode<Vertex> top=getTopNode(lastLayer.get(i));
               if(top.next.data.y>top.data.y){//check that the cell turns clockwise at highest node
                 outerShells.add(lastLayer.get(i));//if it does, it is an outer loop
                 
               }
             }
             if(outerShells.size()==1){
               outer=outerShells.get(0); 
             }else{
               outer=mergeLoops(outerShells); 
             }
           }else{
             outer=lastLayer.get(0); 
           }
           return loopLinks;
  }
    void map(){

      triangles=new ArrayList<Triangle>();
      nodes =new ArrayList<Node>();
      if(col==0) return;
      
      int[] keys=extractLayers(cloud);
       for(int i=1;i<keys.length;i++){
         PNGOverlay[] stamped;
         stamped=reverseStamping(cloud.get(keys[i-1]),cloud.get(keys[i]));
         for(color c : stamped[0].palette){

           ArrayList<LoopList<Vertex>> lastLayer=buildLoops(stamped[1],keys[i-1],c);
           ArrayList<LoopList<Vertex>> thisLayer=buildLoops(stamped[2],keys[i],c);
           //detect and handle internal loops
           if(lastLayer.size()>0&&thisLayer.size()>0){
             ArrayList<ArrayList<LoopList<Vertex>>[]> loopLinks=linkLoops(lastLayer,thisLayer);//this rather anoying data type is an arraylist of all loop pairs. 
           //the basic array is the top and bottom loop in each pair
           //the first element of the list is the outer most shell
           triangles=stitch(triangles,lastLayer,thisLayer);
           }else{
             if(lastLayer.size()>0){
               triangles=face(triangles,lastLayer);
             }else{
               triangles=face(triangles,thisLayer);
             }
           }
           
         }
       }

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
    //strip();
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
