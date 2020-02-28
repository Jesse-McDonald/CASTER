class Binding<T>{
  T stored;
  Binding(T x){
    stored=x; 
  }
  T get(){
    return stored; 
  }
   void set(T x){
     stored=x; 
   }
}
