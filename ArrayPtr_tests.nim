import unittest, ArrayPtr

suite "ArrayPtr":
  test "ArrayPtr's cannot be copied":
    expect AssertionDefect:
      var ptr1: ArrayPtr[int]
      var ptr2 = ptr1

  test "conjure() creates an ArrayPtr":
    let myPtr = conjure(int, 1)
    check myPtr of ArrayPtr[int]

  test "banish() deallocates and sets the pointer to nil":
    var myPtr = conjure(int, 5)
    banish myPtr
    check myPtr.isEmpty and not myPtr.isNotEmpty
    check myPtr.len == 0

  test "[] operator cannot dereference an empty array":
    var myPtr = conjure(bool, 5)
    banish myPtr

    expect AssertionDefect:
      let temp = myPtr[0]

  test "[]= operator cannot dereference a nil pointer":
    var myPtr = conjure(int, 5)
    banish myPtr

    expect AssertionDefect:
      myPtr[3] = 1

  test "[] and []= operators dereference the pointer":
    var myPtr = conjure(int, 5)

    for i in 0 ..< myPtr.len: myPtr[i] = 5
    for i in 0 ..< myPtr.len: check myPtr[i] == 5

  test "[] operator allows object elements to be mutated":
    type TestObj = object
      testValue: int

    var myPtr = conjure(TestObj, 2)
    myPtr[0].testValue = 5
    myPtr[1].testValue = 5

    inc myPtr[1].testValue

    check myPtr[0].testValue == 5
    check myPtr[1].testValue == 6

  test "out-of-bounds indexes cannot be accessed":
    var myPtr = conjure(int, 4)

    expect AssertionDefect:
      myPtr[4] = 1

echo ""
