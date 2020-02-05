class ColorPickerPointer{
  PImage picker;
  PImage map;
  PImage mask;
  color maskColor; 
  ColorPickerPointer(){
      picker=loadImage("ui/picker.png");
      mask=loadImage("ui/pickerMap.png");
      map=createImage(mask.width,mask.height,ARGB);
  }
  ColorPickerPointer draw(float x, float y){
    image(map,x,y-mask.height);
    image(picker,x,y-picker.height);
    return this;
  }
  ColorPickerPointer updateMask(color c){
    if(maskColor !=c){
       maskColor=c;
       map.loadPixels();
       mask.loadPixels();
       for(int i=0;i<map.pixels.length;i++){
         if(mask.pixels[i]==tColor(255,255,255)){
           map.pixels[i]=c;
         }
       }
       map.updatePixels();
    }
    return this;
  }
}
