type ArrayPtr*[T] = object
  data: ptr UncheckedArray[T]
  len*: int

proc `=copy`*[T] (dest: var ArrayPtr[T], source: ArrayPtr[T]) =
  assert false,
    "An ArrayPtr cannot be copied; consider moving it instead."

proc conjure*[T] (t: typedesc[T], len: 0 .. high(int)): ArrayPtr[T] =
  result.data = cast[ptr UncheckedArray[T]](
    alloc0(sizeof(T) * len))

  assert result.data != nil, "Allocation failed."
  result.len = len

proc banish*[T] (this: var ArrayPtr[T]) =
  if this.data != nil:
    dealloc(this.data)
    this.data = nil

  this.len = 0

proc isEmpty*[T] (this: ArrayPtr[T]): bool =
  this.len == 0 or this.data == nil

proc isNotEmpty*[T] (this: ArrayPtr[T]): bool =
  this.len != 0 and this.data != nil

template `[]`*[T] (this: ArrayPtr[T], index: 0 .. high(int)): untyped =
  assert this.data != nil, "Nil pointer access."
  assert this.len > index, "Array index out of bounds."

  this.data[index]

proc `[]=`*[T] (this: ArrayPtr[T], index: 0 .. high(int), value: T) =
  assert this.data != nil, "Nil pointer access."
  assert this.len > index, "Array index out of bounds."

  this.data[index] = value
