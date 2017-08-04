/*

*/
public static class LayerSeeded{
  public static void seedFromPrev(EMImage img){
    //img.overlay.overlay.set(img.layer,img.overlay.overlay.get(img.prevLayer).get());//simple way for debugging
    PImage minimal=img.overlay.overlay.get(img.prevLayer);
    PImage simple=minimal.get();
    for(int i =0;i<minimal.width;i++){
       for( int j=0;j<minimal.height;j++){
           int count=0;
           color c=minimal.get(i,j);
           count+=int(minimal.get(i+1,j+0)==c);
           count+=int(minimal.get(i-1,j+0)==c);
           count+=int(minimal.get(i+0,j+1)==c);
           count+=int(minimal.get(i+0,j-1)==c);
           if(count>3){
              simple.set(i,j,0);
           }
       }
    }
    img.overlay.overlay.set(img.layer,merge(simple.get(),img.overlay.overlay.get(img.layer)));
  }
  static PImage merge(PImage _1, PImage _2){
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