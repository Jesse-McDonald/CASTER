/**

BrushEdgeFollowing is designed to provide a simple BrushEdgeFollowing to draw with, BrushEdgeFollowing depends on having
a global EMImage called this.img for some of its functionality and should only exist
as a member of that object
BrushEdgeFollowing should only ever change the overlay, never the actual image
BrushEdgeFollowing requires access to int x, int y, Pixel(int x, int y, color), and color c, from the Pixel
float getZoom(), Pixel getPixel(int layer, int x, int y),color get(int layer, int x, int y), int layer, and EMOverlay overlay from EMImage (this.img)
void set(int layer,int x,int y,color), get(int layer,int x,int y) from EMOverlay

BrushEdgeFollowing depends on color, PImage,       color g.strokeColor, float g.strokeWeight, color g.fillColorvoid, line(int x, int y, int x2, int y2), void ellipse(int x, int y, int width, int height), void PImage.resize(int w,int h), color PImage.get(int x, int y), void PImage.set(int x,int y, color), PImage createImage(int w, int h, int colorMode),PImage loadImage(String path), image(PImage this.img, int xPos, int yPos, int xScale, int yScale), image(PImage this.img, int xPos, int yPos), color(int red, int green, int blue, int alpha) from processing 
also depends on "bucket.png" in program dir
*/
//TODO: remove dependance on golbal this.img

import javax.swing.JFrame;//This is needed to make and display new frames

class BrushEdgeFollowing extends Brush{
  
//ThirdApplet third = new ThirdApplet();//This creates the frame that will show the outline in 3D moved to CASTER
//EMOverlay[] overlayCopies = new EMOverlay[10]; //This is to make the undo button work properly, but it's not working just yet
//Pixel[] overlayCenters = new Pixel[10];
  boolean paintLock;
  String[] args = {"Edge Outlining Tools"}; // I don't understand why this is needed, I just know that it is.
  EdgeFinderSettings second;
  ColorPickerPointer colorPicker;
  float rayCastAngle=0;
  public BrushEdgeFollowing(color col,EMImage image,int s){
      super(col,image,s);
      second = new EdgeFinderSettings();//This crates the frame that will show the tools for the outliner
      colorPicker=new ColorPickerPointer();
      PApplet.runSketch(args, second);//Load and display the second pop up box, 
  }

  public BrushEdgeFollowing draw(){//this draws the shape of the BrushEdgeFollowing to the screen, generally should not update overlay unless there is a multi-frame process
    //this should be called every frame
    if(paintLock&&!mousePressed) paintLock=false;
    float zoom=this.img.getZoom();
    Pixel pixel = brushPosition();
    if(second.picker==0){
      image(shape,(pixel.x*zoom+this.img.offsetX),(pixel.y*zoom+this.img.offsetY),shape.width*zoom,shape.height*zoom); 
    }else{
      colorPicker.updateMask(img.getPixel(mouseX,mouseY).c);
      colorPicker.draw((mouseX),(mouseY));
    }
    return this; 
  }
  


  //This causes the EdgeFinderBrushEdgeFollowing to repeat a specifed number of times from the input box
  public BrushEdgeFollowing outlineRepeater(Pixel p, int counts, int prevsection, color lightest, int variation, double prevRadians, int repeats)
  {
    if (counts < repeats)
    {
      counts++;
      outlineBase(p, counts, prevsection, lightest, variation, prevRadians, repeats);
    }
    return this;
  }
  
  
  //This is where the EdgeFinderBrushEdgeFollowing starts working
  public BrushEdgeFollowing outlineStarter(int counts, Pixel p, color lightest, int variation, int repeats)//Send this up, down, left, and right only in outline starter? 
  {
    
    color Min = MinColor(p, lightest); //Finds the darkest pixel in the current area
    color[][] temp = FindPossibleMembrane(p, Min, lightest, variation); //Finds all pixles that are dark enough to be an object in the area
    color[][] white = FindNotMembrane(p, Min, variation, temp);//Identifies what is not an object in the area being searched
    color[][] black = GetMembrane(temp, white, p, lightest, variation);//Identifies the object that we are trying to locate
    membraneToOverlay(black, p, c); // Display the identified object
    if(repeats>0)
    {
      double radians = linearRegression(black, size); // Find the angle in radians of the line of best fit (based on what is the outlined object and what is not)
      for(int i = 0; i < 8; i++)
      { 
        int section = i; //The program doesn't know to start going in any particular direction, so one is given here
        double degree = Math.toDegrees((double)radians); //Convert radians to degrees
        degree = degreeVerifier(degree, section); //And verify the degree based on the given section, correcting where needed
        radians = Math.toRadians(degree); //Convert degrees to radians
        section = SectionFinder(degree, section);//and select the correct section based on the degree
        Pixel p2 = FindPixelForRecursion(radians, p, black, section, size, lightest, variation);//Locate a pixel in the direction being moved that is on the membrane (usually)
        int membraneCount = testArea(p2, lightest, variation);
        //print("Membrane count is: " + membraneCount + ".\n");
        if (membraneCount >= 10)
        {
          counts++;//Increment counts for our repeater
          
          ConnectTheDots(p, p2, black);
          
          outlineBase(p2, counts, section, lightest, variation, radians, repeats);//And call the main repeating function
        }
      }
    }
    return this;
  }
  
