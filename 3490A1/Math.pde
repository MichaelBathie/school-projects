  /// BASIC Math functions
// populate as needed, and add others you may need. I only needed these.
// HHIINNT:: use test cases and a test function to make sure you don't have a mistake!!!!!!
//   - I spent like 3 hours because I had a typo in my cross product :(

// the "2D cross product", as in class
float cross2(float[] e1, float[] e2)
{
  return ((e1[0]*e2[1]) - (e1[1]*e2[0]));
}

float[] cross3(float[] a, float[] b)
{
  float x = (a[1]*b[2]) - (a[2]*b[1]);
  float y = (a[2]*b[0]) - (a[0]*b[2]);
  float z = (a[0]*b[1]) - (a[1]*b[0]);
  return new float[]{x, y, z};
}

// normalize v to length 1 in place
void normalize(float[] v)
{
  float mag;
  float sum = 0;
  
  for (int i = 0; i < v.length; i++)
  {
    sum += sq(v[i]);
  }
  
  mag = sqrt(sum);
  
  for (int i = 0; i < v.length; i++)
  {
    v[i] = v[i]/mag;
  }
    
}

float dot(float[] v1, float[] v2)
{ 
  float dotProduct = 0;
  
  for (int i = 0; i < v1.length; i++)
  {
    dotProduct += v1[i]*v2[i];
  }
  return dotProduct;
}

// return a new vector representing v1-v2
float[] subtract(float[] v1, float v2[])
{
  float[] vectorDifference = new float[v1.length];
  
  for (int i = 0; i < vectorDifference.length; i++)
  {
    vectorDifference[i] = v1[i] - v2[i];
  }
  
  return vectorDifference; 
}
