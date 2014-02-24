version = '201402242100'
console.log version

Array.prototype.remove = (arg) ->
  @splice @indexOf(arg), 1
  
# for finding an object/array in a multidimension array
Array.prototype.remove2 = (arg) ->
  index = -1
  for i in [0...@length]
    if JSON.stringify(@[i]) is JSON.stringify(arg)
      index = i
      break
  if index is -1 then return -1 else @splice index, 1
    
Array.prototype.count2 = (arg) ->
  index = 0
  for i in [0...@length]
    if JSON.stringify(@[i]) is JSON.stringify(arg)
      index++
  index

canvas = document.getElementById 'canvas'
context = canvas.getContext '2d'

width = window.innerWidth
height = window.innerHeight
pixelSize = [15, 10]
pixelWidth = Math.floor(width / pixelSize[0]) - 1
pixelHeight = Math.floor(height / pixelSize[1]) - 1

canvas.width = width
canvas.height = height

background = [255, 255, 255]
stroke = ["rgb(0, 0, 0)", "rgb(255, 255, 255)"]
palette = [
  [191, 0,   0  ],
  [239, 127, 0  ]
  [255, 191, 0  ],
  [0,   191, 0  ],
  [0,   191, 191],
  [31,  0,   191],
  [191, 0,   255],
  [255, 0,   191],
  [0,   0,   0  ] ]
textColor = [191, 191, 191]

hearts = [
           [ [0,0,0],
             [1,0,1],
             [1,1,1],
             [0,1,0],
             [0,0,0] ] ]

finSym = [
           [ [0,0,0],
             [0,0,0],
             [0,0,0],
             [0,0,0],
             [0,0,0] ],

           [ [1,1,1],
             [1,0,0],
             [1,1,1],
             [1,0,0],
             [1,0,0] ],

           [ [1,1,1],
             [0,1,0],
             [0,1,0],
             [0,1,0],
             [1,1,1] ],

           [ [1,1,1],
             [1,0,1],
             [1,0,1],
             [1,0,1],
             [1,0,1] ] ]

numbers = [
            [ [1,1,1],
              [1,0,1],
              [1,0,1],
              [1,0,1],
              [1,1,1] ],
        
            [ [1,1,0],
              [0,1,0],
              [0,1,0],
              [0,1,0],
              [1,1,1] ],
          
            [ [1,1,1],
              [0,0,1],
              [1,1,1],
              [1,0,0],
              [1,1,1] ],
          
            [ [1,1,1],
              [0,0,1],
              [1,1,1],
              [0,0,1],
              [1,1,1] ],
          
            [ [1,0,1],
              [1,0,1],
              [1,0,1],
              [1,1,1],
              [0,0,1] ],
          
            [ [1,1,1],
              [1,0,0],
              [1,1,1],
              [0,0,1],
              [1,1,1] ],
          
            [ [1,1,1],
              [1,0,0],
              [1,1,1],
              [1,0,1],
              [1,1,1] ],
          
            [ [1,1,1],
              [0,0,1],
              [0,1,1],
              [0,0,1],
              [0,0,1] ],
          
            [ [1,1,1],
              [1,0,1],
              [1,1,1],
              [1,0,1],
              [1,1,1] ],
          
            [ [1,1,1],
              [1,0,1],
              [1,1,1],
              [0,0,1],
              [0,0,1] ] ]

context.fillStyle = "rgb(#{background[0]}, #{background[1]}, #{background[2]})"
context.fillRect 0, 0, width, height

currentPixel = [0, 0]

keys = { up: "U", down: "D", left: "L", right: "R" }

loadPageVar = (sVar) ->
  return decodeURI(window.location.search.replace(new RegExp("^(?:.*[&\\?]" + encodeURI(sVar).replace(/[\.\+\*]/g, "\\$&") + "(?:\\=([^&]*))?)?.*$", "i"), "$1"));

if loadPageVar('hi') is "false" then document.getElementById('float').style.display = 'none'

level2 = parseInt loadPageVar 'level'
level = if isNaN(level2) then 5 else level2
gameOver = false
lives = 3
score = 0

