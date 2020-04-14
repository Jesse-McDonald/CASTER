import java.util.concurrent.ConcurrentHashMap;//man I miss c++ where I can just use a regular datastructure from 2 threads with limited problems
class PriorityStack{
  ConcurrentHashMap<Integer,PImage> cached;
  ConcurrentHashMap<Integer,PNGImage> loaded;
  Object layerChange;//apparently Java can just bind a semaphore like object to any object, so this acts like a semaphore
  Integer cacheReserved;//because the loader loads first to PImage and then to PNGImage, 1 slot in the cache can not be deleated if it is out of range
  File[] files;
  PriorityStackLoader loader;
  PriorityStackManager manager;
  PImage fastCache;//for the emergency "oh no we need this layer NOW" moments
  int maxLoaded;
  int maxCached;
  String extension="";
  int currentLayer=0;
  int lastLayer=0;
  Pixel lastStart,lastEnd;
  PriorityStack(){
    this(10,100); 
  }
  PriorityStack(int imaxCached, int imaxLoaded){
    layerChange=new Object();
    maxLoaded=imaxLoaded;
    maxCached=imaxCached;
    if(maxLoaded<2){
      maxLoaded=2;
    }
    if(maxCached<2){//minimum cached is 2 because 1 image is the active layer, and 1 is reserved for loading
      maxCached=2; 
    }
    loaded=new ConcurrentHashMap<Integer,PNGImage>();
    cached=new ConcurrentHashMap<Integer,PImage>();
    loader=new PriorityStackLoader(this);
    manager=new PriorityStackManager(this);
    lastStart=new Pixel(0,0,0);
    lastEnd=lastStart;

  }
  void activateManagers(){
    loader.start();
    manager.start(); 
  }

  void loadStack(File[] inFiles){
    files=inFiles;
  }
  PriorityStack draw(EMImage p,Pixel p0, Pixel pe){
    boolean forceCache=false;//this overrides p0 and pe calculation for calling fast cache if we change layers
    if(p.layer!=lastLayer){
      changeLayer(p.layer); 
      forceCache=true;
    }
    if(cached.containsKey(currentLayer)){//we have the layer cached, draw it
      PImage tmp=cached.get(currentLayer);
      image(tmp,p.offsetX, p.offsetY, tmp.width*p.zoom, tmp.height*p.zoom);
    }else{//we have to use fast cache
      if(loaded.containsKey(currentLayer)){//is the image loaded? good, fast cache
        if(forceCache||p0.x!=lastStart.x||p0.y!=lastStart.y||pe.x!=lastEnd.x||pe.y!=lastEnd.y){
          
          fastCache=loaded.get(currentLayer).fastGet(p0.x,p0.y,pe.x,pe.y);
    
        }
        image(fastCache,p.offsetX, p.offsetY, p.img.width*p.zoom, p.img.height*p.zoom);
        //image(temp,p.offsetX+p0.x*p.zoom+p.meta.get(p.layer).offsetX*p.zoom+.5,p.offsetY+p0.y*p.zoom+p.meta.get(p.layer).offsetY*p.zoom+.5,(pe.x-p0.x+1)*p.zoom,(pe.y-p0.y+1)*p.zoom);//this line took a loooooooot of trial an error, trust that it is right
        //never the less, it is off by less than 1 screen pixel).... not sure how to fix it
        lastStart=p0;
        lastEnd=pe;
      }else{//notify user that image is not loaded while image is fetched
        background(0);
        fill(255);
        textSize(25);
        textAlign(CENTER);
        String msg="This layer is not currently loaded\nIf this message persists for more than a few seconds, please check that\n"+files[currentLayer].getPath()+"\nexists and is a valid .png file" ;
        text(msg,width/2,height/2);

      }
     
    }
    
    lastLayer=p.layer;
    return this;
  }
  PImage get(int layer){//retrive an image from the stack (bypass queue)
    PImage ret;
    if(cached.containsKey(layer)){
      ret=cached.get(layer);
    }else if(loaded.containsKey(layer)){
      ret=loaded.get(layer).getImage();
    }else if(layer>0&&layer<files.length){
      ret=load(files[layer]);
    }else{
      ret=createImage(0,0,0);
    }
    return ret;
  }
  
  PImage load(File file){
        
   if (file.isFile()) {
      if (file.getName().contains(extension)){//only attempt to load a file if the file types match existing
        return loadImage(file.getPath());
      }
      
    }
    return null;
    
  }
  PriorityStack cache(int layer, PImage in){
    cached.put(layer,in);
    PNGImage tempPng=new PNGImage(in);
    tempPng.genPalette(in,1);
    loaded.put(layer,tempPng);
    return this;
  }
  PriorityStack changeLayer(int layer){
    currentLayer=layer;
    synchronized(layerChange){//this is java magic that causes a change in layer to wake the manager threads
          layerChange.notifyAll();
    }
    return this;
  }
  PriorityStack cache(int layer, PNGImage in){
    loaded.put(layer,in);
    return this;
  }
  color get(int x, int y){//retrive a pixel from current layer
    return get(currentLayer,x,y);
  }
  color get(int layer, int x, int y){//retrive a pixel from any layer
    color ret;
    if(cached.containsKey(layer)){
      ret=cached.get(layer).get(x,y);
    }else if(loaded.containsKey(layer)){
      ret=loaded.get(layer).get(x,y);
    }else if(layer>0&&layer<files.length){
      ret=load(files[layer]).get(x,y);
    }else{
      ret=0;
    }
    return ret;
  }
}

