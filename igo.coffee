$ ->
  # 変数
  # 19, 13, 9路盤の3択
  numberOfLine = 19
  numberOfPoints = numberOfLine - 1

  # ボードに関する変数
  lineColor = "black"

  boardImage = new Image()
  boardImage.src = "image/wood.jpg"

  # 石に関する変数

  # キャンバス取る
  boardCv = $("#board")[0]
  stoneCv = $("#stone")[0]
  cursorCv = $("#cursor")[0]

  canvasSize = 600
  boardMargin = canvasSize / numberOfLine * 0.5
  lineSpace = (canvasSize - boardMargin * 2) / (numberOfLine - 1)
  stoneRadius = lineSpace / 2 * 0.7
  canvasPos = boardCv.getBoundingClientRect()

  stone = "black"

  # 交点のクラス
  class Point
    constructor: (@col, @row) ->
      @stone = "empty"
      @x = boardMargin + @col * lineSpace
      @y = boardMargin + @row * lineSpace

    # 石を置く
    setStone: (stone) ->
      @stone = stone

    # 石を消す
    emptyStone: ->
      @stone = "empty"

    # 石を描画
    drawStone: ->
      return null if @stone is "empty"

      ctx = stoneCv.getContext "2d"
      ctx.fillStyle = @stone
      ctx.arc @x, @y, stoneRadius, 0, Math.PI * 2, false
      ctx.fill()

    # マウスを載せた時の挙動
    onMouse: (stone) ->
      ctx = cursorCv.getContext "2d"
      ctx.clearRect 0, 0, canvasSize, canvasSize
      ctx.strokeStyle = stone
      ctx.globalAlpha = 0.3
      ctx.beginPath()
      ctx.arc @x, @y, stoneRadius, 0, Math.PI * 2, false
      ctx.stroke()


  # キャンバス
  # ボードを描画
  drawBoard = ->
    ctx = boardCv.getContext "2d"

    ctx.strokeStyle = lineColor
    ctx.fillStyle = lineColor

    # 木の板を用意
    ctx.drawImage boardImage, 0, 0, canvasSize, canvasSize

    # 線の描画に使う変数
    endOfLine = canvasSize - boardMargin
    dotLines = [3, 9, 15]

    # 線を引く
    for line in [0..numberOfLine - 1]
      thisLine = boardMargin + line * lineSpace

      # 横線
      ctx.beginPath()
      ctx.moveTo(boardMargin, thisLine)
      ctx.lineTo(endOfLine, thisLine)
      ctx.stroke()

      # 縦線
      ctx.beginPath()
      ctx.moveTo(thisLine, boardMargin)
      ctx.lineTo(thisLine, endOfLine)
      ctx.stroke()

      # 点を打つ
      if numberOfLine is 19 and line in dotLines
        ctx.beginPath()
        ctx.arc(thisLine, boardMargin + dot * lineSpace, 3, 0, Math.PI * 2, false) for dot in dotLines
        ctx.fill()

  # キャンバスをクリア
  clearCanvas = (cv) ->
    ctx = cv.getContext "2d"
    ctx.clearRect 0, 0, canvasSize, canvasSize

  # 画像のロードが終わったらボードを描画
  boardImage.addEventListener "load", drawBoard, false


  # 交点オブジェクトを生成
  points = []

  for col in [0..numberOfPoints]
    for row in [0..numberOfPoints]
      points.push new Point col, row

  # 座標から交点を取得
  getPoint = (ary, x, y) ->
    for point in ary
      pointX = canvasPos.left + point.x
      pointY = canvasPos.top + point.y

      nearX = pointX - stoneRadius <= x <= pointX + stoneRadius
      nearY = pointY - stoneRadius <= y <= pointY + stoneRadius

      return point if nearX and nearY

  # イベントハンドラ
  $(window).on "mousemove", (e) ->
    clearCanvas cursorCv

    x = e.pageX
    y = e.pageY

    xInCanvas = canvasPos.left <= x <= canvasPos.left + canvasSize
    yInCanvas = canvasPos.top <= y <= canvasPos.top + canvasSize

    if xInCanvas and yInCanvas
      pointOnCursor = getPoint points, x, y
      pointOnCursor.onMouse(stone) if pointOnCursor


  $(cursorCv).on "click", (e) ->
    x = e.pageX
    y = e.pageY

    clickedPoint = getPoint points, x, y
    alert "col: #{clickedPoint.col} row: #{clickedPoint.row}"
