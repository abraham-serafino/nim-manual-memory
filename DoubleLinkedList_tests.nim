import unittest, DoubleLinkedList

suite "DoubleLinkedList":
  test "list is initialized with zero elements":
    let list = DoubleLinkedList()
    check list.len == 0

  test "elements can be inserted anywhere in the list":
    var list: DoubleLinkedList
    check list.insert(0, 3)
    check list.insert(0, 1)
    check list.insert(1, 2)
    check list.len == 3

    var currVal: int
    check list.get(0, currVal) == true and currVal == 1
    check list.get(1, currVal) == true and currVal == 2
    check list.get(2, currVal) == true and currVal == 3

  test "elements of different types can be inserted into the list":
    type Zeroed = enum Zero

    var list: DoubleLinkedList
    check list.insert(0, 2)
    check list.insert(0, cstring("1"))
    check list.insert(0, Zero)

    var zero: Zeroed
    check list.get(0, zero) and zero == Zero

    var one: cstring
    check list.get(1, one) and one == "1"

    var two: int
    check list.get(2, two) and two == 2

  test "elements can be removed from any position in the list":
    var list: DoubleLinkedList

    check list.insert(0, 4)
    check list.insert(0, 3)
    check list.insert(0, 2)
    check list.insert(0, 1)

    var removed: int
    check list.remove(1, removed) == true and removed == 2
    check list.remove(2, removed) == true and removed == 4
    check list.remove(0, removed) == true and removed == 1
    check list.remove(0, removed) == true and removed == 3
    check not list.remove(0, removed)

    check list.len == 0

  test "elements at any index can be mutated":
    var list: DoubleLinkedList
    check list.insert(0, 3)
    check list.insert(0, 1)
    check list.insert(1, 2)

    var currVal: int
    for i in 0 ..< list.len:
      check list.get(i, currVal)
      check list.set(i, currVal - i)

    for i in 0 ..< list.len:
      check list.get(i, currVal) == true and currVal == 1

  test "DoubleLinkedList cannot be copied":
    var list: DoubleLinkedList
    expect AssertionDefect:
      var list2 = list

echo ""
