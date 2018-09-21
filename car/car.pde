int points[][] = { // Car body model
  {-50, -100}, 
  {60, -100}, 
  {120, -10}, 
  {200, -10}, 
  {200, 70}, 

  {190, 70}, 
  {160, 10}, 
  {100, 10}, 
  {80, 70}, 
  {-80, 70}, 
  {-100, 10}, 
  {-160, 10}, 
  {-190, 70}, 

  {-200, 70}, 
  {-200, -10}, 
  {-50, -10}
};

float wheelsize = 2; // Wheel size (x50), car body length and width
float carlength = 2.4;
float carheight = 1.7;

float tupd; // Terrain update value (partially not used)

float zrot; // Wheel rotation around the Z axis

int rwidth; // Width of terrain (both width and depth)

float tires[] = {600, 600, 600, 600}; // Tire data (height, xy-location, etc.)
float tspeeds[] = new float[4], tloc[][] = {
  {300, 200}, 
  {-300, 200}, 
  {300, -200}, 
  {-300, -200}
};
float trloc[][] = new float[4][2];
float carh[] = new float[4]; // Car body "suspension" heights

float cam; // Camera rotation

float speedx, speedy; // Car speed

float fangle, angle; // Tire angle and car angle
float tx, ty; // Terrain scroll values

float speed = 0, prevSpeed = 0; // Car speed now and speed during previous frame for speed calculations
boolean keys[] = new boolean[5]; // Values are true if the W, A, S, D or space keys (respectively) are pressed

void keyPressed() {
  if (key == 'a') {
    keys[0] = true;
  }
  if (key == 'd') {
    keys[1] = true;
  }
  if (key == 'w') {
    keys[2] = true;
  }
  if (key == 's') {
    keys[3] = true;
  }
  if (key == ' ') {
    keys[4] = true;
  }
}

void keyReleased() {
  if (key == 'a') {
    keys[0] = false;
  }
  if (key == 'd') {
    keys[1] = false;
  }
  if (key == 'w') {
    keys[2] = false;
  }
  if (key == 's') {
    keys[3] = false;
  }
  if (key == ' ') {
    keys[4] = false;
  }
}

void setup() {
  fullScreen(P3D);
  rwidth = int(width / 10);
  frameRate(60);
}

void draw() {
  background(0, 0, 255);

  if (keys[0] && fangle < radians(30)) { // Check user input and update speed and rotation to front wheels
    fangle += 0.03;
  }
  if (keys[1] && fangle > radians(-30)) {
    fangle -= 0.03;
  }
  if (!keys[0] && !keys[1]) {
    if (abs(fangle) < 0.08) {
      fangle = 0;
    } else {
      fangle -= 0.06 * (fangle / abs(fangle));
    }
  }
  if (keys[2] && speed < 2 && !keys[4]) {
    speed += constrain(abs(speed - 2), 0, 1) * 0.05;
  } else if (keys[3] && speed > -2 && !keys[4]) {
    speed -= constrain(abs(-2 - speed), 0, 1) * 0.05;
  } else if (!keys[2] && !keys[3]) {
    if (abs(speed) < 0.02) {
      speed = 0;
    } else {
      speed -= 0.01 * (speed / abs(speed));
    }
  }
  for (int i = 0; i < 4; i++) {
    float ang = angler(0, 0, tloc[i][0], tloc[i][1]);
    ang += angle;
    trloc[i][0] = cos(ang) * 300;
    trloc[i][1] = sin(ang) * 200;
  }
  // Apply rotation to whole car
  if (tires[0] > height / 2 + terrain(rwidth / 2 - trloc[0][0] / 10, rwidth / 2 + trloc[0][1] / 10) - 50 * wheelsize - 50 || tires[2] > height / 2 + terrain(rwidth / 2 - trloc[2][0] / 10, rwidth / 2 + trloc[2][1] / 10) - 50 * wheelsize - 50) {
    if (speed != 0) {
      if (keys[4]) {
        angle += (fangle / 60) * (speed / abs(speed)) * (abs(speed) / 2);
        if ((fangle / 60) * (speed / abs(speed)) * (abs(speed) / 2) > 0) {
          carh[2] += 2.5 * speed;
          carh[3] += 2.5 * speed;
        } else if ((fangle / 60) * (speed / abs(speed)) * (abs(speed) / 2) > 0) {
          carh[0] += 2.5 * speed;
          carh[1] += 2.5 * speed;
        }
      } else {
        angle += (fangle / 30) * (speed / abs(speed)) * (abs(speed) / 2);
        if ((fangle / 30) * (speed / abs(speed)) * (abs(speed) / 2) > 0) {
          carh[3] += 3 * speed;
          carh[2] += 3 * speed;
        } else if ((fangle / 30) * (speed / abs(speed)) * (abs(speed) / 2) < 0) {
          carh[0] += 3 * speed;
          carh[1] += 3 * speed;
        }
      }
    }
    if (prevSpeed - speed > 0) {
      carh[0] += (prevSpeed - speed) * 100;
      carh[2] += (prevSpeed - speed) * 100;
    }
    if (speed - prevSpeed > 0) {
      carh[1] += (speed - prevSpeed) * 100;
      carh[3] += (speed - prevSpeed) * 100;
    }
    
    prevSpeed = speed;
    speedx = -cos(angle) * speed;
    speedy = sin(angle) * speed;
    tx += speedx;
    ty += speedy;
  } else {
    speedx *= 0.99;
    speedy *= 0.99;
    tx += speedx;
    ty += speedy;
  }
  if (!keys[4]) {
    zrot += speed / 10;
  } else {
    if (abs(speed) < 0.02) {
      speed = 0;
    } else {
      speed -= 0.02 * (speed / abs(speed));
    }
  }
  updatePhysics(); // Update all
  drawTerrain();
  translate(width / 2, height / 2);
  rotateY(angle);
  translate(width / -2, height / -2);
  drawWheel(width / 2 - 300, 0, 200, zrot, true); // Render all
  drawWheel(width / 2 + 300, 1, 200, zrot, false);
  drawWheel(width / 2 - 300, 2, -200, zrot, true);
  drawWheel(width / 2 + 300, 3, -200, zrot, false);
  drawCar(width / 2 - 300, width / 2 + 300);
  translate(width / 2, height / 2);
  rotateY(-angle);
  translate(width / -2, height / -2);
  
  /*translate(width / 2, 0); // Display speed
  rotateY(cam + QUARTER_PI);
  textSize(64);
  textAlign(CENTER);
  fill(255, 0, 0);
  text(str(speed).substring(0, 1 + 4 * int(str(speed).length() > 4)), 0, 0);
  rotateY(-cam - QUARTER_PI);
  translate(width / -2, 0);*/
  
  // Rotate camera
  camera(sin(cam + QUARTER_PI) * width + width / 2, 0, cos(cam + QUARTER_PI) * width, width / 2, height / 2, 0, 0, 1, 0);
  cam += 0.01;
}

