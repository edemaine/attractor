style = """
  line { stroke: #444; stroke-dasharray: 0.075; stroke-width: 0.075; }
  .obstacle { fill: purple; }
  .blank { fill: white; }

  circle { stroke: none; }
  .magnet { fill: red; stroke: orange; stroke-opacity: 0.75; stroke-width: 0.3; }
  .ball { fill: gray; stroke: #c0c0c0; stroke-opacity: 0.75; stroke-width: 0.3; }

  .magnet, .ball {
    animation: pulse 2s linear infinite;
  }
  @keyframes pulse {
    0% { stroke-opacity: 0.9; }
    50% { stroke-opacity: 0.4; }
    100% { stroke-opacity: 0.9; }
  }

  .colorMagnet0 { fill: #c8e8f3; }
  .colorMagnet1 { fill: #94bdce; }
  .colorMagnet2 { fill: #7b9eb2; }
  .colorMagnet3 { fill: #5e8899; }
  .colorMagnet4 { fill: #54707c; }
  text { font-size: 0.6px; }
"""
margin = 0.3 / 2
obstacle = '1'
blank = '?'

class Game
  constructor: (@svg, @board, @ballXY, @magnetXY) ->
    @renderBoard()
    @ball = @svg?.circle().size(1,1).addClass 'ball'
    @magnet = @svg?.circle().size(1,1).addClass 'magnet'
    @update false
    window?.addEventListener 'keydown', (e) =>
      switch e.key
        when 'h', 'ArrowLeft'
          @moveMagnet -1, 0
        when 'j', 'ArrowDown'
          @moveMagnet 0, +1
        when 'k', 'ArrowUp'
          @moveMagnet 0, -1
        when 'l', 'ArrowRight'
          @moveMagnet +1, 0

  invalid: (x, y) ->
    x < 0 or x >= @board.length or y < 0 or y >= @board[0].length

  hugMove: (dx, dy) ->
    [x, y] = @magnetXY
    if dx
      @board[x][y+1] == obstacle or
      @board[x][y-1] == obstacle or
      @board[x+dx]?[y+1] == obstacle or
      @board[x+dx]?[y-1] == obstacle
    else
      @board[x+1]?[y] == obstacle or
      @board[x-1]?[y] == obstacle or
      @board[x+1]?[y+dy] == obstacle or
      @board[x-1]?[y+dy] == obstacle

  moveMagnet: (dx, dy) ->
    x = @magnetXY[0] + dx
    y = @magnetXY[1] + dy
    if @invalid(x, y) or @board[x][y] == obstacle
      return
    @magnetXY = [x,y]
    @energize()
    @update()

  moveBall: (dx, dy) ->
    x = @ballXY[0] + dx
    y = @ballXY[1] + dy
    if @invalid(x, y) or @board[x][y] == blank
      return false
    @ballXY = [x,y]
    @update()
    true

  energize: ->
    while true
      dx = @magnetXY[0] - @ballXY[0]
      dy = @magnetXY[1] - @ballXY[1]
      break if (dx == 0 or stuckX) and (dy == 0 or stuckY)
      if stuckY or (Math.abs(dx) >= Math.abs(dy) and not stuckX)
        if @moveBall Math.sign(dx), 0
          stuckX = stuckY = false
        else
          stuckX = true
      else
        if @moveBall 0, Math.sign(dy)
          stuckX = stuckY = false
        else
          stuckY = true

  renderBoard: ->
    return unless @svg?
    @svg.element('style').words style
    @squares =
      for col, x in @board
        for char, y in col
          @svg.rect 1, 1
          .move x, y
          .addClass switch char
            when obstacle
              'obstacle'
            when blank
              'blank'
    for x in [0..@board.length]
      @svg.line x, 0, x, col.length
    for y in [0..@board[0].length]
      @svg.line 0, y, @board.length, y
    bbox = @svg.bbox()
    bbox.x -= margin
    bbox.y -= margin
    bbox.width += 2*margin
    bbox.height += 2*margin
    @svg.viewbox bbox

  update: (anim = 20) ->
    if anim
      @ball?.animate(anim).move @ballXY...
      @magnet?.animate(anim).move @magnetXY...
    else
      @ball?.move @ballXY...
      @magnet?.move @magnetXY...

  state: ->
    @ballXY.concat(@magnetXY).toString()

  loadState: (state) ->
    [@ballXY[0], @ballXY[1], @magnetXY[0], @magnetXY[1]] =
      for coord in state.split ','
        parseInt coord
    @update false

  win: ->
    Math.abs(@ballXY[0] - @magnetXY[0]) <= 1 and
    Math.abs(@ballXY[1] - @magnetXY[1]) <= 1

