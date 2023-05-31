class ListStack<T> {
  final List<T> _items = [];

  void push(T item) {
    _items.add(item);
  }

  T pop() {
    if (_items.isNotEmpty) {
      return _items.removeLast();
    }
    throw Exception("Stack is empty");
  }

  T peek() {
    if (_items.isNotEmpty) {
      return _items.last;
    }
    throw Exception("Stack is empty");
  }
  T peekUnder() {
    if (hasPeekUnder) {
      return _items[_items.length-2];
    }
    throw Exception("Element does not exist");
  }

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  int get length => _items.length;

  bool get hasPeekUnder => (_items.length >=2);

  @override
  String toString() {
    return "{${super.hashCode}, ${_items.toString()}}";
  }
}
