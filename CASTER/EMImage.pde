import java.io.*;
import java.nio.ByteBuffer;
/**
EMImage is a master class to coordinate the actions of EMStack, EMOverlay, and Brush
it is designed to have a single global instance of its self called img //TODO: remove this//, some of the sub classes depend heavily on this master object
EMImage depends on having access to int width, int height, int depth void draw(int layer, float offsetX, float offsetY, float scaleX, float scaleY), and color get(int layer, int x, int y) from EMStack
EMOverlay(int width, int height, int depth), void load(InputStream), and void save(OutputStream) from EMOverlay
Brush(color c), void draw(EMImage this),and ArrayList<Pixel> floodFillBackup from Brush
Pixel(int x, int y, int c) from Pixel
float range(float, float, float) from global
EMOverlay depends on int width, int height, color(int red, int green, int blue, int alpha), and color from processing 
*/
class EMImage {
	public Brush brush;//drawning brush object
	private EMStack img;//EM scan stack
	private float offsetX=00;//screen offset
	private float offsetY=00;
	private float zoom=1;//screen zooom
	public EMOverlay overlay;//overlay images
	public int layer;//layer in overlay and img
  public int prevLayer;
 public byte[] uuid;
  public EMProject project;
  boolean saving;//project is currently saving
  SaveThread saveThread;
	public EMImage() {
		project=new EMProject();
    uuid=project.uuid;
    layer=0;
    prevLayer=0;
		changeStack(new EMStack());
//set brush color
//		brush=new Brush(color(255, 0, 0, 50),this,9);//create generic brush
      //brush=new Brush(color(0, 255, 0, 75),this,9);//color blind mode
      brush=new Brush(color(26, 140, 255, 75),this,9);//color blind mode
    
		this.update();//call update... apparently update does not actually do anything right now..... not sure what it was going to do	
  }
  EMImage changeStack(EMStack stack){
    img=stack;
    uuid=project.uuid;
    overlay=img.overlay;
    overlay.uuid=uuid;
    project.path="";
    return this;
  }
  EMImage undo(){
    brush.eStop();//we need this to be safe, just imagin undoing a floodfill and it keeps going after the undo
    overlay.undo(this);
    return this;
  }
  EMImage redo(){
    brush.eStop();
    overlay.redo(this);
    return this;
  }
  EMImage snap(){
   overlay.pushHistory(layer);
   return this;
  }
  public EMImage draw(PApplet screen){
    if(img.size()>0){
      Pixel p0=getPixel(0,0);
      Pixel pe=getPixel(screen.width,screen.height);

      img.draw(this,p0,pe);
      overlay.draw(this,p0,pe);
      //overlay.draw(layer, offsetX+meta.get(layer).offsetX*zoom, offsetY+meta.get(layer).offsetY*zoom, img.width*zoom, img.height*zoom);//draw the overlay OVER that
      brush.draw();//draw the brush on top
    }
    
    if(saving){//display saving text
       screen.textSize(20);
       screen.fill(100,120,250);
       screen.text("Saving",10,30);
    }
    return this;
  }
	public EMImage draw() {//is this function even used anymore? I think it has been replaced by above
    if(img.size()>0){
      img.draw(layer, offsetX, offsetY, img.width*zoom, img.height*zoom);//draw the image stack 
  		overlay.draw(layer, offsetX, offsetY, img.width*zoom, img.height*zoom);//draw the overlay OVER that
  		brush.draw();//draw the brush on top
  

    }

  	return this.update();//again, why update?
    
	}
	
	public EMImage move(float x, float y) {
		//calculate the offset allowing for a 10 pixel allowance adjusted by zoom
		offsetX=range(width-10*zoom, offsetX+x, 10*zoom-img.width*zoom);
		offsetY=range(height-10*zoom, offsetY+y, 10*zoom-img.height*zoom);
		return this.update();//not sure what I planned for update
	}
	
