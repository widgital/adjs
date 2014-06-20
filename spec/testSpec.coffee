
jasmine.getFixtures().fixturesPath = 'base/spec/fixtures/'

describe 'fixcha',->
  it "should do some html yo", ->
    loadFixtures('publisher.html')
    console.log($("p").text())