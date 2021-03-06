/*

Michael Bathie, 7835010
COMP 3490 Assignment 3

*/

final int SCALE = 50;

int columns[][] = new int[10][50];
color colours[][] = new color [11][50];

PImage textures[][] = new PImage[11][50];

float fov = PI/3;

final int FLOOR_HEIGHT = 650;
int running_floor = FLOOR_HEIGHT;

float acceleration = 0.5;
float friction = 0.60;
final float MAX_SPEED = 5;

float jump = -30;
float gravity = 2;
boolean inJump = false;
float non_jump_fall = 0;
boolean falling = false;

float cam_posX;
float cam_posY;
float cam_posZ;
float eye_posX;
float eye_posY;
float eye_posZ;

float character_posX;
float character_posY;
float character_posZ;

PVector movement = new PVector(0,0,0);

//last direction moved
boolean left = false;
boolean right = false;
boolean up = false;
boolean down = false;

boolean face_left = false;
boolean face_right = true;
boolean turn = false;
boolean moving = false;
boolean collide = false;

float lerp_start = 1;
float lerp_stop = -1;
float lerp_step = 0;
float lerp_val = 1;

PImage mario;
PImage mario_jump;
PImage mario_run;
PImage grass;
PImage grass_top;
PImage wood;
PImage wood_top;
PImage birch;
PImage birch_top;
PImage stone;

PImage floor[] = new PImage[3];
PImage woods[] = new PImage[4];

int count = 0;

void setup() {
  size(800, 800, P3D);
  colorMode(RGB, 1.0f);
  textureMode(NORMAL); // uses normalized 0..1 texture coords
  textureWrap(CLAMP);
  
  mario = loadImage("textures/mario.png");
  mario_jump = loadImage("textures/mario_jump.png");
  mario_run = loadImage("textures/mario_run.png");
  grass = loadImage("textures/grass.png");
  grass_top = loadImage("textures/grass_top.jpg");
  wood = loadImage("textures/wood.jpg");
  wood_top = loadImage("textures/wood_top.jpg");
  birch = loadImage("textures/birch.png");
  birch_top = loadImage("textures/birch_wood_top.png");
  stone = loadImage("textures/stone.jpg");
  
  cam_posX = width/2;
  cam_posY = height/2;
  cam_posZ = 100;
  eye_posX = width/2;
  eye_posY = height/2;
  eye_posZ = 0;
  
  character_posX = SCALE/2;
  character_posY = FLOOR_HEIGHT - SCALE;
  character_posZ = 0;
  
  camera(cam_posX, cam_posY, cam_posZ, eye_posX, eye_posY, eye_posZ, 0, 1, 0);
  ortho(-width/2,width/2,-height/2,height/2);
  // ONLY NEEDED FOR BONUS setupPOGL(); // setup our hack to ProcesingOpenGL to let us modify the projection matrix manually

  floor[0] = grass_top;
  floor[1] = stone;
  floor[2] = grass;
  
  
   
  for(int i = 0; i < columns.length; i ++)
  {
    for(int j = 0; j < columns[0].length; j++)
    {
      if(random(40) <= 1)
      {
        columns[i][j] = (int)random(1,8);
      }
    }
  }
  
  for(int i = 0; i < colours.length; i++)
  {
    for(int j = 0; j < colours[0].length; j++)
    {
      float x = random(1);
      float y = random(1);
      float z = random(1);
      colours[i][j] = color(x, y, z);
    }
  }
  
  for(int i = 0; i < textures.length - 1; i++)
  {
    for(int j = 0; j < textures[0].length; j++)
    {
      int x = (int)random(2);
      if(i == 0)
      {
        if(x == 1)
          textures[i+10][j] = stone;
        else if(x == 0)
          textures[i+10][j] = grass;
      }
      textures[i][j] = floor[x];
    }
  }
  
  // WARNING: use loadImage to load any textures in setup or after. If you do it globally / statically processing complains.
  //  - just make a .setup or .init function on your world, player, etc., that loads the textures, and call those from here.
}


