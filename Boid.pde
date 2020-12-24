// Individual Boids that fly around and form Flocks
class Boid
{
  // Boid vectors
  PVector position;
  PVector velocity;
  PVector acceleration;
  PVector dir;
  
  // Boid limits
  float r;             // traingle measurment & distance beyond edge of screen
  float maxForce;      // Maximum steering force
  float maxSpeed;      // Speed limit
  float neighborCount; // number of nearby boids of same type
  float boidTotal;     // total number of boids in flock
  
  // Boid multipliers
  float sepMult = 2.5f;    // Original value 1.5f
  float aliMult = 1.0f;    // Original value 1.0f
  float cohMult = 1.2f;    // Original value 1.0f
  
  // Boid color
  color c1;
  color c2;
  
  float c1R;
  float c1G;
  float c1B;
  
  float c2R;
  float c2G;
  float c2B;
  
  // Particle system
  ParticleSystem ps;  // particles shoot out back of boid like jet exhaust
  int jetFrames = 10;  // particle out back of boid every jetFrames number of frames
  
  // Audio
  float fftLevel = 0.0f;
  
  
  
  
  // Constructor
  Boid(float x, float y, float z, color initColor)
  {
    // Vector initialization
    acceleration = new PVector(0.0f, 0.0f, 0.0f);
    velocity     = PVector.random3D();
    position     = new PVector(x, y, z);
    
    // Limit initialization
    r             = 2.0f;     // adjusts the size of the boid
    maxSpeed      = 10.0f;    // original value = 2.0f
    maxForce      = 0.008f;   // original value = 0.03f 
    neighborCount = 0.0f;
    boidTotal     = 0.0f;
    
    // Color initialization
    c1 = initColor;
    
    // Extract color values from c1
    c1R = c1 >> 16 & 0xFF;
    c1G = c1 >> 8 & 0xFF;
    c1B = c1 & 0xFF;
    
    // Derive c2, opposite color from c1
    float minRGB = min( c1R, ( min(c1G, c1B ) ) );
    float maxRGB = max( c1R, ( max(c1G, c1B ) ) );
    float minMax = minRGB + maxRGB;
    
    c2 = color( minMax - c1R, minMax - c1G, minMax - c1B );
    
    // Extract color values from c2
    c2R = c2 >> 16 & 0xFF;
    c2G = c2 >> 8 & 0xFF;
    c2B = c2 & 0xFF;
    
    // Particle initialization
    ps = new ParticleSystem( position );
    
  }  // End Boid() constructor
  
  
  
  
  // Calls methods to run and draw boids
  void run(ArrayList<Boid> boids, float fftVal_)
  {
    fftLevel = fftVal_;
    
    flock(boids);
    update();
    borders();
    render();
  }
  
  
  
  
  // Applies acceleration force to boids
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
    
    dir = velocity.copy();       // copy velocity for rotational calculations in render()
    
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
  
  
  
  
  // Draws triangle of boid pointing in direction of velocity in 3D
  void render()
  {    
    // 3D Rotations: Just the Z and Y works for some reason. 
    // Math people can explain it to me later.
    float thetaZ = atan2(dir.y, dir.x) + radians(90);
    float thetaY = atan2(dir.x, dir.z) + radians(90);
    // float thetaX = atan2(dir.z, dir.y) + radians(90); 
    // Adding third dimension makes 3D rotation wrong for some reason
    // So don't use it but i left it there just because.
     
    // c1 as fill color. 
    // c2 + alpha mapped to fftLevel as stroke color
    // fftLevel multiplies strokeWeight()
    fill(c1);                                                             // Boid color
    stroke( c2R, c2G, c2B, map(fftLevel, 0.0f, 1.0f, 100.0f, 255.0f) );    // Boid outline color
    strokeWeight( 1.0f + ( 1.0f + (fftLevel * 5.0f) ) );
    //noStroke();    // No outline runs smoother; looks lamer.
    
    // Individual boid position translation matrix
    pushMatrix();
      translate(position.x, position.y, position.z);
      
      ps.updateOrigin(new PVector(0.0f, r * 5.0f, 0.0f));
      
      rotateZ(thetaZ);
      rotateY(thetaY);
      
      float rMult = 5.0f;
      
      beginShape(TRIANGLES);
      
      // 3D Dart Shape
      vertex(0.0f, -r * rMult, 0.0f);        // Dart triangle face 1
      vertex(0.0f, r * rMult, r * rMult);
      vertex(r, r* rMult, 0.0f);
      
      vertex(0.0f, -r * rMult, 0.0f);        // Dart triangle face 2
      vertex(-r, r * rMult, 0.0f);
      vertex(0.0f, r * rMult, r * rMult);
      
      vertex(0.0f, -r * rMult, 0.0f);        // Dart triangle face 3
      vertex(0.0f, r * rMult, -r * rMult);
      vertex(-r, r * rMult, 0.0f);
      
      vertex(0.0f, -r * rMult, 0.0f);        // Dart triangle face 4
      vertex(0.0f, r * rMult, -r * rMult);
      vertex(r, r * rMult, 0.0f);

      endShape();
      
      // Propulsion glow circle that grows as more like boids flock near it
      fill( c2R, c2G, c2B, map(neighborCount, 0.0f, boidTotal, 100.0f, 200.0f) );
      noStroke();
      
      circle( 0.0f, r * rMult, map(neighborCount, 0.0f, boidTotal, 1.0f, 50.0f) );
      
      // Adds particle out the rear of boid every jetFrames number of frames
      if ( (frameCount % jetFrames) == 0 )
      {
        ps.addParticle();
      }
      
      ps.run();
    popMatrix();
    
  }  // End render()
  
  
  
  
  // Separate Boids
  // Checks for nearby boids and steers away
  PVector separate(ArrayList<Boid> boids)
  {
    float sepAmount = 25.0f;                          // Separation Amount
    PVector steer   = new PVector(0.0f, 0.0f, 0.0f);  // Steering PVector
    int count       = 0;
    
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
        steer.sub(velocity);
        steer.limit(maxForce);
      }
      
    }
    
    return steer;
    
  }  // End separate()
  
  
  
  
  // Alignment 
  // For each boid in system calculate avg velocity
  PVector align(ArrayList<Boid> boids)
  {
    float neighborDist = 50.0f;
    PVector sum        = new PVector(0.0f, 0.0f, 0.0f);
    int count          = 0;
    
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
    
  }  // End align()
  
  
  
  
  // Cohesion
  // for the average position of all nearby boids, calculate PVector to steer to that position
  PVector cohesion(ArrayList<Boid> boids)
  {
    float neighborDist = 100.0f;
    PVector sum = new PVector(0.0f, 0.0f, 0.0f);
    int count   = 0;
    boidTotal   = (float)boids.size();
    
    for (Boid other : boids)
    {
      float distance = PVector.dist(position, other.position);
      
      if ( (distance > 0) && (distance < neighborDist) )
      {
        sum.add(other.position);
        count++;
      }
    }
    
    neighborCount = (float)count;
    
    if (count > 0)
    {
      sum.div(count);
      return seek(sum);
    }
    else
    {
      return new PVector(0.0f, 0.0f, 0.0f);
    }
    
  }  // End cohesion()
  
  
}
