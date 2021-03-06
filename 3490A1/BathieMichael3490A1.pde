//Michael Bathie 3490 Assignment 1 


class Triangle {
  Triangle(float[] V1, float[] V2, float[] V3) {  // does DEEP copy!!
    v1 = Arrays.copyOf(V1, V1.length); 
    v2 = Arrays.copyOf(V2, V2.length);
    v3 = Arrays.copyOf(V3, V3.length);
  }

  // position data. in 3D space
  float[] v1; // 3 triangle vertices
  float[] v2;
  float[] v3;

  // projected data. On the screen raster
  float[] pv1; // (p)rojected vertices
  float[] pv2;
  float[] pv3;

  // add other things as needed, like normals (face, vectors), edge vectors, colors, etc.  
  
  float[] e1 = new float[2];
  float[] e2 = new float[2];
  float[] e3 = new float[2];
  
  float totalArea;
}

class Point3D
{
  
 Point3D(float xCoord, float yCoord, float zCoord) 
 {
   x = xCoord;
   y = yCoord;
   z = zCoord;
 }
 
 float x;
 float y;
 float z;
}

Triangle[] sphereList;
Triangle[] rotatedList;

void setup() {
  ortho(-320, 320, 320, -320); // hard coded, 640x640 canvas, RHS
  resetMatrix();
  colorMode(RGB, 1.0f);
  
  strokeWeight(1);

  sphereList = makeSphere(SPHERE_SIZE, 12);
  rotatedList = new Triangle[sphereList.length];
  announceSettings();
}

void settings() {
  size(640, 640, P3D); // hard coded 640x640 canvas
}

float theta = 0.0;
float delta = 0.01;
void draw() {
  clear();
  
  if (rotate)
  {
    theta += delta;
    while (theta > PI*2) theta -= PI*2;
  } 

  if (lineTest)
    lineTest();
  else
  {
    rotateSphere(sphereList, rotatedList, theta);
    drawSphere(rotatedList, lighting, shading);
  }
  
}

//////////////////////  MAIN PROGRAM
// creates a sphere made of triangles, centered on 0,0,0, with given radius
//
// also - 
// calculates the 3 edge vectors for each triangle
// calculates the face normal (unit length)
//
// HINT: first setup a loop to calculate all the points around the sphere,
//       store in an array then loop over those points and setup your triangles.
Triangle[] makeSphere(int radius, int divisions) //(1 <points>)3
{
  Point3D[][] points = new Point3D[divisions][divisions];
  Triangle[] tri = new Triangle[divisions*divisions*2]; 
  
  float x;
  float y;
  float z;
  
  for(int i = 0; i < divisions; i++)
  {
    float convertI = map(i, 0, divisions-1, 0, PI);
    for(int j = 0; j < divisions; j++)
    {
      float convertJ = map(j, 0, divisions, 0, TWO_PI);
      
      x = radius*sin(convertI)*sin(convertJ);
      y = radius*cos(convertI);
      z = radius*sin(convertI)*cos(convertJ);
      
      points[i][j] = new Point3D(x,y,z);
    }
  }
  
  int arrayTrack = 0;
  for(int i = 0; i < divisions; i++)
  {
     for(int j = 0; j < divisions; j++)
     {
       float[] newPoint1 = new float[]{points[i][j].x, points[i][j].y, points[i][j].z};
       float[] newPoint2 = new float[]{points[(i+1)%divisions][j].x, points[(i+1)%divisions][j].y, points[(i+1)%divisions][j].z};
       float[] newPoint3 = new float[]{points[(i+1)%divisions][(j+1)%divisions].x, points[(i+1)%divisions][(j+1)%divisions].y, points[(i+1)%divisions][(j+1)%divisions].z};
       tri[arrayTrack] = new Triangle(newPoint1, newPoint2, newPoint3);
       arrayTrack++;
         
       float[] newPoint4 = new float[]{points[i][j].x, points[i][j].y, points[i][j].z};
       float[] newPoint5 = new float[]{points[(i+1)%divisions][(j+1)%divisions].x, points[(i+1)%divisions][(j+1)%divisions].y, points[(i+1)%divisions][(j+1)%divisions].z};
       float[] newPoint6 = new float[]{points[i][(j+1)%divisions].x, points[i][(j+1)%divisions].y, points[i][(j+1)%divisions].z};
       tri[arrayTrack] = new Triangle(newPoint4, newPoint5, newPoint6);
       arrayTrack++;
     }
  }
  
  return tri;
}


// takes a new triangle, and calculates it's normals and edge vectors
Triangle setupTriangle(Triangle t) //2
{
  return t;
}

