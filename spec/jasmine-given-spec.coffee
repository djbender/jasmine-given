describe "jasmine-given CoffeeScript API", ->
  describe "assigning stuff to this", ->
    Given -> @number = 24
    And -> @number++
    When -> @number *= 2
    Then -> @number == 50
    # or
    Then -> expect(@number).toBe(50)

  describe "assigning stuff to variables", ->
    subject=null
    Given -> subject = []
    When -> subject.push('foo')
    Then -> subject.length == 1
    # or
    Then -> expect(subject.length).toBe(1)

  describe "eliminating redundant test execution", ->
    context "a traditional spec with numerous Then statements", ->
      timesGivenWasInvoked = timesWhenWasInvoked = 0
      Given -> timesGivenWasInvoked++
      When -> timesWhenWasInvoked++
      Then -> timesGivenWasInvoked == 1
      Then -> timesWhenWasInvoked == 2
      Then -> timesGivenWasInvoked == 3
      Then "it's important this gets invoked separately for each spec", -> timesWhenWasInvoked == 4

    context "using And statements", ->
      timesGivenWasInvoked = timesWhenWasInvoked = 0
      Given -> timesGivenWasInvoked++
      When -> timesWhenWasInvoked++
      Then -> timesGivenWasInvoked == 1
      And -> timesWhenWasInvoked == 1
      And -> timesGivenWasInvoked == 1
      And -> timesWhenWasInvoked == 1

    context "chaining Then statements", ->
      timesGivenWasInvoked = timesWhenWasInvoked = 0
      Given -> timesGivenWasInvoked++
      When -> timesWhenWasInvoked++
      Then(-> timesGivenWasInvoked == 1)
      .And(-> timesWhenWasInvoked == 1)
      .And(-> timesGivenWasInvoked == 1)
      .And(-> timesWhenWasInvoked == 1)
      Then -> timesWhenWasInvoked == 2

  describe "Invariant", ->
    context "implicitly called for each Then", ->
      timesInvariantWasInvoked = 0
      Invariant -> timesInvariantWasInvoked++
      Then -> timesInvariantWasInvoked == 1
      Then -> timesInvariantWasInvoked == 2

    context "following a Then", ->
      Given -> @meat = 'pork'
      When -> @meat += 'muffin'
      Then -> @meat == 'porkmuffin'
      And -> @meat != 'hammuffin'

  describe "And", ->
    context "following a Given", ->
      Given -> @a = 'a'
      And -> @b = 'b' == @a #is okay to return false
      Then -> @b == false

    context "following a Then", ->
      Given -> @meat = 'pork'
      When -> @meat += 'muffin'
      Then -> @meat == 'porkmuffin'
      And -> @meat != 'hammuffin'


  describe "giving Given a variable", ->
    context "add a variable to `this`", ->
      Given "pizza", -> 5
      Then -> @pizza == 5

    context "a variable of that name already exists on `this`", ->
      Given -> @muffin = 1
      Given -> spyOn(window, "beforeEach").andCallFake (f) -> f()
      Then -> expect(-> Given "muffin", -> 2).toThrow(
        "Unfortunately, the variable 'muffin' is already assigned to: 1")

    context "a subsequent unrelated test run", ->
      Then -> @pizza == undefined

  describe "Givens before Whens order", ->
      context "Outer block", ->
          Given ->  @a = 1
          Given ->  @b = 2
          When -> @sum = @a + @b
          Then -> @sum == 3

          context "Middle block", ->
            Given -> @units = "days"
            When -> @label = "#{@sum} #{@units}"
            Then -> @label == "3 days"

            context "Inner block A", ->
                Given -> @a = -2
                Then -> @label == "0 days"

            context "Inner block B", ->
                Given -> @units = "cm"
                Then -> @label == "3 cm"

describe "jasmine-given implementation", ->
  describe "returning boolean values from Then", ->
    describe "Then()'s responsibility", ->
      passed=null
      beforeEach ->
        this.addMatchers
          toHaveReturnedFalseFromThen: (ctx) ->
            passed = !this.actual.call(ctx)
            false

      context "a true is returned", ->
        Then -> 1 + 1 == 2
        it "passed", ->
          expect(passed).toBe(false)

      context "a false is returned", ->
        Then -> 1 + 1 == 3
        it "failed", ->
          expect(passed).toBe(true)


  describe 'a failing Invariant will fail a test', ->
    Invariant -> false
    describe 'nested thing', ->
      Then -> jasmine.getEnv().currentSpec.results.failedCount == 1
      And -> jasmine.getEnv().currentSpec.results_ = new jasmine.NestedResults()

  describe "support for jasmine-only style `Then.only` blocks", ->
    Given -> @expectationFunction = jasmine.createSpy('my expectation')
    Given -> spyOn(it, 'only')
    When -> Then.only(@expectationFunction)
    Then -> expect(it.only).toHaveBeenCalledWith jasmine.any(String), jasmine.argThat (arg) =>
      arg()
      @expectationFunction.calls.length == 1


  describe "support for done() style blocks", ->
    describe "Then blocks", ->
      Given -> spyOn(window, 'it')

      context "no-arg Then function", ->
        When -> Then ->
        Then -> expect(it).toHaveBeenCalledWith jasmine.any(String), jasmine.argThat (func) =>
          func.length == 0

      context "done-ful Then function", ->
        When -> Then (done) ->
        Then -> expect(it).toHaveBeenCalledWith jasmine.any(String), jasmine.argThat (func) =>
          func.length == 1






