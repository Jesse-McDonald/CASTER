 
import java.security.SecureRandom;//because I wanted full random for uuid, dont worry about it
import javax.xml.bind.DatatypeConverter;
class EMProject{
  //these are used to verify that the stack is still the same stack

  int numFiles;//number of files in the dir incase some are not .(extension)
  String stackPath;//check if exists, speculate arround if it does not
  String stackTopName;//name of the top image in the stack
  int stackTopHash;//just the hash of the top
  int width,height;//image size
  boolean stackLoaded;//if we finished load so we can hash and count the stack before the project was saved
  int stackSize;//number of files loaded
  int stackHash;
  //unique project identifier
  byte[] uuid;
  //some conditions about the project when it was saved
  ArrayList<EMMeta> meta;
  EMProject(){uuid=createUUID();}
  EMProject(String path){
    importJson(loadJSONObject(path)); 
  }
  
  JSONObject exportJSON(){

    JSONObject ret=new JSONObject();
    
    ret.setInt("numFiles",numFiles);
    ret.setString("stackPath",stackPath);
    ret.setString("topFileName",stackTopName);
    ret.setInt("topFileHash",stackTopHash);
    ret.setInt("width",width);
    ret.setInt("height",height);
    ret.setBoolean("stackLoaded",stackLoaded);
    if(stackLoaded){
      ret.setInt("stackSize",stackSize);
      ret.setInt("stackHash",stackHash);
    }
    ret.setString("UUID",exportUUID());

    JSONArray mData=new JSONArray();
    for(int i=0;i<meta.size();i++){
      mData.setJSONObject(i,meta.get(i).exportJSON()); 
    }
    ret.setJSONArray("Meta",mData);

    return ret;
  }
  EMProject importJson(JSONObject in){
    numFiles=in.getInt("numFiles",numFiles);
    stackPath=in.getString("stackPath");
    stackTopName=in.getString("topFileName");
    stackTopHash=in.getInt("topFileHash");
    width=in.getInt("width",width);
    height=in.getInt("height",height);
    stackLoaded=in.getBoolean("stackLoaded");
    if(stackLoaded){
      stackSize=in.getInt("stackSize");
      stackHash=in.getInt("stackHash");
    }
    importUUID(in.getString("UUID"));
    JSONArray mData=in.getJSONArray("Meta");
    for(int i=0;i<mData.size();i++){
      EMMeta Meta=new EMMeta();
      meta.add(Meta.importJSON(mData.getJSONObject(i)));
    }
    return this;
  }
  byte[] createUUID(){
    SecureRandom random=new SecureRandom();//I know, I know, a bit over kill for a uuid
    byte[] ret=random.generateSeed(16);
    ret[6]=byte((ret[6])|0x40);
    ret[6]=byte(ret[6]&0x4f);//sets 4 highest bits of 7th byte to 0100 because RFC4122 requires it for some reason
    ret[8]=byte(ret[8]|0x80);
    ret[8]=byte(ret[8]&0xbf);//sets 2 highest bits of 9th byte to 10 also for no good reason
    
    //yah, I am not going to encode the UUID as a string, do I look like someone who would just willy nilly increase the size of an id by 16x?
    return ret;
  }
  public String exportUUID(){//ok so I will encode it if you want
    String ret="";
    if(uuid==null){
      return "no uuid created for this project";
    }
    if(uuid.length!=16){
      return "malformed uuid";
    }
    for(int i=0;i<16;i++){
     if(i==4||i==6||i==8||i==10){
      ret+='-'; 
     }
     ret+=hex(uuid[i]);    
    }
    return ret;
  }
  EMProject importUUID(String in){
    String uuidString="";
    for(int i=0;i<in.length();i++){
      if(in.charAt(i)!='-'){
        uuidString+=in.charAt(i); 
      }
    }
    uuid=DatatypeConverter.parseHexBinary(uuidString);
    return this;
  }
  
}
