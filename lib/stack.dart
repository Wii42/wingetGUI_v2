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

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  int get length => _items.length;
}
