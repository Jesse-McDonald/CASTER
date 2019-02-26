//this class is a data container for EM meta data, currently it is only th xy shift, but any data that can be applied to a layer as a whole can be put here
class EMMeta{
 public int offsetX;
 public int offsetY;
 EMMeta(){
  offsetX=0;
  offsetY=0;
 }
 JSONObject exportJSON(){
  JSONObject ret=new JSONObject();
  ret.setInt("offsetX",offsetX);
  ret.setInt("offsetY",offsetY);
  return ret;
 }
 EMMeta importJSON(JSONObject in){
  offsetX=in.getInt("offsetX");
  offsetY=in.getInt("offsetY");
  return this;
 }
}
