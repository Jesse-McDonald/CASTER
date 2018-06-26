import java.util.*;

class PNGImage{
 int width;
 int height;
 char mode;//0 decide, 1 grayscale, 2 byteArray palette, 3 shortArray palette, 4 full color
 protected byte byteArray[][];
 protected short shortArray[][];
 protected color colorArray[][];
 ArrayList<Integer> palette;
 PNGImage(){
  width=0;
  height=0;
  byteArray=null;
  shortArray=null;
  colorArray=null;
  palette=null;
 }
 PNGImage(PImage source){
   byteArray=null;
   shortArray=null;
   colorArray=null;
   palette=null;
   this.width=source.width;
   this.height=source.height;
   
    
 }

 PNGImage(String source){
   this(loadImage(source)); 
 }

 void genPalette(PImage source,int forceGray){//this can not be called from the constructor or other threads will block for this rather long process
   if(forceGray!=0){
      mode=1;
  
      byteArray=new byte[this.width][this.height];
   
        for(int y=0;y<this.height;y++){
           for(int x=0;x<this.width;x++){
             color c=source.get(x,y);
           byteArray[x][y]=byte(round((red(c)+green(c)+blue(c))/3));
    
        }   
      }

   }else{
     

    palette=new ArrayList<Integer>();
    colorArray=new color[this.width][this.height];
    HashMap<Integer,Integer> paletteMap=new HashMap<Integer,Integer>();
    for(int x=0;x<this.width;x++){
        for(int y=0;y<this.height;y++){
          color c=source.get(x,y);
          if(paletteMap.containsKey(c)){
            colorArray[x][y]=paletteMap.get(c);
          }else{
            colorArray[x][y]=palette.size();
            paletteMap.put(c,palette.size());
            palette.add(source.get(x,y));
          }  
        }   
     }
     boolean bAndW=true;
     for(int i =0;i<palette.size();i++){
       if(!(red(palette.get(i))==green(palette.get(i))&&red(palette.get(i))==blue(palette.get(i)))){
         bAndW=false;
         break;
       }
     }
     if(bAndW){
       mode=1;
       byteArray=new byte[this.width][this.height];
       for(int x=0;x<this.width;x++){
        for(int y=0;y<this.height;y++){
          byteArray[x][y]=byte(round((red(source.get(x,y))+green(source.get(x,y))+blue(source.get(x,y)))/3.0));
        }
       }
       colorArray=null;
       palette=null;
     }else if(palette.size()<256){
       mode=2;
       byteArray=new byte[this.width][this.height];
       for(int x=0;x<this.width;x++){
        for(int y=0;y<this.height;y++){
          byteArray[x][y]=byte(colorArray[x][y]);
        }
       }
       colorArray=null;
     }else if(palette.size()< 65536){
       mode=3;
       shortArray=new short[this.width][this.height];
       for(int x=0;x<this.width;x++){
        for(int y=0;y<this.height;y++){
          shortArray[x][y]=(short)colorArray[x][y];
        }
       }
       colorArray=null;
     }else{
       mode=4;
       for(int x=0;x<this.width;x++){
        for(int y=0;y<this.height;y++){
          colorArray[x][y]=palette.get(colorArray[x][y]);
        }
       }
       palette=null;
     }
    }
 }
 color get(int x,int y){
   
   if(x<0||y<0||x>=width||y>=height){
     return 0;
   }
   if(mode==1){
     return (0xff<<24)+((byteArray[x][y])<<16)  +((byteArray[x][y])<<8)  +(byteArray[x][y]);
   }else if(mode==2){
     return palette.get(byteArray[x][y]&0xFF);
   }else if(mode==3){
     return palette.get(shortArray[x][y]&0xFFFF);
   }else if(mode==4){
     return colorArray[x][y];
   }
   return 0;
 }

 PImage getImage(){
   PImage ret=createImage(this.width,this.height,ARGB);
   for(int x=0;x<this.width;x++){
        for(int y=0;y<this.height;y++){
          ret.set(x,y,this.get(x,y));
        }
   }
   return ret;
 }
 PNGImage draw(int x,int y){
   image(this.getImage(),x,y);
   return this;
 }
 PImage fastGet(int sX, int sY, int eX, int eY){
   int px=(eX-sX)*(eY-sY);
   int cn=ceil(sqrt(px/700000.));//if we process more than 700,000 pixles we start to lag our machines, so limit processing to a total of 700,000
   if(cn<1)cn=1;
   
   PImage ret=createImage((eX-sX+1)/cn,(eY-sY+1)/cn,ARGB);

        for(int y=0;y<eY-sY+1;y+=cn){
             for(int x=0;x<eX-sX+1;x+=cn){//x inc is better for speed... I think
          ret.set(x/cn,y/cn,this.get(x+sX,y+sY));
        }
   }
   return ret;
 }
 PImage primeImage(){
   return createImage(this.width,this.height,ARGB);
 }
 PImage getImageRow(int i, PImage temp){
   for(int j=0;j<this.width;j++){
     
     temp.pixels[i*temp.width+j]=get(j,i);
   }
   return temp;
 }
}

class PNGThread extends Thread{
  PImage retv;
  PNGImage in;
  PImage temp;
  boolean terminate=false;
  boolean alive=false;
  void run(){
    alive=true;
    temp=in.primeImage();
    temp.loadPixels();
    for (int i=0;i<temp.height&&!terminate;i++){
      temp=in.getImageRow(i,temp);

    }
    temp.updatePixels();
    retv=temp;
    alive=false;
  }
  
 PImage merge(PImage _1, PImage _2){
    PImage ret=_1.get(); 
    ret.loadPixels();
    _2.loadPixels();
    for(int i =0;i<ret.pixels.length;i++){
         if(_2.pixels[i]!=0){
           ret.pixels[i]=_2.pixels[i];
         }
        
     }
     ret.updatePixels();
    return ret;
  }
  
}