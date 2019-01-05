/**
This class is design to micromange a decision tree based clasification tool that can learn what pixels in an image are membrane or not and rapidly classify all pixels of a similar image
as membrane or not based on a a sample of perfictly and completely traced membranes
depends on access to EMStack img and EMOverlay overlay from EMImage
ArrayList<PImage> overlay from EMOverlay
ArrayList<Pimage> img from EMStack
ClassificationTree(int grid, int pixels), void train(EMImage), void load(File), void save(File) from ClassificationTree
depends on PImage from processing
*/
class DecisionTreeClassification{
  EMImage img;
  ClassificationTree tree;
  DecisionTreeClassification(EMImage image){
    img=image;
    tree=new ClassificationTree(0,0);
  }
  
  DecisionTreeClassification Learn(){//learn new rule for classifying image, expects a EMImage where every membrane (even organel) pixel in img has a corisponding non transparent pixel in overlay
    tree.train(img);
    return this;
  }
  
  DecisionTreeClassification Classify(){//applys learned rules to classify image
   
    return this;
  }
  
  DecisionTreeClassification setTree(ClassificationTree t){//set a new decision tree
    tree=t;
    return this;
  }
  
  DecisionTreeClassification setImage(EMImage i){//set image, use after training or... well or there is no point really
    img=i;
    return this;
  }
  
  DecisionTreeClassification saveTree(File file){//save decision tree
    tree.save(file);
    return this;
  }
  
  DecisionTreeClassification loadTree(File file){//load decistion tree
    tree.load(file);
    return this;
  }
}