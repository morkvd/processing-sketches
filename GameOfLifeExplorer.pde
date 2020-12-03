import java.util.*;
import java.util.concurrent.ThreadLocalRandom;

/**
  Cool rules:
  B1234578/S34
  B2/S1234678
  B1345678/S123678 (border pond)
  B235/S15
  B1347/S1234678

  B3/S23 (conway)
  B146/S8
  B1246/S1234678
  B2345678/S12678
  B125/S123
  B13478/S1234567

  B38/S145678 (contract then expand)
  B245678/S134567 (blocky voids)
  B123678/S1234567 (static 2x2 cubes)
  B1234568/S348 (amoeba flip)

  B1/S78 (strands)
  B1/S1 (fractal squares)
  B1/S12 (stable sticks and oscillating gaps)
  B123458/S123457
  B8/S1234678 (drying up)
  B1348/S134567 (

  B1/S01234567 (space filling)

  B02456/S01234567
  B05/S0124567
  B1/S1

  B1/S01234567 (little squares)
  B0678/S01235
  B4/S0123567 (slow local movement)
  B2567/S08 (shrink then grow)
  B14/S78
  B168/S1268 (slow grow and solidify)
  B356/S1248 (slow cristal)
  B01245678/S0134568 (sparse geometric)
  B16/S01235678 (water blobs)
  B234578/S1 (chunky oscilator)
  B2345/S12357 (ancient tiles)
  B0/S0134568 (organic space filler)
  B01345678/S2 (creeping jewel DMT)

*/

/**
 * Game of Life-like pattern explorer by Mark van Dijken
 * Based on the processing Game of Life example by Joan Soler-Adillon
 *
 * Press SPACE BAR to pause
 * Press L to randomize the life-like ruleset
 * Press any of the bottom row keys z..m on a querty keyboard for various initial states

 * The original Game of Life was created by John Conway in 1970, RIP.
 */

 /* TODO
   get three copies of the grid and compare them { breaking if there is a difference }
   to check if the grid is oscillating between 2 states

   move rule up move rule down
 */

int cellSize = 4;
int hozCells = 0;  // gets set up in setup
int vertCells = 0; // gets set up in setup

// Variables for timer
int interval = 300;
int lastRecordedTime = 0;

// Colors for active/inactive cells
color aliveColor = color(0); // color(floor(random(255)), 255, 150, 255);
color deadColor = color(0); //color(0, 255);

// Array of cells
int[][] cells;
// Buffer to record the state of the cells and use this while changing the others in the interations
int[][] cellsBuffer;

// Pause
boolean paused = false;

// possible range of numbers used in game of life rules
int[] possibleRange = {0, 1, 2, 3, 4, 5, 6, 7, 8};

int[] birthRule = {1}; //getRule();
int[] survivalRule ={0,1,2,3,4,5,6,7}; //getRule();
String ruleString = getRuleString(birthRule, survivalRule);

String getRuleString(int[] birthRule, int[] survivalRule) {
  return "B" + intArrayToString(birthRule) + "/S" + intArrayToString(survivalRule);
}

String intArrayToString(int[] array) {
  String strRet = "";
  for(int i : array) {
    strRet += Integer.toString(i);
  }
  return strRet;
}

// Fisher–Yates shuffle
int[] shuffleArray(int[] arr) {
  int[] temp = new int[arr.length];
  arrayCopy(arr, temp);
  Random rnd = ThreadLocalRandom.current();
  for (int i = temp.length - 1; i > 0; i--) {
    int index = rnd.nextInt(i + 1);
    // Simple swap
    int a = temp[index];
    temp[index] = temp[i];
    temp[i] = a;
  }
  return temp;
}

// create a Birth or Survival rule
int[] getRule() {
  int amount = floor(random(1, possibleRange.length));
  int[] shuffled = shuffleArray(possibleRange);
  return sort(subset(shuffled, 0, amount));
}

// returns true if given array contains value v
boolean contains(int[] array, int value) {
  for(int i : array) {
    if(i == value) return true;
  }
  return false;
}

// creates a 2d grid with a certain cellsize
// if probabilityOfAliveAtStart is 0 the whole grid will be empty
int[][] createGrid(int probabilityOfAliveAtStart) {
  int[][] grid = new int[hozCells][vertCells];
  for (int x = 0; x < hozCells; x++) {
    for (int y = 0; y < vertCells; y++) {
      grid[x][y] = random(100) < probabilityOfAliveAtStart ? 0 : 1;
    }
  }
  return grid;
}

void setup() {
  size (1024, 1024);

  hozCells = width / cellSize;
  vertCells = height / cellSize;

  setStateToRandomized();

  // This stroke will draw the background grid
  noStroke();
  noSmooth();
  colorMode(HSB, 360, 100, 100, 100);
  background(0);

  changeColor();

  int input = 15;
  boolean[] bits = new boolean[7];
  for (int i = 6; i >= 0; i--) {
      bits[i] = (input & (1 << i)) != 0;
  }

  System.out.println(input + " = " + Arrays.toString(bits));
}

void draw() {
  if (millis()-lastRecordedTime > interval && !paused) {
    iteration();
    lastRecordedTime = millis();
    drawGrid();
  }
  drawText();
}

void drawGrid() {
  for (int x = 0; x < hozCells; x++) {
    for (int y = 0; y < vertCells; y++) {
      if (cells[x][y] == 1) {
        fill(aliveColor);
      } else {
        fill(deadColor);
      }
      rect(x * cellSize, y * cellSize, cellSize, cellSize);
    }
  }
}

