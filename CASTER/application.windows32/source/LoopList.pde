class LoopList{
  ListWheel wheel;
  int size=0;
  
  LoopList(Vertex v){
  wheel=new ListWheel(v);
  }
  
  LoopList add(Vertex v){
    this.add(v,size-1);
    
    return this;
  }
  
  LoopList add(Vertex v,int i){
    ListWheel temp=new ListWheel(v);
    get(i);
    temp.lower=wheel;
    temp.higher=wheel.higher;
    wheel.higher=temp;
    temp.higher.lower=temp;
    wheel=temp;
    size+=1;
    return this;
  }
  
  ListWheel get(int i){
    ListWheel mount=wheel;
    i=i%size;
    while(mount.i!=i){
      boolean dir=(size/2<(i-mount.i % size + size) % size);
      if(dir){
        mount=mount.lower;
      }else{
        mount=mount.higher;
      }
    }
    wheel=mount;
    return wheel;
  }
  
  LoopList set(int i, Vertex v){
      get(i).v=v;
      return this;
  }
  
  ListWheel next(){
    wheel=wheel.higher;
    return wheel;
  }
  
  ListWheel last(){
    wheel=wheel.lower;
    return wheel;
  }
  
}
