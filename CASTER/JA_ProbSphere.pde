
class JA_ProbSphere{
  float bestRad;
  float x, y, z;//sphere center
  //x and y are in pixels from top left
  //z is layers from layer 0
  float r;//sphere radius
  Point shellCenter;
  float xs=1,ys=1,zs=1;//pixel scale
  float curProb=1;//probibility that sphere is inside axon
  float probsTotal=0;//sum up total of all probs so we can average them for current Prob
  HashMap<Float, Float> probs;//list of radius and corisponding prob
  float minThresh=255;//colors lighter than this are 0% edge
  float maxThresh=0;//colors darker than this are 100% edge
  ArrayList<Prob_Point> shell;//the shell is centered around 0,0,0, remember to shift to x,y,z before use (or just use as vector)
  JA_ProbSphere(){
    r=0;
    x=0;
    y=0;
    z=0;
    shellCenter=new Point(x,y,z);
    curProb=1;
    probs=new HashMap<Float, Float>();
    shell=new ArrayList<Prob_Point>();
   // probs.put(0.,1.);
  }
  JA_ProbSphere(float ix, float iy, float iz){
     this();
     x=ix;
     y=iy;
     z=iz;
     shellCenter.x=x;
     shellCenter.y=y;
     
     shellCenter.z=z;
  }
  Point getCenter(float r){
    return new Point(x,y,z);  
  }
  void setScale(float ix, float iy, float iz){
    xs=ix;
    ys=iy;
    zs=iz;

  }
  float expand(EMImage img){
    return expand(img, 1); 
  }
  float expand(EMImage img, float ir){//expand r by ir
    r=r+ir;//make sphere larger
    scanSphere(img);
    //curProb=probsTotal/(probs.size()+1);
    probs.put(r,curProb);
    //println(r,probsTotal,probsTotal/probs.size(),curProb);
    return curProb;
  }
  void retotal(){
    probsTotal=0;
    for(Float key: probs.keySet()){
      probsTotal+=probs.get(key);
    }
  }
  float getBestRad(){
    float best=0;
    float bestRat=0;
    for(Float key: probs.keySet()){
      float rat=(key)*(probs.get(key));
      //println(key,rat);
      if(rat>bestRat){
       best=key;
       bestRat=rat;
      }
    }
    bestRad=best;
    return best;
  }
  void generateProbShell(float r,ArrayList<JA_ProbSphere> otherAreas){
    shell=new ArrayList<Prob_Point>(round(4*PI*r*r));//new shell, initilize with roughly the right number of points
    JA_VirtualGrid virtual =new JA_VirtualGrid(img);
    virtual.setCenter(round(x),round(y),round(z));
        
     shellCenter.x=0;
     shellCenter.y=0;
     shellCenter.z=0;
         int totalShell=0;
     for(int k=floor(-r);k<=r;k++){
      for(int i=floor(-r);i<=r;i++){
        for(int j=floor(-r);j<=r;j++){
          float rad=i*i+j*j+k*k;//check what the sphere radius would be assuming that i,j,k are on a sphere
          if(rad>(r-.5)*(r-.5)&&rad<(r+.5)*(r+.5)){//check that our point is on the actual sphere edge
            boolean skip=false;
             for(int z=0;z<otherAreas.size();z++){//check all other spheres to not overlap direction, simply give any pixels that way 0 prob
                 
                 if(otherAreas.get(z).bestRad>dist(otherAreas.get(z).x,otherAreas.get(z).y,otherAreas.get(z).z,x+i,y+j,z+k)){
                    skip=true;
                    
                 }
              }
              if(!skip){
                 shellCenter.x+=i;
                 shellCenter.y+=j;
                 shellCenter.z+=k;
                 totalShell++;
              }
              float probT=0;
              int count=0;
              if(!skip){
                Point vec=new Point(i,j,k);
                vec.normalize();

                for(int d=0;d<=rad;d++){
                  float c=virtual.get(round(i+vec.x*d),round(j+vec.x*d),round(k+vec.x*d));
                  //println(c);
                  probT+=range(0,(c-maxThresh)/(float)(minThresh-maxThresh),1);//set the prob of this pixel
                  count++;
                }
                //println(probT/count);
              }else{
                probT=0;//0 probibility
                count=1;//not division by 0
              }
              if (count<1){
                probT=0;//0 probibility
                count=1;//not division by 0
              }
              shell.add(new Prob_Point(i,j,k,probT/count));
              
          }
        }
      }
    }
    if(totalShell==0){
      totalShell=1; 
    }
    shellCenter.x/=(float)totalShell;
    shellCenter.y/=(float)totalShell;
    shellCenter.z/=(float)totalShell;
    //shellCenter.x+=x;
    //shellCenter.y+=x;
   // shellCenter.z+=x;
  }
  Point vectorizeShell(){
    float x=0,y=0,z=0;
    for(Prob_Point p : shell){
     x+=p.x*p.prob; 
     y+=p.y*p.prob; 
     z+=p.z*p.prob; 
    }
    x/=shell.size();
    y/=shell.size();
    z/=shell.size();
    println("p",x,y,z);
    x-=shellCenter.x;
    y-=shellCenter.y;
    z-=shellCenter.z;
    println("a",x,y,z);
    return (new Point(x,y,z)).normalize();
  }
  void scanSphere(EMImage img){//sets prob by scanning the grid for sphere pixels
    //xs ys and zs accound for needing a squashed sphere for layers being off
    float probTotal=0;//this is a bit odd to do, but we will "average" this later
    int total=0;


    JA_VirtualGrid virtual =new JA_VirtualGrid(img);
    virtual.setCenter(round(x),round(y),round(z));
    /*for(int k=floor(-r/zs);k<=r/zs;k++){
      for(int i=floor(-r/xs);i<=r/xs;i++){
        for(int j=floor(-r/ys);j<=r/ys;j++){
        
         
          float rad=i*i*xs*xs+j*j*ys*ys+k*k*zs*zs;//check what the sphere radius would be assuming that i,j,k are on a sphere
          if(rad>(r-.5)*(r-.5)&&rad<(r+.5)*(r+.5)){//check that our point is on the actual sphere edge


              color c=img.get(round(x+i*xs),round(y+j*ys),round(z+k*zs));
              
              probTotal+=range(0,(greyVal(c)-maxThresh)/(float)(minThresh-maxThresh),1);//this is the base line prob that the pixel being considered is
              //infact open area
              total++;
              //println(probTotal,probTotal/total);
          }
        }
      }
    }*/
    for(int k=floor(-r);k<=r;k++){
      for(int i=floor(-r);i<=r;i++){
        for(int j=floor(-r);j<=r;j++){
          float rad=i*i+j*j+k*k;//check what the sphere radius would be assuming that i,j,k are on a sphere
         
          if(rad>(r-.5)*(r-.5)&&rad<(r+.5)*(r+.5)){//check that our point is on the actual sphere edge

              float c=virtual.get(i,j,k);
              
              probTotal+=range(0,(c-maxThresh)/(float)(minThresh-maxThresh)*100,1);//this is the base line prob that the pixel being considered is
              //infact open area
              total++;
              //println(r,c,range(0,(c-maxThresh)/(float)(minThresh-maxThresh),1),probTotal/total);
              
              //println(probTotal,probTotal/total);
          }
        }
      }
    }
    //println(probTotal/total,1-1/r);
    if(probTotal/total<1-(1/r)){
      curProb-=1-(probTotal/total);
    }
    
    //probsTotal+=probTotal/total;
  }
}
class JA_ProbSpherePinned extends JA_ProbSphere{//regular sphere except the center moves on a line with the pinned edge
   float px,py,pz;//coords of the pined point, same system as x, y, z
   float lx, ly, lz;//this is the vector the line is going
   JA_ProbSpherePinned(){
     super();
     px=0;
     py=0;
     pz=0;
     lx=0;
     ly=0;
     lz=0;
   }
   JA_ProbSpherePinned(float ix, float iy, float iz){
     this();
     px=ix;
     py=iy;
     pz=iz;
  }
  void setDir(Point p){//set the line direction
    lx=p.x;ly=p.y;lz=p.z; 
  }
  void setDir(float ix,float iy,float iz){//set the line direction
    lx=ix;ly=iy;lz=iz; 
  }
  float expand(EMImage img, float ir){//expand r by ir and shift center
    getCenter(r+ir);
    return super.expand(img,ir);
  }
  
  
  Point getCenter(float r){
    x=px+lx*r;
    y=py+ly*r;//find a new center point
    z=pz+lz*r;
    
    return new Point(x,y,z);  
  }
  
  void generateProbShell(float r,ArrayList<JA_ProbSphere> otherAreas){
    getCenter(r);
    super.generateProbShell(r,otherAreas);
  }
}
class Point{
   Point(){}
   float x,y,z,r=0;//r is a cheep hack to allow for checking how long a normalized vector use to be
   Point(float ix, float iy, float iz){
    x=ix;y=iy;z=iz; 
   }
   void print(){
     println('(',x,',',y,',',z,')');
   }
   Point normalize(){
      r=sqrt(x*x+y*y+z*z);
      x=x/r;
      y=y/r;
      z=z/r;
      return this;
   }
}
class Prob_Point extends Point{
   Prob_Point(){}
   float prob;
   Prob_Point(float ix, float iy, float iz){
    super(ix,iy,iz);
   }
   Prob_Point(float ix, float iy, float iz, float ip){
    this(ix,iy,iz);
    prob=ip;
   }
}
