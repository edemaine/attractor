svgtiler = {"0":{"parent":null,"board":[["?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?"],["?","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","?","?","?"],["?","1","?","?","?","?","?","?","?","?","?","?","?","?","?","1","?","?","?"],["?","1","?","1","1","1","1","1","1","1","1","?","?","?","?","1","?","?","?"],["?","1","?","1","?","?","?","?","?","?","?","?","?","?","?","1","?","?","?"],["?","1","?","1","?","1","1","1","1","1","1","1","1","1","1","1","?","?","?"],["?","1","?","1","?","1","?","?","?","?","?","?","?","?","?","1","?","?","?"],["?","1","?","1","?","1","?","1","1","1","1","?","?","?","?","1","?","1","?"],["?","1","?","1","?","1","?","1","?","1","1","?","?","?","?","1","?","1","?"],["?","1","?","1","?","1","?","?","?","1","?","?","?","?","?","1","?","1","?"],["?","1","?","1","?","1","1","1","1","1","1","1","1","1","?","1","?","1","?"],["?","1","?","1","?","?","?","?","?","1","?","?","?","1","?","1","?","1","?"],["?","1","?","1","?","?","?","?","1","1","?","1","?","1","?","1","?","1","?"],["?","1","?","1","?","?","?","?","1","1","1","1","?","1","?","1","?","1","?"],["?","?","?","1","?","?","?","?","?","?","?","?","?","1","?","1","?","1","?"],["?","?","?","1","1","1","1","1","1","1","1","1","1","1","?","1","?","1","?"],["?","?","?","1","?","?","?","?","?","?","?","?","?","?","?","1","?","1","?"],["?","?","?","1","?","?","?","?","1","1","1","1","1","1","1","1","?","1","?"],["?","?","?","1","?","?","?","?","?","?","?","?","?","?","?","?","?","1","?"],["?","?","?","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","?"],["?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?"]],"x":4,"y":0}}
board = svgtiler[0].board
ballStart = [7,9]
magnetStart = [4,9]
colorBall = [
  [8,7],
  [7,7],
  [7,8],
  [7,9],
  [7,10]
]
/*
colorBall = [
  [8,10]
]
*/
if(typeof module !== "undefined") {
  module.exports = {board, ballStart, magnetStart}
}
