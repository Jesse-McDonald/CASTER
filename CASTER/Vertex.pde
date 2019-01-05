//a vertex for a graph, intended to be used in list wheel
//depends on color from processing
class Vertex{
  int x=0;//position
  int y=0;
  int insideX=0;//values for this are limited to -1,0, and 1, specifes direction for inside
  int insideY=0;
  ArrayList<Vertex> connections;//all conected verticies
  color c=0;//just in case I want to record color
  Vertex(){
    this(0,0,0,0);
  }
  Vertex(int x, int y, int iX,int iY){
    this.x=x;
    this.y=y;
    insideX=int(x<iX)-int(x>iX);
    insideY=int(y<iY)-int(y>iY);
    connections=new ArrayList<Vertex>();
  }
  Vertex addRay(Vertex other){//add a one way connection from this vertex to another
        this.connections.add(other);
        return this;
  }
  Vertex addEdge(Vertex other){   //add a bidirectional connection betwene 2 vertecies
    this.connections.add(other);
    other.connections.add(this);
    return this;
  }
}