	public EMImage zoom(float fac) {
		float oldZ=zoom;
		zoom+=(fac)*zoom*.01;
		//adjust offset so center pixel does not move
		//to do this find the edge of the image's offset from the center of the screen
		//then divide it by the original zoom and multiply by the new zoom
		//this gives you current offset from center so add it to the center 
		//and you have the offset
		//then apply the range function for safety
		offsetX=width/2+(offsetX-width/2)/oldZ*zoom;
		offsetY=height/2+(offsetY-height/2)/oldZ*zoom;
		return this.update();//but its here again
	}
	
	public EMImage SetZoom(float zoomTo) {
		return this.zoom(zoomTo-zoom);//untested, hopefully unused, but you never know, so I am including it
	}
	
	public EMImage SetOffset(float x, float y) {
		return this.move(offsetX-x, offsetY-y);//untested, hopefully unused, but you never know, so I am including it
	}
	
	public float getZoom() {
		return zoom;//setting zoom directly would be problematic so it needed to be private, hence a getter
	}
	
	public EMImage update() {
		//... apparently this stub... is just a stub... yah... I don’t know what i was planning to put here so I will probably remove it unless I remember
		return this;
	}
	
	public Pixel getPixel(int screenX, int screenY) {//gets the img pixel at a screen cord
		int x, y;
		color c;

		x=int((screenX-offsetX)/zoom);//+meta.get(layer).offsetX;
		y=int((screenY-offsetY)/zoom);//+meta.get(layer).offsetY;
		c=img.get(layer, x, y);
		return new Pixel(x, y, c);
	}
	public int size(){
    return img.size();
  }
	public Pixel get(int x, int y) {//just an obfuscation of img.img.get(...) to img.get(...)
		color c;
		c=img.get(layer, x, y);
		return new Pixel(x, y, c);
	}
		