void drawText() {
  fill(0, 100, 100, 100);
  int fontSize = 42;
  textSize(fontSize);
  text(ruleString + " ", cellSize, cellSize * 10);
  text(round(frameRate), width - cellSize * 14, cellSize * 10);
}

void iteration() {
  // Save cells to buffer (so we opeate with one array keeping the other intact)
  for (int x = 0; x < hozCells; x++) {
    for (int y = 0; y < vertCells; y++) {
      cellsBuffer[x][y] = cells[x][y];
    }
  }

  for (int x = 0; x < hozCells; x++) {
    for (int y = 0; y < vertCells; y++) {
      // for all neighbouring cells
      int neighbours = 0;
      for (int xx = x-1; xx <= x+1; xx++) {
        for (int yy = y-1; yy <= y+1; yy++) {
          // skip if we are comparing to ourselves
          if (xx == x && yy == y) { continue; }
          // if not out of bounds and cell is alive
          if ((xx >= 0 && xx < hozCells) &&
              (yy >= 0 && yy < vertCells) &&
              (cellsBuffer[xx][yy] == 1)) {
            neighbours++;
          }
        }
      }
      if (cellsBuffer[x][y] == 1 && !contains(survivalRule, neighbours)) {
        cells[x][y] = 0;
      } else if (contains(birthRule, neighbours)) {
        cells[x][y] = 1;
      }
    }
  }
}

void keyPressed() {
  if (key == 'q') {
    changeColor();
  }

  if (key=='l') {
    birthRule = getRule();
    survivalRule = getRule();
    ruleString = getRuleString(birthRule, survivalRule);
  }

  if (key==' ') { // On/off of pause
    paused = !paused;
  }

  if (key=='c') { // Clear all
    for (int x=0; x<hozCells; x++) {
      for (int y=0; y<vertCells; y++) {
        cells[x][y] = 0; // Save all to zero
      }
    }
    drawGrid();
    drawText();
  }

  // bottom row is random setups

  if (key=='x') { // checkerboard
    boolean flipper = false;

    int checkerSize = floor(random(1, 16));

    for (int x=0; x < hozCells; x++) {
      flipper = !flipper;
      if (x % checkerSize == 0) { flipper = !flipper; }
      for (int y=0; y<vertCells; y++) {
        flipper = !flipper;
        if (y % checkerSize == 0) { flipper = !flipper; }
        cells[x][y] = flipper ? 0 : 1;
      }
    }
    drawGrid();
    drawText();
  }

  if (key=='z') { // structured noise
    boolean flipper = false;
    int x_flip = floor(random(1, 10));
    for (int x=0; x < hozCells; x++) {
      flipper = !flipper;
      if (x % x_flip == 0) { flipper = !flipper; }
      int y_flip = floor(random(1, 10));
      for (int y=0; y<vertCells; y++) {
        flipper = !flipper;
        if (y % y_flip == 0) { flipper = !flipper; }
        if (y == vertCells - 1) {x_flip = floor(random(1,10)); }
        cells[x][y] = flipper ? 0 : 1;
      }
    }
    drawGrid();
    drawText();
  }

  if (key=='c') { // long stretchts
    boolean flipper = false;
    int x_flip = floor(random(5, hozCells));
    for (int x=0; x < hozCells; x++) {
      if (x % x_flip == 0) { flipper = !flipper; }
      int y_flip = floor(random(5, vertCells));
      for (int y=0; y < vertCells; y++) {
        if (y % y_flip == 0) { flipper = !flipper; }
        cells[x][y] = flipper ? 0 : 1;
      }
    }
    drawGrid();
    drawText();
  }

  if (key=='v') { // squares
    boolean flipper = false;
    int x_flip = floor(random(5, hozCells));
    int y_flip = floor(random(5, vertCells));

    for (int x=0; x < hozCells; x++) {
      if (x % x_flip == 0) { flipper = !flipper; }
      for (int y=0; y < vertCells; y++) {
        if (y % y_flip == 0) { flipper = !flipper; }
        cells[x][y] = flipper ? 0 : 1;
      }
    }
    drawGrid();
    drawText();
  }

  if (key=='b') { // collumns
    boolean flipper = false;
    int flip = floor(random(2, 4));

    for (int x=0; x < hozCells; x++) {
      for (int y=0; y < vertCells; y++) {
        if (y < (floor(vertCells / 4)) && x % flip == 0)  {
          flipper = true;
        } else {
          flipper = false;
        }

        cells[x][y] = flipper ? 0 : 1;
      }
    }
    drawGrid();
    drawText();
  }

  if (key=='n') { setStateToCentralSquare(); }
  if (key=='m') { setStateToRandomized(); }
}

void setStateToCentralSquare() {
  int size = floor(random(1, 32));
  if (!(size % 2 == 0)) {
    size++;
  }
  int mid_x = floor(hozCells / 2);
  int mid_y = floor(vertCells / 2);
  for (int x=0; x < hozCells; x++) {
    for (int y=0; y < vertCells; y++) {
      if (mid_x - size < x && mid_x + size > x + 1 &&
          mid_y - size < y && mid_y + size > y + 1) {
        cells[x][y] = 1;
      } else {
        cells[x][y] = 0;
      }
    }
  }
  drawGrid();
  drawText();
}

void setStateToRandomized() {
  cells = createGrid(floor(random(1, 100)));
  cellsBuffer = createGrid(0);
  drawGrid();
  drawText();
}

void changeColor() {
  aliveColor = color(
    floor(random(360)),
    floor(random(100)),
    floor(random(100)),
    100
  );
  deadColor = color(
    floor(random(360)),
    floor(random(100)),
    floor(random(100)),
    100
  );
}
