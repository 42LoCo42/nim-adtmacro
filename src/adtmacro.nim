import std/[macros, sugar]

macro adt*(name: untyped, blok: untyped) =
  ## Generates an Algebraic Data Type (ADT).
  runnableExamples:
    # A call like this...
    adt Foo:
      Var1:
        foo: int
        bar: string
      Var2:
        baz:  float
        quux: char
  runnableExamples:
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

  # default type suffixes
  let kindName = ident $name & "Kind"
  let objName  = ident $name & "Obj"

  var kinds = newSeq[NimNode]() # this holds all kinds for the "FooKind" enum

  # all variants aka the body of the case statement
  var variants = collect:
    for variant in blok:
      let identDefs = collect:
        # variant[1] has the "foo: int", "bar: string" fields
        for field in variant[1]:
          # field[0] is the field name, field[1][0] the type
          newIdentDefs(field[0], field[1][0])

      # store variant[0] = the variant name in kinds for enum creation
      kinds.add variant[0]

      # create of-branch for case
      nnkOfBranch.newTree(
        variant[0], # variant name = kind
        nnkRecList.newTree(
          identDefs # list of field definitions
        )
      )

  # the case statement begins with a definition "kind: FooKind"
  variants.insert(newIdentDefs(ident "kind", kindName))

  result = nnkTypeSection.newTree(
    # reference declaration: Foo = ref FooObj
    nnkTypeDef.newTree(
      name,
      newEmptyNode(),
      nnkRefTy.newTree(
        objName
      )
    ),

    # kind declaration: enum FooKind
    # we take [0] because newEnum creates a TypeSection containing
    # the TypeDef we are interested in
    newEnum(kindName, kinds, false, false)[0],

    # object declaration: FooObj = object ...
    nnkTypeDef.newTree(
      objName,
      newEmptyNode(),
      nnkObjectTy.newTree(
        newEmptyNode(),
        newEmptyNode(),
        nnkRecList.newTree(
          nnkRecCase.newTree(
            variants # variants is the body of the case statement
          )
        )
      )
    )
  )
