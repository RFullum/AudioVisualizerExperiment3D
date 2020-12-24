// A 3D reworking of the 2D Processing Example: "Flocking by Daniel Shiffman, an
// implementation of Craig Reynold's Boids program to simulate the flocking behavior 
// of birds. Each boid steers itself based on rules of avoidance, alignment, 
// and coherence."
// https://processing.org/examples/flocking.html
//
// - For each FFT band there's a new flock of a different color. 
// - Each boid is a 3D dart shape with a "jet" of particles out its rear
// - Click the mouse to add a new boid to all flocks.
// - FFT band's amplitude allows faster acceleration of that band's boids
// - FFT band's amplitude intensifies boid's stroke color and weight
// - As boids of a like-kind flock, their nearby numbers increase the size and color
//   of their "propulsion glow circle"
// - Option to include method that adds boids when fft band's amplitude is greater than a threshold
//


import processing.sound.*;


// Audio
AudioIn audioIn;
FFT fft;
int fftResolution = 3;                    // the power you're raising 2 to:  2^fftResolution
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
  fft     = new FFT(this, bands);  // FFT instance
  
  audioIn.start();     // Start audioIn
  fft.input(audioIn);  // FFT to analyze audio from audioIn
  

  // Boid flock
  // for each flock, create instance of flock and populate with initial boid count
  for (int i=0; i<bands; i++)
  {
    flocks[i]     = new Flock();                                     // create flock instance in array
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
  
}  // setup()




void draw()
{
  background(0);  // black
  
  // FFT
  fft.analyze();  // analyze current fft spectrum
  
  // FFT Smoothing (makes fft band amplitude changes more or less smooth
  for (int i=0; i<bands; i++)
  {
    spectrum[i] += (fft.spectrum[i] - spectrum[i]) * smoothingFactor;
    
    /* UNUSED: adds boids to fft's flock if over threshold. To reinstate, also uncomment
     * the addBoidAmp() method below.
     *
    if (spectrum[i] > 0.5f)
    {
      addBoidAmp(i);
    }
    */
  }
  
  // Boids
  // Run all the flocks
  for (int i=0; i<bands; i++)
  {
    // Passing spectrum value logarithmically from 0 to 1
    flocks[i].run( log( map(spectrum[i], 0.0f, 1.0f, 1.0f, 2.71f) ) );
  }
  
}  // draw()




/*  
 * CURRENTLY UNUSED: To reinstate, uncomment, and uncomment the marked logic in
 * the draw() method.
 *
// Function to add another boid to a flock when fft band level is above threshold. //<>// //<>//
void addBoidAmp(int index)
{
  flocks[index].addBoid( new Boid(random(width), random(height), random(height), flockColor[index]) );
}
*/




// When mouse pressed, add a new boid to each flock
void mousePressed()
{
  //flock.addBoid( new Boid(mouseX, mouseY, flock.flockColor) );
  for (int i=0; i<bands; i++)
  {
    flocks[i].addBoid( new Boid(random(width), random(height), random(height), flockColor[i]) );
  }
}
