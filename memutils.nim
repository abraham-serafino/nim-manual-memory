import options

### array pointers
type ArrayPtr*[T] = object
  arr: ptr UncheckedArray[T]
  l: Natural

template conjure*(T: typedesc, len): Option[ptr ArrayPtr[T]] =
  var p: ptr ArrayPtr[T] =
    cast[ptr ArrayPtr[T]](alloc0(sizeof(ArrayPtr[T])))

  if not p.isNil:
    p.arr = cast[ptr UncheckedArray[T]](alloc0(len * sizeof(T)))
    p.l = len

  var o = if p.isNil or p.arr.isNil: none(ptr ArrayPtr[T])
          else: some(p)
  o

template banish*[T](p: var Option[ptr ArrayPtr[T]]) =
  let unboxed = if p.isSome: get(p) else: nil

  if unboxed != nil:
    if unboxed.arr != nil: dealloc(unboxed.arr)

    unboxed.arr = nil
    dealloc(get(p))

  p = none(ptr ArrayPtr[T])

template len*[T](o: Option[ptr ArrayPtr[T]]): int =
  if o.isNone: 0
  else: get(o).l

template getValueAt*[T](o: Option[ptr ArrayPtr[T]], i: 0..high(int)):
    (bool, T) =

  var ret = (false, default(T))

  if o.isSome:
    let unboxed = get(o)

    if i < unboxed.l and not unboxed.arr.isNil:
      ret = (true, get(o).arr[i])

  ret

template setValueAt*[T](
    o: Option[ptr ArrayPtr[T]], i: 0..high(int), value): bool =

  let unboxed = if o.isSome: get(o) else: nil

  if unboxed != nil and i < unboxed.l and unboxed.arr != nil:
    get(o).arr[i] = value
    true

  else: false

### non-array pointers
template conjure*(T: typedesc): Option[ptr T] =
  var p = cast[ptr T](alloc0(sizeof(T)))
  var o = if p.isNil: none(ptr T)
          else: some(p)
  o

template banish*[T](p: var Option[ptr T]) =
  if p.isSome and get(p) != nil: dealloc(get(p))
  p = none(ptr T)

template `->`*[T](o: Option[ptr T], k: untyped): untyped =
  get(o).k

template `[]`*[T](o: Option[ptr T]): untyped =
  get(o)[]

template `[]=`*[T](o: Option[ptr T], val: untyped): untyped =
  get(o)[] = val

### future-proof "defer" keyword
template withDefer*(cb: proc, body: untyped) =
  try:
    body
  finally:
    cb()
