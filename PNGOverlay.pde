
class PNGOverlay extends PNGImage{
 HashMap<Integer,Integer> paletteMap;
 PNGOverlay(int w, int h){
   width=w;
   height=h;
   palette=new ArrayList<Integer>();
   paletteMap=new HashMap<Integer,Integer>();
   mode=2;
 }
 PNGOverlay(int w, int h, ArrayList<Integer> p, HashMap<Integer,Integer> pM){
   this(w,h);
   palette=p;
   paletteMap=pM;
   if(palette.size()<256){
     mode=2;
     byteArray=new byte[this.width][this.height];
   }else if(palette.size()< 65536){
     mode=3;
     shortArray=new short[this.width][this.height];
   }else{//hopefully we dont get here
     mode=4;
     colorArray=new int[this.width][this.height];
     palette=null;
   }
 }
 PNGOverlay set(int x, int y, color c){
   if(x<0||y<0||x>width||y>height){return this;}//handle x and y out of range
   if(mode==4){
     colorArray[x][y]=c;
   }else{ 
     if(!paletteMap.containsKey(c)){
       if(mode==1){
         mode=2; 
         palette=new ArrayList<Integer>();
         paletteMap=new HashMap<Integer,Integer>();
       }
       palette.add(c);
       paletteMap.put(c,palette.size()-1);
       if(mode==2&&palette.size()>255){
         mode=3;
         shortArray=new short[this.width][this.height];
         for(int j=0;j<this.height;j++){
           for(int i=0;i<this.width;i++){
             shortArray[i][j]=(short)(byteArray[i][j]&0xFF); 
           }
         }
         byteArray=null;
         
       }else if(mode==3&&palette.size()>65536){
         mode=4;
         colorArray=new int[this.width][this.height];
         for(int j=0;j<this.height;j++){
           for(int i=0;i<this.width;i++){
             colorArray[i][j]=palette.get(shortArray[i][j]&0xFFFF); 
           }
         }
         shortArray=null;
         palette=null;
       }
     }
     if(mode==1){
        //PNG overlay does not support mode 1,
        System.err.println("Png Overlay does not support mode 1\n If you are not a dev contact us and tell us how you got this error");
     }else if(mode==2){
        byteArray[x][y]=paletteMap.get(c).byteValue();;
     }else if(mode==3){
        shortArray[x][y]=paletteMap.get(c).shortValue();
     }
   }
   return this;
 }
 PNGOverlay merge(PNGOverlay other){
   for(int j=0;j<min(this.height,other.height);j++){
     for(int i=0;i<min(this.width,other.width);i++){
       if(this.get(i,j)==0){
         this.set(i,j,other.get(i,j));
       }
     }
   }
   return this;
 }
  PNGOverlay get(){
   PNGOverlay ret=new PNGOverlay(width,height,palette,paletteMap);
   ret.byteArray=byteArray.clone();
   ret.colorArray=colorArray.clone();
   ret.shortArray=shortArray.clone();
   ret.mode=mode;
   return ret;
 }
  
}