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
      log.log("Excesivly large snap");
      System.err.println("Warning, this log is getting large, you may crash if you keep making logs this size");
    }

    return this;
    
  }
  HistorySnap redo(EMImage target){
    log.start("HistorySnap.redo()");
    target.overlay.logChanges=false;
    for(int i=0;i<before.size();i++){
      target.overlay.set(layer,before.get(i).x,before.get(i).y,after.get(i));
    }
    target.overlay.logChanges=true;
    if(layer!=-1){
    target.layer=layer;
    }
    log.stop();
    return this;
  }
  HistorySnap undo(EMImage target){
    log.start("HistorySnap.undo()");
    target.overlay.logChanges=false;
   
    for(int i=before.size()-1;i>=0;i--){//turns out you should go through the list backwards, suppose I do a=1, a=2, a=1, history logs it as 0,1 1,2 2,1 and then undoes it from 1 to 0, then  1 to 2 and then from 2 to 1, final state being 1, not 0
      target.overlay.set(layer,before.get(i).x,before.get(i).y,before.get(i).c);
    }
    target.overlay.logChanges=true;
    if(layer!=-1){
      target.layer=layer;
    }
    log.stop();
    return this;
  }
}
