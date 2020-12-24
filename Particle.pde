// Particles in ParticleSystem shooting out back of boid
class Particle
{
  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  
  
  // Constructor
  Particle(PVector l)
  {
    acceleration = new PVector(0.0f, 0.05f, 0.0f);
    velocity = new PVector( random(-0.2, 0.2), 0.5f, random(-0.2, 0.2) );
    position = l.copy();
    lifespan = 50.0f;
  }
  
  // Runs update and display functions
  void run()
  {
    update();
    display();
  }
  
  // Adds acceleration to velocty, velocty to position, and degrades lifespan
  void update()
  {
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 1.0f;
  }
  
  // draws particle with alpha decreasing over lifespan, untile lifespan expires
  void display()
  {
    //stroke(255, lifespan);
    noStroke();
    fill(255, lifespan);
    ellipse(position.x, position.y, 4.0f, 4.0f);    
  }
  
  boolean isDead()
  {
    if (lifespan < 0.0f)
    {
      return true;
    }
    else
    {
      return false;
    }
  }
}
