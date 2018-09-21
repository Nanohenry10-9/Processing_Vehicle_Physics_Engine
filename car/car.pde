int points[][] = {
  {-150, -100},
  {60, -100},
  {120, -10},
  {200, -10},
  {200, 100},
  
  {190, 100},
  {160, 10},
  {100, 10},
  {80, 100},
  {-80, 100},
  {-100, 10},
  {-160, 10},
  {-190, 100},
  
  {-200, 100},
  {-200, -10},
  {-150, -10}
};

float wheelsize = 2;
float carlength = 2.4;
float carheight = 1.6;

float tupd;

float zrot;

int rwidth;

float tires[] = new float[4], tspeeds[] = new float[4], tloc[][] = {
  {300, 200},
  {-300, 200},
  {300, -200},
  {-300, -200}
};
float trloc[][] = new float[4][2];
float carh[] = new float[4];

float cam;

float speedx, speedy;

float fangle, angle;
float tx, ty;

void setup() {
  fullScreen(P3D);
  rwidth = int(width / 10);
  frameRate(60);
}

void draw() {
  background(0, 0, 255);
  
  if (keyPressed) {
    if (key == 'a' && fangle < radians(30)) {
      fangle += 0.03;
    } else if (key == 'd' && fangle > radians(-30)) {
      fangle -= 0.03;
    }
  } else {
    if (abs(fangle) < 0.08) {
      fangle = 0;
    } else {
      fangle -= 0.06 * (fangle / abs(fangle));
    }
  }
  for (int i = 0; i < 4; i++) {
    float ang = angler(0, 0, tloc[i][0], tloc[i][1]);
    ang += angle;
    trloc[i][0] = cos(ang) * 300;
    trloc[i][1] = sin(ang) * 200;
  }
  if (tires[0] > height / 2 + terrain(rwidth / 2 - trloc[0][0] / 10, rwidth / 2 + trloc[0][1] / 10) - 50 * wheelsize - 50 || tires[2] > height / 2 + terrain(rwidth / 2 - trloc[2][0] / 10, rwidth / 2 + trloc[2][1] / 10) - 50 * wheelsize - 50) {
    angle += fangle / 50;
    
    speedx = -cos(angle) * 2;
    speedy = sin(angle) * 2;
    tx += speedx;
    ty += speedy;
  } else {
    speedx *= 0.99;
    speedy *= 0.99;
    tx += speedx;
    ty += speedy;
  }
  zrot += 0.1;
  updatePhysics();
  drawTerrain();
  translate(width / 2, height / 2);
  rotateY(angle);
  translate(width / -2, height / -2);
  drawWheel(width / 2 - 300, 0, 200, zrot, true);
  drawWheel(width / 2 + 300, 1, 200, zrot, false);
  drawWheel(width / 2 - 300, 2, -200, zrot, true);
  drawWheel(width / 2 + 300, 3, -200, zrot, false);
  drawCar(width / 2 - 300, width / 2 + 300);
  translate(width / 2, height / 2);
  rotateY(-angle);
  translate(width / -2, height / -2);
  camera(sin(cam + QUARTER_PI) * width + width / 2, 0, cos(cam + QUARTER_PI) * width, width / 2, height / 2, 0, 0, 1, 0);
  cam += 0.01;
}