void draw() {
  background(1);
  noStroke();
  if(doCollision)
    floorCheck();
  pollKeys();
  camera(cam_posX, cam_posY, cam_posZ, eye_posX, eye_posY, eye_posZ, 0, 1, 0);
  adjustFaceDirection();
  drawWorld();
}

void pollKeys() 
{
  //if im moving in any direction, add to the overall speed
  if(keyLeft || keyRight || keyUp || keyDown)
  {
    if((movement.x+acceleration) <= MAX_SPEED && (keyLeft || keyRight))
    {
      movement.x += acceleration;
    }
    else if(!(keyLeft || keyRight))
    {
      movement.x *= friction; 
    }
    
    if((movement.z+acceleration) <= MAX_SPEED && (keyUp || keyDown))
    {
      movement.z += acceleration;
    }
    else if(!(keyUp || keyDown))
    {
      movement.z *= friction;
    }
  }
  else
  {
    if(movement.x > 0)
    {
      movement.x *= friction;
    }
    if(movement.z > 0)
    {
      movement.z *= friction; 
    }
    moving = false;
  }
  
  //if the last direction you moved was left and you're not currently holding the right key
  if(left && !keyRight)
  {
    
    if((!collision(character_posX - movement.x - SCALE/2, true)))
    {
      if(cam_posX > width/2 && character_posX <= SCALE*42 && !collide)
      {
        cam_posX -= movement.x;
        eye_posX -= movement.x;
      }
      if(character_posX > SCALE/2)
      {
        character_posX -= movement.x;
      }
    }
    
    //what direction am i facing
    if(face_right)
    {
      turn = true;
    }
    face_left = true;
    face_right = false;
    
    if(keyLeft)
      moving = true;
    
  }
  //if the last direction you moved was right and you're not currently holding the left key
  else if(right && !keyLeft)
  {
    if((!collision(character_posX + movement.x + SCALE/2, true)))
    {
      if(cam_posX < SCALE*42 && character_posX >= width/2 && !collide)
      {
        cam_posX += movement.x;
        eye_posX += movement.x;
      }
      if(character_posX < (SCALE*50) - SCALE/2)
      {
        character_posX += movement.x; 
      }
    }
    
    //what direction am i facing
    if(face_left)
    {
      turn = true;
    }
    face_right = true;
    face_left = false;
    
    if(keyRight)
      moving = true;
    
  }
  
  //if im holding both left and right at the same time start slowing down
  else if(keyLeft && keyRight)
  {
    if(movement.x > 0)
    {
      movement.x *= friction;
    }
    moving = false;
  }
  
  if(!orthoMode)
  {
    if(up && !keyDown)
    {
      
      if(!testDepthCollision(1))
      {
        if(character_posZ > -SCALE*10)
        {
          character_posZ -= movement.z; 
        }
      }
      
      if(keyUp)
        moving = true;
    }
    else if(down && !keyUp)
    {
      
      if(!testDepthCollision(-1))
      {
        if(character_posZ < 0)
        {
          character_posZ += movement.z; 
        }
      }
      
      if(keyDown)
        moving = true;
    }
    else if(keyUp && keyDown)
    {
      if(movement.z > 0)
      {
        movement.z *= friction;
      }
      moving = false;
    }
  }
  
  //currently sends the character up at a velocity and subtracts gravity over and over
  if(inJump)
  {
     jumpCalc(running_floor);
  }
  else
  {
    //check for when the character is on a column, and they walk off
     if(character_posY + SCALE < running_floor)
     {
       falling = true;
       //if substracting gravity were to put you underground, only subtract the remaining distance
       if(character_posY + non_jump_fall + SCALE > running_floor)
       {
         non_jump_fall = (running_floor - character_posY - SCALE);
         character_posY += non_jump_fall;
       }
       else
       {
         character_posY += non_jump_fall;
         non_jump_fall += gravity;
       }
       
       if(character_posY >= running_floor - SCALE)
       {
         non_jump_fall = 0;
         falling = false;
       }
    }
  }
}

