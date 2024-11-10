type SafePtr*[T] = object
  data: ptr T

proc `=copy`*[T] (dest: var SafePtr[T], source: SafePtr[T]) =
  assert false,
    "A SafePtr cannot be copied; consider moving it instead."

proc conjure*[T] (t: typedesc[T]): SafePtr[T] =
  result.data = cast[ptr T](
    alloc0(sizeof(T)))

  assert result.data != nil, "Allocation failed."

proc banish*[T] (this: var SafePtr[T]) =
  if this.data != nil:
    dealloc(this.data)
    this.data = nil

proc isNil*[T] (this: SafePtr[T]): bool = this.data == nil

proc isNotNil*[T] (this: SafePtr[T]): bool = this.data != nil

proc `[]`*[T] (this: SafePtr[T]): T =
  assert this.data != nil, "Nil pointer access."
  result = this.data[]

proc `[]=`*[T] (this: SafePtr[T], value: T) =
  assert this.data != nil, "Nil pointer access."
  this.data[] = value

template `->`*[T: object] (this: SafePtr[T], prop: untyped): untyped =
  assert this.data != nil, "Nil pointer access."
  this.data.prop
