import java.util.Date;
import java.text.SimpleDateFormat;
class Log{
  String logFile;
  ArrayList<String> logs; 
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
  Log(){
   
    logFile=timeStampF()+".log";
    
    logs=new ArrayList<String>();
  }
  void log(String msg){
    String lg=timeStamp();
    lg+=" "+msg;
    logs.add(lg);
  }
  void saveLog(){
    String[] strings=new String[logs.size()];
    for(int i=0;i<strings.length;i++){
      strings[i]=logs.get(i); 
    }
    saveStrings(logFile,strings);
  }
  void printlog(){
    println(logFile);
    for(int i=0;i<logs.size();i++){
      println(logs.get(i)); 
    } 
  }
}
class ProccessDebugger{
  ProcessNode tree;
  Log log;
  ProccessDebugger(){}
  ProccessDebugger(Log ilog){log=ilog;}
  String debug(){
    String ret="null";
    if(tree!=null){
      ret=tree.tablify(); 
    }
    println(ret);
    return ret;
  }
  ProcessNode genNode(){
    ProcessNode node=new ProcessNode(new Process());
    node.log=log;
    return node; 
  }
  ProcessNode genNode(ProcessNode p){
    ProcessNode ret= new ProcessNode(new Process());
    ret.parrent=p;
    ret.log=log;
    p.children.add(ret);
    return ret;
  }
}

class ProcessNode{
  String path="";
  ProcessNode parrent;
  Process self;
  Log log;
  ArrayList<ProcessNode> children;
  ProcessNode(){
    parrent=null;
    self=null;
    children=new ArrayList<ProcessNode>();
  }
  ProcessNode(ProcessNode p){
   this();
   parrent=p;
  }
  ProcessNode(Process s){
   this();
   self=s;
  }
   long start(){
     if(log!=null){
       log.log(path+"Starting");  
     }
    return self.start();
  }
  void mapParrents(){
    path+=self.name+" ";
    for(int i=0;i<children.size();i++){
       children.get(i).path=path;
       children.get(i).mapParrents();
    }
  }
  float stop(){
    if(log!=null){
       log.log(path+"Stopping");  
     }
    return self.stop();
  }
  String pad(String padding,int d){
    String ret="";
    for(int i=0;i<d;i++){
      ret+=padding; 
    }
    return ret;
  }
  String tablify(){
    String ret="Last\tAVG\tTotal\tittr\tTree\n";

    ret+=tablify(0,true);
    return ret;
  }
  String tablify(int d,boolean last){
    String ret="";
    String end="";
    if(last){
      end+='└';
    }else{
      end+='├';
    }
    if(d==0){
      end="";
    }
    if(children.size()>0){
      end+='┬';
    }else{
      end+='─' ;
    }
    
    if(self!=null){
     ret+=self.tabify()+pad("│",d)+end+self.name+'\n';  
    }
    for(int i=0;i<children.size()-1;i++){
      ret+=children.get(i).tablify(d+1,false);
    }
    if(children.size()>0){
      ret+=children.get(children.size()-1).tablify(d+1,true);
    }
    return ret; 
  }
}
class Process{
  long lastStart;
  long lastEnd;
  float lastTime;
  float totalTime;
  long itterations;
  String name;
  Log log;
  Process(){}
  Process(String iname){
    name=iname; 
  }
  long start(){
    lastStart= (new Date()).getTime();
    return lastStart;
  }
  float stop(){
    lastEnd= (new Date()).getTime();
    lastTime=(lastEnd-lastStart)/1000.;
    totalTime+=lastTime;
    itterations++;
    return lastTime;
  }
  float getAverage(){
    return totalTime/itterations; 
  }
  String stringify(){
    return name+"\t"+tabify(); 
  }
  String tabify(){
    return  String.format("%.3f",lastTime )+"\t"+String.format("%.3f",getAverage() )+"\t"+String.format("%.3f",totalTime )+"\t"+String.format("%04d",itterations);
  }
  
}
int slowFib(int a){
  return slowFibR(a*2);
}
int slowFibR(int a){
  if(a<=2){
    return 1;
  }else{
    return slowFibR(a-1)+slowFibR(a-2); 
  }
}