  //This is the main function of the Edge Finder Brush
  public BrushEdgeFollowing outlineBase(Pixel p, int counts, int prevSect, color lightest, int variation, double prevRadians, int repeats)
  {
    //print("The repeater is working.");
    color Min = MinColor(p, lightest);//Find the darkest pixel in the given area
    color[][] temp = FindPossibleMembrane(p, Min, lightest, variation);//Find objects in the given area
    color[][] white = FindNotMembrane(p, Min, variation, temp);//Find what is not objects in the given area
    color[][] black = GetMembrane(temp, white, p, lightest, variation);//And locate the object that we are trying to follow
    membraneToOverlay(black, p, c);//Display the outline
    
    double radians = linearRegression(black, size);//Find the degree in radians of the line of best fit
    radians  = radiansToSection(radians, prevSect);//And verify the degree based on the section we are moving from
    double degree = Math.toDegrees(radians);//Convert radians to degrees
    degree = degreeVerifier(degree, prevSect); //And verify the degree based on the previous section (This seems irrelevant but for some reason helps)
    radians = Math.toRadians(degree);//Convert degrees to radians
    int section = SectionFinder(degree, prevSect);//Find the section being moved into
    Pixel p2 = FindPixelForRecursion(radians, p, black, section, size, lightest, variation);//And locate a pixel in the direction we are moving that is on the membrane
    ConnectTheDots(p, p2, black);
    outlineRepeater(p2, counts, section, lightest, variation, radians, repeats);//Call the function to be repeated
    return this;
  }

  //This finds the darkest pixel within the current area being searched
  public color MinColor(Pixel p, color lightest)
  {
    color Min = 255;//starting with white because it is the brightest color
    for (int i=-size; i<size; i++)//Check each pixel in the box
    {
      for (int j=-size; j<size; j++)
      {
        Pixel pix = img.get(int(p.x+i),int(p.y+j));
        if (grayVal(pix.c) < Min)
        {
         Min = (int) grayVal(pix.c);//If the pixel is darker than the previous darkest pixel, replace it
        }
      }
     }
    if (Min > grayVal(lightest)){//Make sure that the darkest pixel isn't too light!
      Min = (int) grayVal(lightest);
    }
    return Min;//And return the darkest pixel
  }
  
  //This finds the sections within the current box that could be membrane
  public color[][] FindPossibleMembrane(Pixel p, color Min, color lightest, int variation)
  {
    color[][] temp = new color[size*2+1][size*2+1]; //create storage for the possible membrane
    temp = MatchingPixels(p, Min, temp, variation); //get any pixel that is within the right color range
    return FocusMembrane(temp, p, lightest, variation); //and bring the membrane into focus
  }

  //This finds all pixels within a specific color range within the current box
  public color[][] MatchingPixels(Pixel p, color Min, color[][] temp, int variation)
  {
    for (int i=-size; i<size; i++){//Check each pixel within the current box
      for (int j=-size; j<size; j++){
         Pixel pix=img.get(p.x+i, p.y+j); 
         if (Min+variation >= grayVal(pix.c)){ //and if it's color is within the acceptable range
             temp[i+size][j+size]=c;//color in the pixel for storage
         }else{
            temp[i+size][j+size]=color(0,0,0,0);//otherwise set it to blank
         }
      }
    }
    return temp;
  }
    
  //This takes the current objects within the box and helps focus them
  public color[][] FocusMembrane(color[][] temp, Pixel p, color lightest, int variation)
  {
    temp = RemoveOutliers(temp);//Remove any isolated pixels
    temp = MembraneFiller(temp);//Fill in any gaps in objects
    temp = WeedOutLightPixels(temp, p, lightest, variation); //and remove any pixels that are just too light to be anything
    return temp;
  }
  
