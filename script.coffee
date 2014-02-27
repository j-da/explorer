version = '201402271027'
console.log version

# UTILITIES

Array.prototype.remove = (arg) ->
  @splice @indexOf(arg), 1

# APPLICATION

canvas = document.getElementById 'canvas'
context = canvas.getContext '2d'

width = window.innerWidth
height = window.innerHeight
pixelSize = [30, 20]
pixelWidth = Math.floor(width / pixelSize[0]) - 1
pixelHeight = Math.floor(height / pixelSize[1]) - 1
boardSize = [31, 31] # zero-based

canvas.width = width
canvas.height = height

background = [255, 255, 255]
stroke = ['rgb(0, 0, 0)', 'rgb(255, 255, 255)']
palette = [ [191, 0,   0  ],
            [239, 127, 0  ],
            [255, 191, 0  ],
            [0,   191, 0  ],
            [0,   191, 191],
            [31,  0,   191],
            [191, 0,   255],
            [255, 0,   191],
            [0,   0,   0  ] ]
textColor = [191, 191, 191]

# ALERT: If the height of the symbols or the HUD changes, renderUpdate must be rectified.

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

keys = { up: 'U', down: 'D', left: 'L', right: 'R' }

loadPageVar = (sVar) ->
  return decodeURI(window.location.search.replace(new RegExp("^(?:.*[&\\?]" + encodeURI(sVar).replace(/[\.\+\*]/g, "\\$&") + "(?:\\=([^&]*))?)?.*$", "i"), "$1"));

if loadPageVar('hi') is "false" then document.getElementById('float').style.display = 'none'

level2 = parseInt loadPageVar 'level'
level = if isNaN(level2) then 5 else level2
gameOver = false
lives = 3
score = 0
stepsLeft = level

gen = (size) ->
  moveset = ""
  actions = []
  pixelSet = []

  for i in [0...pixelHeight]
    pixelSet.push []
    for [0...pixelWidth]
      pixelSet[i].push 0

  currentPixel = [ Math.floor((pixelWidth - 1) * 0.5),
                   Math.floor((pixelHeight - 1) * 0.5) ]

  actions = []

  pixelSet[currentPixel[1]][currentPixel[0]]++

  for i in [0...size]
    actions = [keys.up, keys.down, keys.left, keys.right]

    if currentPixel[1] < 2 then actions.remove keys.up
    else if currentPixel[1] is pixelHeight - 1 then actions.remove keys.down
    else if currentPixel[0] < 2 then actions.remove keys.left
    else if currentPixel[0] is pixelWidth - 1 then actions.remove keys.right

    if i > 0
      switch moveset[i - 1]
        when keys.up then actions.remove keys.down
        when keys.down then actions.remove keys.up
        when keys.left then actions.remove keys.right
        when keys.right then actions.remove keys.left

    moveset += actions[Math.floor Math.random() * actions.length]

    switch moveset[i]
      when keys.up then currentPixel[1]--
      when keys.down then currentPixel[1]++
      when keys.left then currentPixel[0]--
      when keys.right then currentPixel[0]++

    pixelSet[currentPixel[1]][currentPixel[0]]++

  pixelSet

renderSymbol = (symbolset, number, offsetX, offsetY) ->
  context.fillStyle = "rgb(#{textColor[0]}, #{textColor[1]}, #{textColor[2]})"
  numString = number.toString()
  for i in [0...numString.length]
    for j in [0...symbolset[parseInt(numString[i])].length] # row
      for k in [0...symbolset[parseInt(numString[i])][j].length] # column
        if symbolset[parseInt(numString[i])][j][k] is 1
          context.fillRect (offsetX + i * (symbolset[parseInt(numString[i])][j].length + 1) + k) * pixelSize[0], (offsetY + j) * pixelSize[1], pixelSize[0], pixelSize[1]
          HUDArray[(offsetY + j)][offsetX + i * (symbolset[parseInt(numString[i])][j].length + 1) + k] = 1

  0

# ALERT: If the height of the symbols or the HUD changes, renderUpdate must be rectified.
# The HUD has a height of 12 including a y-offset of 1

HUDArray = []

