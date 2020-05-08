class ColorPickerPointer{
  PImage picker;
  PImage map;
  PImage mask;
  color maskColor; 
  ColorPickerPointer(){
      log.start("ColorPickerPointer()");
      picker=loadImage("ui/picker.png");
      mask=loadImage("ui/pickerMap.png");
      map=createImage(mask.width,mask.height,ARGB);
      log.stop();
  }
  ColorPickerPointer draw(float x, float y){
    log.start("ColorPickerPointer.draw()");
    image(map,x,y-mask.height);
    image(picker,x,y-picker.height);
    log.stop();
    return this;
  }
  ColorPickerPointer updateMask(color c){
    log.start("ColorPickerPointer.updateMask()");
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
    log.stop();
    return this;
  }
}