void updatePhysics() {
  tspeeds[0] += 0.4;
  tspeeds[1] += 0.4;
  tspeeds[2] += 0.4;
  tspeeds[3] += 0.4;
  for (int i = 0; i < 4; i++) {
    float ang = angler(0, 0, tloc[i][0], tloc[i][1]);
    ang += angle;
    trloc[i][0] = cos(ang) * 300;
    trloc[i][1] = sin(ang) * 200;
  }
  if (tires[0] > height / 2 + terrain(rwidth / 2 - trloc[0][0] / 10, rwidth / 2 + trloc[0][1] / 10) - 50 * wheelsize) {
    float b = tires[0] - (height / 2 + terrain(rwidth / 2 - trloc[0][0] / 10, rwidth / 2 + trloc[0][1] / 10) - 50 * wheelsize);
    tires[0] = height / 2 + terrain(rwidth / 2 - trloc[0][0] / 10, rwidth / 2 + trloc[0][1] / 10) - 50 * wheelsize - 2;
    tspeeds[0] *= -0.6 * min(b, 1);
  }
  if (tires[1] > height / 2 + terrain(rwidth / 2 - trloc[1][0] / 10, rwidth / 2 + trloc[1][1] / 10) - 50 * wheelsize) {
    float b = tires[1] - (height / 2 + terrain(rwidth / 2 - trloc[1][0] / 10, rwidth / 2 + trloc[1][1] / 10) - 50 * wheelsize);
    tires[1] = height / 2 + terrain(rwidth / 2 - trloc[1][0] / 10, rwidth / 2 + trloc[1][1] / 10) - 50 * wheelsize - 2;
    tspeeds[1] *= -0.6 * min(b, 1);
  }
  if (tires[2] > height / 2 + terrain(rwidth / 2 - trloc[2][0] / 10, rwidth / 2 + trloc[2][1] / 10) - 50 * wheelsize) {
    float b = tires[2] - (height / 2 + terrain(rwidth / 2 - trloc[2][0] / 10, rwidth / 2 + trloc[2][1] / 10) - 50 * wheelsize);
    tires[2] = height / 2 + terrain(rwidth / 2 - trloc[2][0] / 10, rwidth / 2 + trloc[2][1] / 10) - 50 * wheelsize - 2;
    tspeeds[2] *= -0.6 * min(b, 1);
  }
  if (tires[3] > height / 2 + terrain(rwidth / 2 - trloc[3][0] / 10, rwidth / 2 + trloc[3][1] / 10) - 50 * wheelsize) {
    float b = tires[3] - (height / 2 + terrain(rwidth / 2 - trloc[3][0] / 10, rwidth / 2 + trloc[3][1] / 10) - 50 * wheelsize);
    tires[3] = height / 2 + terrain(rwidth / 2 - trloc[3][0] / 10, rwidth / 2 + trloc[3][1] / 10) - 50 * wheelsize - 2;
    tspeeds[3] *= -0.6 * min(b, 1);
  }
  tires[0] += tspeeds[0];
  tires[1] += tspeeds[1];
  tires[2] += tspeeds[2];
  tires[3] += tspeeds[3];
}

void drawCar(float a, float b) {
  for (int i = 0; i < 4; i++) {
    carh[i] += (tires[i] - carh[i]) * 0.1;
  }
  stroke(0, 255, 255);
  strokeWeight(6);
  line(a, tires[0], 190, a, tires[2], -190);
  line(b, tires[1], 190, b, tires[3], -190);
  line(a, (tires[0] + tires[2]) / 2, a + 100, (tires[0] + tires[2]) / 2 - 200);
  line(b, (tires[1] + tires[3]) / 2, b - 100, (tires[1] + tires[3]) / 2 - 200);
  line(a + 100, (tires[0] + tires[2]) / 2 - 200, b - 100, (tires[1] + tires[3]) / 2 - 200);
  translate(width / 2, (carh[0] + carh[1] + carh[2] + carh[3]) / 4 - 150);
  rotateZ(radians(angle(a + 100, (carh[0] + carh[2]) / 2 - 200, b - 100, (carh[1] + carh[3]) / 2 - 200)));
  rotateX(-radians((angle(carh[0], -200, carh[2], 200) + angle(carh[1], -200, carh[3], 200)) / 2));
  stroke(200);
  strokeWeight(3);
  noFill();
  
  for (int i = 0; i < 15; i++) {
    if (i >= 4 && i <= 12) {
      continue;
    }
    beginShape();
    vertex(-points[i][0] * carlength, 240, points[i][1] * carheight);
    vertex(-points[i][0] * carlength, -240, points[i][1] * carheight);
    vertex(-points[i + 1][0] * carlength, -240, points[i + 1][1] * carheight);
    vertex(-points[i + 1][0] * carlength, 240, points[i + 1][1] * carheight);
    endShape(CLOSE);
  }
  beginShape();
  vertex(-points[15][0] * carlength, 240, points[15][1] * carheight);
  vertex(-points[15][0] * carlength, -240, points[15][1] * carheight);
  vertex(-points[0][0] * carlength, -240, points[0][1] * carheight);
  vertex(-points[0][0] * carlength, 240, points[0][1] * carheight);
  endShape(CLOSE);
  beginShape();
  for (int i = 0; i < 15; i++) {
    vertex(-points[i][0] * carlength, 240, points[i][1] * carheight);
  }
  vertex(-points[15][0] * carlength, 240, points[15][1] * carheight);
  endShape(CLOSE);
  beginShape();
  for (int i = 0; i < 15; i++) {
    vertex(-points[i][0] * carlength, -240, points[i][1] * carheight);
  }
  vertex(-points[15][0] * carlength, -240, points[15][1] * carheight);
  endShape(CLOSE);
  
  rotateX(radians((angle(carh[0], -200, carh[2], 200) + angle(carh[1], -200, carh[3], 200)) / 2));
  rotateZ(radians(angle(a + 100, (carh[0] + carh[2]) / 2 - 200, b - 100, (carh[1] + carh[3]) / 2 - 200)));
  translate(width / -2, (carh[0] + carh[1] + carh[2] + carh[3]) / -4 + 150);
}

