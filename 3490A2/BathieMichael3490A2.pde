/*
COMP 3490 Assignment 2
Michael Bathie
*/

import java.util.Stack;
import java.util.Random;

// use to implement your model matrix stack
Stack<PMatrix3D> matrixStack = new Stack<PMatrix3D>();

PMatrix3D Vp = new PMatrix3D();
PMatrix3D Pr = new PMatrix3D();
PMatrix3D V = new PMatrix3D();
PMatrix3D M = new PMatrix3D();

PVector up = new PVector(0, 1, 0);
PVector center = new PVector(0, 0, 0);

float zoom = 1;
float angle_track = 0;

int zoom_track = 0; //to remember zoom level when ortho changes

float camera_pan_x = 1280;
float camera_pan_y = 1280;
float camera_pan_min_x = -640;
float camera_pan_min_y = -640;

Random x = new Random();

float pole_angle1;
float pole_angle2;
float pole_angle3;
float pole_angle4;

color car1;
color car2;

// called once, at the start of our program
void setup() {
  size(640, 640);
  colorMode(RGB, 1.0f);
  Vp.reset();
  Pr.reset();
  V.reset();
  M.reset();
  
  pole_angle1 = -PI/12 + x.nextFloat() * (PI/12 - (-PI/12));
  pole_angle2 = -PI/12 + x.nextFloat() * (PI/12 - (-PI/12));
  pole_angle3 = -PI/12 + x.nextFloat() * (PI/12 - (-PI/12));
  pole_angle4 = -PI/12 + x.nextFloat() * (PI/12 - (-PI/12));
  
  car1 = color(x.nextFloat() * (1), x.nextFloat() * (1), x.nextFloat() * (1));
  car2 = color(x.nextFloat() * (1), x.nextFloat() * (1), x.nextFloat() * (1));
  
  Vp = getViewPort();
  Pr = getOrtho(orthoMode);
}

// called roughly 60 times per second
void draw() {
  clear();

  // HELLO world, so to speak
  // draw a line from the top left to the center, in Processing coordinate system
  //  highlights what coordinate system you are currently in.
  stroke(1,1,1);
  if (testMode) {
    drawTest(1000);
    drawTest(100);
    drawTest(1);
  } else {
    drawScene();
  }
}


/* ==================== DRAWING COMMANDS ==================== */

void drawScene()
{
  background(0.5,0.5,1);
  fill(0.5,1,0.5);
  beginShape();
    myVertex(-1,0.6);
    myVertex(1,0.6);
    
    myVertex(1,0.6);
    myVertex(1,-1);
    
    myVertex(1,-1);
    myVertex(-1,-1);
    
    myVertex(-1,-1);
    myVertex(-1,0.6);
  endShape(CLOSE);
  
  drawRoad();
}

void drawRoad()
{
  fill(0.5,0.5,0.5);
  myPush(M);
  myTranslate(-1,0);
  beginShape();
    myVertex(0,0);
    myVertex(2,0);
    
    myVertex(2,0);
    myVertex(2,-0.6);
    
    myVertex(2,-0.6);
    myVertex(0,-0.6);
    
    myVertex(0,-0.6);
    myVertex(0,0);
  endShape(CLOSE);
   
  myPush(M);
  myTranslate(0, -0.3);
  drawRoadLines(5);
  M = myPop();
  
  myPush(M);
  myTranslate(0.25, 0.1);
  myRotate(pole_angle1);
  myScale(1, 0.75);
  drawSignPole(color(0.5,0.5,0.5));
  M = myPop();
  
  myPush(M);
  myTranslate(0.75, 0);
  myRotate(pole_angle2);
  myScale(1, 1.25);
  drawSignPole(color(0.5,0.5,0.5));
  M = myPop();
  
  myPush(M);
  myTranslate(1.25, 0.15);
  myRotate(pole_angle3);
  myScale(1, 0.85);
  drawSignPole(color(0.5,0.5,0.5));
  M = myPop();
  
  myPush(M);
  myTranslate(1.75, 0.125);
  myRotate(pole_angle4);
  myScale(1, 1.1);
  drawSignPole(color(0.5,0.5,0.5));
  M = myPop();
  
  fill(car1);
  myPush(M);
  myTranslate(0.4, -0.425);
  drawCar();
  M = myPop();
  
  fill(car2);
  myPush(M);
  myTranslate(1.2, -0.425);
  drawCar();
  M = myPop();


  M = myPop();
}

void drawRoadLines(float numLines) //<>//
{
  float gap = 2/numLines;
  float line_height = 0.05;
  
  myPush(M);
  myTranslate(0,line_height/2);
  fill(1,1,0);
  for(int i = 0; i < numLines; i++)
  {
    beginShape();
      myVertex(0,0);
      myVertex(0.2,0);
      
      myVertex(0.2,0);
      myVertex(0.2, -0.05);
      
      myVertex(0.2,-0.05);
      myVertex(0,-0.05);
      
      myVertex(0,-0.05);
      myVertex(0,0);
    endShape(CLOSE);
    myTranslate(gap, 0);
  }
  myPop();
}

