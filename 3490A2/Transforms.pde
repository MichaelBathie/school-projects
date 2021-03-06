
void myVertex(PVector vert)
{
  _myVertex(vert.x, vert.y, false);
}

void myVertex(float x, float y)
{
  _myVertex(x, y, true);
}

void myVertex(float x, float y, boolean debug)
{
  _myVertex(x, y, debug);
}

// translate the given point from object space to viewport space,
// then plot it with vertex.
void _myVertex(float x, float y, boolean debug)
{
  //TODO: .... do it.
  PVector p = new PVector(x,y,1);
  
  center = determineCameraPan();
  V = getCamera(up, center, zoom);
  M.mult(p, p);
  V.mult(p, p);
  Pr.mult(p, p);
  Vp.mult(p, p);
 
  p.x = p.x/p.z;
  p.x = p.x/p.z;
  p.x = p.x/p.z;
  // suggested debug:
  //if (debug)
    //println(x+" "+y+" --> "+p.x+" "+p.y+" "+p.z);  // pz is w, should always be 1
  vertex(p.x, p.y);
}
