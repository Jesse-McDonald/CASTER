class Loop{
  LoopList nodes;
  Loop(Vertex vert){
    nodes=new LoopList(vert);
  }
  Loop add(Vertex vert){
    nodes.add(vert);
    return this;
  }
  
}