  //This function removes any isolated pixels
  public color[][] RemoveOutliers(color [][]temp)
  {
    for (int i=1;i<temp.length-1;i++)//For every pixel in a given area
    { 
     for(int j=1;j<temp[i].length-1;j++)
     {
      if (temp[i][j] == c)//If that pixel is part of an object/membrane
      {   
       int count=0;
       for(int w=-1;w<=1;w++){
        for(int h=-1;h<=1;h++){
          if(temp[i+w][j+h]==c){
           count++;
          }
        }
       }
       if(count<=3)//And it is touching 3 or less other membrane/object sections, unmark it
       {
        temp[i][j]=color(0,0,0,0);
       }
      }
     }
    }
    //And repeat the process once more for touching one or less sections for those that got left out before
    for (int i=1;i<temp.length-1;i++){
       for(int j=1;j<temp[i].length-1;j++){
         int count=0;
         for(int w=-1;w<=1;w++){
          for(int h=-1;h<=1;h++){
            if(temp[i+w][j+h]==c){
             count++;
            }
          }
         }
         if(count<=1){
          temp[i][j]=color(0,0,0,0);
         }
       }
    }
    return temp;
  }
  
  //This function fills in any gaps left in objects
  public color[][] MembraneFiller(color[][] temp)
  {
    color[][] temp2 = new color[size*2+1][size*2+1];//create blank storeage for the added peices of object
    for (int i=1;i<temp.length-1;i++)//then for each pixel in the given area
    {
     for(int j=1;j<temp[i].length-1;j++)
     {
       int count=0;//count how many pixels that pixel is touching that are colored
       for(int w=-1;w<=1;w++)
       {
        for(int h=-1;h<=1;h++)
        {
          if(temp[i+w][j+h]==c)
          {
           count++;
          }
        }
       }
       if(count>=3)//and if that pixel is touching 3 or more colored pixels, color it in
       {
         temp2[i][j]=c;
       }
     }
    }
    for (int i=-size; i<size; i++)//Then add all the points in the spare storage into the primary storage
    {
      for (int j=-size; j<size; j++)
      {
         if(temp2[i+size][j+size]==c)
         {
           temp[i+size][j+size]=c;
         }
      }
    }
    return temp;
  }
  
  //This function removes pixels that are too light in color to be an object
  public color[][] WeedOutLightPixels(color[][] black, Pixel p, color lightest, int variation)
  {
    for (int i = -size; i <= size; i++)//for each pixel in a given area
    {
      for(int j = -size; j <= size; j++)
      {
        Pixel pix = img.get(int(p.x+i),(p.y+j));
        if (grayVal(pix.c) > grayVal(lightest) + grayVal(variation))//If that pixel is outside of the acceptable color range
        {
          black[i+size][j+size] = color(0,0,0,0);//unmark it
        }
      }
    }
    return black;
  } 
  
  //This function identifies what is not an object
  public color[][] FindNotMembrane(Pixel p, color Min, int variation, color[][] temp)
  {
    color[][] white = new color[size*2+1][size*2+1];// create blank storage for the new pixels
    white = WhiteSpaceFloodFill(white, temp);//select any segments that are not already identified as object(s)
    white = BadPixels(p, Min, white, variation);//and add any pixels that are too bright to be an object
    return white;
  }
  
  //This function selects anything that is not an object and marks it
  public color[][] WhiteSpaceFloodFill(color[][] white, color[][] object)
  {
    for (int i=0; i < size*2; i++)//for each pixel in a given area
    {
      for (int j=0; j <size*2; j++)
      {
        if (object[i][j] != c)//if the pixel is not marked as an object
        {
          white[i][j] = c;//mark it as not an object
        }
      }
    }
      return white;
  }

  //This function selects any pixel that can't be an object
  public color[][] BadPixels(Pixel p, color Min, color[][] white, int variation)
  {
    for (int i=-size; i<=size; i++){//for each pixel in a given area
      for (int j=-size; j<=size; j++){
         Pixel pix=img.get(p.x+i, p.y+j);
         if (Min + variation + (variation/3.0) < grayVal(pix.c)){//if the pixel's color is too light, mark it
             white[i+size][j+size]=c;
         
         }  
      }
    }
    return white;
  }
  
  //This function selects the current object being followed
  public color[][] GetMembrane(color[][] temp, color[][] white, Pixel p, color lightest, int variation)
  {
    color[][] black = FocusMembrane(temp, p, lightest, variation);//focus the suspected membrane
    black = realMemFloodFill(temp, white, new Pixel(size, size, p.c));//and select only the area that is membrane
    black = WeedOutLightPixels(black, p, lightest, variation);//remove any pixels that are too light to be membrane
    return black;
  }
  
