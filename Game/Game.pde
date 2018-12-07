Ball ball;
PFont f;

float plateHeight=500;
float plateWidth=500;
float plateDepth=20;

float cylinderBaseSize = 30;
float cylinderHeight = 40;
int cylinderResolution = 40;
PShape openCylinder = new PShape();
PShape surface1 = new PShape();
PShape surface2 = new PShape();

ArrayList<PVector> cylinders= new ArrayList();

void settings() {
  size(displayWidth, displayHeight, P3D);
}


void setup() {
  f = createFont("Arial", 16, true);
  ball = new Ball();

  float angle;
  float[] x = new float[cylinderResolution + 1];
  float[] y = new float[cylinderResolution + 1];
  //get the x and y position on a circle for all the sides
  for (int i = 0; i < x.length; i++) {
    angle = (TWO_PI / cylinderResolution) * i;
    x[i] = sin(angle) * cylinderBaseSize;
    y[i] = cos(angle) * cylinderBaseSize;
  }

  openCylinder = createShape();
  openCylinder.beginShape(QUAD_STRIP);
  //draw the border of the cylinder
  for (int i = 0; i < x.length; i++) {
    openCylinder.vertex(x[i], y[i], 0);
    openCylinder.vertex(x[i], y[i], cylinderHeight);
  }
  openCylinder.endShape();

  surface1 = createShape();
  surface1.beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < x.length; i++) {
    surface1.vertex(0, 0, cylinderHeight);
    surface1.vertex(x[i], y[i], cylinderHeight);
  }
  surface1.endShape();
  surface2 = createShape();
  surface2.beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < x.length; i++) {
    surface2.vertex(0, 0, 0);
    surface2.vertex(x[i], y[i], 0);
  }
  surface2.endShape();
}


float speed = 1;
float s = 0;
void mouseWheel(MouseEvent event) {
  if (placeCylinder==false) {
    s += event.getCount();
    s = constrain(s, -100, 100);
    speed = map(s, -100, 100, 0.2, 1.5);
  }
}


float rx=0;
float rz=0;
float x=0;
float z=0;
void mouseDragged() {
  if (placeCylinder==false) {
    x = map(-mouseY, -height, 0, -PI/3.0, PI/3.0)
      -map(-pmouseY, -height, 0, -PI/3.0, PI/3.0);
    if ( (rx+x<=PI/3.0) && (rx+x>=-PI/3.0) ) rx+=x*speed;
    z = map(mouseX, 0, width, -PI/3.0, PI/3.0)
      -map(pmouseX, 0, width, -PI/3.0, PI/3.0);
    if ( (rz+z<=PI/3.0) && (rz+z>=-PI/3.0) ) rz+=z*speed;
  }
}

boolean placeCylinder=false;
void keyPressed() {
  if ((key == CODED)&&(keyCode == SHIFT)) {
    placeCylinder=true;
  }
}
void keyReleased() {
  if ((key == CODED)&&(keyCode == SHIFT)) {
    placeCylinder=false;
  }
}

void mouseClicked() {
  if ( (placeCylinder)&&(mouseX>=width/2-plateWidth/2+cylinderBaseSize-5)&&(mouseX<=width/2+plateWidth/2-cylinderBaseSize+5)
    &&(mouseY>=height/2-plateHeight/2+cylinderBaseSize-5)&&(mouseY<=height/2+plateHeight/2-cylinderBaseSize+5)) {
    cylinders.add(new PVector(mouseX, mouseY));
  }
}


