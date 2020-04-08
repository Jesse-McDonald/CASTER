class PriorityStack{
  HashMap<Integer,PImage> cached;
  HashMap<Integer,PNGImage> loaded;
  Object layerChange;//apparently Java can just bind a semaphore like object to any object, so this acts like a semaphore
  Integer cacheReserved;//because the loader loads first to PImage and then to PNGImage, 1 slot in the cache can not be deleated if it is out of range
  File[] files;
  PImage fastCache;//for the emergency "oh no we need this layer NOW" moments
  int maxLoaded;
  int maxCached;
  int currentLayer;
  PriorityStack(int imaxCached, int imaxLoaded){
    maxLoaded=imaxLoaded;
    maxCached=imaxCached;
    if(maxLoaded<2){
      maxLoaded=2;
    }
    if(maxCached<2){//minimum cached is 2 because 1 image is the active layer, and 1 is reserved for loading
      maxCached=2; 
    }
  }
  PriorityStack draw(EMImage p,Pixel p0, Pixel pe){
    
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
    
  }
  PriorityStack cache(int layer, PImage in){
    cached.put(layer,in);
    loaded.put(layer,new PNGImage(in));
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
            parent.loaded.remove(key);
          }
        }
      }
      if(parent.loaded.size()>parent.maxLoaded){//if its still too full, take a more agressive pass
        noChange=false;
        for(Integer k : parent.loaded.keySet()){
          if(abs(k-layer)>parent.maxLoaded/2){//key is out of range of layer, so remove it
            parent.loaded.remove(key);
          }
        }
      }
      if(layerIttr<=parent.maxLoaded){//is there actualy room to load? 
        noChange=false;//we may not actualy make a change, but we could have, so we did
        int index=layer+layerIttr/2*(layerIttr%2*2-1);//in theory this should oscelate arround layer (ie if layer is 10, the sequence is 10,11,9,12,8,13,7,14...)
        if(index<0){//we dont want negative layers, if we do get any, realocate those loads to further out + numbers
         index=index+parent.maxLoaded;
        }
        
        if(!parent.loaded.containsKey(index)){
          parent.cacheReserved=index;//reserve PImage, even if it does not exist
          if(!parent.cached.containsKey(index)){//it didnt exist, load from hdd
            parent.cached.put(index,parent.load(parent.files[index]));
          }
          //regardless of if the PImage used to exist, it does now, PNGImage it
          parent.loaded.put(index,new PNGImage(parent.cached.get(index)));
          synchronized(parent.layerChange){//as a courtisy we should tell the manager thread that there may be work to do in the cache
            parent.layerChange.notifyAll();
          }
        }
        layerIttr++;
      }

      if(noChange){//no change was even attempted, it is time to sleep untill the layer is next changed
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
            parent.cached.remove(key);
          }
        }
      }
      if(layer!=parent.cacheReserved&&parent.cached.size()>parent.maxCached){//if its still too full, take a more agressive pass
        noChange=false;
        for(Integer k : parent.loaded.keySet()){
          if(abs(k-layer)>=parent.maxCached/2){//key is out of range of layer, so remove it
            parent.loaded.remove(key);
          }
        }
      }
      if(layerIttr<=parent.maxCached){//is there actualy room to load? 
        noChange=false;//we may not actualy make a change, but we could have, so we did
        int index=layer+layerIttr/2*(layerIttr%2*2-1);//in theory this should oscelate arround layer (ie if layer is 10, the sequence is 10,11,9,12,8,13,7,14...)
        if(index<0){//we dont want negative layers, if we do get any, realocate those loads to further out + numbers
         index=index+parent.maxCached;
        }
        
        if(!parent.cached.containsKey(index)){//we need to cache the layer
          if(!parent.loaded.containsKey(index)){//if loaded does not have it skip, loading caches the image anyway so it will get cached
            parent.cached.put(index,parent.loaded.get(index).getImage());
          }
        }
        layerIttr++;
      }

      if(noChange){//no change was even attempted, it is time to sleep untill the layer is next changed
        
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
