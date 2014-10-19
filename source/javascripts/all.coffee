//= require idangerous.swiper.js
//= require l10n
//= require localizations
//= require math
//= require_tree .

$expression = document.getElementById("expression")
$buttons = document.getElementById("buttons")
$result = document.getElementById("result")

operators = ["^", "/", "*", "-", "+", "×", "−", "÷",","]
units = ["m", "in", "ft", "mi", "L", "floz", "cp", "pt", "g", "kg", "oz", "lb", "K", "°C", "°F"]
restart = null
swiping = false
history = []

document.title = 'name'.toLocaleString()
document.documentElement.lang = String.locale || document.documentElement.lang

mySwiper = new Swiper '.swiper-container',
  loop: true,
  moveStartThreshold: 32,
  resistance: false,
  onSlideChangeStart: ->
    swiping = true
  onSlideChangeEnd: ->
    swiping = false

humanize = (number) ->
  math.format(number, 6).toString().
    replace(/-/g, "−").
    replace(/deg/g, "°")

compile = (string) ->
  string.
    replace(/→/g, "to").
    replace(/×/g, "*").
    replace(/−/g, "-").
    replace(/÷/g, "/").
    replace(/√/g, "sqrt").
    replace(/π/g, "PI").
    replace(/mod/g, "%").
    replace(/rand/g, "random()").
    replace(/dice/g, "ceil(6*random())").
    replace(/log/g, "log10").
    replace(/ln/g, "log").
    replace(/°/g, "deg")

doDigit = (button) ->
  doClear() if restart
  string = button.textContent
  $expression.value += string
  history.push string

doFunction = (button) ->
  string = button.textContent + "("
  if restart
    string += humanize(restart) + ")"
    doClear()
  $expression.value += string
  history.push string

doSpace = ->
  string = " "
  $expression.value += string
  history.push string
  restart = null

getResult = ->
  string = humanize(restart)
  string = "(" + string + ")" if restart.re and restart.im

  $expression.value = string
  history = [string]
  restart = null

doUnit = (button) ->
  getResult() if restart
  string = button.textContent
  if history[history.length - 1] in units
    doBackspace()
  $expression.value += string
  history.push string

doOperator = (button) ->
  getResult() if restart
  if history[history.length - 1] in operators
    doBackspace()
  string = button.textContent
  $expression.value += string
  history.push string

doClear = ->
  $expression.value = ""
  $result.value = ""
  history = []
  restart = null

doBackspace = ->
  last = history.pop()
  $expression.value = $expression.value.slice(0, 0 - last.length)
  restart = null

fixParentheses = ->
  open = ($expression.value.match(/\(/g) || []).length
  close = ($expression.value.match(/\)/g) || []).length
  for n in [0 ... open-close] by 1
    $expression.value += ")"
    history.push ")"

doEqual = ->
  if $expression.value
    try
      fixParentheses()
      result = math.eval compile($expression.value)
      $result.value = humanize(result)
      restart = result
    catch
      $result.value = 'error'.toLocaleString()

event = if 'ontouchend' in document.documentElement then 'touchend' else 'click'

$buttons.addEventListener event, (e) ->
  return if swiping
  button = e.target
  switch e.target.className
    when "button digit"
      doDigit button
    when "button function"
      doFunction button
    when "button space"
      doSpace button
    when "button unit"
      doUnit button
    when "button operator"
      doOperator button
    when "button clear"
      doClear button
    when "button backspace"
      doBackspace button
    when "button equal"
      doEqual button