PVector position= new PVector(width/2, height/2, 0);
void draw() {
  background(200);
  fill(0);
  pushMatrix();
  translate(width/2, height/2, 0);

  if (placeCylinder) {
    box(plateHeight, plateWidth, plateDepth);

    //Draw 2D ball
    translate(position.x, position.z, plateDepth);
    pushMatrix();
    fill(255);
    noStroke();
    ellipse(0, 0, 50, 50);
    popMatrix();

    //Draw cylinders
    popMatrix();
    for (int i=0; i<cylinders.size(); ++i) {
      pushMatrix();
      translate(cylinders.get(i).x, cylinders.get(i).y, plateDepth);
      shape(openCylinder);
      shape(surface1);
      shape(surface2);
      popMatrix();
    }
  } else {
    rotateX(rx);
    rotateZ(rz);
    box(plateHeight, plateDepth, plateWidth);
    pushMatrix();
    
    //draw the cylinders
    pushMatrix();
    for (int i=0; i<cylinders.size(); ++i) {
      pushMatrix();
      translate(cylinders.get(i).x-width/2, -plateDepth/2, cylinders.get(i).y-height/2);
      rotateX(HALF_PI);
      shape(openCylinder);
      shape(surface1);
      shape(surface2);
      popMatrix();
    }
    popMatrix();

    //draw the ball
    translate(0, -40, 0); //ball on the surface of the board
    position=ball.update(rx, rz); //changing the position as the inclination
    position=ball.checkEdges(position); //check if new position is not outside the board
    position=ball.checkCylinderCollision(position);//check if there is a collision with a cylinder
    translate(position.x, position.y, position.z); //new coordinate system
    ball.display();//displaying
    popMatrix();
    popMatrix();
  }
  textFont(f, 16);
  stroke(0);
  fill(0);
  text("Rotation X : "+ round(rx*180/PI)+
    "        Rotation Z : "+round(rz*180/PI), 
    0, 
    15);
}
class Ball {

  PVector location;
  PVector velocity;
  PVector gravityForce;
  float gravityConstant = 8;
  float sphereRadius = 30;

  Ball() {
    location = new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0);
    if (rx>0) {
      velocity.set(velocity.x, 0, -0.8);
    } else if (rx<0) {
      velocity.set(velocity.x, 0, 0.8);
    } else {
      velocity.set(velocity.x, 0, 0);
    }

    if (rz>0) {
      velocity.set(0.8, 0, velocity.z);
    } else if (rz<0) {
      velocity.set(-0.8, 0, velocity.z);
    } else {
      velocity.set(0, 0, velocity.z);
    }

    gravityForce = new PVector(0, 0, 0);
  }


  PVector update(float rx, float rz) {

    float normalForce = 1;
    float mu = 1.5;
    float frictionMagnitude = normalForce * mu;
    PVector friction = velocity.get();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);

    gravityForce.x = sin(rz) * gravityConstant;
    gravityForce.z = -sin(rx) * gravityConstant;

    return location.add(velocity.add(friction.add(gravityForce)));
  }
  void display() {
    noStroke();
    fill(255);
    sphere(sphereRadius);
  }
  PVector checkEdges(PVector location) {

    if (location.x >= plateWidth/2-sphereRadius) {
      location.set(plateWidth/2-sphereRadius, 0, location.z);
      velocity.x = velocity.x * -1;
    } else if (location.x <= -plateWidth/2+sphereRadius) {
      location.set(-plateWidth/2+sphereRadius, 0, location.z);
      velocity.x = velocity.x * -1;
    }
    if (location.z >= plateHeight/2-sphereRadius) {
      location.set(location.x, 0, plateHeight/2-sphereRadius);
      velocity.z = velocity.z * -1;
    } else if (location.z <= -plateHeight/2+sphereRadius) {
      location.set(location.x, 0, -plateHeight/2+sphereRadius);
      velocity.z = velocity.z * -1;
    }
    return location;
  }
  
   PVector checkCylinderCollision(PVector location) {
    for (int i=0; i<cylinders.size(); ++i) {
      PVector cylinder = new PVector (cylinders.get(i).x-(displayWidth/2), cylinders.get(i).y-(displayHeight/2));
      PVector ball = new PVector(location.x,location.z);
      PVector normalVector = new PVector(cylinder.x-ball.x,cylinder.y-ball.y);
      PVector newVelocity = new PVector(velocity.x,velocity.z);
      
      float dist=normalVector.mag();
      if( dist<=(cylinderBaseSize+sphereRadius) ) { 
        PVector n1= normalVector.copy();
        n1.normalize();
        float factor= newVelocity.dot(n1);
        n1.mult(2*factor);
        newVelocity.sub(n1);
        
        velocity.set(newVelocity.x,0,newVelocity.y);
        
        PVector n= normalVector.copy();
        n.normalize();
        n.mult(cylinderBaseSize+sphereRadius);
        location.set(cylinder.x-n.x,0,cylinder.y-n.y);
      }
    }
    return location;
  }

  
  
}