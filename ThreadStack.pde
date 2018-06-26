class ThreadStack extends Thread{
  EMStack target;
  ThreadStack(EMStack given){
    target=given;
  }
  public void run(){
    int startTime;
    while(target.progress<target.files.length){
      startTime=millis();
      //PNGImage temp=new PNGImage(
      
      target.frameLoadStack();
      //println(millis()-startTime);
    }
    target.files=null;
  }
}