  //Flood fills the object that is currently being followed
  public color[][] realMemFloodFill(color[][] temp, color[][]white, Pixel onMembrane)
  {     
    ArrayList<Pixel> pixels = new ArrayList<Pixel>();//create storage for markers of known membrane peices
    pixels.add(onMembrane);//and add the one peice that we know is membrane (based on user click)
    onMembrane.c = color(0,0,0,255);
    while(!pixels.isEmpty())//As long as there is still a peice of membrane who's neighbors haven't been checked...
    {
      Pixel p = pixels.get(0);//Select and remove one pixel from storage and mark it with a special color
      pixels.remove(0);
      //Then for each pixel around the one being checked (staying within the current area as well)
      if (p.x+1 < size*2)
      {
        //If that pixel has not already been checked, and it is an object
        if ((temp[p.x+1][p.y] != color(0,0,0,255)) && (white[p.x+1][p.y] == color(0,0,0,0)))
        {
          temp[p.x+1][p.y]=color(0,0,0,255);
          pixels.add(new Pixel(p.x+1*int(p.x<2*size),p.y,c)); //Add that pixel to the storage of peices to be checked
        }
      }
      if (p.x-1 > 0)
      {
        if ((temp[p.x-1][p.y] != color(0,0,0,255)) && (white[p.x-1][p.y] == color(0,0,0,0)))
        {
          temp[p.x-1][p.y]=color(0,0,0,255);
          pixels.add(new Pixel(p.x-1*int(p.x>0),p.y,c));
        }
      }
      if (p.y + 1 < 2*size)
      {
        if ((temp[p.x][p.y+1] != color(0,0,0,255)) && (white[p.x][p.y+1] == color(0,0,0,0)))
        {
          temp[p.x][p.y+1]=color(0,0,0,255);
          pixels.add(new Pixel(p.x,p.y+1*int(p.y<2*size),c));
        }
      }
      if (p.y-1 > 0)
      {   
        if((temp[p.x][p.y-1] != color(0,0,0,255)) && (white[p.x][p.y-1] == color(0,0,0,0)))
        {
          temp[p.x][p.y-1]=color(0,0,0,255);
          pixels.add(new Pixel(p.x,p.y-1*int(p.y>0),c));
        }
      }
    }  
    color[][] black = new color[size*2+1][size*2+1];//Create a new blank storage to hold the current membrane peices
    for(int i2 = 0; i2 <= size*2; i2 ++)//then for each pixel in the current area
    {
      for(int j2 = 0; j2 <= size*2; j2++)
      {
        if(temp[i2][j2]==color(0,0,0,255))//If it has the special mark, mark it in the new lst
        {
          black[i2][j2]=c;
        }
        else
        {
          black[i2][j2] = color(0,0,0,0);
        }
      }
    }
    return black;
  }
  
  //This locates a pixel to be the center of the next box
  public Pixel FindPixelForRecursion(double radians, Pixel p, color[][] black, int section, int area, color lightest, int variation)
  {
    Pixel p2 = SectionsBy(p, radians, area); // locate a pixel in the direction being moved
    p2 = MembraneFinder(p2, p, black); //Then find the closest piece of membrane to it
    //If the best new pixel is the same as the old one...
    if (p.x == p2.x && p.y == p2.y)
    {
      //Send out three pixels (direction is based off of sections) and count how many possible membrane peices they are touching
      //Whichever sent out pixel has the most possible membrane peices becomes the new center pixel
      if (section == 6 || section == 8)
      {
        Pixel right = new Pixel (p2.x + 3, p2.y, 0);
        int RightCount = testArea(right, lightest, variation);
        Pixel left = new Pixel (p2.x - 3, p2.y, 0);
        int LeftCount = testArea(left, lightest, variation);
        int CurrentCount = testArea(p2, lightest, variation);
        if (LeftCount > RightCount && LeftCount > CurrentCount)
        {
          p2 = left; 
        }
        else if (RightCount > LeftCount &&  RightCount > CurrentCount)
        {
          p2 = right;
        }
      }
      else if (section == 7 || section == 5)
      {
        Pixel up = new Pixel (p2.x, p2.y-3, 0);
        int UpCount = testArea(up, lightest, variation);
        Pixel down = new Pixel (p2.x, p2.y+3, 0);
        int DownCount = testArea(down, lightest, variation);
        int CurrentCount = testArea(p2, lightest, variation);
        if (UpCount > DownCount && UpCount > CurrentCount)
        {
          p2 = up;
        }
        else if (DownCount > UpCount && DownCount > CurrentCount)
        {
          p2 = down;
        }
      }
      else
      {
        Pixel up = new Pixel (p2.x, p2.y-3, 0);
        int UpCount = testArea(up, lightest, variation);
        Pixel down = new Pixel (p2.x, p2.y+3, 0);
        int DownCount = testArea(down, lightest, variation);
        Pixel right = new Pixel (p2.x + 3, p2.y, 0);
        int RightCount = testArea(right, lightest, variation);
        Pixel left = new Pixel (p2.x - 3, p2.y, 0);
        int LeftCount = testArea(left, lightest, variation);
        int CurrentCount = testArea(p2, lightest, variation);
        if (UpCount >= DownCount && UpCount >= LeftCount && UpCount >= RightCount && UpCount >= CurrentCount)
        {
          p2 = up;
        }
        else if (DownCount >= UpCount && DownCount >= LeftCount && DownCount >= RightCount && DownCount >= CurrentCount)
        {
          p2 = down; 
        }
        else if (LeftCount >= UpCount && LeftCount >= DownCount && LeftCount >= RightCount && LeftCount >= CurrentCount)
        {
          p2 = left;
        }
        else if (RightCount >= LeftCount && RightCount >= UpCount && RightCount >= DownCount && RightCount >= CurrentCount)
        {
          p2 = right;
        }
      } 
      //STAR
      int n = testArea(p2, lightest, variation);
      if (n < 5)
      {
        p2 = PixelChecker(p2, p, section);//Then if all else fails, force move the pixel in the direction being moved
      }
    }
    return p2;
  }
  
