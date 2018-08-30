style = '''
  line { stroke: black; stroke-dasharray: 0.1; stroke-width: 0.1; }
  .obstacle { fill: purple; }
  .blank { fill: white; }

  circle { stroke: none; }
  .magnet { fill: red; stroke: orange; stroke-opacity: 0.75; stroke-width: 0.3; }
  .ball { fill: gray; stroke: #c0c0c0; stroke-opacity: 0.75; stroke-width: 0.3; }
'''
margin = 0.3 / 2
obstacle = '1'
blank = '?'

class Game
  constructor: (@svg, @board, @ballXY, @magnetXY) ->
    @svg?.element('style').words style
    @renderBoard()
    @ball = @svg?.circle().size(1,1).addClass 'ball'
    @magnet = @svg?.circle().size(1,1).addClass 'magnet'
    @update()
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

  update: ->
    @ball?.move @ballXY...
    @magnet?.move @magnetXY...

  state: ->
    @ballXY.concat(@magnetXY).toString()

  loadState: (state) ->
    [@ballXY[0], @ballXY[1], @magnetXY[0], @magnetXY[1]] =
      for coord in state.split ','
        parseInt coord
    @update()

  win: ->
    Math.abs(@ballXY[0] - @magnetXY[0]) <= 1 and
    Math.abs(@ballXY[1] - @magnetXY[1]) <= 1

gui = ->
  window.game = new Game SVG('game'),
    window.board, window.ballStart, window.magnetStart
  document.getElementById('solve')?.addEventListener 'click', -> search false
  document.getElementById('solveHug')?.addEventListener 'click', -> search true
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
  #game = new Game null, level.board, [10,25], [6,25]
  ## A good test for hugMoves
  #level.board[13][25] = blank
  todo = [game.state()]
  parent = {}
  parent[game.state()] = null
  while todo.length
    state = todo.shift()
    game.loadState state
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
  count = 0
  for col in board
    for char in col
      if char == obstacle
        count += 1
  log "#{count} filled pixels"

search() if module?
