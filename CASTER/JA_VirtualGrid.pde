class JA_VirtualGrid{
  EMImage img;
  int x,y,z;
  JA_VirtualGrid(EMImage image){
   img=image; 
  }
  void setCenter(int ix, int iy, int iz){
    x=ix;y=iy;z=iz;
  }
  float get(int ix,int iy,int iz){
  
    float c1=greyVal(img.get(x+ix,y+iy,floor(iz/7)+z));
    float c2=greyVal(img.get(x+ix,y+iy,ceil(iz/7)+z));

    return c1*(iz%7/7.)+c2*(7-iz%7)/7.;
  }
}
