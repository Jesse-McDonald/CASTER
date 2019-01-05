//FBuffer is fast buffer, it works like a queue except that it never grows and objects fall off the end.
//To make this work we have a finite array and then we move the start of the array to a different location in the array
//for all accesses, this way its like we shift the entire array over, but we never have to move anything
class FBuffer<T>{
 T[] array;
 private int startIndex;//this is the 0 index right now, subject to change. but we reeaaly dont want someone else changing it on us
 int size;
 int first;//index of top most set by most recent push or pop
 int written;//total number written, not greater than or equal to size
 FBuffer(T[] useThis){//supply the class with a pre initilised array to use because java is a real pain in the ass almost all the time and you cant easily create a new array of generic objects for no good reason
    startIndex=0;
    array = useThis;//useThis is sacrificial, we really dont care what it is, and we will over write all of it
   
    size=array.length; 
    for(int i=0;i<size;i++){//speaking of overwriting, lets do that now, for saftey
      array[i]=null;
    }
    
 }
 T get(int i){//because I cant overload [] operator for some reason
   return array[(((startIndex-i)%size)+size)%size];
 }
 FBuffer set(int i, T content){//because I cant overload [] operator for some reason
   array[(((startIndex-i)%size)+size)%size]=content;
   return this;
 }
 T top(){
  return this.get(0); 
 }
 T next(){
   if(startIndex==first){
     return null; 
   }else{
    startIndex=(startIndex+1)%size;

    return this.get(0);  
   }
 }
 T prev(){
   if((((first-startIndex)%size)+size)%size>=written){
     return null; 
   }else{
     startIndex=((startIndex-1)+size)%size;
     
     return this.get(0);  
   }
   
 }
 FBuffer push(T content){//supprisingly I would not want to overload anything for this
   startIndex=(startIndex+1)%size;//I dont think startIndex can be negative under these rules
   array[startIndex]=content;
   
   first=startIndex;
   written=min(written+1,size);
   return this;
 }
 T pop(){//same here;
   T temp=array[startIndex];
   array[startIndex]=null;
   startIndex=((startIndex-1)+size)%size;//I think we can skip the first mod in this case, not sure though
   first=startIndex;
   written=max(written-1,0);
   return temp; 
 }
 boolean isEmpty(){
   for(int i=0;i<size;i++){//speaking of overwriting, lets do that now, for saftey
      if(array[i]!=null){
        return true; 
      }
    }
    return false;
 }
}