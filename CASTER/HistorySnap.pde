class HistorySnap{
  int layer;//layer the snap was taken on
  ArrayList<Pixel>before;
  ArrayList<Integer>after;
  boolean changed=false;
  HistorySnap(){
    before=new ArrayList<Pixel>();
    after=new ArrayList<Integer>();
  }
  HistorySnap(int l){
    this();
    layer=l;
  }
  HistorySnap log(Pixel point, color change){
    if(point.c!=change){
      before.add(point);
      after.add(change);
      changed=true;
    }
    if(before.size()>12000000){
      System.err.println("Warning, this log is getting large, you may crash if you keep making logs this size");
    }
    return this;
    
  }
  HistorySnap redo(EMImage target){
    target.overlay.logChanges=false;
    for(int i=0;i<before.size();i++){
      target.overlay.set(layer,before.get(i).x,before.get(i).y,after.get(i));
    }
    target.overlay.logChanges=true;
    target.layer=layer;
    return this;
  }
  HistorySnap undo(EMImage target){
    target.overlay.logChanges=false;
   
    for(int i=0;i<before.size();i++){
      target.overlay.set(layer,before.get(i).x,before.get(i).y,before.get(i).c);
    }
    target.overlay.logChanges=true;
    target.layer=layer;
    return this;
  }
}