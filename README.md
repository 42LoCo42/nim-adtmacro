```nim
# A call like this...
adt Foo:
  Var1:
    foo: int
    bar: string
  Var2:
    baz:  float
    quux: char
  
# ...will generate the following types:
type
  Foo = ref FooObj
  FooKind = enum
    Var1,
    Var2
  FooObj = object
    case kind: FooKind
      of Var1:
        foo: int
        bar: string
      of Var2:
        baz:  float
        quux: char
 
# and you can do this:
let abc = Foo(kind: Var1, foo: 42, bar: "ADTs are cool")
let def = Foo(kind: Var2, baz: 13.37, quux: '*')
echo abc.repr, ", ", def.repr
```
