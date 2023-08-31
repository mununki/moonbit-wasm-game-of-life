enum Cell {
  Dead
  Alive
}

struct Universe {
  width : Int
  height : Int
  mut cells : Array[Cell]
}

// colors in Js
// 0: GRID_COLOR,
// 1: DEAD_COLOR,
// 2: ALIVE_COLOR,

// externref

type Canvas_ctx

func begin_path(self : Canvas_ctx) = "canvas" "begin_path"

func set_stroke_style(self : Canvas_ctx, color : Int) = "canvas" "set_stroke_style"

func set_fill_style(self : Canvas_ctx, color : Int) = "canvas" "set_fill_style"

func move_to(self : Canvas_ctx, x : Int, y : Int) = "canvas" "move_to"

func line_to(self : Canvas_ctx, x : Int, y : Int) = "canvas" "line_to"

func stroke(self : Canvas_ctx) = "canvas" "stroke"

func fill_rect(self : Canvas_ctx, x : Int, y : Int, width : Int, height : Int) = "canvas" "fill_rect"

func get_index(self : Universe, row : Int, column : Int) -> Int {
  row * self.width + column
}

pub func new() -> Universe {
  let width = 64
  let height = 64
  let cells : Array[Cell] = array_make(width * height, Dead)
  var idx = 0
  while idx < width * height {
    if idx % 2 == 0 || idx % 7 == 0 {
      cells[idx] = Alive
    } else {
      cells[idx] = Dead
    }
    idx = idx + 1
  }
  { width, height, cells }
}

pub func get_width(self : Universe) -> Int {
  self.width
}

pub func get_height(self : Universe) -> Int {
  self.height
}

pub func get_cell(self : Universe, idx : Int) -> Int {
  match self.cells[idx] {
    Alive => 1
    Dead => 0
  }
}

func live_neighbor_count(self : Universe, row : Int, column : Int) -> Int {
  var count = 0
  let delta_rows = [self.height - 1, 0, 1]
  let delta_cols = [self.width - 1, 0, 1]
  var r = 0
  while r < 3 {
    var c = 0
    while c < 3 {
      if delta_rows[r] == 0 && delta_cols[c] == 0 {
        c = c + 1
        continue
      }
      let neighbor_row = (row + delta_rows[r]) % self.height
      let neighbor_col = (column + delta_cols[c]) % self.width
      let idx = self.get_index(neighbor_row, neighbor_col)
      count = count + self.get_cell(idx)
      c = c + 1
    }
    r = r + 1
  }
  count
}

func tick(self : Universe) {
  let next : Array[Cell] = array_make(self.width * self.height, Dead)
  var r = 0
  while r < self.height {
    var c = 0
    while c < self.width {
      let idx = self.get_index(r, c)
      let cell = self.cells[idx]
      let live_neighbor = self.live_neighbor_count(r, c)
      let next_cell : Cell = match (cell, live_neighbor) {
        (Alive, c) =>
          if c < 2 {
            Dead
          } else if c == 2 || c == 3 {
            Alive
          } else {
            Dead
          }
        (Dead, 3) => Alive
        _ => cell
      }
      next[idx] = next_cell
      c = c + 1
    }
    r = r + 1
  }
  self.cells = next
}

func draw_grid(self : Universe, canvas : Canvas_ctx, cell_size : Int) {
  canvas.begin_path()
  canvas.set_stroke_style(0)
  var c = 0
  while c <= self.width {
    canvas.move_to(c * (cell_size + 1) + 1, 0)
    canvas.line_to(c * (cell_size + 1) + 1, (cell_size + 1) * self.height + 1)
    c = c + 1
  }
  var r = 0
  while r <= self.height {
    canvas.move_to(0, r * (cell_size + 1) + 1)
    canvas.line_to((cell_size + 1) * self.width + 1, r * (cell_size + 1) + 1)
    r = r + 1
  }
  canvas.stroke()
}

func draw_cells(self : Universe, canvas : Canvas_ctx, cell_size : Int) {
  canvas.begin_path()
  var r = 0
  while r < self.height {
    var c = 0
    while c < self.width {
      let idx = self.get_index(r, c)
      let cell = self.cells[idx]
      match cell {
        Alive => canvas.set_fill_style(2)
        Dead => canvas.set_fill_style(1)
      }
      canvas.fill_rect(
        c * (cell_size + 1) + 1,
        r * (cell_size + 1) + 1,
        cell_size,
        cell_size,
      )
      c = c + 1
    }
    r = r + 1
  }
  canvas.stroke()
}

pub func render(self : Universe, canvas : Canvas_ctx, cell_size : Int) {
  self.tick()
  self.draw_grid(canvas, cell_size)
  self.draw_cells(canvas, cell_size)
}

