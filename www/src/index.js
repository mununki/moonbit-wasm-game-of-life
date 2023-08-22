const importObject = {
  spectest: {
    print_i32: (x) => process.stdout.write(String(x)),
    print_char: (x) => process.stdout.write(String.fromCharCode(x)),
  },
};

WebAssembly.instantiateStreaming(fetch("src/game_of_life.wasm"), importObject)
  .then((obj) => {
    const universe_new = obj.instance.exports["moonbit_game_of_life/lib::new"];
    const universe_tick =
      obj.instance.exports[
        "moonbit_game_of_life/lib::@moonbit_game_of_life/lib.Universe::tick"
      ];
    const universe_cells =
      obj.instance.exports[
        "moonbit_game_of_life/lib::@moonbit_game_of_life/lib.Universe::get_cells"
      ];
    const universe_height =
      obj.instance.exports[
        "moonbit_game_of_life/lib::@moonbit_game_of_life/lib.Universe::get_height"
      ];
    const universe_width =
      obj.instance.exports[
        "moonbit_game_of_life/lib::@moonbit_game_of_life/lib.Universe::get_width"
      ];
    const universe_get_cell =
      obj.instance.exports[
        "moonbit_game_of_life/lib::@moonbit_game_of_life/lib.Universe::get_cell"
      ];

    class Universe {
      static __wrap(ptr) {
        const obj = Object.create(Universe.prototype);
        obj.ptr = ptr;

        return obj;
      }

      static new() {
        var ret = universe_new();
        return Universe.__wrap(ret);
      }

      width() {
        var ret = universe_width(this.ptr);
        return ret >>> 0;
      }

      height() {
        var ret = universe_height(this.ptr);
        return ret >>> 0;
      }

      cells() {
        var ret = universe_cells(this.ptr);
        return ret;
      }

      get_cell(idx) {
        var ret = universe_get_cell(this.ptr, idx);
        return ret;
      }

      tick() {
        universe_tick(this.ptr);
      }
    }

    const universe = Universe.new();

    const width = universe.width();
    const height = universe.height();

    const CELL_SIZE = 5;
    const GRID_COLOR = "#CCCCCC";
    const DEAD_COLOR = "#FFFFFF";
    const ALIVE_COLOR = "#000000";

    const canvas = document.getElementById("game-of-life-canvas");
    canvas.height = (CELL_SIZE + 1) * height + 1;
    canvas.width = (CELL_SIZE + 1) * width + 1;

    const ctx = canvas.getContext("2d");

    const getIndex = (row, column) => {
      return row * width + column;
    };

    const renderLoop = () => {
      universe.tick();

      drawGrid();
      drawCells();

      requestAnimationFrame(renderLoop);
    };
    requestAnimationFrame(renderLoop);

    const drawGrid = () => {
      ctx.beginPath();
      ctx.strokeStyle = GRID_COLOR;

      for (let i = 0; i <= width; i++) {
        ctx.moveTo(i * (CELL_SIZE + 1) + 1, 0);
        ctx.lineTo(i * (CELL_SIZE + 1) + 1, (CELL_SIZE + 1) * height + 1);
      }

      for (let j = 0; j <= height; j++) {
        ctx.moveTo(0, j * (CELL_SIZE + 1) + 1);
        ctx.lineTo((CELL_SIZE + 1) * width + 1, j * (CELL_SIZE + 1) + 1);
      }

      ctx.stroke();
    };

    const drawCells = () => {
      ctx.beginPath();

      for (let row = 0; row < height; row++) {
        for (let col = 0; col < width; col++) {
          const idx = getIndex(row, col);

          ctx.fillStyle =
            universe.get_cell(idx) === 0 ? DEAD_COLOR : ALIVE_COLOR;

          ctx.fillRect(
            col * (CELL_SIZE + 1) + 1,
            row * (CELL_SIZE + 1) + 1,
            CELL_SIZE,
            CELL_SIZE
          );
        }
      }

      ctx.stroke();
    };
  })
  .catch((e) => console.log("Error to load wasm", e));
