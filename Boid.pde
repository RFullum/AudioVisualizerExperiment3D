// Individual Boids that fly around and form Flocks
class Boid
{
  // Boid vectors
  PVector position;
  PVector velocity;
  PVector acceleration;
  PVector dir;
  
  // Boid limits
  float r;           // traingle measurment & distance beyond edge of screen
  float maxForce;    // Maximum steering force
  float maxSpeed;    // Speed limit
  
  // Boid multipliers
  float sepMult = 2.5f;    // Original value 1.5f
  float aliMult = 1.0f;    // Original value 1.0f
  float cohMult = 1.2f;    // Original value 1.0f
  
  // Boid color
  color c1;
  color c2;
  
  // Particle system
  ParticleSystem ps;  // particles shoot out back of boid like jet exhaust
  int jetFrames = 10;  // particle out back of boid every jetFrames number of frames
  
  // Constructor
  Boid(float x, float y, float z, color initColor)
  {
    // Vector initialization
    acceleration = new PVector(0.0f, 0.0f, 0.0f);
    velocity = PVector.random3D();
    position = new PVector(x, y, z);
    
    // Limit initialization
    r = 2.0f;
    maxSpeed = 20.0f;    // original value = 2.0f
    maxForce = 0.008f;  // original value = 0.03f 
    
    // Color initialization
    c1 = initColor;
    float minRGB = min( red(c1), ( min(green(c1), blue(c1) ) ) );
    float maxRGB = max( red(c1), ( max(green(c1), blue(c1) ) ) );
    float minMax = minRGB + maxRGB;
    c2 = color( minMax - red(c1), minMax - green(c1), minMax - blue(c1) );
    
    // Particle initialization
    ps = new ParticleSystem( position );
  }
  
  // Calls methods to run and draw boids
  void run(ArrayList<Boid> boids)
  {
    flock(boids);
    update();
    borders();
    render();
  }
  
  // Applies accelleration force to boids
  void applyForce(PVector force)
  {
    acceleration.add(force);
  }
  
  
  // Accumulate new acceleration based on Separation, Alignment, and Cohesion
  void flock(ArrayList<Boid> boids)
  {
    PVector sep = separate(boids);
    PVector ali = align(boids);
    PVector coh = cohesion(boids);
    
    // You can arbitrarily change these force weights for different flock/boid behavior
    sep.mult(sepMult);    // Original value 1.5f
    ali.mult(aliMult);    // Original value 1.0f
    coh.mult(cohMult);    // Original value 1.0f
    
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }
  
  // Update boid values
  void update()
  {
    velocity.add(acceleration);  // Update velocity
    velocity.limit( maxSpeed );  // limit speed
    dir = velocity.copy();
    position.add(velocity);      // new position based on velocity
    acceleration.mult(0.0f);     // Reset accel to 0
  }
  
  // Seeks other like boids
  PVector seek(PVector target)
  {
    PVector desired = PVector.sub(target, position);    // Vector pointing to position of target
    desired.setMag( maxSpeed );
    
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxForce);
    
