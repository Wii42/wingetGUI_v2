extension RangeNum on num {
  bool isBetween(num a, num b) {
    //not  ( both greater || both lesser )
    return !((a > this && b > this) || (a < this && b < this));
  }
}
