import unittest, SafePtr

suite "SafePtr":
  test "SafePtr's cannot be copied":
    expect AssertionDefect:
      var ptr1: SafePtr[int]
      var ptr2 = ptr1

  test "conjure() creates a SafePtr":
    let myPtr = conjure int
    check myPtr of SafePtr[int]

  test "banish() deallocates and sets the pointer to nil":
    var myPtr = conjure int
    banish myPtr
    check myPtr.isNil and not myPtr.isNotNil

  test "[] operator cannot dereference a nil pointer":
    var myPtr = conjure array[5, bool]
    banish myPtr

    expect AssertionDefect:
      let temp = myPtr[]

  test "[]= operator cannot dereference a nil pointer":
    var myPtr = conjure cstring
    banish myPtr

    expect AssertionDefect:
      myPtr[] = cstring("Hello world")

  test "[] and []= operators dereference the pointer":
    var myPtr = conjure int
    myPtr[] = 5
    check myPtr[] == 5

  test "-> operator allows object pointers to be mutated":
    type TestObj = object
      testValue: int

    var myPtr = conjure TestObj
    myPtr->testValue = 5
    check myPtr[].testValue == 5

echo ""
