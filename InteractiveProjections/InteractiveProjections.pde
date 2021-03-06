void settings() {
  size(1000, 780, P2D);
}
void setup () {
}

float scaleValue=1;
void mouseDragged() 
{
  scaleValue = scaleValue + 0.01;
}

float rotateValueX=0;
float rotateValueY=0;
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      rotateValueX= (rotateValueX+0.1);
    } else if (keyCode == DOWN) {
      rotateValueX= (rotateValueX-0.1);
    } 
   else if (keyCode == RIGHT){
    rotateValueY= (rotateValueY+0.1);
  }else if (keyCode == LEFT){
    rotateValueY= (rotateValueY-0.1);
  }}
}


void draw() {
  background(255, 255, 255);
  My3DPoint eye = new My3DPoint(0, 0, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0);
  My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);
  
  //rotated around y
  float[][] transform4 = rotateYMatrix(rotateValueY);
  input3DBox = transformBox(input3DBox, transform4);
  projectBox(eye, input3DBox);
  
  //rotated around x
  float[][] transform1 = rotateXMatrix(rotateValueX);
  input3DBox = transformBox(input3DBox, transform1);
  projectBox(eye, input3DBox);
  
  //rotated and translated
  float[][] transform2 = translationMatrix(200, 200, 0);
  input3DBox = transformBox(input3DBox, transform2);
  projectBox(eye, input3DBox);
  
  //rotated translated and scale
  float[][] transform3 = scaleMatrix(scaleValue, scaleValue, scaleValue);
  input3DBox = transformBox(input3DBox, transform3);
  projectBox(eye, input3DBox).render(); 
}

class My2DPoint {
  float x;
  float y;
  My2DPoint(float x, float y) {
    this.x = x;
    this.y = y;
  }
}
class My3DPoint {
  float x;
  float y;
  float z;
  My3DPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

My2DPoint projectPoint(My3DPoint eye, My3DPoint p) { 
  My2DPoint point = new My2DPoint(0.0, 0.0);
  float xp = (p.x-eye.x)*(eye.z/(eye.z-p.z));
  float yp= (p.y-eye.y)*(eye.z/(eye.z-p.z));
  point.x=xp;
  point.y=yp;
  return point;
}

class My2DBox {
  My2DPoint[] s;
  My2DBox(My2DPoint[] s) {
    this.s = s;
  }
  void render() {
    line(s[0].x, s[0].y, s[1].x, s[1].y);
    line(s[0].x, s[0].y, s[3].x, s[3].y);
    line(s[0].x, s[0].y, s[4].x, s[4].y);
    line(s[2].x, s[2].y, s[6].x, s[6].y);
    line(s[2].x, s[2].y, s[3].x, s[3].y);
    line(s[2].x, s[2].y, s[1].x, s[1].y);
    line(s[1].x, s[1].y, s[5].x, s[5].y);
    line(s[3].x, s[3].y, s[7].x, s[7].y);
    line(s[4].x, s[4].y, s[5].x, s[5].y);
    line(s[4].x, s[4].y, s[7].x, s[7].y);
    line(s[5].x, s[5].y, s[6].x, s[6].y);
    line(s[6].x, s[6].y, s[7].x, s[7].y);
  }
}

class My3DBox {
  My3DPoint[] p;
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ) {
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[]{new My3DPoint(x, y+dimY, z+dimZ), 
      new My3DPoint(x, y, z+dimZ), 
      new My3DPoint(x+dimX, y, z+dimZ), 
      new My3DPoint(x+dimX, y+dimY, z+dimZ), 
      new My3DPoint(x, y+dimY, z), 
      origin, 
      new My3DPoint(x+dimX, y, z), 
      new My3DPoint(x+dimX, y+dimY, z)
    };
  }
  My3DBox(My3DPoint[] p) {
    this.p = p;
  }
}