void drawSignPole(color c)
{
  fill(c);
  myPush(M);
  
  beginShape();
    myVertex(0,0);
    myVertex(0.025,0);
      
    myVertex(0.025,0);
    myVertex(0.025, 0.4);
      
    myVertex(0.025,0.4);
    myVertex(0,0.4);
      
    myVertex(0,0.4);
    myVertex(0,0);
  endShape(CLOSE);
  
  myPush(M);
  myTranslate(-0.15, 0.3);
  drawSign();
  M = myPop();
  
  M = myPop();
}

void drawSign()
{
  myPush(M);
  fill(0.1,0.4,0.1);
  beginShape();
    myVertex(0,0);
    myVertex(0.3,0);
      
    myVertex(0.3,0);
    myVertex(0.3, 0.2);
      
    myVertex(0.3,0.2);
    myVertex(0,0.2);
      
    myVertex(0,0.2);
    myVertex(0,0);
  endShape(CLOSE);
  
  myPush(M);
  myTranslate(0.075, 0.05);
  drawSignDirection();
  M = myPop();
  
  M = myPop();
}

void drawSignDirection()
{
  myPush(M);
  
  fill(1);
  beginShape();
    myVertex(0,0);
    myVertex(0.1,0);
      
    myVertex(0.1,0);
    myVertex(0.1, -0.02);
      
    myVertex(0.1,-0.02);
    myVertex(0.15,0.04);
      
    myVertex(0.15,0.04);
    myVertex(0.1,0.1);
    
    myVertex(0.1,0.1);
    myVertex(0.1,0.08);
    
    myVertex(0.1,0.08);
    myVertex(0,0.08);
    
    myVertex(0,0.08);
    myVertex(0,0);
  endShape(CLOSE);
  
  M = myPop();
}

void drawCar()
{
  myPush(M);
  beginShape();
    myVertex(0,0);
    myVertex(0.4,0);
      
    myVertex(0.4,0);
    myVertex(0.4, 0.25);
      
    myVertex(0.4,0.25);
    myVertex(0,0.25);
      
    myVertex(0,0.25);
    myVertex(0,0);
  endShape(CLOSE);
  
  myPush(M);
  myTranslate(0.060,-0.05);
  drawWheel();
  M = myPop();
  
  myPush(M);
  myTranslate(0.240,-0.05);
  drawWheel();
  M = myPop();
  
  M = myPop();
}

void drawWheel()
{
  myPush(M);
  
  fill(0);
  beginShape();
    myVertex(0,0);
    myVertex(0.1,0);
      
    myVertex(0.1,0);
    myVertex(0.1, 0.1);
      
    myVertex(0.1,0.1);
    myVertex(0,0.1);
      
    myVertex(0,0.1);
    myVertex(0,0);
  endShape(CLOSE);
  
  M = myPop();
}

/* ==================== MATRIX MANIPULATION ==================== */ //<>// //<>// //<>// //<>// //<>// //<>//

void myPush(PMatrix3D state) //<>//
{
  matrixStack.push(state.get());  //<>//
}

PMatrix3D myPop() //<>//
{ //<>//
  return matrixStack.pop(); //<>//
} //<>// //<>//

void myRotate(float theta)
{
  PMatrix3D rotate = new PMatrix3D(cos(theta), -sin(theta), 0, 0,
                                  sin(theta), cos(theta), 0, 0,
                                  0, 0, 1, 0,
                                  0, 0, 0, 1);
                                  
  M.apply(rotate);
}

void myScale(float sx, float sy)
{
  PMatrix3D scale = new PMatrix3D(sx, 0, 0, 0,
                                  0, sy, 0, 0,
                                  0, 0, 1, 0,
                                  0, 0, 0, 1);
                                  
  M.apply(scale);
}

void myTranslate(float tx, float ty)
{
  PMatrix3D translate = new PMatrix3D(1, 0, tx, 0,
                                      0, 1, ty, 0,
                                      0, 0, 1, 0,
                                      0, 0, 0, 1);
                                      
  M.apply(translate);
}

PMatrix3D getViewPort()
{
  PMatrix3D working_matrix = new PMatrix3D();
  working_matrix.m00 = width/2;
  working_matrix.m11 = -height/2;
  working_matrix.m02 = width/2;
  working_matrix.m12 = height/2;
  
  return working_matrix;
}

PMatrix3D getOrtho(float left, float right, float top, float bottom)
{ 
  Pr.reset();
  PMatrix3D working_matrix = new PMatrix3D();
  working_matrix.reset();
  
  PMatrix3D translate = new PMatrix3D(1 ,0 ,-((left+right)/2), 0,
                                       0, 1, -((top+bottom)/2), 0,
                                       0, 0, 1, 0,
                                       0, 0, 0, 1);
                                       
  PMatrix3D scale = new PMatrix3D((2/(right-left)), 0, 0, 0,
                                  0, (2/(top-bottom)), 0, 0,
                                  0, 0, 1, 0,
                                  0, 0, 0, 1);
  
  working_matrix.apply(scale);
  working_matrix.apply(translate);
  
  Pr = working_matrix;
  
  return working_matrix;
}

