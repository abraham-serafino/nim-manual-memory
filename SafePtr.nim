type SafePtr* = object
  size: 0..high(int)
  data: pointer

proc `=copy`* (dest: var SafePtr, source: SafePtr) =
  assert false,
    "A SafePtr cannot be copied; consider moving it instead."

proc copy* (dest: var SafePtr, source: SafePtr) =
  let size = source.size
  if dest.data != nil: dealloc(dest.data)

  dest.size = size
  dest.data = alloc(size)
  assert dest.data != nil, "Allocation failed."

  dest.data.copyMem(source.data, size)

proc conjure* (t: typedesc): SafePtr =
  let size = sizeof(t)
  result.size = size
  result.data = alloc0(size)
  assert result.data != nil, "Allocation failed."

proc banish* (this: var SafePtr) =
  if this.data != nil:
    dealloc(this.data)
    this.data = nil

proc isNil* (this: SafePtr): bool = this.data == nil

proc isNotNil* (this: SafePtr): bool = this.data != nil

proc `[]`*[T] (this: SafePtr, t: typedesc[T]): var T =
  assert this.data != nil, "Nil pointer access."
  assert this.size >= sizeof(t),
    "Pointer references an object larger than the specified type."

  result = cast[ptr T](this.data)[]

proc `[]=`*[T] (this: var SafePtr, t: typedesc[T], value: T) =
  assert this.data != nil, "Nil pointer access."
  assert this.size >= sizeof(t),
    "Pointer references an object larger than the specified type."

  cast[ptr T](this.data)[] = value