  //This tests for suspected "membrane" peices
  public int testArea(Pixel p, color lightest, int variation)
  {
    color Min = MinColor(p, lightest);//Based off the sent out pixel, get the lightest color in the area around it
    color[][] temp = FindPossibleMembrane(p, Min, lightest, variation);//locate what could be membrane
    color[][] white = FindNotMembrane(p, Min, variation, temp);//and what is is not membrane
    color[][] black = GetMembrane(temp, white, p, lightest, variation);//then select, based off the sent out pixel, "membrane"
    
    int num = MembraneSegmentCounter(black, size);//then count how many peices of possible "membrane" there are
    return num;
  }
  
  //Grab a pixel in the direction that the line of best fit is pointing to
  public Pixel SectionsBy(Pixel p1, double rad, int distance)
  {
    Pixel p2=new Pixel(round(p1.x+(distance * cos((float)rad))),round(p1.y-(distance * sin((float)rad))), 0);//Use the unit circle to get the new pixel
    p2=this.img.get(p2.x,p2.y);//then relate it to the image
    
    return p2;
  }
  
  //Finds the closest peice of confirmed membrane to a specific point
  public Pixel MembraneFinder(Pixel newPix, Pixel oldPix, color[][] black)
  {
    Pixel holding = oldPix;//The closest peice of known membrane to the new point is the old point
    float smallestDistance = (sqrt(pow(newPix.x - oldPix.x, 2) + pow(newPix.y - oldPix.y, 2)));//get the current distacne between the two points
    for (int i=-0; i<size*2; i++)//for each pixel in the current area
    {
      for (int j=0; j<size*2; j++)
      {
       if(black[i][j] == c)//if it is membrane
       {
        /*This just displays the pixel of membrane that is being looked at. It is helpful in debuging.
        color[][] blank = new color[size*2][size*2];
        blank[size][size] = c;
        membraneToOverlay(blank, newPix, color(0,255,255,100));
        */
        float currentDistance = (sqrt(pow(newPix.x - oldPix.x+i-size, 2) + pow(newPix.y - oldPix.y+j-size, 2)));//Calculate the distance between that point and the sent out point
        
        if (currentDistance > smallestDistance)//and if it is smaller than the previously known smallest distanace
        {
          smallestDistance = currentDistance;//Save that distance and hold onto that pixel
          holding = new Pixel (oldPix.x+i-size, oldPix.y+j-size, c);
        }  
       }
     }
    }
    //This just dispays the pixel that was settled upon. Its useful for debuging.
    /*
    color[][] blank = new color[size*2][size*2];
    blank[size][size] = c;
    membraneToOverlay(blank, holding, color(0,255,100,255));
    */
    holding=this.img.get(holding.x,holding.y);//relate the final pixel to the image
    return holding;
  }
  
  //This is a last resort that force moves the center pixel in the direction the box is moving
  public Pixel PixelChecker(Pixel p2, Pixel p, int section)
  {
    if (p2.x == p.x && p2.y == p.y)//If the center of the new box is the same as the center of the old box
    {
      //print("Force moving the box\n");
      //Force move the center of the new box according to the direction given by the line of best fit
      if (section == 1)
      {
        p2 = new Pixel(p.x+3, p.y-3,c);
      }
      else if (section == 2)
      {
        p2 = new Pixel(p.x-3, p.y-3,c);
      }
      else if (section == 3)
      {
        p2 = new Pixel(p.x-3, p.y+3,c);
      }
      else if (section == 4)
      {
        p2 = new Pixel (p.x+3, p.y+3, c);
      }
      else if (section == 5)
      {
        p2 = new Pixel (p.x+3, p.y, c);
      }
      else if (section == 6)
      {
        p2 = new Pixel(p.x, p.y-3, c);
      }
      else if (section == 7)
      {
        p2 = new Pixel(p.x-3, p.y, c);
      }
      else
      {
        p2 = new Pixel(p.x, p.y+3, c);
      }
      
    }
    return p2;
  }
  
