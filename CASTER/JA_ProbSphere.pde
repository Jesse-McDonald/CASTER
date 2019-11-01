
class JA_ProbSphere{
  float x, y, z;//sphere center
  //x and y are in pixels from top left
  //z is layers from layer 0
  float r;//sphere radius
  float xs=1,ys=1,zs=1;//pixel scale
  float curProb;//probibility that sphere is inside axon
  float probsTotal;//sum up total of all probs so we can average them for current Prob
  HashMap<Float, Float> probs;//list of radius and corisponding prob
  float minThresh=255;//colors lighter than this are 0% edge
  float maxThresh=0;//colors darker than this are 100% edge
  JA_ProbSphere(){
    r=0;
    x=0;
    y=0;
    z=0;
    curProb=1;
    probs=new HashMap<Float, Float>();
  }
  JA_ProbSphere(float ix, float iy, float iz){
     this();
     x=ix;
     y=iy;
     z=iz;
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
    curProb=probsTotal/probs.size();
    probs.put(r,curProb);
    return curProb;
  }
  void retotal(){
    probsTotal=0;
    for(Float key: probs.keySet()){
      probsTotal+=probs.get(key);
    }
  }
  void scanSphere(EMImage img){//sets prob by scanning the grid for sphere pixels
    //xs ys and zs accound for needing a squashed sphere for layers being off
    float probTotal=0;//this is a bit odd to do, but we will "average" this later
    int total=0;
    for(int i=floor(-r/xs);i<=r/xs;i++){
      for(int j=floor(-r/ys);j<=r/ys;j++){
        for(int k=floor(-r/zs);k<=r/zs;k++){
          total++;
          float rad=i*i*xs*xs+j*j*ys*ys+k*k*zs*zs;//check what the sphere radius would be assuming that i,j,k are on a sphere
          if(rad<(r-.5)*(r-.5)&&rad>(r+.5)*(r+.5)){//check that our point is on the actual sphere edge
              color c=img.get(round(x+i*xs),round(y+j*ys),round(z+k*zs));
              probTotal+=range(0,maxThresh-greyVal(c),1);//this is the base line prob that the pixel being considered is
              //infact open area
              
          }
        }
      }
    }
    probsTotal+=probTotal/total;
  }
}
class JA_ProbSpherePinned extends JA_ProbSphere{//regular sphere except the center moves on a line with the pinned edge
   float px,py,pz;//coords of the pined point, same system as x, y, z
   float lx, ly, lz;//this is the vector the line is going
   JA_ProbSpherePinned(){super();}
   JA_ProbSpherePinned(float ix, float iy, float iz){
     this();
     px=ix;
     py=iy;
     pz=iz;
  }
  void setDir(float ix,float iy,float iz){//set the line direction
    lx=ix;ly=iy;lz=iz; 
  }
  float expand(EMImage img, float ir){//expand r by ir and shift center
    r=r+ir;//make sphere larger
    
    x=px+lx*r;
    y=py+ly*r;//find a new center point
    z=pz+lz*r;
    
    scanSphere(img);
    curProb=probsTotal/probs.size();
    probs.put(r,curProb);
    return curProb;
  }
}
