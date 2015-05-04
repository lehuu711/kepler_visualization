/*

 Kepler Visualization
 2011 - new data added in 2012
 blprnt@blprnt.com
 
 You can toggle between view modes with the keys 4,3,2,1,` 
 
 */

// Import libraries
import processing.opengl.*;
PFont label = createFont("Helvetica", 96);

// Display size
int xScreen = 1000;
int yScreen = 800;

// Camera movement variables
float xShift = 0;
float yShift = 0;
float txShift = 0;
float tyShift = 0;
final static float shift = 20;

// Hold all of our planets
ArrayList<ExoPlanet> planets = new ArrayList();

// Conversion constants
float ER = 1;           // Earth Radius, in pixels
float AU = 1500;        // Astronomical Unit, in pixels
float YEAR = 50000;     // One year, in frames

// Max/Min numbers
float maxTemp = 3257;
float minTemp = 3257;
float yMax = 10;
float yMin = 0;
float maxSize = 0;
float minSize = 1000000;

// Axis labels
String xLabel = "Semi-major Axis (Astronomical Units)";
String yLabel = "Temperature (Kelvin)";

// Rotation vectors used to control the main 3D space
PVector rot = new PVector();
PVector trot = new PVector();

// Master zoom
float zoom = 0;
float tzoom = 0.3;

// A zero-one weight that controls whether the planets are flat on the
// plane (0) or not (1)
float flatness = 0;
float tflatness = 0;

// Add controls (e.g. zoom, sort selection)
Controls controls; 
int showControls;
boolean draggingZoomSlider = false;
boolean isMoving = true;

// Parameters to transpose the mouse location on the field
float mX = 0;
float mY = 0;
float mZ = 0;
float mTheta = 0;
float mRadius = 0;

// Value for making selected ExoPlanets flicker
float blink = 0;
int tBlink = 2;

// Easter egg fun
boolean easterEgg = false;
PImage egg1;
PImage egg2;

ExoPlanet markedPlanet = null;

// Displays planet data
SidePanel panel = new SidePanel(xScreen,yScreen,300);

// Buttons
ModeButton noSort = new ModeButton(48,350,20,20,"Reset Parameters");
ModeButton fieldFlip = new ModeButton(48,400,20,20,"Flip between Views");
ModeButton fieldTilt = new ModeButton(48,450,20,20,"Tilt Plane (Non-Plot View Only)");
ModeButton sizeSort = new ModeButton(48,500,20,20, "Sort by Size");
ModeButton tempSort = new ModeButton(48,550,20,20, "Sort by Temperature");

boolean mouseClicked = false;

void setup() {
  size(xScreen, yScreen, OPENGL);
  background(0);
  smooth();  
  textFont(label, 96);

// TODO delete
// Because NASA released their data from 2011 and 2012 in somewhat
// different formats, there are two functions to load the data and populate
// the 'galaxy'.
//  getPlanets(sketchPath + "/data/KeplerData.csv", false);
//  println(planets.size());
//  getPlanets(sketchPath + "/data/planets2012_2.csv", true);
//  println(planets.size());
  
  // Populate the "galaxy"
  getPlanets(sketchPath + "/data/20150504KOI.csv", true);
  println(planets.size());
  addMarkerPlanets();
  updatePlanetColors();
  
  controls = new Controls();
  showControls = 1;
  
  // Load Easter eggs
  egg1 = loadImage("head1.png");
  egg2 = loadImage("head2.png");
}

void getPlanets(String url, boolean header) {
  // The data is loaded and a planet is made from each line of the data
  String[] pArray = loadStrings(url);
  
  
// TODO delete
//  int start = is2012 ? 0 : 1; // skip header on 2011 data
//  for (int i = start; i < pArray.length; i++) {
//    ExoPlanet p;
//    if (is2012) {
//      p = new ExoPlanet().fromCSV2012(split(pArray[i], ",")).init();
//    } else {
//      p = new ExoPlanet().fromCSV2011(split(pArray[i], ",")).init();
//    }

  int start = header ? 1 : 0; // skip header 
  for (int i = start; i < pArray.length; i++) { 
    ExoPlanet p;
    p = new ExoPlanet().from(split(pArray[i], ",")).init();
    if(p.radius < 100) {
      planets.add(p);
    }
    
    maxSize = max(p.radius, maxSize);
    minSize = min(p.radius, minSize);

    // These are two planets from the 2011 data set that I wanted to feature.
    if (p.KOI.equals("326.01") || p.KOI.equals("314.02")) {
      p.feature = true;
      p.label = p.KOI;
    } 
  }
}

