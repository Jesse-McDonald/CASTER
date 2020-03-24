class ListNode<Data>{
  Data data;
  ListNode<Data> next;
  ListNode<Data> last;
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
