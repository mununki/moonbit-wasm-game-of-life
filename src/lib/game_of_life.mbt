///|
priv enum Cell {
  Dead
  Alive
}

///|
struct Universe {
  width : Int
  height : Int
  mut cells : FixedArray[Cell]
}

// colors in Js
// 0: GRID_COLOR,
// 1: DEAD_COLOR,
// 2: ALIVE_COLOR,

// externref

///|
extern type Canvas_ctx

///|
fn begin_path(self : Canvas_ctx) = "canvas" "begin_path"

///|
fn set_stroke_style(self : Canvas_ctx, color : Int) = "canvas" "set_stroke_style"

///|
fn set_fill_style(self : Canvas_ctx, color : Int) = "canvas" "set_fill_style"

///|
fn move_to(self : Canvas_ctx, x : Int, y : Int) = "canvas" "move_to"

///|
fn line_to(self : Canvas_ctx, x : Int, y : Int) = "canvas" "line_to"

///|
fn stroke(self : Canvas_ctx) = "canvas" "stroke"

///|
fn fill_rect(self : Canvas_ctx, x : Int, y : Int, width : Int, height : Int) = "canvas" "fill_rect"

///|
fn get_index(self : Universe, row : Int, column : Int) -> Int {
  row * self.width + column
}

///|
pub fn get_random_int(rand : @random.Rand, limit~ : Int) -> Int {
  let x = rand.uint(limit=limit.reinterpret_as_uint()).reinterpret_as_int()
  if x == 0 {
    x + 1
  } else {
    x
  }
}

///|
pub fn new(width : Int, height : Int) -> Universe {
  let cells : FixedArray[Cell] = FixedArray::make(width * height, Dead)
  let rand = @random.new()
  for idx in FixedArray::makei(width * height, fn(i) -> Int { i }) {
    if idx % (get_random_int(rand, limit=9) + 1) == 0 ||
      idx % (get_random_int(rand, limit=9) + 1) == 0 {
      cells[idx] = Alive
    } else {
      cells[idx] = Dead
    }
  }
  { width, height, cells }
}

///|
pub fn get_width(self : Universe) -> Int {
  self.width
}

///|
pub fn get_height(self : Universe) -> Int {
  self.height
}

///|
pub fn get_cell(self : Universe, idx : Int) -> Int {
  match self.cells[idx] {
    Alive => 1
    Dead => 0
  }
}

///|
fn live_neighbor_count(self : Universe, row : Int, column : Int) -> Int {
  let mut count = 0
  let delta_rows = [self.height - 1, 0, 1]
  let delta_cols = [self.width - 1, 0, 1]
  for dr in delta_rows {
    for dc in delta_cols {
      if dr == 0 && dc == 0 {
        continue
      }
      let neighbor_row = (row + dr) % self.height
      let neighbor_col = (column + dc) % self.width
      let idx = self.get_index(neighbor_row, neighbor_col)
      count = count + self.get_cell(idx)
    }
  }
  count
}

///|
pub fn tick(self : Universe) -> Unit {
  let next : FixedArray[Cell] = FixedArray::make(self.width * self.height, Dead)
  for r in FixedArray::makei(self.height, fn(i) -> Int { i }) {
    for c in FixedArray::makei(self.width, fn(i) -> Int { i }) {
      let idx = self.get_index(r, c)
      let cell = self.cells[idx]
      let live_neighbor = self.live_neighbor_count(r, c)
      let next_cell : Cell = match (cell, live_neighbor) {
        (Alive, 2 | 3) => Alive
        (Alive, _) => Dead
        (Dead, 3) => Alive
        (otherwise, _) => otherwise
      }
      next[idx] = next_cell
    }
  }
  self.cells = next
}

///|
fn draw_grid(self : Universe, canvas : Canvas_ctx, cell_size : Int) -> Unit {
  canvas.begin_path()
  canvas.set_stroke_style(0)
  for c in FixedArray::makei(self.width + 1, fn(i) -> Int { i }) {
    canvas.move_to(c * (cell_size + 1) + 1, 0)
    canvas.line_to(c * (cell_size + 1) + 1, (cell_size + 1) * self.height + 1)
  }
  for r in FixedArray::makei(self.height + 1, fn(i) -> Int { i }) {
    canvas.move_to(0, r * (cell_size + 1) + 1)
    canvas.line_to((cell_size + 1) * self.width + 1, r * (cell_size + 1) + 1)
  }
  canvas.stroke()
}

///|
fn draw_cells(self : Universe, canvas : Canvas_ctx, cell_size : Int) -> Unit {
  canvas.begin_path()
  for r in FixedArray::makei(self.height, fn(i) -> Int { i }) {
    for c in FixedArray::makei(self.width, fn(i) -> Int { i }) {
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
    }
  }
  canvas.stroke()
}

///|
pub fn render(self : Universe, canvas : Canvas_ctx, cell_size : Int) -> Unit {
  self.tick()
  self.draw_grid(canvas, cell_size)
  self.draw_cells(canvas, cell_size)
}