void updatePlanetColors()
{
  // Calculate overall min/max temps (will include the marker planets this way)
  for (int i = 0; i < planets.size(); i++)
  {
    ExoPlanet p = planets.get(i);
    maxTemp = max(p.temp, maxTemp);
    minTemp = min(abs(p.temp), minTemp);
  }

  colorMode(HSB);
  for (int i = 0; i < planets.size(); i++)
  {
    ExoPlanet p = planets.get(i);

    if (0 < p.temp)
    {
      float h = map(sqrt(p.temp), sqrt(minTemp), sqrt(maxTemp), 200, 0);
      p.col = color(h, 255, 255);
    }
    else
    {
      // What should we do with planets that have a negative temp in kelvin?
      p.col = color(200, 255, 255);
    }
  }
  colorMode(RGB);
}


void addMarkerPlanets() {
  // Now, add the solar system planets
  ExoPlanet mars = new ExoPlanet();
  mars.period = 686;
  mars.radius = 0.533;
  mars.axis = 1.523;
  mars.incl = 1.850;
  mars.temp = 212;
  mars.feature = true;
  mars.label = "Mars";
  mars.init();
  planets.add(mars);

  ExoPlanet earth = new ExoPlanet();
  earth.period = 365;
  earth.radius = 1;
  earth.axis = 1;
  earth.incl = 0;
  earth.temp = 254;
  earth.feature = true;
  earth.label = "Earth";
  earth.init();
  planets.add(earth);

  ExoPlanet jupiter = new ExoPlanet();
  jupiter.period = 4331;
  jupiter.radius = 11.209;
  jupiter.axis = 5.2;
  jupiter.incl = 7.005;
  jupiter.temp = 124;
  jupiter.feature = true;
  jupiter.label = "Jupiter";
  jupiter.init();
  planets.add(jupiter);

  ExoPlanet mercury = new ExoPlanet();
  mercury.period = 87.969;
  mercury.radius = 0.3829;
  mercury.axis = 0.387;
  mercury.incl = 1.305;
  mercury.temp = 434;
  mercury.feature = true;
  mercury.label = "Mercury";
  mercury.init();
  planets.add(mercury);
}

void draw() {
  calcMousePos();
  calcBlink();
  
  // Ease rotation vectors, zoom
  zoom += (tzoom - zoom) * 0.01;     
  if (zoom < 0)  {
     zoom = 0;
  } else if (zoom > 3.0) {
     zoom = 3.0;
  }
  controls.updateZoomSlider(zoom);  
  rot.x += (trot.x - rot.x) * 0.1;
  rot.y += (trot.y - rot.y) * 0.1;
  rot.z += (trot.z - rot.z) * 0.1;

  // Ease the flatness weight
  flatness += (tflatness - flatness) * 0.1;

  // MousePress - Controls Handling 
  if (mousePressed) {
     if((showControls == 1) && controls.isZoomSliderEvent(mouseX, mouseY)) {
        draggingZoomSlider = true;
        zoom = controls.getZoomValue(mouseY);        
        tzoom = zoom;
     } 
  }



  background(10);
  
  // show controls
  if (showControls == 1) {
     controls.render(); 
  }
  
  translate(-xShift,-yShift);
  pushMatrix();
  // We want the center to be in the middle and slightly down when flat, and to the left and down when raised
  translate(width/2 - (width * flatness * 0.4), height/2 + (160 * rot.x));
  rotateX(rot.x);
  rotateZ(rot.z);
  scale(zoom);

  // Draw the sun
  fill(255 - (255 * flatness));
  noStroke();
  ellipse(0, 0, 10, 10);

  // Draw Rings:
  strokeWeight(2);
  noFill();

  // Draw a 2 AU ring
  stroke(255, 100 - (90 * flatness));
  ellipse(0, 0, AU * 2, AU * 2);

  // Draw a 1 AU ring
  stroke(255, 50 - (40 * flatness));
  ellipse(0, 0, AU, AU);

  // Draw a 10 AU ring
  ellipse(0, 0, AU * 10, AU * 10);

  // Draw the Y Axis
  stroke(255, 100);
  pushMatrix();
  rotateY(-PI/2);
  line(0, 0, 500 * flatness, 0);

  // Draw Y Axis max/min
  pushMatrix();
  fill(255, 100 * flatness);
  rotateZ(PI/2);
  textFont(label);
  textSize(12);
  textAlign(LEFT);
  text(round(yMin), -textWidth(str(yMin)), 0);
  text(round(yMax), -textWidth(str(yMax)), -500);
  popMatrix();

  // Draw Y Axis Label
  fill(255, flatness * 255);
  text(yLabel, 250 * flatness, -10);

  popMatrix();

  // Draw the X Axis if we are not flat
  pushMatrix();
  rotateZ(PI/2);
  line(0, 0, 1500 * flatness, 0);

  if (flatness > 0.5) {
    pushMatrix();
    rotateX(PI/2);
    line(AU * 1.06, -10, AU * 1.064, 10); 
    line(AU * 1.064, -10, AU * 1.068, 10);   
    popMatrix();
  }

  // Draw X Axis Label
  fill(255, flatness * 255);
  rotateX(-PI/2);
  text(xLabel, 50 * flatness, 17);

  // Draw X Axis min/max
  fill(255, 100 * flatness);
  text(1, AU, 17);
  text("0.5", AU/2, 17);

  popMatrix();

  // Render the planets
  for (int i = 0; i < planets.size(); i++) {
    ExoPlanet p = planets.get(i);
    if (p.vFlag < 4) {
      if (isMoving) {
        p.update();
      }
      p.render(panel);
    }
  }
  popMatrix();
  translate(xShift,yShift);
  panel.render();
  
  fieldFlip.render();
  fieldTilt.render();
  noSort.render();
  sizeSort.render();
  tempSort.render();
  
  xShift += (txShift-xShift) * 0.1;
  yShift += (tyShift-yShift) * 0.1;
  
  //Make sure mouse isn't still clicked by the end of the frame
  mouseClicked = false;
}

