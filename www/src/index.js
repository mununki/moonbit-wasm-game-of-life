const GRID_COLOR = "#CCCCCC";
const DEAD_COLOR = "#FFFFFF";
const ALIVE_COLOR = "#000000";

const colors = {
  0: GRID_COLOR,
  1: DEAD_COLOR,
  2: ALIVE_COLOR,
}

const importObject = {
  spectest: {
    print_i32: (x) => process.stdout.write(String(x)),
    print_char: (x) => process.stdout.write(String.fromCharCode(x)),
  },
  canvas: {
    begin_path: ctx => ctx.beginPath(),
    move_to: (ctx, x, y) => ctx.moveTo(x, y),
    line_to: (ctx, x, y) => ctx.lineTo(x, y),
    set_stroke_style: (ctx, color) => ctx.strokeStyle = colors[color],
    set_fill_style: (ctx, color) => ctx.fillStyle = colors[color],
    stroke: ctx => ctx.stroke(),
    fill_rect: (ctx, x, y, width, height) => ctx.fillRect(x, y, width, height)
  }
};

WebAssembly.instantiateStreaming(fetch("src/game_of_life.wasm"), importObject)
  .then((obj) => {
    const universe_new = obj.instance.exports["moonbit_game_of_life/lib::new"];
    const get_width = obj.instance.exports["moonbit_game_of_life/lib::@moonbit_game_of_life/lib.Universe::get_width"];
    const get_height = obj.instance.exports["moonbit_game_of_life/lib::@moonbit_game_of_life/lib.Universe::get_height"];
    const render = obj.instance.exports["moonbit_game_of_life/lib::@moonbit_game_of_life/lib.Universe::render"];

    const universe = universe_new()

    const width = get_width(universe);
    const height = get_height(universe);
    const CELL_SIZE = 5;

    const canvas = document.getElementById("game-of-life-canvas");
    canvas.height = (CELL_SIZE + 1) * height + 1;
    canvas.width = (CELL_SIZE + 1) * width + 1;

    const ctx = canvas.getContext("2d");

    const renderLoop = () => {
      render(universe, ctx, CELL_SIZE)

      requestAnimationFrame(renderLoop);
    };
    requestAnimationFrame(renderLoop);

  })
  .catch((e) => console.log("Error to load wasm", e));
