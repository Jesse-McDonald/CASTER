class ProgramSettings{
 int maxPixelCache=1400000;
 int monitorPPI=100;
 boolean saveMonitorPPI=true;
 int maxProgramRam=120000;
 int undoDepth=100;
 int maxFastCache=10;
 int maxPNGCache=1000;
 boolean logExecution;
 boolean autoOpen=true;
 String lastProject="";
 float floodSpeed=1;
 JSONObject raw;
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
   raw=settingsJSON;
  maxPixelCache=settingsJSON.getInt("maxPixelCache");
  maxFastCache=settingsJSON.getInt("MaxFastCache");
  maxPNGCache=settingsJSON.getInt("MaxPNGCache");
  maxProgramRam=settingsJSON.getInt("maxProgramRam");
  monitorPPI=settingsJSON.getInt("monitorPPI");
  undoDepth=settingsJSON.getInt("undoDepth"); 
  floodSpeed=settingsJSON.getFloat("floodSpeed");
  logExecution=settingsJSON.getBoolean("LogExecution");
  if(monitorPPI==-1){
    saveMonitorPPI=false;
   monitorPPI=Toolkit.getDefaultToolkit().getScreenResolution();//this does not get true dpi, but it gets the dpi according to the os so good enought
  }
  autoOpen=settingsJSON.getBoolean("autoOpen");
  lastProject=settingsJSON.getString("lastProject");
  return this;
 }
 ProgramSettings save(){
   log.log("program settings saved");
   raw.setInt("maxPixelCache",maxPixelCache);
   raw.setInt("maxProgramRam",maxProgramRam);
   if(saveMonitorPPI){
     raw.setInt("monitorPPI",monitorPPI);
   }else{
     raw.setInt("monitorPPI",-1); 
   }
   raw.setInt("undoDepth",undoDepth); 
   raw.setBoolean("autoOpen",autoOpen);
   raw.setString("lastProject",lastProject);
   saveJSONObject(raw,"data/settings.json");//apparently data/ is only infered on load -_-
   return this;
 }
}