// This function draws the 2D, already projected triangle, on the raster
// - it culls degenerate or back-facing triangles
//
// - it calls fillTriangle to do the actual filling, and bresLine to
// make the triangle outline. 
//
// - implements the specified lighting model (using the global enum type)
// to calculate the vertex colors before calling fill triangle. Doesn't do shading
//
// - if needed, it draws the outline and normals (check global variables)
//
// HINT: write it first using the gl LINES/TRIANGLES calls, then replace
// those with your versions once it works.
void draw2DTriangle(Triangle t, Lighting lighting, Shading shading) //1
{
  t.e1[X] = t.pv2[X] - t.pv1[X]; //<>//
  t.e1[Y] = t.pv2[Y] - t.pv1[Y]; //<>//
  t.e2[X] = t.pv3[X] - t.pv2[X];
  t.e2[Y] = t.pv3[Y] - t.pv2[Y];
  t.e3[X] = t.pv1[X] - t.pv3[X];
  t.e3[Y] = t.pv1[Y] - t.pv3[Y];
  
  t.totalArea = cross2(t.e1, t.e2)/2;
  
  if (!(t.totalArea < 1))
  {
    fillTriangle(t, shading);
    stroke(1,0,0);
    
    if (doOutline)
    {
      bresLine((int)t.pv1[X], (int)t.pv1[Y], (int)t.pv2[X], (int)t.pv2[Y]);
      bresLine((int)t.pv2[X], (int)t.pv2[Y], (int)t.pv3[X], (int)t.pv3[Y]);
      bresLine((int)t.pv3[X], (int)t.pv3[Y], (int)t.pv1[X], (int)t.pv1[Y]);
    }
    /*
    else
    {
      beginShape(POINTS); 
      vertex(t.pv1[0], t.pv1[1]);
      vertex(t.pv2[0], t.pv2[1]);
      vertex(t.pv3[0], t.pv3[1]);
      endShape();
    }
    */ //remove comment to see points when outline is false
  } //<>//
}

// uses a scanline algorithm to fill the 2D on-raster triangle
// - implements the specified shading algorithm to set color as specified
// in the global variable shading. Note that for NONE, this function simply
// returns without doing anything
// - uses POINTS to draw on the raster
void fillTriangle(Triangle t, Shading shading)
{
  //bounding box
  int xMin = min((int)t.pv1[X], (int)t.pv2[X], (int)t.pv3[X]);
  int xMax = max((int)t.pv1[X], (int)t.pv2[X], (int)t.pv3[X]);
  int yMin = min((int)t.pv1[Y], (int)t.pv2[Y], (int)t.pv3[Y]);
  int yMax = max((int)t.pv1[Y], (int)t.pv2[Y], (int)t.pv3[Y]);
  
  stroke(1,1,1);
  
  if (shading == Shading.FLAT)
  {
    for (int i = xMin; i <= xMax; i++)
    {
      for (int j = yMin; j <= yMax; j++)
      {
        float[] newVector1 = new float[]{(float)i - t.pv1[X], (float)j - t.pv1[Y]};
        float[] newVector2 = new float[]{(float)i - t.pv2[X], (float)j - t.pv2[Y]};
        float[] newVector3 = new float[]{(float)i - t.pv3[X], (float)j - t.pv3[Y]};
        
        if (cross2(t.e1, newVector1) >= 0 && cross2(t.e2, newVector2) >= 0 && cross2(t.e3, newVector3) >= 0)
        {
          beginShape(POINTS);
          vertex(i,j);
          endShape();
        }
      }
    }
  }
  
  if (shading == Shading.BARYCENTRIC)
  {
    for (int i = xMin; i <= xMax; i++)
    {
      for (int j = yMin; j <= yMax; j++)
      {
        float[] newVector1 = new float[]{(float)i - t.pv1[X], (float)j - t.pv1[Y]};
        float[] newVector2 = new float[]{(float)i - t.pv2[X], (float)j - t.pv2[Y]};
        float[] newVector3 = new float[]{(float)i - t.pv3[X], (float)j - t.pv3[Y]};
        
        float crossV1 = cross2(t.e1, newVector1);
        float crossV2 = cross2(t.e2, newVector2);
        float crossV3 = cross2(t.e3, newVector3);
        
        float uAreaProportion = (crossV2/2)/t.totalArea;
        float vAreaProportion = (crossV3/2)/t.totalArea;
        float wAreaProportion = (crossV1/2)/t.totalArea;
        
        if (crossV1 >= 0 && crossV2 >= 0 && crossV3 >= 0)
        {
          stroke(uAreaProportion, vAreaProportion, wAreaProportion);
          beginShape(POINTS);
          vertex(i,j);
          endShape();
        }
      }
    }
  }
}

// given point p, normal n, eye location, light location, calculates phong
// - material represents ambient, diffuse, specular as defined at the top of the file
// - calculates the diffuse, specular, and multiplies it by the material and
// - fillcolor values
float[] phong(float[] p, float[] n, float[] eye, float[] light, 
  float[] material, float[] fillColor, float s)
{
  return new float[]{0, 0, 0};
}

// implements Bresenham's line algorithm
void bresLine(int fromX, int fromY, int toX, int toY)
{
  float error = 0.5f;
  float m; //slope
  int stepX = 1;
  int stepY = 1;
  
  int x = fromX; //start
  int y = fromY; //position
  
  float deltaX = toX - fromX; //difference between x and y 
  float deltaY = toY - fromY; //to calculate the slope of the line
  
  if (deltaX < 0)
  {
    deltaX = deltaX * -1;
    stepX = stepX * -1;
  }
    
  if (deltaY < 0)
  {
    deltaY = deltaY * -1.0f;
    stepY = stepY * -1;
  }
  
  if (deltaX > deltaY) 
  {
    m = deltaY/deltaX; //<>//
    
    while (x != toX) 
    {
      beginShape(POINTS);
      vertex(x,y);
      endShape();
      
      x += stepX;
      error += m;
      
      if (error > 0.5f)
      {
        y += stepY;
        error -= 1.0f;
      }
    }
  }
  else
  {
    m = deltaX/deltaY;  //<>//
    
    while (y != toY)
    {
      beginShape(POINTS);
      vertex(x,y);
      endShape();
      
      y += stepY;
      error += m;
      
      if (error > 0.5f)
      {
        x += stepX;
        error -= 1.0f;
      }
    }
  }
}
