// Group of cohesive Boids
class Flock
{
  ArrayList<Boid> boids;
  
  Flock()
  {
    boids = new ArrayList<Boid>();    // Initialize list
  }
  
  // Passes entire list of boids to each boid
  void run()
  {
    for (Boid b : boids)
    {
      b.run(boids);
    }
  }
  
  // Add boid
  void addBoid(Boid b)
  {
    boids.add(b);
  }
}
