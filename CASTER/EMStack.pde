/**
	EMStack is really an obfuscation of ArrayList<PImage> img built to decrease the legwork of EMImage
	it passes though many useful functions such as add, size, and get
	EMStack does not depend on any custom classes
	EMStack does depend on PImage, color, PImage loadImage(String path), and image(PImage img, int x, int y, int xScale, int yScale) from processing
*/
class EMStack{
	int width;//img width
	int height;//img height
	int depth;//number of images in stack 
	ArrayList<PNGImage> img;
  File[] files;
  String extension;
  int progress;
  PImage cached;
  PImage fastCache;
  Pixel lastStart,lastEnd;
  int lastLayer=-1;
  ThreadStack ts;
  PNGThread pthread; //this is a c joke ;)
  EMOverlay overlay;
  EMStack(){//new empty EMStack
		img=new ArrayList<PNGImage>();
    overlay=new EMOverlay(0, 0, 0);//create a overlay for the stack
    lastStart=new Pixel(0,0,0);
    lastEnd=lastStart;
	}
	EMStack(String dir){//new EMStack seeded from picture file by path
		this(new File(dir)); 
	}    
	int hashCode(){
    long hash=0;
    for(int i=0;i<depth;i++){
      hash+=img.get(i).hashCode();
           
    }
    //println(hash);
    //println(depth);
    return (int)hash;
  }
	EMStack(File base){//new EMStack seeded from picture file
		this();
		File folder=new File(base.getParent());//this gets the parrent folder of the given image
   extension=base.getName();//extract img type
   extension=extension.substring(extension.lastIndexOf('.'),extension.length()-1);
   files=folder.listFiles();//get all files in folder
		Arrays.sort(files);//this fixes file order on linux
    frameLoadStack();//load 1 layer so the rest of the program does not complain
  
		ts=new ThreadStack(this);//load the full dir to the stack in sepperate thread
    //new Thread(ts).start();//this line would trigger a race condition with the thread stack updating a project vs an EMImage being initilized
    pthread=new PNGThread();
    
		
		
	}
  EMStack launch(){
    new Thread(ts).start(); 
    return this;
  }
	EMStack frameLoadStack(){
    
    if(progress<files.length){
    if (files[progress].isFile()) {
      if (files[progress].getName().contains(extension)){//only attempt to load a file if the file types match existing
        //println("loading PImage");
        PImage temp=loadImage(files[progress].getPath());
        //println("Creating PNG");
        PNGImage tempPng=new PNGImage(temp);
        //println("Converting to PNG");
        tempPng.genPalette(temp,1);
        //println("adding PNG to stack");
        add(tempPng);
        //println(tempPng.hashCode());
        //println("done frame load");  
      }
    }
    
    progress++;
    this.width=img.get(0).width;
    this.height=img.get(0).height;//update width, height, and depth
    this.depth=img.size();
    //println("meta data updated");
    }
    return this;
  }
  EMStack add(PNGImage image){
    
    
   // println("updating meta");
    this.width=image.width;
    this.height=image.height;//update width, height, and depth
    overlay.height=height;
    overlay.width=width;
    
    //println("creating new overlay layer");
    overlay.addLayer();
   //println("adding image to stack");
    img.add(image);
    depth=img.size();
    //println("finished add");
    return this;
  }
	EMStack add(PImage image){//add a new image to the stack, can be dangerous if EMOverlay and meta are not updated with the additional layer
		
    //println("creating PNGImage");
    PNGImage temp=new PNGImage(image);
    //println("Converting to PNG");
    temp.genPalette(image,1);
    return add(temp);
    //println("updating meta");
	}
  EMStack draw(EMImage p,Pixel p0, Pixel pe){
    boolean forceCache=false;
    if(img.size()>p.layer){
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
        pthread.in=img.get(p.layer);
        cached=null;
        pthread.retv=cached;
        new Thread(pthread).start();
        lastLayer=p.layer;
        forceCache=true;//we have just set last layer to current layer, so any further tests of last layer in this function must rely on this instead
      }
      if(cached!=null){
          
          image(cached,p.offsetX, p.offsetY, this.width*p.zoom, this.height*p.zoom);
      }else{
        if(pthread.retv!=null){
         cached=pthread.retv; 
        }
        if(p0.x!=lastStart.x||p0.y!=lastStart.y||pe.x!=lastEnd.x||pe.y!=lastEnd.y||forceCache){
          fastCache=img.get(p.layer).fastGet(p0.x,p0.y,pe.x,pe.y);
    
        }
        image(fastCache,p.offsetX, p.offsetY, this.width*p.zoom, this.height*p.zoom);
        //image(temp,p.offsetX+p0.x*p.zoom+p.meta.get(p.layer).offsetX*p.zoom+.5,p.offsetY+p0.y*p.zoom+p.meta.get(p.layer).offsetY*p.zoom+.5,(pe.x-p0.x+1)*p.zoom,(pe.y-p0.y+1)*p.zoom);//this line took a loooooooot of trial an error, trust that it is right
        //never the less, it is off by less than 1 screen pixel).... not sure how to fix it
        lastStart=p0;
        lastEnd=pe;
      }
    }
    return this;
  }
	EMStack draw(int layer,float x,float y,float zX,float zY){//draw current layer
    
    if(img.size()>layer){
      if(layer!=lastLayer){
        cached = img.get(layer).getImage();
        lastLayer=layer;
      }
		  image(cached,x,y,zX,zY);
    }

		return this;
	}
	
	int size(){//obfiscates img.img.size() to img.size()
		return img.size();
	}
	
	color get(int layer, int x,int y){//obfuscates img.img.get(layer).get(x,y) to img.get(x,y)
    if(layer<img.size()){
		  return img.get(layer).get(x,y);
    }else{
      return 0;//if the layer is out of frame, return a 0 color
    }
	}

}