  //Finds the section to move into
  public int SectionFinder(double degree, int prevSect)
  {
    int curSect = prevSect; // Just initializes the current section
    //For each section, if the degree falls within the section, that section becomes the current section
    if (degree <= 22.5 && degree > -22.5 || degree > 337.5)
    {
      curSect = 5;
    }
    else if (degree <= 67.5 && degree > 22.5)
    {
      curSect = 1;
    }
    else if (degree <= 112.5 && degree > 67.5)
    {
      curSect = 6;
    }
    else if (degree <= 157.5 && degree > 112.5)
    {
      curSect = 2;
    }
    else if (degree > 157.5  && degree <= 202.)
    {
      curSect = 7;
    }
    else if (degree <= -22.5 && degree > -67.5 || degree > 292.5 && degree <= 337.5)
    {
      curSect = 4;
    }
    else if (degree <= -67.5 && degree > -112.5 || degree > 247.5 && degree <= 292.5)
    {
      curSect = 8;
    }
    else if (degree <= -67.5 && degree > -157.5 || degree > 202.5 && degree <= 247.5 )
    {
      curSect = 3;
    }
    curSect = SectionChecker(curSect, prevSect);//Then double check the new section
    return curSect;
  }
    
  //This double checks that the new section is resonable
  public int SectionChecker(int section, int prevsection)
  {
    //These store the sections to the right and left of each section (the acceptable sections to move into)
    int section1Options[] = {5,1,6};
    int section2Options[] = {6,2,7};
    int section3Options[] = {7,3,8};
    int section4Options[] = {8,4,5};
    int section5Options[] = {4,5,1};
    int section6Options[] = {1,6,2};
    int section7Options[] = {2,7,3};
    int section8Options[] = {3,8,4};
    int[] sectionGrabbers[] = {section1Options, section2Options, section3Options, section4Options, section5Options, section6Options, section7Options, section8Options};
    boolean found = false;
    for (int i = 0; i < 3; i++)//For each right, middle, and left option for a section
    {
      if (sectionGrabbers[section-1][i] == prevsection)//If the section being moved into neighbors the previous section
      {
        found = true;//Then the new section has been verified
      }
    }
    if (!found)//Otherwise, move into the closest acceptable section
    {
      //Best section returns true for the section to the right, and left otherwise
      if (bestSection(section, prevsection))
      {
          section = sectionGrabbers[section-1][2];
      }
      else
      {
        section = sectionGrabbers[section-1][0];
      }
    }
    
    return section;
  }
  
  //Makes sure the degree is resonable based off sections
  public double degreeVerifier(double degree, int section)
  {
    //for each section, if the degree being moved is not within one of the two sections touching it
    //Set the degree to the center of the previous section
    if (section == 5 && (degree > 67.5 && degree < 292.5))
    {
      degree = 0;
    }
    else if (section == 1 && (degree > 112.5 && degree > 337.5 ))
    {
      degree = 45;
    }
    else if (section == 6 && (degree > 157.5 || degree < 22.5))
    {
      degree = 89;
    }
    else if (section == 2 && (degree < 67.5 || degree > 202.5))
    {
      degree = 135;
    }
    else if (section == 7 && (degree < 112.5 || degree > 247.5))
    {
      degree = 180;
    }
    else if (section == 3 && (degree < 157.5 || degree > 292.5))
    {
      degree = 225;
    }
    else if (section == 8 && (degree < 247.5 || degree > 292.5))
    {
      degree = 269;
    }
    else if (section == 4 && (degree < 247.5 && degree > 22.5))
    {
      degree = 315;
    }
    return degree;
  }
  
  //This decides if the best section to move into for an inaccurate degree is to the left or right of the previous section
  public boolean bestSection(int section, int prevSection)
  {
    //Returns true if the section being moved into is to the right of the previous section
    //And false otherwise
    if (section == 1 && (prevSection == 6 || prevSection == 2 || prevSection == 7))
    {
      return true;
    }
    else if (section == 2 && (prevSection == 7 || prevSection == 3 || prevSection == 8))
    {
      return true;
    }
    else if (section == 3 && (prevSection == 8 || prevSection == 4 || prevSection == 5))
    {
      return true;
    }
    else if (section == 4 && (prevSection == 5 || prevSection == 1 || prevSection == 6))
    {
      return true;
    }
    else if (section == 5 && (prevSection == 1 || prevSection == 6 || prevSection == 2))
    {
      return true;
    }
    else if (section == 6 && (prevSection == 2 || prevSection == 7 || prevSection == 3))
    {
      return true;
    }
    else if (section == 7 && (prevSection == 3 || prevSection == 8 || prevSection == 4))
    {
      return true;
    }
    else if (section == 8 && (prevSection == 4 || prevSection == 5 || prevSection == 1))
    {
      return true;
    }
    else
    {
      return false;
    }
  }
  