//running checks on what the current floor is 
void floorCheck()
{ 
   int column = (int)character_posX/SCALE;
   int row = abs((int)character_posZ/SCALE);
   
   row = min(row, 9);
   column = min(column, 49);
   
   if(columns[row][column] != 0 && inJump)
   {
      running_floor = FLOOR_HEIGHT - (columns[row][column] * SCALE);
      if(running_floor != FLOOR_HEIGHT)
        return;
   }
   else if(orthoMode)
   {
     boolean check = false;
     int record = 0;
     
     for(int i = 0; i < 10; i ++)
     {
       if(columns[i][column] != 0)
       {
         check = true;
         record = max(i, record);
       }
     }
     if(check)
     {
       running_floor = FLOOR_HEIGHT - (columns[record][column] * SCALE);
       if(running_floor != FLOOR_HEIGHT)
        return;
     }
     else
     {
       running_floor = FLOOR_HEIGHT;
     }  
   }
   else if(columns[row][column] == 0)
   {
      running_floor = FLOOR_HEIGHT;
   }
}

//collision fix for colliding in the Z direction
boolean testDepthCollision(int fix)
{ 
  if((collision(character_posZ - fix*movement.z , false)))
  {
     return true;
  }
  
  character_posX += SCALE/2;
  
  if((collision(character_posZ - fix*movement.z, false)))
  {
    character_posX -= SCALE/2;
    return true;
  }
  
  character_posX -= SCALE;
  
  if((collision(character_posZ - fix*movement.z, false)))
  {
    character_posX += SCALE/2;
    return true;
  }
  
  character_posX += SCALE/2;
  
  return false;
  
}

//what happens when you press space
void jumpCalc(float floor)
{
  if(character_posY + SCALE <= floor)
     {
       //if substracting gravity were to put you underground, only subtract the remaining distance
       if(character_posY + jump + SCALE > floor)
       {
         jump = (floor - character_posY - SCALE);
         character_posY += jump;
       }
       else
       {
         character_posY += jump;
         jump += gravity;
       }
     }
     
     if(character_posY >= floor - SCALE)
     {
       inJump = false;
       jump = -30;
     }
}

//colliding on X and Z
boolean collision(float new_pos, boolean sideways)
{
  collide = false;
  
  if(doCollision)
  {
    int column;
    int row;
    
    if(sideways)
    {
      column = (int)new_pos/SCALE;
      row = abs((int)character_posZ/SCALE);
    }
    else
    {
      column = (int)character_posX/SCALE;
      row = abs((int)new_pos/SCALE);
    }
    
    row = min(row, 9);
    column = min(column, 49);
    
    if(orthoMode)
    {
       for(int i = 0; i < 10; i++)
       {
         if(columns[i][column] != 0)
         {
           if(character_posY > 600 - columns[i][column]*50)
           {
             collide = true;
             movement.x = 0;
             movement.y = 0;
             break;
           }
         }
       }
    }
    else
    {
      if(columns[row][column] != 0)
      {
        if(character_posY > 600 - columns[row][column]*50)
        {
          collide = true;
          if(sideways)
          {
            movement.x = 0;
          }
          else
          {
            movement.z = 0; 
          }
          movement.y = 0;
        }
      }
    }
  }
  
  return collide;
}

void perspectiveChange(boolean ortho) 
{
   if(!ortho)
   {
     cam_posY = height/2;
     cam_posZ = 100;
     ortho(-width/2,width/2,-height/2,height/2);
     orthoMode = true;
   }
   else
   {
     cam_posY = height/2.0-300;
     cam_posZ = 550;
     perspective(fov, width/height, 10, 2000);
     orthoMode = false;
   }
}

//lerp to reflect the character
void adjustFaceDirection()
{
  if(turn)
  {
    if(face_right)
    {
      lerp_val = lerp(2, 0, lerp_step) - 1;
      lerp_step -= 0.1;
    }
    else if(face_left)
    {
      lerp_val = lerp(2, 0, lerp_step) - 1;
      lerp_step += 0.1;
    }
    if(lerp_val < -1 || lerp_val > 1)
    {
      turn = false;
      //basically adjusting for impercision
      if(face_left)
      {
        lerp_step = 1;
        lerp_val = -1;
      }
      else if(face_right)
      {
        lerp_step = 0;
        lerp_val = 1;
      }
    }
    
  }
}