renderHUD = () ->
  console.log "renderHUD"

  HUDArray = []
  for i in [0...pixelHeight]
    HUDArray.push []
    for j in [0...pixelWidth]
      HUDArray[i].push 0

  if gameOver
    context.fillStyle = "rgb(#{background[0]}, #{background[1]}, #{background[2]})"
    context.fillRect (Math.ceil(pixelWidth * .5 - 1.5 * (finSym[0][0].length + 1)) - 0.5) * pixelSize[0], (Math.ceil((pixelHeight - finSym[0].length) * .5) - 0.5) * pixelSize[1], (finSym[0][0].length + 1) * 3 * pixelSize[0], (finSym[0].length + 1) * pixelSize[1]
    renderSymbol finSym, 123, Math.ceil(pixelWidth * .5 - 1.5 * (finSym[0][0].length + 1)), Math.ceil((pixelHeight - finSym[0].length) * .5)
  renderSymbol numbers, level, 1, 1
  for i in [0...lives]
    renderSymbol hearts, 0, pixelWidth - (hearts[0][0].length + 1) * (i + 1) + 1, 1

  context.fillRect pixelWidth * pixelSize[0], pixelHeight * pixelSize[1], pixelSize[0], pixelSize[1]

  0

renderFull = (pixelSet) ->
  context.fillStyle = "rgb(#{background[0]}, #{background[1]}, #{background[2]})"
  context.fillRect 0, 0, width, height

  renderHUD()

  for y in [0...pixelHeight]
    for x in [0...pixelWidth]
      k = pixelSet[y][x] - 1
      if (k > -1)
        if k > palette.length - 1 then k = palette.length - 1
      
        context.fillStyle = "rgb(#{palette[k][0]}, #{palette[k][1]}, #{palette[k][2]})"
        context.fillRect x * pixelSize[0] + 1, y * pixelSize[1] + 1, pixelSize[0] - 2, pixelSize[1] - 2
      
  context.strokeStyle = stroke[0]
  context.strokeRect currentPixel[0] * pixelSize[0] + 0.5, currentPixel[1] * pixelSize[1] + 0.5, pixelSize[0] - 1, pixelSize[1] - 1
  
  context.strokeStyle = stroke[1]
  context.strokeRect currentPixel[0] * pixelSize[0] + 1.5, currentPixel[1] * pixelSize[1] + 1.5, pixelSize[0] - 3, pixelSize[1] - 3
      
  0

renderUpdate = (pixelSet) ->
  context.strokeStyle = "rgb(#{background[0]}, #{background[1]}, #{background[2]})"
  context.strokeRect lastPixel[0] * pixelSize[0] + 0.5, lastPixel[1] * pixelSize[1] + 0.5, pixelSize[0] - 1, pixelSize[1] - 1

  pixels = [lastPixel, currentPixel]
  for i in pixels
    k = pixelSet[i[1]][i[0]] - 1
    if k > -1
      if k > palette.length - 1 then k = palette.length - 1

      context.fillStyle = "rgb(#{palette[k][0]}, #{palette[k][1]}, #{palette[k][2]})"
      context.fillRect i[0] * pixelSize[0] + 1, i[1] * pixelSize[1] + 1, pixelSize[0] - 2, pixelSize[1] - 2
    else
      context.fillStyle = "rgb(#{background[0]}, #{background[0]}, #{background[0]})"
      context.fillRect i[0] * pixelSize[0] + 1, i[1] * pixelSize[1] + 1, pixelSize[0] - 2, pixelSize[1] - 2

  context.strokeStyle = stroke[0]
  context.strokeRect currentPixel[0] * pixelSize[0] + 0.5, currentPixel[1] * pixelSize[1] + 0.5, pixelSize[0] - 1, pixelSize[1] - 1
  
  context.strokeStyle = stroke[1]
  context.strokeRect currentPixel[0] * pixelSize[0] + 1.5, currentPixel[1] * pixelSize[1] + 1.5, pixelSize[0] - 3, pixelSize[1] - 3
  
  # If the newly rendered pixels overlap the HUD, it needs to be evaluated and redrawn.
  # This occurs if the currentPixel's y-coordinate is less than one more than the height of the HUD, including y-offset, assuming the HUD is at the top of the screen.
  if currentPixel[1] < 7
    context.fillStyle = "rgb(#{textColor[0]}, #{textColor[1]}, #{textColor[2]})"
    if pixelSet[lastPixel[1]][lastPixel[0]] is 0 and HUDArray[lastPixel[1]][lastPixel[0]] is 1 then context.fillRect lastPixel[0] * pixelSize[0], lastPixel[1] * pixelSize[1], pixelSize[0], pixelSize[1]
    if pixelSet[currentPixel[1]][currentPixel[0]] is 0 and HUDArray[currentPixel[1]][currentPixel[0]] is 1 then context.fillRect currentPixel[0] * pixelSize[0], currentPixel[1] * pixelSize[1], pixelSize[0], pixelSize[1]

  0

