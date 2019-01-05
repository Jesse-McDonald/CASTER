/**
this class handles the decistions to be made by a decision tree
//STUB:
depends on access to int depth, EMOverlay overlay, and EMStack img from EMImage
color get(int layer, int x, int y), void set(int layer, int x, int y, color) from EMOverlay
color get(int layer, int x, int y) from EMStack
it also depends on color from processing
*/
class ClassificationTree{
  int size;
  int count;
  ClassificationTree(int grid, int pixels){
    size=grid;
    count=pixels;
  }
  ClassificationTree train(EMImage img){
    
    return this;
  }
  ClassificationTree save(File file){
    
    return this;
  }
  
  ClassificationTree load(File file){
    
    return this;
  }
}