	public EMImage changeLayer(float direction){//changes the current layer, designed for a mouse wheel, expects a signed input so as to decide which direction to go
		brush.eStop();
		if (direction>0){//I could probiably optimize this, but with the number of layer changes being so low.... why bother
      prevLayer=layer;//do this inside the if so it does not accidentally trigger
			layer=min(img.depth-1,layer+1);
		}else if (direction<0){
      prevLayer=layer;
			layer=max(0,layer-1);
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
  public byte[] wrapLong(long toWrap){//I dont know that writing longs does not work, but at this point I dont trust it
    ByteBuffer temp = ByteBuffer.allocate(8);
    temp.putLong(toWrap);//convert int to ByteBuffer
    byte[] conv=new byte[4];//integers are generally 4 bytes, and if that changes for some reason, the file type still thinks ints are 4 bytes so this is constant
    for(int i=0;i<4;i++){//convert ByteBuffer to byte[] (Since for some reason ByteBuffer does not have a .getBytes or similar)
      conv[i]=temp.get(i);
    }
    return conv;
  }
  public boolean saveProject(String file){
    boolean ret=false;
    project.height=img.height;
    project.width=img.width;
    uuid=project.uuid;
    if(img.img.size()>0){
      project.stackTopHash=this.img.img.get(0).hashCode();
    }
    if(!file.equals("")){
      project.path=file; 
    }
    project.save();
    
    return ret;
  }
	public boolean saveOverlay(File fileName){//saves current layout to JEMO format
    return saveOverlay(fileName.getAbsolutePath());
  }
  public boolean saveOverlay(String path){
    if(saving){
      return false;
    }else{
      saveThread=new SaveThread(path);
      saveThread.start();
    }
      
      
    return true;

	}
	class SaveThread extends Thread{
    String path;
    SaveThread(String inPath){
      path=inPath; 
    }
    public void run(){
      saving=true;
    File fileName;
    int dot=path.lastIndexOf('.');
    String ext="";
    if(dot>=0){
      ext=path.substring(dot ,path.length()).toLowerCase();
    }
    if(!ext.equals(".jemo")){
        path+=".jemo";
    }
    
    project.lastOverlay=path;
    fileName=new File(path);
    try{
      OutputStream file= new BufferedOutputStream(new FileOutputStream(fileName));
      file.write('J'); //setup header
      file.write('E');
      file.write('M');
      file.write('O');
      file.write(1);//write the version number for the file type
      file.write(uuid);
      file.write(wrapInt(layer));//write current active layer, I threw this in because I think when I load an overlay I would want to snap to the last position
      overlay.save(file);//turn the saving over to EMOverlay, we expect it to not close the file
      file.flush();
      file.close();
    }catch(IOException ex){
      saving=false;
    }
    autoSave();
    saving=false;
    }
  }
  public boolean loadOverlay(String filename){
   return loadOverlay(new File(filename)); 
  }
	public boolean loadOverlay(File fileName){//load JEMO file to overlay, replaces overlay

		try{
			InputStream file = new BufferedInputStream(new FileInputStream(fileName));
			byte[] byte4=new byte[4];
			file.read(byte4);
			String var=new String(byte4);//read and test header
      byte ver;//get version number
      ver=(byte)file.read();
			if(!var.equals("JEMO")){
				println("Invalid file type");
				file.close();
				return false;

			}
      if(ver<1){
        println("file version no longer suported, min supported version:1");
        file.close();
        return false;
      }
      if(ver>1){
        println("file version not yet suported, max supported version:1");
        file.close();
        return false;
      }
      //read and check uuid here
      if(ver==1){
        byte[] byte16=new byte[16];
        file.read(byte16);
        overlay.uuid=byte16;

        for(int i=0;i<16;i++){
           if(uuid[i]!=byte16[i]){
             //warn()
             //println(project.uuid[i]+" "+byte16[i]);
             println("Warning, this file was saved from a different project");
            break;
           }
        }
        
        file.read(byte4);
  			int tLayer=min(ByteBuffer.wrap(byte4).getInt(),img.depth-1);//it is very important we don’t change layer yet, processing multithreads
  			//file io, so this may running parallel to draw, if we change the layer now there is a very good chance we switch to that layer in the overlay
  			//before it exists and we don’t want that
  			overlay.load(file);//pass loading to EMOverlay
        
        if(tLayer<img.depth){//only move if the stack is loaded there too
  			  layer=tLayer;//ok, now that overlay is fully loaded we can safely change layers to the proper layer
        }
  			file.close();
  			}  
      }
  		catch(IOException ex){
  			println(ex);
  			println("exception"+ex);
  			return false; 
  		}
      project.lastOverlay=fileName.getAbsolutePath();
      autoSave();
  		return true;
   
	}  
  int screenX(Pixel p){
    return round((p.x)*zoom+offsetX+zoom/2.);
  }
  int screenY(Pixel p){
    return round((p.y)*zoom+offsetY+zoom/2.);
  }
  float greyVal(color c){//this averages the RGB values of a given color to determine its grayscale value
    return ((c >> 16 & 0xFF) + (c >> 8 & 0xFF) + (c & 0xFF))/3.0;//extract and average rgb values
  }
  /*land mark alignment no longer supported, use TrackEM
  public EMImage alignLandmarks(int size){return alignLandmarks(size,1);}//because FRIKING JAVA DOES NOT ALLOW DEFAULT ARGUMENTS!!!
  
  public EMImage alignLandmarks(int size, int startLayer){//size is how large of a shift should be considered for a alignment
    for(int l=min(1,startLayer);l<img.depth;l++){
      float bestVal=Float.MAX_VALUE;//large start-
      EMMeta bestPos=new EMMeta();//track the meta of the best spot
      for(int x=-size; x<size;x++){
        for(int y=-size; y<size;y++){
          //println("("+x+","+y+")");//debug line
          float value=0;
          meta.get(l).offsetX=0;
          meta.get(l).offsetY=0;
          for(int i=size;i<img.width-size;i++){
            for (int j=size;j<img.height-size;j++){//5 nested for loops? man I feel bad
              float base =greyVal(img.get(l,x+i,y+j));
              float next=greyVal(img.get(l-1,i,j));//calculate how well the entire image matches to the previous layer
              value+=abs(base-next)/255;
              
            }
          }
          //println(value);
          if(value<bestVal){
            bestVal=value;//check if this shift is better or not
            bestPos.offsetX=-x;
            bestPos.offsetY=-y;
          }
        }
      }
      meta.get(l).offsetX=bestPos.offsetX;
      meta.get(l).offsetY=bestPos.offsetY;
      //println("best ("+bestPos.offsetX+","+bestPos.offsetY+")");
    }
    return this;
  }
*/
}
