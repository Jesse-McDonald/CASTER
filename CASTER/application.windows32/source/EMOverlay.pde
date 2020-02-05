import java.nio.ByteBuffer;
/**
EMOverlay is really an obfuscation of ArrayList<PImage> overlay built do decrease the legwork of EMImage
this class tracks the overlay array, the image width, height, and depth, it also handles drawing the overlay
and passes through some functions like get and set to the overlay, additionally EMOvelay handles file IO for its self
EMOverlay does not depend on external access to any custom classes
EMOverlay does depends on void PImage.updatePixels(), void PImage.loadPixels(), PImage.pixels, PImage PImage(int w, int h, int mode), color PImage.get(int x,int y) void PImage.set(int x,int y,color), and void image(PImage img, int x, int y, int xScale, int yScale) from Processing
color must be resolvable to int for save to work
*/
class EMOverlay{
  FBuffer<HistorySnap> history;
  HistorySnap fHistory;
  boolean logChanges=true;
	ArrayList<PNGOverlay> overlay;//PImage stack for storing the overlay
  HashMap<Integer,Integer> key;
  ArrayList<Integer> palette;
  HashMap<Integer,Integer> paletteMap;
	int width;//width of overlay, all PImages in overlay should have same width
	int height;//height of overlay, all PImages in overlay should have same width
	int depth;//number of PImages in overlay
  public byte[] uuid;
  PImage drawCache;
  PImage fastCache;
  PImage cached;
  Pixel lastStart,lastEnd;
  int lastLayer=-1;
  PNGThread pthread; //this is a c joke ;)
  //public ArrayList<EMMeta> meta;//meta data for a given layer
	EMOverlay(int w, int h, int d){
		width=w;//set width height and depth
		height=h;
		depth=0;
		overlay=new ArrayList<PNGOverlay>();
    //meta=new ArrayList<EMMeta>();
    key=new HashMap<Integer,Integer>();
    palette=new ArrayList<Integer>();
    paletteMap=new HashMap<Integer,Integer>();
    palette.add(0);
    paletteMap.put(0,0);
    cached=createImage(w,h,ARGB);
		for( int i=0;i<d;i++){
			addLayer();
		}
    pthread=new PNGThread();
    history=new FBuffer<HistorySnap>(new HistorySnap[programSettings.undoDepth]);
    fHistory=new HistorySnap();
    lastStart=new Pixel(0,0,0);
    lastEnd=lastStart;
	}
  boolean exists(int layer){
    return key.containsKey(layer); 
  }
	EMOverlay addLayer(){
    //println("adding "+width+" "+height+" image");
    //meta.add(new EMMeta());
    //overlay.add(new PImage(width,height,ARGB));//populate overlay with blank PImages//removed for keyed stack
    depth++;
    return this;
  }
	EMOverlay set(int l, int x, int y, color c){//obfuscate overlay.overlay.get(key.get(layer)).set(x,y,c) to overlay.set(layer, x, y, c)
    
    if(!key.containsKey(l)){

      overlay.add(new PNGOverlay(width,height,palette,paletteMap));//add new image to the stack and add its index to the key
      key.put(l,overlay.size()-1);
    }
    if(cached!=null){
      cached.set(x,y,c);
    }else{
      drawCache.set(x,y,c); 
    }
    
    if(logChanges){
      fHistory.log(new Pixel(x,y,overlay.get(key.get(l)).get(x,y)),c);
    }
    if(x<width||x>=0||y<height||y>=0){
		  //overlay.get(key.get(l)).set(x-meta.get(l).offsetX,y-meta.get(l).offsetY,c);
      overlay.get(key.get(l)).set(x,y,c);//we removed meta shifts from the overlay, it does not make sense for the future of this since meta is not stored in the JEMO, but the 3d visualization is only based on the JEMO so if
      //we landmark align the image and save an JEMO, then make a 3d of it, it will be shifted.  combine that with the server based landmark alignment that is planned and overlay shifting is rather hard to justify
    }
		return this;
	}
	