gen = (size, preventInvert) ->
  moveset = ""
  pixelSet = []
  actions = []
  
  currentPixel = [Math.floor(pixelWidth * 0.5), Math.floor(pixelHeight * 0.5)]
  
  for i in [0...size]
    actions = [keys.up, keys.down, keys.left, keys.right]
    
    if currentPixel[1] is 0 then actions.remove keys.up
    else if currentPixel[1] is pixelHeight - 1 then actions.remove keys.down
    else if currentPixel[0] is 0 then actions.remove keys.left
    else if currentPixel[0] is pixelWidth - 1 then actions.remove keys.right
    
    if preventInvert and i > 0
      if moveset[i - 1] is keys.up then actions.remove keys.down
      else if moveset[i - 1] is keys.down then actions.remove keys.up
      else if moveset[i - 1] is keys.left then actions.remove keys.right
      else if moveset[i - 1] is keys.right then actions.remove keys.left
      
    moveset += actions[Math.floor Math.random() * actions.length]
    
    if moveset[i] is keys.up then currentPixel[1]--
    else if moveset[i] is keys.down then currentPixel[1]++
    else if moveset[i] is keys.left then currentPixel[0]--
    else if moveset[i] is keys.right then currentPixel[0]++
    
    pixelSet.push [currentPixel[0], currentPixel[1]]
  
  pixelSet
  
renderSymbol = (symbolset, number, offsetX, offsetY) ->
  context.fillStyle = "rgb(#{textColor[0]}, #{textColor[1]}, #{textColor[2]})"
  numString = number.toString()
  for i in [0...numString.length]
    for j in [0...symbolset[parseInt(numString[i])].length] # row
      for k in [0...symbolset[parseInt(numString[i])][j].length] # column
        if symbolset[parseInt(numString[i])][j][k] is 1
          context.fillRect (offsetX + i * (symbolset[parseInt(numString[i])][j].length + 1) + k) * pixelSize[0], (offsetY + j) * pixelSize[1], pixelSize[0], pixelSize[1]
  0

renderHUD = () ->
  if gameOver
    context.fillStyle = "rgb(#{background[0]}, #{background[1]}, #{background[2]})"
    context.fillRect (Math.ceil(pixelWidth * .5 - 1.5 * (finSym[0][0].length + 1)) - 0.5) * pixelSize[0], (Math.ceil((pixelHeight - finSym[0].length) * .5) - 0.5) * pixelSize[1], (finSym[0][0].length + 1) * 3 * pixelSize[0], (finSym[0].length + 1) * pixelSize[1]
    renderSymbol finSym, 123, Math.ceil(pixelWidth * .5 - 1.5 * (finSym[0][0].length + 1)), Math.ceil((pixelHeight - finSym[0].length) * .5)
  renderSymbol numbers, level, 1, 1
  renderSymbol numbers, score, pixelWidth - (numbers[0][0].length + 1) * score.toString().length + 1, numbers[0].length + 2
  for i in [0...lives]
    renderSymbol hearts, 0, pixelWidth - (hearts[0][0].length + 1) * (i + 1) + 1, 1

  context.fillRect pixelWidth * pixelSize[0], pixelHeight * pixelSize[1], pixelSize[0], pixelSize[1]
  
render = (pixelSet) ->
  context.fillStyle = "rgb(#{background[0]}, #{background[1]}, #{background[2]})"
  context.fillRect 0, 0, width, height

  renderHUD()

  for i in [0...pixelSet.length]
    j = pixelSet.slice(0, i).count2(pixelSet[i])

    if j > palette.length - 1 then j = palette.length - 1
    
    context.fillStyle = "rgb(#{palette[j][0]}, #{palette[j][1]}, #{palette[j][2]})"
    context.fillRect pixelSet[i][0] * pixelSize[0] + 1, pixelSet[i][1] * pixelSize[1] + 1, pixelSize[0] - 2, pixelSize[1] - 2
    
  context.strokeStyle = stroke[0]
  context.strokeRect currentPixel[0] * pixelSize[0] + 0.5, currentPixel[1] * pixelSize[1] + 0.5, pixelSize[0] - 1, pixelSize[1] - 1
  
  context.strokeStyle = stroke[1]
  context.strokeRect currentPixel[0] * pixelSize[0] + 1.5, currentPixel[1] * pixelSize[1] + 1.5, pixelSize[0] - 3, pixelSize[1] - 3
      
  0
  