    return steer;
  }
  
  
  // Wraps at borders
  void borders()
  {
    if (position.x < -r)
      position.x = width + r;
    if (position.y < -r) 
      position.y = height + r;
    if (position.z < -height - r)
      position.z = height + r;
      
    if (position.x > width + r)
      position.x = -r;
    if (position.y > height + r)
      position.y = -r;
    if (position.z > height + r)
      position.z = -r; 
  }
  
  
  // Draws triangle of boid pointing in direction of velocity
  // Currently only rotates in XY directions. Needs to also rotate 
  // to face Z direction
  void render()
  {    
    // Original 2D theta
    // float theta = velocity.heading() + radians(90);
    
    // 3D Rotations: Just the Z and Y works for some reason. 
    // Math people can explain it to me later.
    float thetaZ = atan2(dir.y, dir.x) + radians(90);
    float thetaY = atan2(dir.x, dir.z) + radians(90);
    // float thetaX = atan2(dir.z, dir.y) + radians(90); 
    // Adding third dimension makes 3D rotation wrong for some reason
    // So don't use it but i left it there just because.
    
    fill(c1);      // Boid color
    stroke(c2);    // Boid outline color
    //noStroke();    // No outline runs smoother.
    
    // Individual boid position translation matrix
    pushMatrix();
      translate(position.x, position.y, position.z);
      ps.updateOrigin(new PVector(0.0f, r * 5.0f, 0.0f));
      
      rotateZ(thetaZ);
      rotateY(thetaY);
      
      /* ORIGINAL 2D Rotate
      rotate(theta);
      */
      
      
      beginShape(TRIANGLES);
      
      /*  ORIGINAL 2D TRIANGLE
      vertex(0, -r * 2.0f);
      vertex(-r, r * 2.0f);
      vertex(r, r * 2.0f);
      */
      
      // 3D Dart Shape
      vertex(0.0f, -r * 5.0f, 0.0f);
      vertex(0.0f, r * 5.0f, r * 5.0f);
      vertex(r, r* 5.0f, 0.0f);
      
      vertex(0.0f, -r * 5.0f, 0.0f);
      vertex(-r, r * 5.0f, 0.0f);
      vertex(0.0f, r * 5.0f, r * 5.0f);
      
      vertex(0.0f, -r * 5.0f, 0.0f);
      vertex(0.0f, r * 5.0f, -r * 5.0f);
      vertex(-r, r * 5.0f, 0.0f);
      
      vertex(0.0f, -r * 5.0f, 0.0f);
      vertex(0.0f, r * 5.0f, -r * 5.0f);
      vertex(r, r * 5.0f, 0.0f);

      
      endShape();
      
      // Adds particle out the rear of boid every jetFrames number of frames
      if ( (frameCount % jetFrames) == 0 )
      {
        ps.addParticle();
      }
      
      ps.run();
    popMatrix();
  }
  
  // Separate Boids
  // Checks for nearby boids and steers away
  PVector separate(ArrayList<Boid> boids)
  {
    float sepAmount = 25.0f;                          // Separation Amount
    PVector steer = new PVector(0.0f, 0.0f, 0.0f);    // Steering PVector
    int count = 0;
    
    // For each boid in the system, check if it's too close.
    // If it's between you an the sepAmount, calculate vector away from neighbor
    for (Boid other : boids)
    {
      float distance = PVector.dist(position, other.position);
      
      if ( (distance > 0.0f) && (distance < sepAmount) )
      {
        PVector diff = PVector.sub(position, other.position);
        
        diff.normalize();
        diff.div(distance);      // Weight steering by distance
        steer.add(diff);
        count++;                 // Keep track of how many
      }
      
      // Average by count
      if (count > 0)
      {
        steer.div( (float)count );
      }
      
      if (steer.mag() > 0.0f )
      {
        steer.setMag(maxSpeed);
        // steer.normalize();      // setMag() replaces this
        // steer.mult(maxSpeed);    // setMag() replaces this
        steer.sub(velocity);
        steer.limit(maxForce);
      }
      
      
    }
    
    return steer;
  }
  
  // Alignment 
  // For each boid in system calculate avg velocity
  PVector align(ArrayList<Boid> boids)
  {
    float neighborDist = 50.0f;
    PVector sum = new PVector(0.0f, 0.0f, 0.0f);
    int count = 0;
    
    for (Boid other : boids)
    {
      float distance = PVector.dist(position, other.position);
      
      if ( (distance > 0.0f) && (distance < neighborDist) )
      {
        sum.add(other.velocity);
        count++;
      }
    }
    
    if (count > 0)
    {
      sum.div( (float)count );
      sum.setMag(maxSpeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxForce);
      
      return steer;
    }
    else
    {
      return new PVector(0.0f, 0.0f, 0.0f);
    }
  }
  
  // Cohesion
  // for the average position of all nearby boids, calculate PVector to steer to that position
  PVector cohesion(ArrayList<Boid> boids)
  {
    float neighborDist = 50.0f;
    PVector sum = new PVector(0.0f, 0.0f, 0.0f);
    int count = 0;
    
    for (Boid other : boids)
    {
      float distance = PVector.dist(position, other.position);
      
      if ( (distance > 0) && (distance < neighborDist) )
      {
        sum.add(other.position);
        count++;
      }
    }
    
    if (count > 0)
    {
      sum.div(count);
      return seek(sum);
    }
    else
    {
      return new PVector(0.0f, 0.0f, 0.0f);
    }
  }
}
