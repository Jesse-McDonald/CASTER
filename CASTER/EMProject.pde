 
import java.security.SecureRandom;//because I wanted full random for uuid, dont worry about it
import javax.xml.bind.DatatypeConverter;
class EMProject{
  //these are used to verify that the stack is still the same stack
  String path="";
  int layer=0;
  String savedBy;
  int version;
  int numFiles;//number of files in the dir incase some are not .(extension)
  String stackPath;//check if exists, speculate arround if it does not
  String stackTopName;//name of the top image in the stack
  String lastOverlay;
  int width,height;//image size
  boolean stackLoaded;//if we finished load so we can hash and count the stack before the project was saved
  int stackSize;//number of files loaded

  //unique project identifier
  byte[] uuid;
  //some conditions about the project when it was saved
  EMProject(){
    uuid=createUUID();
    stackPath="";
    stackTopName="";
     }
  EMProject(String path){
    this();
    importJson(loadJSONObject(path)); 
    this.path=path;
  }
  EMProject autoSave(){
   if(!path.equals("")){
      save();
   }
   return this;
  }
  EMProject save(){
    if(path.equals("")){
      selectOutput("Select project file","save",null,this);
    }else{
      save(path); 
    }
    
    return this;
  }
  EMProject save(File file){
    if(file!=null){
      path=file.getAbsolutePath();
      save(path);
    }
    return this;
    
  }
  EMProject save(String file){
    saveJSONObject(exportJSON(),file);
    return this;
  }
  JSONObject exportJSON(){
    log.log("Saving project json");
    JSONObject ret=new JSONObject();
    ret.setInt("version",1);
    ret.setString("savedBy",VERSION);
    ret.setInt("numFiles",numFiles);
    ret.setString("stackPath",stackPath);
    ret.setString("topFileName",stackTopName);
    ret.setInt("width",width);
    ret.setInt("height",height);
    ret.setBoolean("stackLoaded",stackLoaded);
    ret.setInt("layer",layer);
    ret.setString("lastOverlay",lastOverlay);
    JSONArray j=new JSONArray();
    for(int i=0;i<sidebar.scroll.colors.size();i++){
     
      JSONObject col=new JSONObject();
      col.setInt("color",sidebar.scroll.colors.get(i).c);
      col.setString("name",sidebar.scroll.colors.get(i).name);
      j.setJSONObject(i,col);
    }
    ret.setJSONArray("Layers",j);
    if(stackLoaded){
      ret.setInt("stackSize",stackSize);
    }
    ret.setString("UUID",exportUUID());

    
    return ret;
  }
  EMProject importJson(JSONObject in){
    int c=0;
    lastOverlay=in.getString("lastOverlay");
    version=in.getInt("version");
    savedBy=in.getString("savedBy");
    numFiles=in.getInt("numFiles",numFiles);
    stackPath=in.getString("stackPath");
    stackTopName=in.getString("topFileName");
    layer=in.getInt("layer");
    width=in.getInt("width",width);
    height=in.getInt("height",height);
    stackLoaded=in.getBoolean("stackLoaded");
    JSONArray j=in.getJSONArray("Layers");
    for(int i=0;i<j.size();i++){
      JSONObject obj=j.getJSONObject(i);
      sidebar.scroll.addColor(obj.getInt("color"),obj.getString("name"));
    }
    if(stackLoaded){
      stackSize=in.getInt("stackSize");
    }
    importUUID(in.getString("UUID"));
   
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
