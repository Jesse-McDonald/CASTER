class LoopList<Data>{
  ListNode<Data> current;
  ListNode<Data> start;
  ListNode<Data> end;
  LoopList(){
   current=null;
   start=null;
   end=null;
  }
  LoopList set(Data data){
    ListNode<Data> temp=new ListNode<Data>(data);
    if(current!=null){
       temp.next=current.next;
       temp.last=current;
       current.next=temp;
       if(temp.next!=null){
        temp.next.last=temp; 
       }else{
        end=temp; 
       }
       current=temp;
    }else if(end!=null){//current some how not existant, go to end
      current=temp;
      end.next=current;
      current.last=end;
      end=current;
    }else{//new list
      start=temp;
      current=start;
      end=start;
    }
    return this;
  }
  ListNode get(){
    return current; 
  }
  ListNode getNext(){
    if(current!=null){
      return current.next; 
    }else{
      return start; 
    }
  }
  
  ListNode getPrevious(){
    if(current!=null){
      return current.next; 
    }else{
      return end; 
    }
  }
  LoopList loop(){
    if(start!=null&end!=null){
      start.last=end;
      end.next=start;
    }
    return this;
  }
  LoopList breakLoop(){
    if(start!=null&end!=null){
      start.last=null;
      end.next=null;
    }
    return this;
  }
}
