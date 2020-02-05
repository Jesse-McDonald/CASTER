class ThreadStack extends Thread{
  EMStack target;
  ThreadStack(EMStack given){
    target=given;
  }
  public void run(){
    
    int startTime;
    int totalStart=target.files.length;
    boolean newProject=img.project.stackPath.equals("");//if we dont have a stack start we are a new project
    if (newProject){
      img.project.numFiles=target.files.length;
      
    }
    if(target.files.length>0){
      img.project.stackTopName=target.files[0].getName();
      img.project.stackPath=target.files[0].getParent();
    }
    while(target.progress<target.files.length){
      startTime=millis();
      //PNGImage temp=new PNGImage(
      
      target.frameLoadStack();
      //println(millis()-startTime);
    }
    img.project.stackLoaded=true;
    img.project.stackSize=target.img.size();
    img.project.stackHash=target.hashCode();
    target.files=null;
  }
}
