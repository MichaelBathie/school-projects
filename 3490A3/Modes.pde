final char KEY_VIEW = 'r';
final char KEY_LEFT = 'a';
final char KEY_RIGHT = 'd';
final char KEY_UP = 'w';
final char KEY_DOWN = 's';
final char KEY_JUMP = ' ';
final char KEY_BONUS = 'b';
final char KEY_TEX = 't';
final char KEY_COLLISION = 'c';

boolean keyLeft = false;
boolean keyRight = false;
boolean keyDown = false;
boolean keyUp = false;
boolean keyJump = false;
boolean doBonus = false;
boolean doTextures = false;
boolean doCollision = false;

// false is perspective mode.
boolean orthoMode = true;

void keyPressed()
{
  if(key == KEY_VIEW)
  {
    perspectiveChange(orthoMode);
  }
  else if(key == KEY_LEFT)
  {
    keyLeft = true;
    left = true;
    right = false;
  }
  else if(key == KEY_RIGHT)
  {
    keyRight = true;
    right = true;
    left = false;
  }
  else if(key == KEY_UP)
  {
    keyUp = true;
    up = true;
    down = false;
  }
  else if(key == KEY_DOWN)
  {
    keyDown = true;
    down = true;
    up = false;
  }
  else if(key == KEY_JUMP)
  {
    keyJump = true;
    if(!falling)
      inJump = true;
  }
  else if(key == KEY_TEX)
  {
    if(doTextures)
    {
      doTextures = false;
    }
    else
    {
      doTextures = true; 
    }
  }
  else if(key == KEY_COLLISION)
  {
    if(doCollision)
    {
      doCollision = false;
    }
    else
    {
      doCollision = true; 
    }
  }
}

void keyReleased()
{
  if(key == KEY_LEFT)
  {
    keyLeft = false; 
    if(keyRight && left)
    {
      right = true;
    }
  }
  else if(key == KEY_RIGHT)
  {
    keyRight = false;
    if(keyLeft && right)
    {
      left = true;
    }
  }
  else if(key == KEY_UP)
  {
    keyUp = false; 
    if(keyDown && up)
    {
      down = true;
    }
  }
  else if(key == KEY_DOWN)
  {
    keyDown = false; 
    if(keyUp && down)
    {
      up = true;
    }
  }
   else if(key == KEY_JUMP)
  {
    keyJump = false;
  }
}
