// A 3D reworking of the 2D Processing Example: Flocking by Daniel Shiffman, an
// implementation of Craig Reynold's Boids program to simulate the flocking behavior 
// of birds. Each boid steers itself based on rules of avoidance, alignment, 
// and coherence.
// https://processing.org/examples/flocking.html
//
// For each FFT band there's a new flock of a different color. 
// Click the mouse to add a new boid to all flocks.
//
// To Do ideas:
//   - Have flocks of same band do something when they're near each other
//     such as high alpha or lerp colors or add shape or something
//   - Have FFT band amplitude modify boids direction, flocking rules, or color change
//   - Figure out how to rotate Boid class in 3D (Currently only rotates in 2D) 

import processing.sound.*;


// Audio
AudioIn audioIn;
FFT fft;
int fftResolution = 4;                    // the power you're raising 2 to:  2^fftResolution
int bands = (int)pow(2, fftResolution);   // number of FFT bands using fftResolution
float smoothingFactor = 0.2f;             // reaction to FFT band amplitude speed. (lower = faster)
float[] spectrum = new float[bands];      // array of FFT band values for smoothing
float fftThresh = 0.5f;                   // *to be used for FFT/Boid interactions*


// Boid flock
Flock[] flocks = new Flock[bands];      // Array of instances
color[] flockColor = new color[bands];  // Array of colors for individual flocks
int initBoidCount = 50;                 // Starting number of boids in each flock (original 150)


void setup()
{
  fullScreen(P3D);  // 3D mode fullscreen
  
  // Audio setup
  audioIn = new AudioIn(this, 0);  // Audio input on default device
  fft = new FFT(this, bands);      // FFT instance
  
  audioIn.start();     // Start audioIn
  fft.input(audioIn);  // FFT to analyze audio from audioIn
  

  // Boid flock
  // for each flock, create instance of flock and populate with initial boid count
  for (int i=0; i<bands; i++)
  {
    flocks[i] = new Flock();                                         // create flock instance in array
    flockColor[i] = color( random(255), random(255), random(255) );  // assign color to flock instance
    
    // Add initial boids to each flock in random places at startpoint (xStart, yStart, zStart) 
    for (int j=0; j<initBoidCount; j++)
    {    
      float xStart = map( i, 0.0f, bands, 0.0f, width ) + random( -(width / bands), (width / bands) );
      float yStart = map( j, 0.0f, initBoidCount, 0.0f, height ) + random( -(height / initBoidCount), (height / initBoidCount) );
      float zStart = random( -map( (i * j), 0.0f, bands * initBoidCount, 0.0f, height), map( (i * j), 0.0f, bands * initBoidCount, 0.0f, height));
      flocks[i].addBoid( new Boid(xStart, yStart, zStart, flockColor[i]) );
    }
  }
  
}



void draw()
{
  background(0);  // black
  
  // FFT
  fft.analyze();  // analyze current fft spectrum
  
  // FFT Smoothing (makes fft band amplitude changes more or less smooth
  for (int i=0; i<bands; i++)
  {
    spectrum[i] += (fft.spectrum[i] - spectrum[i]) * smoothingFactor;
  }
  
  
  // Boids
  // Run all the flocks
  for (int i=0; i<bands; i++)
  {
    flocks[i].run();
  }
  
}


// Function to add another boid to a flock //<>//
void addBoidAmp(int index)
{
  flocks[index].addBoid( new Boid(random(width), random(height), random(height), flockColor[index]) );
}

// When mouse pressed, add a new boid to each flock
void mousePressed()
{
  //flock.addBoid( new Boid(mouseX, mouseY, flock.flockColor) );
  for (int i=0; i<bands; i++)
  {
    flocks[i].addBoid( new Boid(random(width), random(height), random(height), flockColor[i]) );
  }
}
