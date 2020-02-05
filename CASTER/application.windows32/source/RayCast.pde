
class RayCast extends Brush{
    public RayCast(color col,EMImage image,int s){
      super(col,image,s);
    }
  float rayCastAngle=0;


  public RayCast draw(){//this draws the shape of the brush to the screen, generally should not update overlay unless there is a multi-frame process
    //this should be called every frame
    float zoom=this.img.getZoom();
    Pixel pixel = brushPosition();
      color temp=g.strokeColor;//store the current stroke color so we can restore it later
      float w=g.strokeWeight;//same for stroke width
      color fill=g.fillColor;//and fill
      stroke(c);//set stroke to layer color
      strokeWeight(10);//nice wide lines
      /*final int RAY_COUNT=4;
      for(int i=0;i<size*RAY_COUNT;i++){//this code draws the rays, does not look the greatest so instead I use the rotating ray
        float theta=PI*2.0/size/RAY_COUNT;
        //image(shape,(pixel.x*zoom+this.img.offsetX),(pixel.y*zoom+this.img.offsetY),shape.width*zoom,shape.height*zoom); 
        //line((pixel.x*zoom+this.img.offsetX+zoom/2),(pixel.y*zoom+this.img.offsetY+zoom/2),(pixel.x*zoom+this.img.offsetX+zoom/2)+cos(theta*i)*size/2*zoom,(pixel.y*zoom+this.img.offsetY+zoom/2)+sin(theta*i)*size/2*zoom);
        for(int j=0;j<=size;j++){
          line((pixel.x*zoom+this.img.offsetX+zoom/2),(pixel.y*zoom+this.img.offsetY+zoom/2),(pixel.x*zoom+this.img.offsetX+zoom/2)+cos(theta*i)*size/2*zoom,(pixel.y*zoom+this.img.offsetY+zoom/2)+sin(theta*i)*size/2*zoom);
        }
      }*/
      line(mouseX,mouseY,mouseX+cos(rayCastAngle)*size/2*zoom,mouseY+sin(rayCastAngle)*size/2*zoom);//draw line at current angle angle
      fill(color(0,0,0,0),0);//set fill to transparrent so the circle is no color inside        
      ellipse(mouseX,mouseY,size*zoom,size*zoom);//draw a circle arround the mouse where the ray will sweep
      stroke(temp);//restor stroke
      strokeWeight(w);//and weight
      fill(fill);//and fill
      rayCastAngle+=.2;//increment angle, larger values are generaly faster, smaller are slower, I found 0.2 is about right
    return this; 
  }

  public RayCast rayCastBrush(int x, int y){//projects rays from the mouse which stop and fill when a certain gradiant is met, then smooth the result
      Pixel pixel =this.img.getPixel(x,y);//seed first pixel
      final int RAY_COUNT=4;//rays go out in this many directions 
      float zoom=this.img.zoom;
      //smoothBrush(pixel.x,pixel.y);//comment other smooth and un comment this one to see how it works
      for(int i=0;i<size*RAY_COUNT;i++){//make circle of rays
        float theta=PI*2.0/size/RAY_COUNT;//determine angle of rays
        //image(shape,(pixel.x*zoom+this.img.offsetX),(pixel.y*zoom+this.img.offsetY),shape.width*zoom,shape.height*zoom); 
        //line((pixel.x*zoom+this.img.offsetX+zoom/2),(pixel.y*zoom+this.img.offsetY+zoom/2),(pixel.x*zoom+this.img.offsetX+zoom/2)+cos(theta*i)*size/2*zoom,(pixel.y*zoom+this.img.offsetY+zoom/2)+sin(theta*i)*size/2*zoom);
        ArrayList<Pixel> line=new ArrayList<Pixel>();//get a list ready to add pixels to allong the line
        Pixel last=new Pixel(pixel.x,pixel.y,c);//track the last pixel, faster than following the linked list
        for(int j=0;j<=size;j++){//run a dot scan allong the line and add all pixels to the list
          Pixel p=this.img.getPixel(int((pixel.x*zoom+this.img.offsetX+zoom/2)+cos(theta*i)*j/2*zoom),int((pixel.y*zoom+this.img.offsetY+zoom/2)+sin(theta*i)*j/2*zoom));//record new pixel
          //ellipse(int((pixel.x*zoom+this.img.offsetX+zoom/2)+cos(theta*i)*j/2*zoom),int((pixel.y*zoom+this.img.offsetY+zoom/2)+sin(theta*i)*j/2*zoom),10,10);//visualize scan, lags program
          line.add(last);//add last pixel
          if((p.x!=last.x||p.y!=last.y)&&gradMatch(last,p)){//check that current and last are not the same pixel, if they arent, check them against gradMatch to see if we should stop the line
            this.img.overlay.set(this.img.layer,last.x,last.y,c);//fill last pixel
            break;//break out of the for, we have all of the 
          }
          last=p;//swap current to last
        }
        for(int j=0; j<line.size();j++){//fill entire line to end point
          this.img.overlay.set(this.img.layer,line.get(j).x,line.get(j).y,c);
        }
      }
      smoothBrush(pixel.x,pixel.y);//smooths area
      return this;
  }


