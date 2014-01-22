###*
 * @author inorganik
 * @example
 * numAnim = new countUp "SomeElementYouWantToAnimate", 99.99, 2, 1.5
 * numAnim.start()
 * @version 0.0.6
###
class countUp
  useEasing: true
  startTime: null
  remaining: null
  rAF: null

  ###*
   * @param {String} target Id of Html element where counting occurs.
   * @param {Number} startVal The value you want to start at.
   * @param {Number} endVal The value you want to arrive at.
   * @param {Integer} decimals=0 Number of decimal places in number.
   * @param {Float} duration=2 Duration in seconds.
  ###
  constructor: (target, startVal, endVal, decimals=0, duration=2) ->
    lastTime = 0
    vendors = ['webkit', 'moz','ms']

    @doc = document.getElementById target
    startVal = Number startVal  
    endVal = Number endVal
    @countDown = if startVal > endVal then true else false
    decimals = Math.max(0, decimals)
    @dec = Math.pow(10, decimals)
    @duration = duration * 1000
    @frameVal = startVal

    # make sure requestAnimationFrame and cancelAnimationFrame are defined
    # polyfill for browsers without native support by Opera engineer Erik
    # Möller
    while x < vendors.length and not window.requestAnimationFrame
      window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame']
      window.cancelAnimationFrame =
        window[vendors[x] + 'CancelAnimationFrame'] || window[vendors[x] + 'CancelRequestAnimationFrame']

    unless window.requestAnimationFrame
      window.requestAnimationFrame = (callback, element) ->
        currTime = new Date().getTime()
        timeToCall = Math.max 0, 16 - (currTime - lastTime)

        id = window.setTimeout(->
          callback currTime + timeToCall
        , timeToCall)

        lastTime = currTime + timeToCall
        id

    unless window.cancelAnimationFrame
      window.cancelAnimationFrame = (id) ->
        clearTimeout id

  # format startVal on initialization
  @doc.innerHTML = @addCommas startVal.toFixed(decimals)

  # Robert Penner's easeOutExpo
  easeOutExpo: (t, b, c, d) ->
    c * (-Math.pow(2, -10 * t / d) + 1) * 1024 / 1023 + b

  count: (timestamp) ->
    @startTime = timestamp if @startTime is null
    progress = timestamp - @startTime
      
    # to ease or not to ease is the question
    if @useEasing
      if @countDown
        i = @easeOutExpo progress, 0, startVal - endVal, @duration
        @frameVal = startVal - i
      else
        @frameVal = @easeOutExpo(progress, startVal, endVal - startVal, @duration)
    else
      if @countDown
        i = (startVal - endVal) * (progress / @duration)
        @frameVal = startVal - i
      else
        @frameVal = startVal + (endVal - startVal) * (progress / @duration)
        
    # decimal
    @frameVal = Math.round(@frameVal * @dec) / @dec

    # don't go past enVal since progress can exceed duration in last grame
    if @countDown
      @frameVal = if (@framVal < endVal) then endVal else @frameVal
    else
      @frameVal = if (@framVal > endVal) then endVal else @frameVal

    # formate and print value
    @doc.innerHTML = @addCommas @frameVal.toFixed(decimals)

    # weather to continue
    if progress < @duration
      @rAF = requestAnimationFrame @count
    else
      @callback() if @callback?


  start: (@callback) ->
    # make sure endVal is a number
    unless isNaN(endVal) and isNan(startVal) isnt null
      requestAnimationFrame @count
    else
      console.log('countUp error: startVal or endVal is not a number')
      @doc.innerHTML = '--'
    false

  stop: ->
    cancelAnimationFrame @rAF

  reset: ->
    stop()
    @doc.innerHTML = @addCommas startVal.toFixed(decimals)

  resume: ->
    @startTime = null
    @duration = @remaining
    @startVal = @framVal
    requestAnimationFrame @count

  ###*
   * add commas to a number every 3 places
   * @param {String|Number} nStr
   * @return {String} the comma-delimited number
  ###
  addCommas: (nStr) ->
    [x1, x2] = String(nStr).split('.')
    x2 = if x2? then "." + x2 else ''

    rgx = /(\d+)(\d{3})/
    while rgx.test(x1)
      x1 = x1.replace(rgx, '$1' + ',' + '$2')

    x1 + x2
