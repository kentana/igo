// Generated by CoffeeScript 1.6.3
(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  $(function() {
    var Board, Point, board, boardCtx, boardCv, canvasPos, canvasSize, clearCanvas, cursorCtx, cursorCv, mutualMode, nextStone, numberOfLines, points, stoneCtx, stoneCv;
    numberOfLines = 19;
    mutualMode = true;
    nextStone = "black";
    boardCv = $("#board")[0];
    boardCtx = boardCv.getContext("2d");
    stoneCv = $("#stone")[0];
    stoneCtx = stoneCv.getContext("2d");
    cursorCv = $("#cursor")[0];
    cursorCtx = cursorCv.getContext("2d");
    canvasSize = boardCv.width;
    canvasPos = boardCv.getBoundingClientRect();
    clearCanvas = function(ctx) {
      return ctx.clearRect(0, 0, canvasSize, canvasSize);
    };
    points = [];
    Board = (function() {
      function Board(lines) {
        this.lines = lines;
        this.changeLines(this.lines);
        this.image = new Image();
        this.image.src = "image/wood.jpg";
        this.lineColor = "black";
        this.dotLines = [3, 9, 15];
      }

      Board.prototype.changeLines = function(num) {
        var col, row, _i, _ref, _results;
        this.lines = num * 1;
        this.points = this.lines - 1;
        this.margin = canvasSize / this.lines * 0.5;
        this.linePadding = (canvasSize - this.margin * 2) / this.points;
        this.stoneRadius = this.linePadding / 2 * 0.7;
        this.lineEnd = canvasSize - this.margin;
        points = [];
        _results = [];
        for (col = _i = 0, _ref = this.points; 0 <= _ref ? _i <= _ref : _i >= _ref; col = 0 <= _ref ? ++_i : --_i) {
          _results.push((function() {
            var _j, _ref1, _results1;
            _results1 = [];
            for (row = _j = 0, _ref1 = this.points; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; row = 0 <= _ref1 ? ++_j : --_j) {
              _results1.push(points.push(new Point(this, col, row)));
            }
            return _results1;
          }).call(this));
        }
        return _results;
      };

      Board.prototype.getPoint = function(ary, x, y) {
        var nearX, nearY, point, pointX, pointY, _i, _len;
        for (_i = 0, _len = ary.length; _i < _len; _i++) {
          point = ary[_i];
          pointX = canvasPos.left + point.x;
          pointY = canvasPos.top + point.y;
          nearX = (pointX - this.stoneRadius <= x && x <= pointX + this.stoneRadius);
          nearY = (pointY - this.stoneRadius <= y && y <= pointY + this.stoneRadius);
          if (nearX && nearY) {
            return point;
          }
        }
      };

      Board.prototype.drawBoard = function() {
        var dot, line, thisLine, _i, _j, _len, _ref, _ref1, _results;
        boardCtx.strokeStyle = this.lineColor;
        boardCtx.fillStyle = this.lineColor;
        boardCtx.drawImage(this.image, 0, 0, canvasSize, canvasSize);
        _results = [];
        for (line = _i = 0, _ref = this.points; 0 <= _ref ? _i <= _ref : _i >= _ref; line = 0 <= _ref ? ++_i : --_i) {
          thisLine = this.margin + line * this.linePadding;
          boardCtx.beginPath();
          boardCtx.moveTo(this.margin, thisLine);
          boardCtx.lineTo(this.lineEnd, thisLine);
          boardCtx.stroke();
          boardCtx.beginPath();
          boardCtx.moveTo(thisLine, this.margin);
          boardCtx.lineTo(thisLine, this.lineEnd);
          boardCtx.stroke();
          if (this.lines === 19 && __indexOf.call(this.dotLines, line) >= 0) {
            boardCtx.beginPath();
            _ref1 = this.dotLines;
            for (_j = 0, _len = _ref1.length; _j < _len; _j++) {
              dot = _ref1[_j];
              boardCtx.arc(thisLine, this.margin + dot * this.linePadding, 3, 0, Math.PI * 2, false);
            }
            _results.push(boardCtx.fill());
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };

      return Board;

    })();
    Point = (function() {
      function Point(board, col, row) {
        this.col = col;
        this.row = row;
        this.stone = "empty";
        this.x = board.margin + this.col * board.linePadding;
        this.y = board.margin + this.row * board.linePadding;
      }

      Point.prototype.setStone = function(stone) {
        this.stone = stone;
        if (mutualMode) {
          nextStone = ["black", "white"][(stone === "black") * 1];
          return $("#next-stone")[0].value = nextStone;
        }
      };

      Point.prototype.emptyStone = function() {
        return this.stone = "empty";
      };

      Point.prototype.drawStone = function(board) {
        if (this.stone === "empty") {
          return null;
        }
        stoneCtx.fillStyle = this.stone;
        stoneCtx.beginPath();
        stoneCtx.arc(this.x, this.y, board.stoneRadius, 0, Math.PI * 2, false);
        return stoneCtx.fill();
      };

      Point.prototype.onMouse = function(stone) {
        cursorCtx.strokeStyle = stone;
        cursorCtx.globalAlpha = 0.3;
        cursorCtx.beginPath();
        cursorCtx.arc(this.x, this.y, board.stoneRadius, 0, Math.PI * 2, false);
        return cursorCtx.stroke();
      };

      return Point;

    })();
    board = new Board(numberOfLines);
    $(board.image).on("load", function() {
      return board.drawBoard();
    });
    $(cursorCv).on("mousemove", function(e) {
      var pointOnCursor, x, y;
      cursorCtx.clearRect(0, 0, canvasSize, canvasSize);
      x = e.pageX;
      y = e.pageY;
      pointOnCursor = board.getPoint(points, x, y);
      if (pointOnCursor) {
        return pointOnCursor.onMouse(nextStone);
      }
    });
    $(cursorCv).on("click", function(e) {
      var clickedPoint, point, x, y, _i, _len, _results;
      x = e.pageX;
      y = e.pageY;
      clickedPoint = board.getPoint(points, x, y);
      if (clickedPoint) {
        switch (clickedPoint.stone) {
          case "empty":
            clickedPoint.setStone(nextStone);
            break;
          default:
            clickedPoint.emptyStone();
        }
        clearCanvas(stoneCtx);
        _results = [];
        for (_i = 0, _len = points.length; _i < _len; _i++) {
          point = points[_i];
          _results.push(point.drawStone(board));
        }
        return _results;
      }
    });
    return $(".config").on("change", function() {
      var ctx, _i, _len, _ref;
      switch (this.id) {
        case "board-kind":
          _ref = [boardCtx, stoneCtx];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            ctx = _ref[_i];
            clearCanvas(ctx);
          }
          board.changeLines(this.value);
          return board.drawBoard();
        case "stone-mode":
          return mutualMode = this.value === "mutual";
        case "next-stone":
          return nextStone = this.value;
      }
    });
  });

}).call(this);
