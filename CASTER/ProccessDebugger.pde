import java.util.Date;
import java.text.SimpleDateFormat;
import java.util.Stack;
import java.util.LinkedList;
class StackTrace{
  LinkedList<String> logs;
  Stack<Process> stack;
  String filename;
    String timeStamp(){
     Date time=new Date();
     SimpleDateFormat format = new SimpleDateFormat("[yyyy/MM/dd HH:mm:ss.SSS]");
     return format.format(time);
  }
  String timeStampF(){
     Date time=new Date();
     SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH-mm-ss");
     return format.format(time);
  }
  StackTrace(){
    filename=timeStampF()+".log";
    stack = new Stack<Process>();
    logs=new LinkedList<String>();
  }
   void log(String msg){
    String lg=timeStamp();
    lg+=" "+msg;
    logs.add(lg);
  }
  void saveLog(){
    String[] strings=new String[logs.size()];
    int i=0;
    for(String str:logs){
      strings[i]=str;
      i++;
    }
    saveStrings(filename,strings);
  }
  void printLog(){
    println(filename);
    for(String str:logs){
      println(str); 
    } 
  }
  String pad(String padding,int d){
    String ret="";
    for(int i=0;i<d;i++){
      ret+=padding; 
    }
    return ret;
  }
  long start(String name){
     Process proc=new Process(name);
     String log="";
     long time=proc.start();
     log+=timeStamp();
     log+=pad("\t",stack.size());
     log+=name+"{";
     stack.add(proc);
     logs.add(log);
     return time;
  }
  float stop(){
     Process proc=stack.pop();
     String log="";
     float dur=proc.stop();
     log+=timeStamp();
     log+=pad("\t",stack.size());
     log+="}";

     logs.add(log);
     return dur;
  }
  
}


class Process{
  long start;
  long end;
  String name;
  Process(){}
  Process(String iname){
    name=iname; 
  }
  long start(){
    start= (new Date()).getTime();
    return start;
  }
  float stop(){
    end= (new Date()).getTime();
    return (end-start)/1000.;
  }
  
}
