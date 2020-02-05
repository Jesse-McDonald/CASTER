import java.nio.ByteBuffer;
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
 PNGOverlay set(long index,color c){
   return set(int(index%width),int(index/width),c); 
 }
 PNGOverlay set(int x, int y, color c){
   if(x<0||y<0||x>=width||y>=height){return this;}//handle x and y out of range
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
 public byte[] wrapNByte(long toWrap,int n){//a method that wraps n bytes of a long in a byte[]
    ByteBuffer temp = ByteBuffer.allocate(8);//a long is 8 bytes, we wrap it all to start with
    temp.putLong(toWrap);//convert int to ByteBuffer
    byte[] conv=new byte[n];
    for(int i=0;i<n;i++){//copy last n bytes
      conv[i]=temp.get((8-n)+i);
    }
    return conv;
  }
 int unwrapNBytes(byte[] unwrap){
   int ret=0;
   for(int i=0;i<unwrap.length;i++){
     ret=ret<<8;
     ret+=(unwrap[i]&0xff);
   }

   return ret;
 }
 boolean fromJEMOv1(int colorSize, InputStream file) throws IOException{
   boolean fileTerminator=false;
   byte[] byte4=new byte[4];
   byte[] byteC=new byte[colorSize];
   byte[] byte2=new byte[2];
   file.read(byte4);
   long index=(ByteBuffer.wrap(byte4).getInt()&0x00000000ffffffffL);
   if(index==0){
     fileTerminator=true;
   }
   boolean run=true;
   while(run){
     file.read(byteC);
     file.read(byte2);
     color c=palette.get(unwrapNBytes(byteC));    
     int count=(ByteBuffer.wrap(byte2).getShort()&0x0000ffff);//damn it java, why do I have to do this to get an unsigned short


     if(count==0&&c==0){
       run=false; //stop when we hit the layer terminator
     }else{
       fileTerminator=false; //if we dont hit the layer terminator first try its not a file terminator
     }
     for(int i=0;i<count;i++){
       set(index,c);
       index++;
     }
    
   }
    
   return fileTerminator;//is this layer the file terminator
 }
 OutputStream toJEMOv1(int colorSize,OutputStream file) throws IOException{//we throw an exception because this is not the first step in writing and previous layers are already handeling io exceptions so I dont feel like handeling it here
  //writing good to here
   long first=-1;
   int last=0;
   int index=0;

   for(int y=0;y<height;y++){//find first and last pixel
     for(int x=0;x<width;x++){
        
        if(get(x,y)!=0){
          if(first<0){
            
            first=index;//in theory this will break if you have more than 2^16x2^16 pixel picture where the last pixel is colored.... I hope we never have that problem
          }
          last=index;
        }
        index++;
     }
   }
   //println("First passs finised");
   last++;
   if(first<0||first==last){
     byte[] scrap=new byte[colorSize+6];
     scrap[0]=1;//prevent early file termination
     file.write(scrap);
     return file;
   }
   //println("we didnt scrap");
   color c=0;
   int len=0;
   file.write(wrapNByte(first,4));
   for(long i=first;i<=last;i++){
     
     if(len>Short.MAX_VALUE*2-1||get(i)!=c||i==last ){
       if(len>0){
         

          file.write(wrapNByte(paletteMap.get(c),colorSize));//dont invert the index, both sides know that the array its self is inverted so they will invert before reading
          file.write(wrapNByte(len,2));
         len=0;
       }

       c=get(i);

     }
     len++;
   }
   file.write(new byte[colorSize+2]);//write layer terminator (oh please java auto 0 dont fail me now)
   return file;
 }
  
}