void drawWorld()
{
  pushMatrix();
  translate(SCALE/2, FLOOR_HEIGHT);
  for(int i = 0; i < SCALE; i ++)
  {
    pushMatrix();
    for(int j = 0; j < 10; j++)
    {
      myBox(colours[10][i], colours[j][i], textures[10][i], textures[j][i]); 
      if(columns[j][i] >= 1)
      {
        pushMatrix();
        translate(0,-SCALE,0);
        myColumn(columns[j][i], colours[j][i]);
        popMatrix();
      }
      translate(0,0,-SCALE);
    }
    popMatrix();
    translate(SCALE,0,0);
  }
  popMatrix();
  pushMatrix();
  translate(character_posX, character_posY, character_posZ);
  applyMatrix(lerp_val,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);
  if(!doTextures)
    fill(1,0,0);
  beginShape();
  if(doTextures)
  {
    if(inJump)
      texture(mario_jump);
    else if(moving && count > 10)
    {
      texture(mario_run);
    }
    else 
      texture(mario);
  }
  vertex(-SCALE/2, -SCALE/2, 0, 0);
  vertex(SCALE/2, -SCALE/2, 1, 0);
  vertex(SCALE/2, SCALE/2, 1, 1);
  vertex(-SCALE/2, SCALE/2, 0, 1);
  endShape(CLOSE);
  popMatrix();
  
  count++;
  count = count%20;
}

void myBox(color face, color top, PImage face_t, PImage top_t)
{
  
  //front face
  if(!doTextures)
    fill(face);
  beginShape();
  if(doTextures)
    texture(face_t);
  vertex(-SCALE/2, -SCALE/2, 0, 0);
  vertex(SCALE/2, -SCALE/2, 1, 0);
  vertex(SCALE/2, SCALE/2, 1, 1);
  vertex(-SCALE/2, SCALE/2, 0, 1);
  endShape(CLOSE);
  
  if(!doTextures)
    fill(top);
  pushMatrix();
  translate(0, -SCALE/2, -SCALE/2);
  rotateX(PI/2);
  //top face
  beginShape();
  if(doTextures)
    texture(top_t);
  vertex(-SCALE/2, -SCALE/2, 0, 0);
  vertex(SCALE/2, -SCALE/2, 1, 0);
  vertex(SCALE/2, SCALE/2, 1, 1);
  vertex(-SCALE/2, SCALE/2, 0, 1);
  endShape(CLOSE);
  popMatrix();
  
  if(!doTextures)
    fill(top);
  //incase it has columns
  pushMatrix();
  translate(-SCALE/2, 0, -SCALE/2);
  rotateY(PI/2);
  //left face
  beginShape();
  if(doTextures)
    texture(face_t);
  vertex(-SCALE/2, -SCALE/2, 0, 0);
  vertex(SCALE/2, -SCALE/2, 1, 0);
  vertex(SCALE/2, SCALE/2, 1, 1);
  vertex(-SCALE/2, SCALE/2, 0, 1);
  endShape(CLOSE);
  popMatrix();
  
  if(!doTextures)
    fill(top);
  pushMatrix();
  translate(SCALE/2, 0, -SCALE/2);
  rotateY(PI/2);
  //right face
  beginShape();
  if(doTextures)
    texture(face_t);
  vertex(-SCALE/2, -SCALE/2, 0, 0);
  vertex(SCALE/2, -SCALE/2, 1, 0);
  vertex(SCALE/2, SCALE/2, 1, 1);
  vertex(-SCALE/2, SCALE/2, 0, 1);
  endShape(CLOSE);
  popMatrix();
}

void myColumn(int num, color c)
{
  pushMatrix();
  for(int i = 0; i < num; i++)
  {
    if(num % 2 == 0)
      myBox(c,c, wood, wood_top);
    else
      myBox(c,c, birch, birch_top);
    translate(0,-SCALE,0);
  }
  popMatrix();
}