void calcMousePos() {
  //Overhead view, (x,y) coordinates
  if (tflatness == 0) {
    mX = (mouseX+xShift - xScreen/2)/zoom;
    mY = (mouseY-yShift - yScreen/2)/zoom;
    mZ = 0;
  }
  //Chart view, (y,z) (?) coordinates
  //(0,0) starts at the bottom left (center of revolution)
  else if (tflatness == 1) {
    //x-field is not used for the plot
    mX = 0;
    
    //Plot edge (x-axis) starts at bottom, 1/10 of screen width
    //x-axis is actually the y-field value
    mY = (mouseX+xShift-xScreen/10)/zoom;
    
    //Plot edge starts at bottom 500+(screen height - 500)/2
    //y-axis is actually the z-field value
    float offset = 500+(yScreen-500)/2;
    mZ = (offset-mouseY-yShift)/zoom;
  }
}

void calcBlink() {
  float t = blink+tBlink;
  if (t>250 || t<150) {
    tBlink *= -1;
  }
  t = max(150,t);
  t = min(250,t);
  blink = t;
}

void sortBySize() {
  // Raise the planets off of the plane according to their size
  for (int i = 0; i < planets.size(); i++) {
    planets.get(i).tz = map(planets.get(i).radius, 0, maxSize, 0, 500);
  }
}

void sortByTemp() {
  // Raise the planets off of the plane according to their temperature
  for (int i = 0; i < planets.size(); i++) {
    planets.get(i).tz = map(planets.get(i).temp, minTemp, maxTemp, 0, 500);
  }
}

void unSort() {
  // Put all of the planets back onto the plane
  for (int i = 0; i < planets.size(); i++) {
    planets.get(i).tz = 0;
  }
}

void keyPressed() {
  String timeStamp = hour() + "_"  + minute() + "_" + second();
  if (key == 's') {
    save("out/Kepler" + timeStamp + ".png");
  } else if (key == 'c'){
     showControls = -1 * showControls;
  } else if (key == 'e') {
    easterEgg = true;
  }

  if (keyCode == UP) {
    tyShift -= shift;
  } 
  else if (keyCode == DOWN) {
    tyShift += shift;
  }
  else if (keyCode == LEFT) {
    txShift -= shift;
  } 
  else if (keyCode == RIGHT) {
    txShift += shift;
  }

  else if (key == '`') {
    unSort(); 
    toggleFlatness(0);
  }
}

void toggleFlatness(float f) {
  tflatness = f;
  if (tflatness == 1) {
    trot.x = PI/2;
    trot.z = -PI/2;
  }
  else {
    trot.x = 0;
    trot.z = 0;
  }
}

void keyReleased() {
  if (key == 'e') {
    easterEgg = false;
  }
}

void mouseReleased() {
  draggingZoomSlider = false;
}

void mouseClicked() {
  mouseClicked = true;
  if (fieldFlip.isClicked(mouseClicked)) {
    tflatness = (tflatness == 1) ? (0):(1);
    toggleFlatness(tflatness);
  }
  else if (fieldTilt.isClicked(mouseClicked)) {
    if (tflatness == 1) {
    }
    else if (trot.x == PI/2) {
      trot.x = 0;
    }
    else {
      trot.x = PI/2;
    }
  }
  else if (noSort.isClicked(mouseClicked)) {
    unSort();
    tflatness = 0;
    trot.x = 0;
    trot.z = 0;
    txShift = 0;
    tyShift = 0;
    
  }
  else if (tempSort.isClicked(mouseClicked)) {
    sortByTemp(); 
    trot.x = PI/2;
    yLabel = "Temperature (Kelvin)";
    //toggleFlatness(1);
    yMax = maxTemp;
    yMin = minTemp;
  }
  else if (sizeSort.isClicked(mouseClicked)) {
    sortBySize();
    trot.x = PI/2;
    //toggleFlatness(1);
    yLabel = "Planet Size (Earth Radii)";
    yMax = maxSize;
    yMin = 0;
  }
}