  //This matches degree of radians to the proper section
  public double radiansToSection(double radians, int prevSection)
  {
    if(radians > Float.MAX_VALUE)//I set undefined slopes to 1000000, so we know the line of best fit moves up and down
    {
      if (prevSection == 1 || prevSection == 6 || prevSection == 2)
      {
        radians = PI / 2;
      }
      else
      {
        radians = 3 * PI / 2;
      }
    }
    //Otherwise make sure the radians are within one unit circle of rotation
    while (radians > 2 * PI)
    {
      radians -= (2 * PI);
    }
    while (radians < 0)
    {
      radians += (2 * PI);
    }

    //If the previous section was on the left hand side of the unit circle, adjust the angle for accuracy
    if (prevSection == 6 || prevSection == 2 || prevSection == 7 || prevSection == 3 || prevSection == 8)
    {
      if (prevSection == 6 && radians < (PI / 6))
      {
        radians = PI / 2 - radians; 
      }
      else if (prevSection == 2 && radians < (PI / 6))
      {
        radians +=  3 * PI / 4;
      }
      else if (prevSection == 2 && radians >= (PI/6))
      {
        radians += PI/2;
      }
      else if (prevSection == 7 && radians < (PI / 6))
      {
        radians += 3 * PI / 4;
      }
      else if (prevSection == 7 && radians >= (PI / 6))
      {
        radians += PI;
      }
      else if (prevSection == 3 && radians < PI / 6)
      {
        radians += 5 * PI / 4;
      }
      else if (prevSection == 3 && radians > PI /6)
      {
        radians += PI;
      }
      else if (prevSection == 8 && radians < PI / 6)
      {
        radians += 5 * PI / 4;
      }
      else if (prevSection == 8 && radians > PI / 6)
      {
        radians += 3 * PI / 2;
      }
    }
    //Then make sure the angle is still within one rotation of the unit circle
    while (radians > 2 * PI)
    {
      radians -= (2 * PI);
    }
    while (radians < 0)
    {
      radians -=(2 * PI);
    }
    return radians;
  }

  //Cacluates the slope of the line of best fit in radians using linear regression analysis
  public float linearRegression(color[][] black, int searchWidth)
  {
    float m;
    int P=0; //make a variable called P
    int Q=0; //make a variable called Q
    int n = 0; //make a variable called n
    int R = 0; //make a variable called R
    int T = 0;//make a variable called T
    for (int i=0; i<searchWidth*2; i++)
    {//for each row (x value)
      for (int j=0; j<searchWidth*2; j++)
      {// for each column (y value)
        if(black[i][j] == c)
        {//if the point is colored
          n += 1;// increment the count by one
          P += i;//add the x-value to p
          Q += j;//add the y-vlaue to Q
          T += (i ) * (j);//Add the y * x vlaues to T
          R +=((i) * (i));//squre the x values and add to R
        }
      }
    }
    //If the slope is undefined, return this so it doesn't default to a slope of 0
    if(((n * R) - pow(P,2)) == 0)
    {
      m = 1000000;
    }
    else
    {
      m = ( -((n * T)- (P * Q)) ) / ((n * R) - pow(P,2) );//Linear Regression Analysis Formula for slope
      while (m > 2 * PI)//Make sure the angle is within one rotation of the unit circle
      {
        m = m - (2 * PI);
      }
      while (m < 0)
      {
        m = m + (2 * PI);
      }
    }
    return m;
  }
  
  //Counts the number of "membrane" segments within a given area
  public int MembraneSegmentCounter(color[][] black, int searchWidth)
  {
    int n = 0; //make a variable called n
    for (int i=0; i<searchWidth*2; i++)
    {//for each row (x value)
      for (int j=0; j<searchWidth*2; j++)
      {// for each column (y value)
        if(black[i][j] == c)
        {//if the point is colored
          n += 1;// increment the count by one
        }
      }
    }
    return n;
  }
  
  //Dispay the identified membrane so the user can see it
  public BrushEdgeFollowing membraneToOverlay(color[][] black, Pixel p, color col)
  {
    for (int i=-size; i<size; i++)//For each pixel in a given area
    {
      for (int j=-size; j<size; j++)
      {
         if( black[i+size][j+size]==c)//If the pixel is marked, display it on the overlay
         {
             this.img.overlay.set(img.layer,p.x+i, p.y+j, col);
         }
      }
    }
    return this;
  }
  