gui = ->
  window.game = new Game SVG('game'),
    window.board, window.ballStart, window.magnetStart
  document.getElementById('left')?.addEventListener 'click', ->
    window.game.moveMagnet -1, 0
  document.getElementById('down')?.addEventListener 'click', ->
    window.game.moveMagnet 0, +1
  document.getElementById('up')?.addEventListener 'click', ->
    window.game.moveMagnet 0, -1
  document.getElementById('right')?.addEventListener 'click', ->
    window.game.moveMagnet +1, 0
  document.getElementById('solve')?.addEventListener 'click', -> search false
  document.getElementById('solveHug')?.addEventListener 'click', -> search true
  document.getElementById('download')?.addEventListener 'click', ->
    blob = new Blob [window.game.svg.svg()], type: "image/svg+xml"
    document.getElementById('svglink').href = URL.createObjectURL blob
    document.getElementById('svglink').download =
      window.location.pathname.replace /^.*\//, ''
        .replace /\.html$/, '.svg'
    document.getElementById('svglink').click()

window?.onload = gui

window?.animate = (states) ->
  states.reverse()
  i = 0
  window.setInterval ->
    return if i >= states.length
    window.game.loadState states[i]
    i += 1
  , 100

logReset = ->
  document?.getElementById('log')?.innerHTML = ''
log = (msg) ->
  console.log msg
  document?.getElementById('log')?.innerHTML += "#{msg}<br>"

search = (hug = false) ->
  logReset()
  if window?
    game = new Game null, window.game.board,
      window.game.ballXY.slice(), window.game.magnetXY.slice()
  else
    levelFile = process.argv[2] or 'level1.js'
    levelFile = "./#{levelFile}"
    level = require levelFile
    game = new Game null, level.board, level.ballStart, level.magnetStart
  if window.colorBalls?
    window.game.renderBoard()
    window.colorBall = window.colorBalls.shift() ? []
    window.colorBallId ?= 0
    for position, i in window.colorBall
      console.log i,i + (window.colorBall.length < 5)
      window.game.svg.circle 0.666
      .center position[0] + 0.5, position[1] + 0.5
      .addClass "colorMagnet#{i + (window.colorBall.length < 5)}"
      window.game.svg.text String.fromCharCode 'A'.charCodeAt() + window.colorBallId
      .center position[0] + 0.5, position[1] + 0.5
      window.colorBallId += 1
  window.game.ball.remove()
  window.game.magnet.remove()
  #game = new Game null, level.board, [10,25], [6,25]
  ## A good test for hugMoves
  #level.board[13][25] = blank
  counts = {}
  todo = [game.state()]
  parent = {}
  parent[game.state()] = null
  while todo.length
    state = todo.shift()
    game.loadState state
    counts[game.magnetXY] ?= 0
    counts[game.magnetXY] += 1
    #counts[game.ballXY] ?= 0
    #counts[game.ballXY] += 1
    if window.colorBall?
      for position, i in window.colorBall
        if game.ballXY[0] == position[0] and
           game.ballXY[1] == position[1]
          window.game.squares[game.magnetXY[0]][game.magnetXY[1]]
          .addClass "colorMagnet#{i + (window.colorBall.length < 5)}"
    if game.win()
      log '## WIN! :-('
      here = state
      out = 'animate(['
      while here
        out += "'#{here}',"
        here = parent[here]
      out += '])'
      console.log out
      eval out if window?
      return
    for move in [[-1,0], [+1,0], [0,-1], [0,+1]]
      game.loadState state
      if hug
        continue unless game.hugMove move...
      game.moveMagnet move...
      moveState = game.state()
      unless moveState of parent
        parent[moveState] = state
        todo.push moveState
  log '## LOSE! :-)'
  log "#{(key for key of parent).length} visited states"
  filled = 0
  unfilled = 0
  for col in board
    for char in col
      if char == obstacle
        filled += 1
      else
        unfilled += 1
  log "#{filled} filled pixels"
  log "#{unfilled} unfilled pixels"
  hist = {}
  total = 0
  for key, count of counts
    hist[count] ?= 0
    hist[count] += 1
    total += 1
    [x, y] = key.split ","
    #window.game.squares[x][y].addClass "m#{count}"
  console.log hist
  console.log "#{total} total places"

search() if module?
