// ParticleSystem shooting particles out rear of each boid
class ParticleSystem
{
  ArrayList<Particle> particles;  // Particles in particleSystem
  PVector origin;                 // Origin of particles
  
  
  
  // Constructor
  ParticleSystem(PVector position)
  {
    origin = position.copy();
    particles = new ArrayList<Particle>();
  }
  
  
  
  // Adds a new particle to system at origin
  void addParticle()
  {
    particles.add( new Particle(origin) );
  }
  
  
  
  // Moves origin along with boid
  void updateOrigin(PVector newOrigin)
  {
    origin = newOrigin.copy();
  }
  
  
  
  // Shoots particles out of system, displaying each particle until it's dead
  void run()
  {
    for (int i = particles.size() - 1; i >= 0; i--)
    {
      Particle p = particles.get(i);
      p.run();
      
      if ( p.isDead() )
      {
        particles.remove(i);
      }
    }
  }
}