class PriorityStackLoader extends Thread{
  PriorityStack parent;
  boolean stop;
  PriorityStackLoader(PriorityStack iparent){
    parent=iparent; 
  }
  void run(){
    stop=false;
    int layer=-1;
    int layerIttr=1;
    while(!stop){
      boolean noChange=true;
      if(layer!=parent.currentLayer){
         layer=parent.currentLayer;
         layerIttr=1;
      }
      if(parent.loaded.size()>parent.maxLoaded){//time to start removing extras
        noChange=false;
        for(Integer k : parent.loaded.keySet()){
          if(abs(k-layer)>parent.maxLoaded){//key is out of range of layer, so remove it
            parent.loaded.remove(k);
          }
        }
      }
      if(parent.loaded.size()>parent.maxLoaded){//if its still too full, take a more agressive pass
        noChange=false;
        for(Integer k : parent.loaded.keySet()){
          if(abs(k-layer)>parent.maxLoaded/2){//key is out of range of layer, so remove it
            parent.loaded.remove(k);
          }
        }
      }
      if(layerIttr<=parent.maxLoaded){//is there actualy room to load? 
        noChange=false;//we may not actualy make a change, but we could have, so we did
        int index=layer+layerIttr/2*(layerIttr%2*2-1);//in theory this should oscelate arround layer (ie if layer is 10, the sequence is 10,11,9,12,8,13,7,14...)
        if(index<0){//we dont want negative layers, if we do get any, realocate those loads to further out + numbers
         index=index+parent.maxLoaded;
        }
        if(index>=parent.files.length){

           continue;//we are past the edge of the stack, it is time to stop trying to load

        }
        if(!parent.loaded.containsKey(index)){
          parent.cacheReserved=index;//reserve PImage, even if it does not exist
          if(!parent.cached.containsKey(index)){//it didnt exist, load from hdd
          
            PImage tmp=parent.load(parent.files[index]);
            if(tmp!=null){
              parent.cached.put(index,tmp);
            }
          }
          //regardless of if the PImage used to exist, it does now, PNGImage it
          PNGImage tempPng=new PNGImage(parent.cached.get(index));
          tempPng.genPalette(parent.cached.get(index),1);
          parent.loaded.put(index,tempPng);
          synchronized(parent.layerChange){//as a courtisy we should tell the manager thread that there may be work to do in the cache
            parent.layerChange.notifyAll();
          }
        }
        layerIttr++;
      }

      if(noChange){//no change was even attempted, it is time to sleep untill the layer is next changed
        layerIttr=1;
        synchronized(parent.layerChange){//this is java magic that will make a thread wait untill it is notified to start again
          try {
            parent.layerChange.wait();
          } catch(InterruptedException e) {
          
          }
        }
      }
    }
  }
}
class PriorityStackManager extends Thread{
  PriorityStack parent;
  boolean stop;
  PriorityStackManager(PriorityStack iparent){
    parent=iparent; 
  }
    void run(){
    stop=false;
    int layer=-1;
    int layerIttr=1;
    while(!stop){
      boolean noChange=true;
      if(layer!=parent.currentLayer){
         layer=parent.currentLayer;
         layerIttr=1;
      }
      if(parent.cached.size()>parent.maxCached){//time to start removing extras
        noChange=false;
        for(Integer k : parent.cached.keySet()){
          if(layer!=parent.cacheReserved&&abs(k-layer)>parent.maxCached){//key is out of range of layer, so remove it

            parent.cached.remove(k);
          }
        }
      }
      if(parent.cached.size()>parent.maxCached){//if its still too full, take a more agressive pass
        noChange=false;
        for(Integer k : parent.cached.keySet()){
          if(layer!=parent.cacheReserved&&abs(k-layer)>=parent.maxCached/2){//key is out of range of layer, so remove it
 
            parent.cached.remove(k);
          }
        }
      }
      if(layerIttr<=parent.maxCached){//is there actualy room to load? 
        noChange=false;//we may not actualy make a change, but we could have, so we did
        int index=layer+layerIttr/2*(layerIttr%2*2-1);//in theory this should oscillate arround layer (ie if layer is 10, the sequence is 10,11,9,12,8,13,7,14...)
        if(index<0){//we dont want negative layers, if we do get any, realocate those loads to further out + numbers
         index=index+parent.maxCached;
        }
        
        if(!parent.cached.containsKey(index)){//we need to cache the layer
          if(parent.loaded.containsKey(index)){//if loaded does not have it skip, loading caches the image anyway so it will get cached

            parent.cached.put(index,parent.loaded.get(index).getImage());
          }
        }
        layerIttr++;
      }

      if(noChange){//no change was even attempted, it is time to sleep untill the layer is next changed
          layerIttr=1;//since no change was made, reset the layer itterator incase we skipped an unloaded layer
          synchronized(parent.layerChange){//this is java magic that will make a thread wait untill it is notified to start again
            try {

              parent.layerChange.wait();
            } catch(InterruptedException e) {
            
            }
          }
      }
    }
  }
}
