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
	ArrayList<PImage> overlay;//PImage stack for storing the overlay
	int width;//width of overlay, all PImages in overlay should have same width
	int height;//height of overlay, all PImages in overlay should have same width
	int depth;//number of PImages in overlay
  public ArrayList<EMMeta> meta;//meta data for a given layer
	EMOverlay(int w, int h, int d){
		width=w;//set width height and depth
		height=h;
		depth=d;
		overlay=new ArrayList<PImage>();
    meta=new ArrayList<EMMeta>();
		for( int i=0;i<d;i++){
			overlay.add(new PImage(w,h,ARGB));//populate overlay with blank PImages
		}

	}
	
	EMOverlay set(int l, int x, int y, color c){//obfuscate overlay.overlay.get(layer).set(x,y,c) to overlay.set(layer, x, y, c)
		overlay.get(l).set(x-meta.get(l).offsetX,y-meta.get(l).offsetY,c);
		return this;
	}
	
	color get(int l, int x,int y){//obfuscate overlay.overlay.get(layer).get(x,y) to overlay.get(layer, x, y)
		return overlay.get(l).get(x-meta.get(l).offsetX,y-meta.get(l).offsetY); 
	}
	
	EMOverlay draw(int layer, float offsetX,float offsetY, float zX, float zY){//draw overlay to screen, should be done after the EMStack is drawn
		image(overlay.get(layer), offsetX, offsetY, zX, zY);//draw the overlay at layer, assumes layer is within bounds
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
	
	EMOverlay save(OutputStream file) throws IOException{//this writes the overlay to a JEMO file
		file.write(wrapInt(width));//write width, height, and depth
		file.write(wrapInt(height));
		file.write(wrapInt(depth));
		for(int i=0;i<depth;i++){
			file.write(toByteArray(overlay.get(i)));//write all pixels of layer i
		}
		return this;
	}
	
	EMOverlay load(InputStream file) throws IOException{//load overlay from JEMO file
		byte[] temp=new byte[4];
		file.read(temp);
		width=ByteBuffer.wrap(temp).getInt();//get the width, height, and depth
		file.read(temp);
		height=ByteBuffer.wrap(temp).getInt();
		file.read(temp);
		depth=ByteBuffer.wrap(temp).getInt();
		ArrayList<PImage>tOverlay=new ArrayList<PImage>();//generate temportary overlay, safer
		for(int i=0;i<depth;i++){
			temp =new byte[width*height*4];
			file.read(temp);
			tOverlay.add(fromByteArray(temp,width,height));//read all pixels of layer i
		}
    overlay=tOverlay;
		return this;
	}
	
	PImage fromByteArray(byte[] bytes,int w, int h){//translate a byte[] to a PImage
		PImage ret= new PImage(w,h,ARGB);
		ret.loadPixels();//prep pixels, I don’t think this is actually needed
		for(int i=0;i<w*h;i++){//note that i needs to increment by 1 for ret, but by 4 for bytes, so we do this
			ret.pixels[i]=color(bytes[4*i+1]& 0xFF,bytes[4*i+2]& 0xFF,bytes[4*i+3]& 0xFF,bytes[4*i+0]& 0xFF);//extract 4 byte color in ARGB order into a function that expects RGBA order
		}
		ret.updatePixels(); //save the updated pixels back to the image
		return ret;
	}
	
	byte[] toByteArray(PImage img){//convert PImage to byte[]
		img.loadPixels();//this one is needed to ensure latest pixels data
		byte[] ret=new byte[img.height*img.width*4];
		for(int i=0; i<img.height*img.width;i++){//go through pixel by pixel
			color c=img.pixels[i];
			ByteBuffer temp = ByteBuffer.allocate(4);
			temp.putInt(c);//color is stored internally as an integer in the form 0xAARRGGBB so this works fine
			for(int j=0;j<4;j++){
				ret[i*4+j]=temp.get(j);//note that i needs to increment by 1 for pixels, but by 4 for ret, so we do this
			}
		}
		return ret; 
	}

}