  private boolean gradMatch(Pixel temp,Pixel p){//determins if 2 pixels have enough of a gradient to them
    float threshold=32;//arbitrary threshold for comparison 32 seems to work well for ray cast
    float _1=greyVal(temp.c);
    float _2=greyVal(p.c);
    return (_1-_2)*(_1-_2)*3>threshold*threshold;
  }

  float greyVal(color c){//this averages the RGB values of a given color to determine its grayscale value
    return ((c >> 16 & 0xFF) + (c >> 8 & 0xF) + (c & 0xFF))/3.0;//extract and average rgb values
  }

  public RayCast paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    Pixel pixel= brushPosition();
    this.img=img;
    rayCastBrush(mouseX,mouseY);
    
    return this;
  }

  public RayCast smoothBrush(int startX, int startY){//this brush smooths out thin ridges and fills in thin gaps, it does this by checking the number of neighboring pixels for each pixel, it is designed to be used with ray fill, but can be used independantly
    ArrayList<Pixel> add=new ArrayList<Pixel>();//list of pixels to fill, we have to do these last or it will throw off the calculations
    ArrayList<Pixel> remove=new ArrayList<Pixel>();  //list of pixels to clear, we have to do these last or it will throw off the calculations
    float ss=size*size/4;//callculate r^2 from D
    for(int x=0;x<size;x++){
      for(int y=0;y<size;y++){
        //this.img.overlay.set(this.img.layer,startX+x,startY+y,c);
        int posX=x-size/2;
        int posY=y-size/2;
        if (posX*posX+posY*posY<ss){//good old pathagrean circle from inequality for filling a circle
          if(this.img.overlay.get(this.img.layer,startX+posX,startY+posY)!=c){//check for empty pixel
            int count=0;
            for(int i=-1;i<2;i++){//for loops for getting a 9 square (3x3) area centered on the point inside the cricle
              for(int j=-1;j<2;j++){
                count+=int(this.img.overlay.get(this.img.layer,startX+posX+i,startY+posY+j)==c);//count adjacent pixels
              }  
            }
            
            if(count>4){
               add.add(new Pixel(startX+posX,startY+posY,c));//if enough pixels are full arround it, fill this one in
            }
          }else if(this.img.overlay.get(this.img.layer,startX+posX,startY+posY)==c){//check full pixels
            int count=0;
            for(int i=-1;i<2;i++){//for loops for getting a 9 square (3x3) area centered on the point inside the cricle
              for(int j=-1;j<2;j++){
                count+=int(this.img.overlay.get(this.img.layer,startX+posX+i,startY+posY+j)!=c);//couund adjacent pixels
              }  
            }
            
            if(count>4){
              remove.add(new Pixel(startX+posX,startY+posY,color(0,0,0,0)));//add pixel to remove
            }
          }
        }
      }
    }
    for(int i=0;i<add.size();i++){
      this.img.overlay.set(this.img.layer,add.get(i).x,add.get(i).y,c);//add pixles to add
    }
    for(int i=0;i<remove.size();i++){
      this.img.overlay.set(this.img.layer,remove.get(i).x,remove.get(i).y,color(0,0,0,0));//clear pixels to clear
    }
    return this;
  }
  public RayCast update(){//updates the shape of the brush, this should only be called when there is a reasonable certainty that the brush has changed in some way
    //as it can be a computationally complex operation
    shape=createImage((int)1,(int)1,ARGB);//no shape because the brush is generated dynamicly
    return this;
  }

}