My2DBox projectBox (My3DPoint eye, My3DBox box) { 
  My2DPoint[] ProjectTab = { 
    new My2DPoint(0.0, 0.0), 
    new My2DPoint(0.0, 0.0), 
    new My2DPoint(0.0, 0.0), 
    new My2DPoint(0.0, 0.0), 
    new My2DPoint(0.0, 0.0), 
    new My2DPoint(0.0, 0.0), 
    new My2DPoint(0.0, 0.0), 
    new My2DPoint(0.0, 0.0)};
  int i=0;
  for (My3DPoint point : box.p) {
    ProjectTab[i]= projectPoint(eye, point);
    i++;
  }
  return new My2DBox(ProjectTab);
}

float[] homogeneous3DPoint (My3DPoint p) {
  float[] result = {p.x, p.y, p.z, 1};
  return result;
}

float[][]  rotateXMatrix(float angle) {
  return(new float[][] {{1, 0, 0, 0}, 
    {0, cos(angle), sin(angle), 0}, 
    {0, -sin(angle), cos(angle), 0}, 
    {0, 0, 0, 1}});
}
float[][] rotateYMatrix(float angle) { 
  return(new float[][] {{cos(angle), 0, -sin(angle), 0}, 
    {0, 1, 0, 0}, 
    {sin(angle), 0, cos(angle), 0}, 
    {0, 0, 0, 1}});
}
float[][] rotateZMatrix(float angle) { 
  return(new float[][] {{cos(angle), -sin(angle), 0, 0}, 
    {sin(angle), cos(angle), 0, 0}, 
    {0, 0, 1, 0}, 
    {0, 0, 0, 1}});
}
float[][] scaleMatrix(float x, float y, float z) { 
  return(new float[][] {{x, 0, 0, 0}, 
    {0, y, 0, 0}, 
    {0, 0, z, 0}, 
    {0, 0, 0, 1}});
}
float[][] translationMatrix(float x, float y, float z) { 
  return (new float[][]{{1, 0, 0, x}, 
    {0, 1, 0, y}, 
    {0, 0, 1, z}, 
    {0, 0, 0, 1}});
}

float[] matrixProduct(float[][] a, float[] b) { 
  float[] product = new float[]{ 0.0, 0.0, 0.0, 0.0};
  for (int i=0; i<a.length; ++i) {
    for (int j=0; j<b.length; ++j) {
      product[i]=product[i]+a[i][j]*b[j];
    }
  }
  return product;
}


My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  float[][] homogeneous3DPoints={ {0, 0, 0, 0}, 
    {0, 0, 0, 0}, 
    {0, 0, 0, 0}, 
    {0, 0, 0, 0}, 
    {0, 0, 0, 0}, 
    {0, 0, 0, 0}, 
    {0, 0, 0, 0}, 
    {0, 0, 0, 0}
  };
  float[][] product={ {0, 0, 0, 0}, 
    {0, 0, 0, 0}, 
    {0, 0, 0, 0}, 
    {0, 0, 0, 0}, 
    {0, 0, 0, 0}, 
    {0, 0, 0, 0}, 
    {0, 0, 0, 0}, 
    {0, 0, 0, 0}
  };
  int i=0;
  for (My3DPoint p : box.p) {
    homogeneous3DPoints[i]=homogeneous3DPoint(p);
    i++;
  }
  int j=0;
  for (float[] homP : homogeneous3DPoints) {
    product[j] = matrixProduct(transformMatrix, homP);
    j++;
  }
  My3DPoint[] points={new My3DPoint(0.0, 0.0, 0.0), 
    new My3DPoint(0.0, 0.0, 0.0), 
    new My3DPoint(0.0, 0.0, 0.0), 
    new My3DPoint(0.0, 0.0, 0.0), 
    new My3DPoint(0.0, 0.0, 0.0), 
    new My3DPoint(0.0, 0.0, 0.0), 
    new My3DPoint(0.0, 0.0, 0.0), 
    new My3DPoint(0.0, 0.0, 0.0), 
  };
  for (int l=0; l<product.length; ++l) {
    points[l]=euclidian3DPoint(product[l]);
  }
  return new My3DBox(points);
}

My3DPoint euclidian3DPoint (float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}