void updatePhysics() { // Update physics
  tspeeds[0] += 0.4; // Update gravity
  tspeeds[1] += 0.4;
  tspeeds[2] += 0.4;
  tspeeds[3] += 0.4;
  for (int i = 0; i < 4; i++) { // Calculate location of wheel on terrain after rotating
    float ang = angler(0, 0, tloc[i][0], tloc[i][1]);
    ang += angle;
    trloc[i][0] = cos(ang) * 300;
    trloc[i][1] = sin(ang) * 200;
  }
  // Update wheel 1, 2, 3 and 4
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
  tires[0] += tspeeds[0]; // Apply new speeds
  tires[1] += tspeeds[1];
  tires[2] += tspeeds[2];
  tires[3] += tspeeds[3];
}

void drawCar(float a, float b) { // Render car body
  for (int i = 0; i < 4; i++) { // Calculate smoothed points for "suspension"
    carh[i] += (tires[i] - carh[i]) * 0.1;
  }
  stroke(0, 255, 255);
  strokeWeight(6);
  line(a, tires[0], 190, a, tires[2], -190);
  line(b, tires[1], 190, b, tires[3], -190);
  line(a, (tires[0] + tires[2]) / 2, b, (tires[1] + tires[3]) / 2);
  //line(a, (tires[0] + tires[2]) / 2, a + 100, (tires[0] + tires[2]) / 2 - 200);
  //line(b, (tires[1] + tires[3]) / 2, b - 100, (tires[1] + tires[3]) / 2 - 200);
  //line(a + 100, (tires[0] + tires[2]) / 2 - 200, b - 100, (tires[1] + tires[3]) / 2 - 200);
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
  rotateZ(-radians(angle(a + 100, (carh[0] + carh[2]) / 2 - 200, b - 100, (carh[1] + carh[3]) / 2 - 200)));
  translate(width / -2, (carh[0] + carh[1] + carh[2] + carh[3]) / -4 + 150);
}

void drawWheel(float x, int j, float z, float rot, boolean f) { // Render a wheel
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

void drawTerrain() { // Render the terrain
  noStroke();
  fill(0, 255, 0);
  for (int i = 0; i < rwidth - 1; i++) {
    beginShape(TRIANGLE_STRIP);
    for (int j = 0; j < rwidth; j++) {
      if (mode == -1) {
        if (sin(i / 10.0 + tx / 6.0) + sin(j / 10.0 + ty / 6.0) > 1) {
          fill(0, 150, 0);
        } else {
          fill(0, 100, 0);
        }
      } else {
        fill(0, 255 - (terrain(i, j) / 600 * 255), 0);
      }
      vertex(i * 10, height / 2 + terrain(i, j), j * 10 - width / 2);
      vertex((i + 1) * 10, height / 2 + terrain(i + 1, j), j * 10 - width / 2);
    }
    endShape();
  }
  tupd += 0.02;
}

// Different testing environments
int mode = 5; // 2 is default, -1 is flat

float terrain(float x, float y) { // Get terrain height at (x, y)
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
      return (x + tx) % 100 * 2 + (y + ty) % 100 * 2 + 300;
    case 4:
      return (sin((x + tx) / 10) * 50 + 150) + (sin((y + ty) / 10) * 50 + 150);
    case 5:
      return noise((x + tx) / 100) * 600;
  }
  return 300;
}

float angle(float x1, float y1, float x2, float y2) { // Get angle between two points (deg)
  return degrees(atan2(y2 - y1, x2 - x1));
}

float angler(float x1, float y1, float x2, float y2) { // Get angle between two points (rad)
  return atan2(y2 - y1, x2 - x1);
}
