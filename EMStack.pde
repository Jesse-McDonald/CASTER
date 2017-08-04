/**
	EMStack is really an obfuscation of ArrayList<PImage> img built do decrease the legwork of EMImage
	it passes though many useful functions such as add, size, and get
	EMStack does not depend on any custom classes
	EMStack does depend on PImage, color, PImage loadImage(String path), and image(PImage img, int x, int y, int xScale, int yScale) from processing
*/
class EMStack{
	int width;//img width
	int height;//img height
	int depth;//number of images in stack 
	ArrayList<PImage> img;
  public ArrayList<EMMeta> meta;//meta data for a given layer
	EMStack(){//new empty EMStack
		img=new ArrayList<PImage>();
	}
	EMStack(String dir){//new EMStack seeded from picture file by path
		this(new File(dir)); 
	}    
	
	EMStack(File base){//new EMStack seeded from picture file
		this();
		File folder=new File(base.getParent());//this gets the parrent folder of the given image
		String extension=base.getName();//extract img type
		extension=extension.substring(extension.lastIndexOf('.'),extension.length()-1);
		File[] files=folder.listFiles();//get all files in folder
		//load the full dir to the stack;
		for (int i = 0; i < files.length; i++) {
			if (files[i].isFile()) {
				if (files[i].getName().contains(extension)){//only attempt to load a file if the file types match existing
				  add(loadImage(files[i].getPath()));
				}
			}
		}
		this.width=img.get(0).width;
		this.height=img.get(0).height;//update width, height, and depth
		this.depth=img.size();
	}
	
	EMStack add(PImage image){//add a new image to the stack, can be dangerous if EMOverlay and meta are not updated with the additional layer
		img.add(image);
		width=image.width;
		height=image.height;//update width, height, and depth
		depth=img.size();
		return this;
	}
	
	EMStack draw(int layer,float x,float y,float zX,float zY){//draw current layer
		image(img.get(layer),x,y,zX,zY);
		return this;
	}
	
	int size(){//obfiscates img.img.size() to img.size()
		return img.size();
	}
	
	color get(int layer, int x,int y){//obfuscates img.img.get(layer).get(x,y) to img.get(x,y)
		return img.get(layer).get(x-meta.get(layer).offsetX,y-meta.get(layer).offsetY);
	}

}