	color get(int l, int x,int y){//obfuscate overlay.overlay.get(layer).get(x,y) to overlay.get(layer, x, y)
    if(key.containsKey(l)){
		  //return overlay.get(key.get(l)).get(x-meta.get(l).offsetX,y-meta.get(l).offsetY); 
      return overlay.get(key.get(l)).get(x,y);//we removed meta shifts from the overlay, it does not make sense for the future of this since meta is not stored in the JEMO, but the 3d visualization is only based on the JEMO so if
      //we landmark align the image and save an JEMO, then make a 3d of it, it will be shifted.  combine that with the server based landmark alignment that is planned and overlay shifting is rather hard to justify
    }else{
     return 0; 
    }
	}
  EMOverlay pushHistory(int layer){

      if(fHistory.changed){
         history.push(fHistory); 
      }
      fHistory=new HistorySnap(layer);
      return this;    
  }
  EMOverlay undo(EMImage parrent){
    HistorySnap temp=history.top();
    history.prev();
    if(temp!=null){
      temp.undo(parrent); 
    }
    
    return this;
  }
  EMOverlay redo(EMImage parrent){
    history.next();
    HistorySnap temp=history.top();
    
    if(temp!=null){
      temp.redo(parrent); 
    }
    
    return this;
  }
	EMOverlay draw(EMImage p,Pixel p0, Pixel pe){
    boolean forceCache=false;
    if(key.containsKey(p.layer)){
        if(p.layer!=lastLayer){
          if(pthread.alive){
            pthread.terminate=true;
            try{//I hate java, if I dont want to catch an exception, dont force me to
              pthread.join();
            }catch (InterruptedException e) {
              e.printStackTrace();
           }
           
          }
          pthread=new PNGThread();
          pthread.terminate=false;
          pthread.in=overlay.get(key.get(p.layer));
          cached=null;
          
          pthread.retv=cached;
          new Thread(pthread).start();
          lastLayer=p.layer;
          forceCache=true;
          drawCache=createImage(width,height,ARGB);
          pushHistory(lastLayer);
        }
        if(cached!=null){
            if(drawCache!=null){
              cached=merge(cached,drawCache);
              drawCache=null;
            }
            //image(cached,p.offsetX+p.meta.get(p.layer).offsetX*p.zoom, p.offsetY+p.meta.get(p.layer).offsetY*p.zoom, this.width*p.zoom, this.height*p.zoom);
            image(cached,p.offsetX, p.offsetY, this.width*p.zoom, this.height*p.zoom);//we removed meta shifts from the overlay, it does not make sense for the future of this since meta is not stored in the JEMO, but the 3d visualization is only based on the JEMO so if
      //we landmark align the image and save an JEMO, then make a 3d of it, it will be shifted.  combine that with the server based landmark alignment that is planned and overlay shifting is rather hard to justify
        }else{
          if(pthread.retv!=null){
           cached=pthread.retv; 
          }
          if(p0.x!=lastStart.x||p0.y!=lastStart.y||pe.x!=lastEnd.x||pe.y!=lastEnd.y||forceCache){
            fastCache=overlay.get(key.get(p.layer)).fastGet(p0.x,p0.y,pe.x,pe.y);
            //drawCache=merge(fastCache,drawCache);
          }
          
          //this is not ideal, but it is easier than trying to merge them
          image(fastCache,p.offsetX+p.meta.get(p.layer).offsetX*p.zoom, p.offsetY+p.meta.get(p.layer).offsetY*p.zoom, this.width*p.zoom, this.height*p.zoom);
          image(drawCache,p.offsetX+p.meta.get(p.layer).offsetX*p.zoom, p.offsetY+p.meta.get(p.layer).offsetY*p.zoom, this.width*p.zoom, this.height*p.zoom);
          //image(temp,p.offsetX+p0.x*p.zoom+p.meta.get(p.layer).offsetX*p.zoom+.5,p.offsetY+p0.y*p.zoom+p.meta.get(p.layer).offsetY*p.zoom+.5,(pe.x-p0.x+1)*p.zoom,(pe.y-p0.y+1)*p.zoom);//this line took a loooooooot of trial an error, trust that it is right
          //never the less, it is off by less than 1 screen pixel).... not sure how to fix it
          lastStart=p0;
          lastEnd=pe;
          //PImage temp=overlay.get(key.get(p.layer)).fastGet(p0.x,p0.y,pe.x,pe.y);
          //image(temp,p.offsetX+p0.x*p.zoom+p.meta.get(p.layer).offsetX*p.zoom+.5,p.offsetY+p0.y*p.zoom+p.meta.get(p.layer).offsetY*p.zoom+.5,(pe.x-p0.x+1)*p.zoom,(pe.y-p0.y+1)*p.zoom);//this line took a loooooooot of trial an error, trust that it is right
          //never the less, it is off by less than 1 screen pixel).... not sure how to fix it  
        }
    }
    return this;
  }
  EMOverlay draw(int layer,float x,float y,float zX,float zY){//draw current layer
    if(key.containsKey(layer)){
      if(overlay.size()>layer){
        if(layer!=lastLayer){
          cached = overlay.get(key.get(layer)).getImage();
          lastLayer=layer;
        }
        image(cached,x,y,zX,zY);
      }
    }
    return this;
  }
 
	
	public byte[] wrapInt(int toWrap){//a method that wraps an int in a byte[] because write(int) ONLY WRITES THE LOW BYTE TO THE FILE!!!!!!!!
		ByteBuffer temp = ByteBuffer.allocate(4);
		temp.putInt(toWrap);//convert int to ByteBuffer
		byte[] conv=new byte[4];//integers are generally 4 bytes, and if that changes for some reason, the file type still thinks ints are 4 bytes so this is constant
		for(int i=0;i<4;i++){//convert ByteBuffer to byte[] (Since for some reason ByteBuffer does not have a .getBytes or similar)
			conv[i]=temp.get(i);
		}
		return conv;
	}
	//convert to JEMO v.1 major fixes needed, taken temporaroly off line
	EMOverlay save(OutputStream file) throws IOException{//this writes the overlay to a JEMO file

		file.write(wrapInt(width));//write width, height, and depth
		file.write(wrapInt(height));
		file.write(wrapInt(depth));
    for(int i=palette.size()-1;i>0;i--){//create pallete
      color c=palette.get(i);
      if(c==0){
        palette.remove(i);//there should be no null colors in the palette other than index 0, if there are, destroy them
      }else{
       
       file.write(wrapInt(c));//wrap the colors nice and tight in a byte array, this should be in the correct order, but there is a chance that this is in RGBA order, if it is, change the JEMO protocal to match 
      } 
    }
    file.write(wrapInt(0));//write 0x00000000, this should terminate the palette array with the null color
		int firstLayer=-1;
    int lastLayer=-1;
    for(int i=0;i<depth;i++){//find first and last layer
      if(key.containsKey(i)&&exists(i)){
        if(firstLayer<0){
          firstLayer=i;
        }
        lastLayer=i;
      } 
    }
    lastLayer++;
    file.write(wrapInt(firstLayer));
    int colorSize=ceil((log(palette.size())/log(2))/8);//calculate how many bytes are required for a layer
    for(int i=firstLayer;i<lastLayer;i++){//process layers
      
      if(key.containsKey(i)&&exists(i)){
        overlay.get(key.get(i)).toJEMOv1(colorSize,file);//write all pixels of layer i
      }else{
        byte[] scrap=new byte[colorSize+6];//get enough zeros
        scrap[0]=1;//prevent file terminating, only terminate layer
        file.write(scrap);
      } 
		}
      byte[] scrap=new byte[colorSize+6];//get enough zeros,colorSize for the color, 4 for the offset, and 2 for the length
      file.write(scrap);//terminate file
		return this;
	}
	EMOverlay set(int x, int y, color c){
    this.set(img.layer,x,y,c);
    return this;
  }
  //update to JEMO v.1
	EMOverlay load(InputStream file) throws IOException{//load overlay from JEMO file

		byte[] temp=new byte[4];
		file.read(temp);
		width=ByteBuffer.wrap(temp).getInt();//get the width, height, and depth
		file.read(temp);
		height=ByteBuffer.wrap(temp).getInt();
		file.read(temp);
		depth=ByteBuffer.wrap(temp).getInt();
		//ArrayList<PImage>tOverlay=new ArrayList<PImage>();//generate temportary overlay, safer

    key=new HashMap<Integer,Integer>();//dump old overlay and make a new one
    overlay=new ArrayList<PNGOverlay>();
    palette=new ArrayList<Integer>();
    paletteMap=new HashMap<Integer,Integer>();
    
    color c=1;
    ArrayList<Integer> inversePalette=new ArrayList<Integer>();
    while(c!=0){
      file.read(temp);
      c=ByteBuffer.wrap(temp).getInt();
      inversePalette.add(c);
    }
    for(int i=inversePalette.size()-1;i>=0;i--){
       palette.add(inversePalette.get(i));
       paletteMap.put(inversePalette.get(i),palette.size()-1);//this should work I think, but if the colors are screwed up this is probiably why
    }
    inversePalette=null;
    int colorSize=ceil((log(palette.size())/log(2))/8);//calculate how many bytes are required for a layer
    boolean run=true;
    file.read(temp);
    int layerCount=ByteBuffer.wrap(temp).getInt();
    
    
		while(run){
      
      PNGOverlay layer=new PNGOverlay(width,height,palette,paletteMap);
			run=!layer.fromJEMOv1(colorSize,file);//continue reading if not terminated
      
      if(run){
        //println("added layer at "+layerCount);
        overlay.add(layer);
        key.put(layerCount,overlay.size()-1);
      }
      layerCount++;
			//Overlay.add(fromByteArray(temp,width,height));//read all pixels of layer i
		}

    //overlay=tOverlay;
    lastLayer=-1;//reset layer cache by making the program think we just changed layers
		return this;
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
