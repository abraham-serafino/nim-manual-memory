import memutils, options, strformat

### simple, "safe" pointers
var myPtr = conjure int
myPtr[] = 15
assert myPtr[] == 15

banish myPtr
banish myPtr # no issues with double free

# Pointer is an option type; you can use
# isSome and isNone to avoid dereferencing
# a null pointer.
assert myPtr.isNone

try: myPtr[] = 9
# null pointers cannot be dereferenced
except: assert getCurrentException() of UnpackDefect



### dynamically allocated arrays
var a = conjure(Natural, 5)
let a_len = a.len
assert a_len == 5
let (anyValueFound, actualValue) = a.getValueAt(4)

# array is initialized with reasonable bottom values
assert (anyValueFound, actualValue) == (true, Natural(0))

for i in 0 ..< a_len:
  # setValueAt always reports on its success
  assert a.setValueAt(i, 19) == true

# cool - we can do pointer arithmetic!
for i in 0 ..< a_len:
  assert a.getValueAt(i) == (true, Natural(19))

# You cannot write outside the bounds of the array
assert a.setValueAt(9000, 88) == false
# Or read outside the bounds of the array
assert a.getValueAt(9000) == (false, Natural(0))

banish a
assert a.isNone
assert a.len == 0

# Nim forces you to do something with the
# return value from setValueAt.
discard a.setValueAt(0, 99)
# You cannot set a value on a "banish"ed array
assert a.getValueAt(0) == (false, Natural(0))

type Person = object
  name: string
  age: Natural

proc init(this: Option[ptr Person], name: string, age: Natural): bool =
  if this.isSome:
    this->name = name
    this->age = age
    return true

  return false

### Look how easy it is to dynamically allocate space for objects!
var john = conjure Person
var wasInitialized = john.init(name = "john", age = 22)
assert wasInitialized

var mary = conjure Person
wasInitialized = mary.init(name = "mary", age = 23)
assert wasInitialized

var students = Person.conjure(2)
var students_len = students.len

proc cleanUp =
  banish john
  banish mary
  banish students

  assert john.isNone
  assert mary.isNone
  assert students.isNone

# cleanUp() will be called at the end of the defer block -
# so you don't forget to free all your pointers
withDefer(cleanUp):

  # Object pointer Option types can be unboxed with the "->" shorthand
  inc john->age
  assert (john->age) == (mary->age)

  discard students.setValueAt(0, Person(name: "susan", age: 11))
  discard students.setValueAt(1, Person(name: "michael", age: 12))

  var (_, firstStudent) = students.getValueAt(0)
  inc firstStudent.age
  # firstStudent is a *copy* of the object at students[0], so
  # you have to put it back into the array after you change it.
  discard students.setValueAt(0, firstStudent)

  # pointer arithmetic - cool!
  for i in 0 ..< students_len:
    let (wasFound, student) = students.getValueAt(i)
    assert wasFound and student.age == 12

### Prevent dangling pointers:
var myPtr1 = conjure int
myPtr1[] = 1

# let myPtr2 = myPtr1     # <- don't do this!
let myPtr2 = move(myPtr1) # <- do this, instead
assert myPtr1.isNone

assert myPtr2[] == 1
myPtr2[] = 99
assert myPtr2[] == 99
