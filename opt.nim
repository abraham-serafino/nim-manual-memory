type Option*[T] = object
  is_some: bool
  data: T

proc some*[T] (value: T): Option[T] =
  result.is_some = true
  result.data = value

proc none*[T] (t: typedesc[T]): Option[T] =
  result.is_some = false

proc isSome*[T] (self: Option[T]): bool =
  self.is_some

proc isNone*[T] (self: Option[T]): bool =
  not self.is_some

proc get*[T] (self: Option[T]): T =
  if not self.is_some:
    # @TODO repalce with a "cleanQuit" that calls pre-registered quit handlers
    quit("Invalid attempt to access a 'none' Option.")

  result = self.data