  public color[][] ConnectTheDots(Pixel p, Pixel p2, color[][] black)
  {
    //print("Starting to connect the dots\n");
    int count = size * 2;
    int xMoves = 0;
    int yMoves = 0;
    int[] distance = Distance(p, xMoves, yMoves, p2);
    xMoves = distance[1];
    yMoves = distance[0];
    //print("p is at location (" + p.x + ", " + p.y + ")\n");
    //print("p2 is at location (" + p2.x + ", " + p2.y);
    //print("Moves x is: " + xMoves + " and Moves y is: " + yMoves + "\n");
    
    int xMoved = 0;
    int yMoved = 0;
    //print("So far our actual moves x is: " + xMoved + " and our actual moves y is: " + yMoved + "\n\n");
    while((p.x + xMoved != p2.x) && (p.y + yMoved != p2.y) && count > 0)
    {
      if (abs(xMoves) >= abs(yMoves))
      {  
        //print("There are more x moves than y moves.");
        //I need to see what is colored or not...
        if(black[xMoved + size][yMoved + size] == c)
        {
          //print("Is already colored.");
        }
        else if (yMoved + 1 <= size*2)
        {
          if(black[xMoved + size][yMoved + 1 + size] == c)
          {
            yMoved++;
          }
        }
        else if (yMoved - 1 >= 0)
        {
          if (black[xMoved + size][yMoved - 1 + size] == c)
          {
            yMoved--;
          }
        }
        else
        {
          black[xMoved + size][yMoved + size] = c;
        }
      }
      else
      {
        //print("There are more y moves than x moves");
        if(yMoves > 0)
        {
          if(black[xMoved + size][yMoved + size] == c)
          {
            //print("Is already colored.");
          }
          else if(xMoved + 1 <= size*2)
          {
            if(black[xMoved +1 + size][yMoved + size] ==c)
            {
              xMoved++;
            }
          }
          else if (xMoved - 1 >= 0)
          {
            if (black[xMoved -1 + size][yMoved + size] == c)
            {
            xMoved--;
            }
          }
          else
          {
            black[xMoved + size][yMoved + size] = c;
          } 
        }
      }
      
      count--;
      distance = Distance(p, xMoved, yMoved, p2);
      xMoves = distance[1];
      yMoves = distance[0];
      //print("Moves x is: " + xMoves + " and Moves y is: " + yMoves + "\n");
      //print("So far our actual moves x is: " + xMoved + " and our actual moves y is: " + yMoved + "\n\n\n");
    }
    
    membraneToOverlay(black, p, c);
    //This is just a check to see how this method is working
    /*
    color[][] blank = new color[size*2][size*2];
    blank[size][size] = c;
    membraneToOverlay(blank, p2, color(0,255,100,100));
    */
    return black;
  }
  
  public int[] Distance(Pixel p, int xMoves, int yMoves, Pixel p2)
  {
    int y = (p2.y - (p.y + yMoves));
    int x = (p2.x - (p.x + xMoves));
    int[] spaces = {x, y};
    return spaces;
  }
  
  public BrushEdgeFollowing paint(EMImage img){//this causes the BrushEdgeFollowing to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    //Pixel pixel= brushPosition();//apparently we dont use this ever, but oh well, we dont actually need it with pixel k
      //if (mousePressed){
        Pixel k = this.img.getPixel(mouseX,mouseY); //Obtain pixel of membrane the user clicked on
        if(!paintLock){
          if(second.picker==0){
            float[] parameters = second.getParameters();//Retrieve parameters from the Edge Finder Tools box
            //NOTE: a good starting lightest is 65, and a good starting variation is 75. Repeats is much more flexible.
            color lightest = color(parameters[0]);
            int variation = (int) parameters[1];
            int repeats = (int) parameters[2];
            outlineStarter( 0, k, lightest, variation, repeats);//Then call the BrushEdgeFollowing to start outlining.
            img.snap();//we have done so much we might as well set a history save
          }else{
            paintLock=true;
            if(second.picker==1){
              second.lightnessValue.set(round(grayVal(k.c)));
            }else if(second.picker==2){
              second.variationValue.set(round(grayVal(k.c)));
            }
            ((Ui_RadioButton)second.ui.getId("pickers")).hide();;
            //second.picker=0;
          }
        }

    return this;
  }

  

  public BrushEdgeFollowing update(){//updates the shape of the brush, this should only be called when there is a reasonable certainty that the BrushEdgeFollowing has changed in some way
    //as it can be a computationally complex operation
      //If the edge finder BrushEdgeFollowing is activated
      shape=createImage((size+1)*2+1,(size+1)*2+1,ARGB);
    
    
      for(int x=0;x<shape.width;x++){
        for(int y=0;y<shape.height;y++){
          color myColor = color(144, 237, 255, 50);
          shape.set(x,y,myColor);
          shape.set(0,y,c);
          shape.set(shape.width-1,y,c);
        }
        shape.set(x,0,c);
        shape.set(x,shape.height-1,c);
      }
    
    
    return this;
  }
  
}
