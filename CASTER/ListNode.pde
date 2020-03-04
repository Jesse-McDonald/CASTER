class ListNode<Data>{
  Data data;
  ListNode next;
  ListNode last;
  ListNode(){
   data=null;
   next=null;
   last=null;
  }
  ListNode(Data node){
    data=node;
    next=null;
    last=null;
  }
}
