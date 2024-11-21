import unittest, SafePtr

suite "SafePtr":
  test "SafePtr's cannot be implicitly copied":
    expect AssertionDefect:
      var ptr1: SafePtr
      var ptr2 = ptr1

  test "Explicitly copying a SafePtr just copies its data":
    var ptr1: SafePtr = conjure int
    ptr1[int] = 3

    var ptr2: SafePtr
    ptr2.copy(ptr1)

    check ptr2 != ptr1
    check ptr2[int] == 3

  test "conjure() creates a SafePtr":
    let myPtr = conjure int
    check myPtr is SafePtr

  test "banish() deallocates and sets the pointer to nil":
    var myPtr = conjure int
    banish myPtr
    check myPtr.isNil and not myPtr.isNotNil

  test "[] operator cannot dereference a nil pointer":
    var myPtr = conjure array[5, bool]
    banish myPtr

    expect AssertionDefect:
      let temp = myPtr[array[5, bool]]

  test "[]= operator cannot dereference a nil pointer":
    var myPtr = conjure cstring
    banish myPtr

    expect AssertionDefect:
      myPtr[cstring] = cstring("Hello world")

  test "[] and []= operators dereference the pointer":
    var myPtr = conjure int
    myPtr[int] = 5
    check myPtr[int] == 5

  test "[] and []= operators are type safe":
    var myPtr = conjure int8

    expect AssertionDefect:
      discard myPtr[int32]

  test "[] operator allows object pointers to be mutated":
    type TestObj = object
      testValue: int

    var myPtr = conjure TestObj
    myPtr[TestObj].testValue = 5
    check myPtr[TestObj].testValue == 5

echo ""