gameBoard = gen level, true
cacheBoard = gameBoard.slice 0
currentPixel = [gameBoard[0][0], gameBoard[0][1]]
render gameBoard

escapeKey = () ->
  if gameOver
    gameOver = false
    lives = 3
    level = if isNaN(level2) then 5 else level2
    score = 0
    gameBoard = gen level, true
    cacheBoard = gameBoard.slice 0
    currentPixel = [gameBoard[0][0], gameBoard[0][1]]
    render gameBoard
    return -1
  if lives > 0
    lives--
    gameBoard = cacheBoard.slice 0
    currentPixel = [gameBoard[0][0], gameBoard[0][1]]
    render gameBoard
    return -1
  else
    gameOver = true
    console.log "Game Over ", {level: level, score: score}
    renderHUD()
    return -1

keyEvent = (ee) ->
  e = if window.event then window.event else ee
  kc = e.keyCode
  
  if kc is 38 then key = keys.up
  else if kc is 40 then key = keys.down
  else if kc is 37 then key = keys.left
  else if kc is 39 then key = keys.right
  else if kc is 27 or kc is 32 then return escapeKey()
  else
    console.log "Input blocked: unknown key"
    return -1

  actionEvent key

touchKeyEvent = (e) ->
  document.getElementById('float').style.display = 'none'

  x = e.clientX
  y = e.clientY

  if x > width * 0.7 and y > height * 0.70 then return escapeKey()
  else if x > width * 0.35 and x < width * 0.65 and y < height * 0.30 then key = keys.up
  else if x > width * 0.35 and x < width * 0.65 and y > height * 0.70 then key = keys.down
  else if x < width * 0.30 and y > height * 0.35 and y < height * 0.65 then key = keys.left
  else if x > width * 0.70 and y > height * 0.35 and y < height * 0.65 then key = keys.right
  else
    console.log "Input blocked: unknown key"
    return -1

  actionEvent key

  return 0

actionEvent = (key) ->
  switch key
    when keys.up then currentPixel2 = [currentPixel[0], currentPixel[1] - 1]
    when keys.down then currentPixel2 = [currentPixel[0], currentPixel[1] + 1]
    when keys.left then currentPixel2 = [currentPixel[0] - 1, currentPixel[1]]
    when keys.right then currentPixel2 = [currentPixel[0] + 1, currentPixel[1]]
    else
      console.log "Input blocked: unknown key"
      return -1
  
  j = -1
  for i in [0...gameBoard.length]
    if currentPixel2[0] is gameBoard[i][0] and currentPixel2[1] is gameBoard[i][1]
      j = i
      break
  
  if j is -1
    console.log "Input blocked: not valid tile"
    return -1
  
  gameBoard.remove2 currentPixel
  
  currentPixel[0] = currentPixel2[0]
  currentPixel[1] = currentPixel2[1]
  
  score += level

  if gameBoard.length > 1
    render gameBoard
  else
    score += level * level
    gameBoard = gen ++level, true
    cacheBoard = gameBoard.slice 0
    currentPixel = [gameBoard[0][0], gameBoard[0][1]]
    render gameBoard

  0

document.addEventListener 'keyup', keyEvent, false
document.addEventListener 'click', touchKeyEvent, false
document.addEventListener 'touchstart', touchKeyEvent, false

window.addEventListener 'resize', (e) ->
  console.log "Resize"
  width = window.innerWidth
  height = window.innerHeight
  pixelWidth = Math.floor(width / pixelSize[0]) - 1
  pixelHeight = Math.floor(height / pixelSize[1]) - 1
  render gameBoard
  0