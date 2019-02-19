class ProgramSettings{
 int maxPixelCache=1400000;
 int monitorPPI=100;
 int maxProgramRam=120000;
 int undoDepth=100;
 boolean autoOpen=true;
 String lastProject="";
 ProgramSettings(String path){
   this(loadJSONObject(path)); 
 }
 ProgramSettings(JSONObject json){
   load(json);
 }
 ProgramSettings load(String path){
   return load(loadJSONObject(path)); 
 }
 ProgramSettings load(JSONObject settingsJSON){
  maxPixelCache=settingsJSON.getInt("maxPixelCache");
  maxProgramRam=settingsJSON.getInt("maxProgramRam");
  monitorPPI=settingsJSON.getInt("monitorPPI");
  undoDepth=settingsJSON.getInt("undoDepth"); 
  if(monitorPPI==-1){
   monitorPPI=Toolkit.getDefaultToolkit().getScreenResolution();//this does not get true dpi, but it gets the dpi according to the os so good enought
  }
  autoOpen=settingsJSON.getBoolean("autoOpen");
  lastProject=settingsJSON.getString("lastProject");
  return this;
 }
}
