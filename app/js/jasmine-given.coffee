((jasmine) ->

  mostRecentlyUsed = null

  stringifyExpectation = (expectation) ->
    matches = expectation.toString().replace(/\n/g,'').match(/function\s?\(.*\)\s?{\s*(return\s+)?(.*?)(;)?\s*}/i)
    if matches and matches.length >= 3 then matches[2].replace(/\s+/g, ' ') else ""

  jasmine._given =
    matchers:
      toHaveReturnedFalseFromThen: (context, n, done) ->
        result = false
        exception = undefined
        try
          result = @actual.call(context, done)
        catch e
          exception = e
        @message = ->
          msg = "Then clause#{if n > 1 then " ##{n}" else ""} `#{stringifyExpectation(@actual)}` failed by "
          if exception
            msg += "throwing: " + exception.toString()
          else
            msg += "returning false"
          msg

        result == false

  beforeEach ->
    @addMatchers(jasmine._given.matchers)
  root = @

  root.Given = ->
    mostRecentlyUsed = root.Given
    beforeEach getBlock(arguments)

  whenList = []

  root.When = ->
    mostRecentlyUsed = root.When
    b = getBlock(arguments)
    beforeEach ->
      whenList.push(b)
    afterEach ->
      whenList.pop()

  invariantList = []

  root.Invariant = (invariantBehavior) ->
    mostRecentlyUsed = root.Invariant
    beforeEach ->
      invariantList.push(invariantBehavior)
    afterEach ->
      invariantList.pop()

  getBlock = (thing) ->
    setupFunction = o(thing).firstThat (arg) -> o(arg).isFunction()
    assignResultTo = o(thing).firstThat (arg) -> o(arg).isString()
    doneWrapperFor setupFunction, (done) ->
      context = jasmine.getEnv().currentSpec
      result = setupFunction.call(context, done)
      if assignResultTo
        unless context[assignResultTo]
          context[assignResultTo] = result
        else
          throw new Error("Unfortunately, the variable '#{assignResultTo}' is already assigned to: #{context[assignResultTo]}")

  mostRecentExpectations = null

  declareJasmineSpec = (specArgs, itFunction = it) ->
    label = o(specArgs).firstThat (arg) -> o(arg).isString()
    expectationFunction = o(specArgs).firstThat (arg) -> o(arg).isFunction()
    mostRecentlyUsed = root.subsequentThen
    mostRecentExpectations = expectations = [expectationFunction]

    itFunction "then #{label ? stringifyExpectation(expectations)}", doneWrapperFor(expectationFunction, (done) ->
      block() for block in (whenList ? [])
      for expectation, i in invariantList.concat(expectations)
        expect(expectation).not.toHaveReturnedFalseFromThen(jasmine.getEnv().currentSpec, i + 1, done)
    )
    Then: subsequentThen
    And: subsequentThen

  doneWrapperFor = (func, toWrap) ->
    if func.length == 0
      -> toWrap()
    else
      (done) -> toWrap(done)


  root.Then = ->
    declareJasmineSpec(arguments)

  root.Then.only = ->
    declareJasmineSpec(arguments, it.only)

  root.subsequentThen = (additionalExpectation) ->
    mostRecentExpectations.push additionalExpectation
    this

  mostRecentlyUsed = root.Given
  root.And = ->
    mostRecentlyUsed.apply this, jasmine.util.argsToArray(arguments)

  o = (thing) ->
    isFunction: ->
      Object::toString.call(thing) is "[object Function]"

    isString: ->
      Object::toString.call(thing) is "[object String]"

    firstThat: (test) ->
      i = 0
      while i < thing.length
        return thing[i]  if test(thing[i]) is true
        i++
      return undefined

) jasmine
