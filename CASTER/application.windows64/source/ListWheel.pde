//a link in my loop list data type (only for vertecis) it tracks the next, the last, and its own index aswell as the data type, 
class ListWheel{
  Vertex v;
  int i;
  ListWheel lower;
  ListWheel higher;
  ListWheel(Vertex vert){//call only as first call
     v=vert;
     i=0;
     lower=this;
     higher=this;
  }
  ListWheel(Vertex vert, ListWheel l, ListWheel h){
    v=vert;
     lower=l;
     i=lower.i+1;
     higher=h;
     higher.updateI();
  }
  
  ListWheel updateI(){
    if(i==0){
      
    }else{
      i=lower.i+1;
      if(higher.i!=i+1){
       higher.updateI(); 
      }
    }     
    return this;
  }
  
  Vertex get(){
   return v;
  }
  
  ListWheel set(Vertex vert){
   this.v=vert;
   return this;
  }
}
