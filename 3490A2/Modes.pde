final char KEY_ROTATE_RIGHT = ']';
final char KEY_ROTATE_LEFT = '[';
final char KEY_ZOOM_IN = '=';
final char KEY_ZOOM_OUT = '-';
final char KEY_ORTHO_CHANGE = 'o';
final char KEY_TEST_MODE = 't';

final float ANGLE_CHANGE = PI/16; // additive
final float ZOOM_CHANGE = 1.1;    // multiplicative


// if on, draws test pattern. Otherwise, draws your scene
boolean testMode = true;

enum OrthoMode {
  IDENTITY,        // no change. straight to viewport
    CENTER640,     // 0x0 at center, width/height is 640 (+- 320)
    BOTTOMLEFT640, // 0x0 at bottom left, top right is 640x640
    FLIPX,         // same as CENTER640 but x is flipped
    ASPECT         // uneven aspect ratio: x is < -320 to 320 >, y is <-100 - 100> 
}
OrthoMode orthoMode = OrthoMode.IDENTITY;
final OrthoMode DEFAULT_ORTHO_MODE = OrthoMode.CENTER640; //<>//

void keyPressed()
{
  if (key == KEY_ROTATE_RIGHT)
  {
    angle_track -= ANGLE_CHANGE;
    rotateCamera(-ANGLE_CHANGE);
  }
  if (key == KEY_ROTATE_LEFT)
  {
    angle_track += ANGLE_CHANGE;
    rotateCamera(ANGLE_CHANGE);
  }
  if (key == KEY_ZOOM_IN)
  {
    zoom *= ZOOM_CHANGE;
    adjustZoom(true); //zoom in 
    announceSettings("zoom");
  }

  if (key == KEY_ZOOM_OUT)
  {
    zoom /= ZOOM_CHANGE;
    adjustZoom(false); //zoom out
    announceSettings("zoom");
  }

  if (key == KEY_ORTHO_CHANGE)
  {
    int next = (orthoMode.ordinal()+1)%OrthoMode.values().length;
    orthoMode = OrthoMode.values()[next];
    getOrtho(orthoMode);
    announceSettings("ortho");
  }

  if (key == KEY_TEST_MODE)
  {
    if(testMode)
      testMode = false;
    else
      testMode = true;
  }

}

void announceSettings(String mode)
{
  String msg = "";
  if(mode.equals("ortho"))
    msg+="Orthographic: "+orthoMode;
  else if(mode.equals("zoom"))
    msg+="Zoom Level: "+zoom;
  println(msg);
}
