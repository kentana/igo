$ ->
  # 変数
  # 19, 13, 9路盤の3択
  numberOfLine = 19

  # 石の切り替えモード
  mutualMode = true

  # 次に置く石
  nextStone = "black"

  # キャンバス取る
  boardCv = $("#board")[0]
  stoneCv = $("#stone")[0]
  cursorCv = $("#cursor")[0]
  canvasSize = 600
  canvasPos = boardCv.getBoundingClientRect()

  # キャンバスをクリア
  clearCanvas = (cv) ->
    ctx = cv.getContext "2d"
    ctx.clearRect 0, 0, canvasSize, canvasSize

  # 交点を入れる配列
  points = []



  # 碁盤のクラス
  class Board
    constructor: (@lines) ->
      @points = @lines - 1
      @margin = canvasSize / @lines * 0.5
      @linePadding = (canvasSize - @margin * 2) / @points
      @stoneRadius = @linePadding / 2 * 0.7
      @image = new Image()
      @image.src = "image/wood.jpg"
      @lineColor = "black"
      @dotLines = [3, 9, 15]
      @lineEnd = canvasSize - @margin

      # 交点オブジェクトを生成
      points = []

      for col in [0..@points]
        for row in [0..@points]
          points.push new Point @, col, row


    # 碁盤の種類を変更
    changeLines: (num) ->
      @lines = num * 1
      @points = @lines - 1
      @margin = canvasSize / @lines * 0.5
      @linePadding = (canvasSize - @margin * 2) / @points
      @stoneRadius = @linePadding / 2 * 0.7
      @lineEnd = canvasSize - @margin

      # 交点オブジェクトを修正
      points = []

      for col in [0..@points]
        for row in [0..@points]
          points.push new Point @, col, row


    # 座標から交点を取得
    getPoint: (ary, x, y) ->
      for point in ary
        pointX = canvasPos.left + point.x
        pointY = canvasPos.top + point.y

        nearX = pointX - @stoneRadius <= x <= pointX + @stoneRadius
        nearY = pointY - @stoneRadius <= y <= pointY + @stoneRadius

        return point if nearX and nearY


    # 碁盤を描画
    drawBoard: ->
      ctx = boardCv.getContext "2d"

      ctx.strokeStyle = @lineColor
      ctx.fillStyle = @lineColor

      # 木の板を用意
      ctx.drawImage @image, 0, 0, canvasSize, canvasSize

      # 線を引く
      for line in [0..@points]
        thisLine = @margin + line * @linePadding

        # 横線
        ctx.beginPath()
        ctx.moveTo(@margin, thisLine)
        ctx.lineTo(@lineEnd, thisLine)
        ctx.stroke()

        # 縦線
        ctx.beginPath()
        ctx.moveTo(thisLine, @margin)
        ctx.lineTo(thisLine, @lineEnd)
        ctx.stroke()

        # 点を打つ
        if @lines is 19 and line in @dotLines
          ctx.beginPath()
          ctx.arc(thisLine, @margin + dot * @linePadding, 3, 0, Math.PI * 2, false) for dot in @dotLines
          ctx.fill()



  # 交点のクラス
  class Point
    constructor: (board, @col, @row) ->
      @stone = "empty"
      @x = board.margin + @col * board.linePadding
      @y = board.margin + @row * board.linePadding


    # 石を置く
    setStone: (stone) ->
      @stone = stone

      if mutualMode
        nextStone = ["black", "white"][(stone is "black") * 1]
        $("#next-stone")[0].value = nextStone


    # 石を消す
    emptyStone: ->
      @stone = "empty"


    # 石を描画
    drawStone: (board) ->
      return null if @stone is "empty"

      ctx = stoneCv.getContext "2d"
      ctx.fillStyle = @stone
      ctx.beginPath()
      ctx.arc @x, @y, board.stoneRadius, 0, Math.PI * 2, false
      ctx.fill()


    # マウスを載せた時の挙動
    onMouse: (stone) ->
      ctx = cursorCv.getContext "2d"
      ctx.clearRect 0, 0, canvasSize, canvasSize
      ctx.strokeStyle = stone
      ctx.globalAlpha = 0.3
      ctx.beginPath()
      ctx.arc @x, @y, board.stoneRadius, 0, Math.PI * 2, false
      ctx.stroke()



  # 画像のロードが終わったらボードを描画
  board = new Board(numberOfLine)
  board.image.addEventListener "load", ->
    board.drawBoard()
  , false



  # イベントハンドラをセット
  # カーソル位置に対応する交点を表示
  $(cursorCv).on "mousemove", (e) ->
    clearCanvas cursorCv

    x = e.pageX
    y = e.pageY

    pointOnCursor = board.getPoint points, x, y
    pointOnCursor.onMouse(nextStone) if pointOnCursor


  # クリックしたら、石をトグルして、描画する
  $(cursorCv).on "click", (e) ->
    x = e.pageX
    y = e.pageY

    clickedPoint = board.getPoint points, x, y

    # 石をトグル
    if clickedPoint
      switch clickedPoint.stone
        when "empty" then clickedPoint.setStone nextStone
        else clickedPoint.emptyStone()

      # 石を描画
      clearCanvas stoneCv
      point.drawStone(board) for point in points


  # 設定を変更したら、反映する
  $(".config").on "change", ->
    switch @.id
      # 碁盤の種類変更
      when "board-kind"
        clearCanvas cv for cv in [boardCv, stoneCv]
        board.changeLines(@.value)
        board.drawBoard()

      # 石を置いたあとに、次の石を切り替えるか
      when "stone-mode"
        mutualMode = @.value is "mutual"

      # 次に置く石の色
      when "next-stone"
        nextStone = @.value
