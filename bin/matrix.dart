import 'dart:math';
import 'dart:io';
import 'package:ansicolor/ansicolor.dart';

List gridGenerate(int width, height) {
  // fixed-length list!
  return List.generate(height, (i) => List.filled(width, ' '));
}

void gridDraw(List grid) {
  var buffer = StringBuffer();
  for (List line in grid) {
    buffer
    // cascade notation, we love it
      ..writeAll(line, ' ')
      ..write('\n');
  }
  print(buffer.toString());
}

void blockAdd(Set blocks, int x, y, height) {
  double step = max(.005, .03 * Random().nextDouble());
  String alpha = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!(#*`~\$%(%_^(*!\$@_#\$_}:?{|][/\\;,][/].\\";
  List colors = [22, 28, 34, 40];
  int len = max(2, Random().nextInt(10));
  AnsiPen pen = AnsiPen()..xterm(colors[((step / .03) * colors.length).toInt()]);
  var buffer = StringBuffer();
  for (int i = 0; i < height; i++) {
    buffer.write(alpha[Random().nextInt(alpha.length)]);
  }
  blocks.add([x, y, step, len, buffer.toString(), pen]);
}

void blocksUpdate(Set blocks, List grid, int delta) {
  Set buffer = {};
  for (List block in blocks) {
    int x = block[0];
    double y = block[1].toDouble();
    double step = block[2];
    if (grid[min((y+step).floor(), grid.length-1)][x] == ' ') {
      block[1] += (step * delta);
    } else {
      buffer.add(block);
    }

    for (int i = max(0, (y-block[3]).floor()); i <= min(y, grid.length-1); i++) {
      AnsiPen pen = block[5];
      grid[i][x] = pen(block[4][i]);
    }
  }
  blocks.removeAll(buffer);
}

void main(List<String> arguments) {

  ansiColorDisabled = false;

  // so darn simple to get the terminal size
  int width = stdout.terminalColumns, height = stdout.terminalLines;
  Set blocks = {};
  final stopwatch = Stopwatch()..start();
  int prev = stopwatch.elapsedMilliseconds;
  while (true) {
    int now = stopwatch.elapsedMilliseconds;
    int delta = now - prev;
    prev = now;

    List grid = gridGenerate(width, height);
    int x = Random().nextInt(width), y = 0;
    blockAdd(blocks, x, y, height);
    blocksUpdate(blocks, grid, delta);
    gridDraw(grid);
    sleep(Duration(milliseconds: 40));
  }
}
