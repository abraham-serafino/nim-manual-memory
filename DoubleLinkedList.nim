# SafePtr only allows you to have one reference to each memory address,
# so you cannot use it to implement cyclical data structures, such as
# Doubly-linked lists.

# The good news is that these data structures *can* clean up after
# themselves, be self-contained, encapsulate pointers to allocated memory so
# callers can't access them, and avoid being "copied," so as to prevent
# dangling pointers, nil access and double-free errors.

# This example also introduces the "result reference" pattern --
# the practice of 1) returning a boolean success or failure value, and
# 2) passing in a reference to a variable that should receive the function's
# output, rather than 1) throwing an exception on failure and 2) returning
# the function's output. This pattern serves as an alternative to Nim's
# memory-unsafe exceptions by forcing the user to do something with the
# success/failure value of each function call.

type Node = object
  next: ptr Node = nil
  prev: ptr Node = nil
  data: pointer = nil

type DoubleLinkedList* = object
  firstNode: ptr Node = nil
  len*: int = 0

proc `=copy`* (dest: var DoubleLinkedList, source: DoubleLinkedList) =
  assert false,
    "A DoubleLinkedList cannot be copied; consider moving it instead."

proc deleteFirst (this: var DoubleLinkedList) =
  if this.len == 0 or this.firstNode == nil: return

  let node = this.firstNode
  let next = node.next

  this.firstNode = next

  if next != nil: next.prev = nil

  dealloc node.data
  dealloc node

  if this.len > 0: dec this.len

proc `=destroy` (this: var DoubleLinkedList) =
  while this.len > 0 and this.firstNode != nil:
    this.deleteFirst()

proc nodeAt (this: DoubleLinkedList, index: 0 .. high(int)): ptr Node =
  if this.firstNode == nil or index >= this.len:
    return # result.isNil will be true

  var currNode = this.firstNode

  for i in 0 ..< index:
    if currNode == nil: break
    currNode = currNode.next

  result = currNode

proc insert*[T] (this: var DoubleLinkedList,
    index: 0 .. high(int), value: T): bool =

  result = false

  if index >= this.len and not (index == 0 and this.firstNode == nil):
    return

  let firstNode = this.firstNode

  var newNode = cast[ptr Node](alloc0(sizeof(Node)))
  assert newNode != nil, "Unable to allocate space for node."

  newNode.data = cast[ptr T](alloc0(sizeof(value)))
  assert newNode.data != nil, "Unable to allocate space for node data."

  cast[ptr T](newNode.data)[] = value

  if firstNode == nil:
    if index == 0:
      this.firstNode = newNode
      inc this.len
      result = true

    return

  let next = this.nodeAt(index)
  if next == nil: return
  let prev = next.prev

  newNode.next = next
  next.prev = newNode

  if index == 0: this.firstNode = newNode

  if prev != nil:
    prev.next = newNode
    newNode.prev = prev

  inc this.len
  result = true

proc remove*[T] (this: var DoubleLinkedList,
    index: 0 .. high(int), value: var T): bool =

  result = false

  if index >= this.len or this.firstNode == nil: return

  let node = this.nodeAt(index)
  if node == nil: return
  if node.data != nil: value = cast[ptr T](node.data)[]

  let next = node.next
  let prev = node.prev

  if index == 0: this.firstNode = next

  if next != nil: next.prev = prev
  if prev != nil: prev.next = next

  dealloc node.data
  dealloc node

  if this.len > 0: dec this.len
  result = true

proc get*[T] (this: DoubleLinkedList,
    index: 0 .. high(int), value: var T): bool =

  result = false
  let node = this.nodeAt(index)
  if node == nil or node.data == nil: return

  value = cast[ptr T](node.data)[]
  result = true

proc set*[T] (this: DoubleLinkedList,
    index: 0 .. high(int), value: T): bool =

  result = false
  let node = this.nodeAt(index)
  if node == nil or node.data == nil: return

  cast[ptr T](node.data)[] = value
  result = true
