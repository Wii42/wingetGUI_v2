extension ListExtension<T> on List<T>{
  T? get(int index){
    if(index < 0 || index >= length){
      return null;
    }
    return this[index];
  }
}