PMatrix3D getOrtho(OrthoMode mode)
{
  
  camera_pan_x = 1280;
  camera_pan_y = 1280;
  camera_pan_min_x = -640;
  camera_pan_min_y = -640;
  
  if(mode == OrthoMode.IDENTITY)
  {
    Pr.reset();
    
    camera_pan_x = 4;
    camera_pan_y = 4;
    camera_pan_min_x = -2;
    camera_pan_min_y = -2;
    
    orthoZoomHelper();
    
    return Pr;
  }
  else if(mode == OrthoMode.CENTER640)
  {
    orthoZoomHelper();
    return getOrtho(-320, 320, 320, -320);
  }
    
  else if(mode == OrthoMode.BOTTOMLEFT640)
  {
    orthoZoomHelper();
    return getOrtho(0, 640, 640, 0);
  }
    
  else if(mode == OrthoMode.FLIPX)
  {
    orthoZoomHelper();
    return getOrtho(320, -320, 320, -320);
  }
    
  else if(mode == OrthoMode.ASPECT)
  {
    orthoZoomHelper();
    return getOrtho(-320, 320, 100, -100);
  }
   return null;
}

//Helps maintain the zoom level when switching ortho
void orthoZoomHelper()
{
  float zoom_level = pow(ZOOM_CHANGE, (float)abs(zoom_track));
  
  if(zoom_track > 0)
  {
    camera_pan_x /= zoom_level;
    camera_pan_y /= zoom_level;
    camera_pan_min_x /= zoom_level;
    camera_pan_min_y /= zoom_level;
  }
  else if(zoom_track < 0)
  {
    camera_pan_x *= zoom_level;
    camera_pan_y *= zoom_level;
    camera_pan_min_x *= zoom_level;
    camera_pan_min_y *= zoom_level;  
  }
  
  //if zoom_track is 0 leave default pan
}

PMatrix3D getCamera(PVector up, PVector center, float zoom)
{
  PMatrix3D basis = new PMatrix3D(up.y ,-up.x ,0, 0,
                                       up.x, up.y,0, 0,
                                       0, 0, 1, 0,
                                       0, 0, 0, 1);
                                       
  PMatrix3D translate = new PMatrix3D(1 ,0 ,-center.x, 0,
                                       0, 1,-center.y, 0,
                                       0, 0, 1, 0,
                                       0, 0, 0, 1);
                                       
  PMatrix3D zoom_matrix = new PMatrix3D(zoom ,0 ,0, 0,
                                       0, zoom,0, 0,
                                       0, 0, 1, 0,
                                       0, 0, 0, 1);  
                                       
  basis.apply(zoom_matrix);
  basis.apply(translate);
  
  return basis; 
}

void adjustZoom(boolean zoom)
{
  if(zoom)
  {
    camera_pan_x = camera_pan_x / ZOOM_CHANGE;
    camera_pan_y = camera_pan_y / ZOOM_CHANGE;
    camera_pan_min_x = camera_pan_min_x / ZOOM_CHANGE;
    camera_pan_min_y = camera_pan_min_y / ZOOM_CHANGE; 
    zoom_track++;
  }
  else
  {
    camera_pan_x = camera_pan_x * ZOOM_CHANGE;
    camera_pan_y = camera_pan_y * ZOOM_CHANGE;
    camera_pan_min_x = camera_pan_min_x * ZOOM_CHANGE;
    camera_pan_min_y = camera_pan_min_y * ZOOM_CHANGE;
    zoom_track--;
  }
}

PVector determineCameraPan()
{
  
  float x_prop = mouseX/(float)width;
  float y_prop = 1 - (mouseY/(float)height);
  
  x_prop *= camera_pan_x;
  y_prop *= camera_pan_y;
  
  x_prop += camera_pan_min_x;
  y_prop += camera_pan_min_y;
  
  PVector center_pan = new PVector(x_prop, y_prop);
  
  //corrects the angle of the center of the camera to adjust panning after a rotate
  PMatrix3D angle_correction = new PMatrix3D(cos(angle_track) ,-sin(angle_track) ,0, 0,
                                       sin(angle_track), cos(angle_track),0, 0,
                                       0, 0, 1, 0,
                                       0, 0, 0, 1);
                                       
  angle_correction.mult(center_pan, center_pan);
  
  return center_pan;
} 

void rotateCamera(float angle)
{ 
  PMatrix3D rotate = new PMatrix3D(cos(angle) ,-sin(angle) ,0, 0,
                                       sin(angle), cos(angle),0, 0,
                                       0, 0, 1, 0,
                                       0, 0, 0, 1);
                                       
  rotate.mult(up, up);
}

void mousePressed()
{
  
}