gameBoard = gen level, true
cacheBoard = []
cacheBoard.push gameBoard[i].slice(0) for i in [0...gameBoard.length]
currentPixel = [ Math.floor((pixelWidth - 1) * 0.5),
                 Math.floor((pixelHeight - 1) * 0.5) ]
lastPixel = currentPixel.slice 0
renderFull gameBoard

escapeKey = () ->
  if gameOver
    gameOver = false
    lives = 3
    level = if isNaN(level2) then 5 else level2
    score = 0
    stepsLeft = level
    gameBoard = gen level, true
    cacheBoard = []
    cacheBoard.push gameBoard[i].slice(0) for i in [0...gameBoard.length]
    currentPixel = [ Math.floor((pixelWidth - 1) * 0.5),
                     Math.floor((pixelHeight - 1) * 0.5) ]
    lastPixel = currentPixel.slice 0
    renderFull gameBoard
  else if lives > 0
    lives--
    gameBoard = []
    gameBoard.push cacheBoard[i].slice(0) for i in [0...cacheBoard.length]
    currentPixel = [ Math.floor((pixelWidth - 1) * 0.5),
                     Math.floor((pixelHeight - 1) * 0.5) ]
    lastPixel = currentPixel.slice 0
    stepsLeft = level
    renderFull gameBoard
  else
    gameOver = true
    console.log "Game Over ", {level: level, score: score, stepsLeft: stepsLeft}
    renderHUD()
  
  0

actionEvent = (key) ->
  switch key
    when keys.up then currentPixel2 = [currentPixel[0], currentPixel[1] - 1]
    when keys.down then currentPixel2 = [currentPixel[0], currentPixel[1] + 1]
    when keys.left then currentPixel2 = [currentPixel[0] - 1, currentPixel[1]]
    when keys.right then currentPixel2 = [currentPixel[0] + 1, currentPixel[1]]
    else
      console.log "Input blocked: unknown key"
      return -1

  if gameBoard[currentPixel2[1]][currentPixel2[0]] < 1
    console.log "Input blocked: not valid tile #{currentPixel2}"
    return -1

  gameBoard[currentPixel[1]][currentPixel[0]]--
  
  lastPixel = currentPixel.slice 0
  currentPixel = currentPixel2.slice 0

  if --stepsLeft > 0
    console.log stepsLeft
    renderUpdate gameBoard
  else
    score += level
    gameBoard = gen ++level, true
    cacheBoard = []
    cacheBoard.push gameBoard[i].slice(0) for i in [0...gameBoard.length]
    currentPixel = [ Math.floor((pixelWidth - 1) * 0.5),
                     Math.floor((pixelHeight - 1) * 0.5) ]
    lastPixel = currentPixel.slice 0
    stepsLeft = level
    renderFull gameBoard

  0

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
  e.preventDefault()

  document.getElementById('float').style.display = 'none'

  x = if e.touches then e.touches[0].clientX else e.clientX
  y = if e.touches then e.touches[0].clientY else e.clientY

  if x > width * 0.7 and y > height * 0.70 then return escapeKey()
  else if x > width * 0.35 and x < width * 0.65 and y < height * 0.30 then key = keys.up
  else if x > width * 0.35 and x < width * 0.65 and y > height * 0.70 then key = keys.down
  else if x < width * 0.30 and y > height * 0.35 and y < height * 0.65 then key = keys.left
  else if x > width * 0.70 and y > height * 0.35 and y < height * 0.65 then key = keys.right
  else
    console.log "Input blocked: unknown key"
    return -1

  actionEvent key

document.addEventListener 'keyup', keyEvent, false
document.addEventListener 'click', touchKeyEvent, false
document.addEventListener 'touchstart', touchKeyEvent, false
document.addEventListener 'touchmove', ((e) -> e.preventDefault()), false