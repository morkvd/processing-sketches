void setup() {
  size(1200,900);
  colorMode(HSB, 100);
  background(100);
  
}

void draw() {
  int limit = 10000;
  randomBlendMode();
  background(
    floor(random(0, 100)),
    floor(random(0, 100)),
    floor(random(0, 100))
  );
  
  float angle = PI/floor(random(2, 50));
  float startSpreadWidth = random(1, 6);
  float startSpreadHeight = random(4, 8);
  float len = random(1, 100);
  float rotation = random(100, 10000);
  
  for (int i = 1; i < limit; i++) {    
    IntList sequence = new IntList();
    int n = i;
    
    do {
      sequence.append(n);
      n = collatz(n, 2, 3);

    } while(n != 1);
    sequence.append(1);
    sequence.reverse();
    
    resetMatrix();
    translate(
      width/8*random(1, startSpreadWidth), 
      height/8*random(1, startSpreadHeight)
    );
    rotate(i/rotation);
    for (int j = 0; j < sequence.size(); j++) {
      int val = sequence.get(j);
      
      
      
      if (val % 2 == 0) {
        rotate(angle);
      } else {
        rotate(-angle);
      }
      strokeWeight(1);
      stroke(color(map(i, 1, limit, 0, 100), 70, 50), 8);
      line(0, 0, 0, -len);
      translate(0, -len);//translate(-i*0.0009*len, -len);
    }
  }
  
  println("done");
  
}


int collatz(int n, int d, int m) {
  if (n % d == 0) {
    return n / d;  
  } else {
    return (n * m + 1)/2;
  }
}

void randomBlendMode() {
  int[] blendModes = { 
    BLEND, 
    ADD,
    SUBTRACT,
    DARKEST,
    LIGHTEST,
    DIFFERENCE,
    EXCLUSION,
    MULTIPLY,
    SCREEN,
    REPLACE
  };
  int bi = floor(random(0, blendModes.length));
  println(blendModes[bi]);
  blendMode(blendModes[bi]);
}