void drawWheel(float x, int j, float z, float rot, boolean f) {
  translate(x, tires[j], z);
  if (f) {
    rotateY(fangle);
  }
  if (j == 0 || j == 2) {
    rotateX(-radians(angle(tires[0], -200, tires[2], 200)) - HALF_PI);
  } else {
    rotateX(-radians(angle(tires[1], -200, tires[3], 200)) - HALF_PI);
  }
  rotateZ(rot);
  fill(40);
  stroke(0);
  beginShape(QUAD_STRIP);
  for (float i = 0; i <= 22.5; i += 1.5) {
    vertex(sin(radians(i * 16)) * wheelsize * 50, cos(radians(i * 16)) * wheelsize * 50, 40);
    vertex(sin(radians(i * 16)) * wheelsize * 50, cos(radians(i * 16)) * wheelsize * 50, -40);
  }
  endShape(CLOSE);
  beginShape();
  for (float i = 0; i < 22.5; i += 1.5) {
    vertex(sin(radians(i * 16)) * wheelsize * 50, cos(radians(i * 16)) * wheelsize * 50, 40);
  }
  endShape(CLOSE);
  beginShape();
  for (float i = 0; i < 22.5; i += 1.5) {
    vertex(sin(radians(i * 16)) * wheelsize * 50, cos(radians(i * 16)) * wheelsize * 50, -40);
  }
  endShape(CLOSE);
  rotateZ(-rot);
  if (j == 0 || j == 2) {
    rotateX(radians(angle(tires[0], -200, tires[2], 200)) + HALF_PI);
  } else {
    rotateX(radians(angle(tires[1], -200, tires[3], 200)) + HALF_PI);
  }
  if (f) {
    rotateY(-fangle);
  }
  translate(-x, -tires[j], -z);
}

void drawTerrain() {
  noStroke();
  fill(0, 255, 0);
  for (int i = 0; i < rwidth - 1; i++) {
    beginShape(TRIANGLE_STRIP);
    for (int j = 0; j < rwidth; j++) {
      fill(0, 255 - (terrain(i, j) / 600 * 255), 0);
      vertex(i * 10, height / 2 + terrain(i, j), j * 10 - width / 2);
      vertex((i + 1) * 10, height / 2 + terrain(i + 1, j), j * 10 - width / 2);
    }
    endShape();
  }
  tupd += 0.02;
}

int mode = 3; // 2 is default

float terrain(float x, float y) {
  switch (mode) {
    case 0:
      if (x > rwidth / 2 && y > rwidth / 2) {
        return sin(tupd) * 150 + 150;
      }
      if (x < rwidth / 2 && y > rwidth / 2) {
        return sin(tupd + HALF_PI) * 150 + 150;
      }
      if (x < rwidth / 2 && y < rwidth / 2) {
        return sin(tupd + PI) * 150 + 150;
      }
      if (x > rwidth / 2 && y < rwidth / 2) {
        return sin(tupd + PI + HALF_PI) * 150 + 150;
      }
      return 300;
    case 1:
      if (y > rwidth / 2) {
        return sin(tupd) * 800 + 400;
      }
      return 300;
    case 2:
      x += tx;
      y += ty;
      return noise(x / 100.0, y / 100.0) * 600;
    case 3:
      return (x + tx) % 100 * 2 + 200;
    case 4:
      return (sin((x + tx) / 10) * 50 + 150) + (sin((y + ty) / 10) * 50 + 150);
  }
  return 300;
}

float angle(float x1, float y1, float x2, float y2) {
  return degrees(atan2(y2 - y1, x2 - x1));
}

float angler(float x1, float y1, float x2, float y2) {
  return atan2(y2 - y1, x2 - x1);
}
