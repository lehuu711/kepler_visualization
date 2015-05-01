import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.opengl.*; 

import au.com.bytecode.opencsv.*; 
import au.com.bytecode.opencsv.bean.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Kepler2012 extends PApplet {

/*

 Kepler Visualization
 2011 - new data added in 2012
 blprnt@blprnt.com
 
 You can toggle between view modes with the keys 4,3,2,1,` 
 */

// Import libraries

PFont label = createFont("Helvetica", 96);

//Display sizes
int xScreen = 1000;
int yScreen = 800;

// Here's the big list that will hold all of our planets
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

// Rotation Vectors - control the main 3D space
PVector rot = new PVector();
PVector trot = new PVector();

// Master zoom
float zoom = 0;
float tzoom = 0.3f;

// This is a zero-one weight that controls whether the planets are flat on the
// plane (0) or not (1)
float flatness = 0;
float tflatness = 0;

// add controls (e.g. zoom, sort selection)
Controls controls; 
int showControls;
boolean draggingZoomSlider = false;
boolean isMoving = true;

//Parameters to transpose the mouse location on the field
float mX = 0;
float mY = 0;
float mZ = 0;
float mTheta = 0;
float mRadius = 0;

//Value for making selected ExoPlanets flicker
float blink = 0;
int tBlink = 2;

boolean mouseClicked = false;

ExoPlanet markedPlanet = null;

SidePanel panel = new SidePanel(xScreen,yScreen,300);

ModeButton fieldFlip = new ModeButton(48,350,20,20,"Flip between orbit and plot field.");
ModeButton fieldTilt = new ModeButton(48,400,20,20,"Tilt view of the plane.");
ModeButton noSort = new ModeButton(48,450,20,20,"Unsort the planets.");
ModeButton sizeSort = new ModeButton(48,500,20,20, "Sort Exoplanets by size.");
ModeButton tempSort = new ModeButton(48,550,20,20, "Sort Exoplanets by temperature.");


public void setup() {
  size(xScreen, yScreen, OPENGL);
  background(0);
  smooth();  

  textFont(label, 96);

  // Because NASA released their data from 2011 and 2012 in somewhat
  // different formats, there are two functions to load the data and populate
  // the 'galaxy'.
  getPlanets(sketchPath + "/data/KeplerData.csv", false);
  println(planets.size());
  getPlanets(sketchPath + "/data/planets2012_2.csv", true);
  println(planets.size());
  addMarkerPlanets();
  updatePlanetColors();
  
  controls = new Controls();
  showControls = 1;
  
}

public void getPlanets(String url, boolean is2012) {
  // Here, the data is loaded and a planet is made from each line.
  String[] pArray = loadStrings(url);
  int start = is2012 ? 0 : 1; // skip header on 2011 data
  for (int i = start; i < pArray.length; i++) {
    ExoPlanet p;
    if (is2012) {
      p = new ExoPlanet().fromCSV2012(split(pArray[i], ",")).init();
    } 
    else {
      p = new ExoPlanet().fromCSV(split(pArray[i], ",")).init();
    }
    planets.add(p);
    maxSize = max(p.radius, maxSize);
    minSize = min(p.radius, minSize);

    // These are two planets from the 2011 data set that I wanted to feature.
    if (p.KOI.equals("326.01") || p.KOI.equals("314.02")) {
      p.feature = true;
      p.label = p.KOI;
    } 
  }
}

public void updatePlanetColors()
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


public void addMarkerPlanets() {
  // Now, add the solar system planets
  ExoPlanet mars = new ExoPlanet();
  mars.period = 686;
  mars.radius = 0.533f;
  mars.axis = 1.523f;
  mars.temp = 212;
  mars.feature = true;
  mars.label = "Mars";
  mars.init();
  planets.add(mars);

  ExoPlanet earth = new ExoPlanet();
  earth.period = 365;
  earth.radius = 1;
  earth.axis = 1;
  earth.temp = 254;
  earth.feature = true;
  earth.label = "Earth";
  earth.init();
  planets.add(earth);

  ExoPlanet jupiter = new ExoPlanet();
  jupiter.period = 4331;
  jupiter.radius = 11.209f;
  jupiter.axis = 5.2f;
  jupiter.temp = 124;
  jupiter.feature = true;
  jupiter.label = "Jupiter";
  jupiter.init();
  planets.add(jupiter);

  ExoPlanet mercury = new ExoPlanet();
  mercury.period = 87.969f;
  mercury.radius = 0.3829f;
  mercury.axis = 0.387f;
  mercury.temp = 434;
  mercury.feature = true;
  mercury.label = "Mercury";
  mercury.init();
  planets.add(mercury);
}

public void draw() {
  calcMousePos();
  calcBlink();
  
  // Ease rotation vectors, zoom
  zoom += (tzoom - zoom) * 0.01f;     
  if (zoom < 0)  {
     zoom = 0;
  } else if (zoom > 3.0f) {
     zoom = 3.0f;
  }
  controls.updateZoomSlider(zoom);  
  rot.x += (trot.x - rot.x) * 0.1f;
  rot.y += (trot.y - rot.y) * 0.1f;
  rot.z += (trot.z - rot.z) * 0.1f;

  // Ease the flatness weight
  flatness += (tflatness - flatness) * 0.1f;

  // MousePress - Controls Handling 
  if (mousePressed) {
     if((showControls == 1) && controls.isZoomSliderEvent(mouseX, mouseY)) {
        draggingZoomSlider = true;
        zoom = controls.getZoomValue(mouseY);        
        tzoom = zoom;
     } 
     
     // MousePress - Rotation Adjustment
     else if (!draggingZoomSlider) {
       //trot.x += (pmouseY - mouseY) * 0.01;
       //trot.z += (pmouseX - mouseX) * 0.01;
     }
  }



  background(10);
  
  // show controls
  if (showControls == 1) {
     controls.render(); 
  }
  
  pushMatrix();
  // We want the center to be in the middle and slightly down when flat, and to the left and down when raised
  translate(width/2 - (width * flatness * 0.4f), height/2 + (160 * rot.x));
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

  if (flatness > 0.5f) {
    pushMatrix();
    rotateX(PI/2);
    line(AU * 1.06f, -10, AU * 1.064f, 10); 
    line(AU * 1.064f, -10, AU * 1.068f, 10);   
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
  panel.render();
  
  //Make sure mouse isn't still clicked by the end of the frame
  mouseClicked = false;
  
  fieldFlip.render();
  fieldTilt.render();
  noSort.render();
  sizeSort.render();
  tempSort.render();
}

public void calcMousePos() {
  //Overhead view, (x,y) coordinates
  if (tflatness == 0) {
    mX = (mouseX - xScreen/2)/zoom;
    mY = (mouseY - yScreen/2)/zoom;
    mZ = 0;
  }
  //Chart view, (y,z) (?) coordinates
  //(0,0) starts at the bottom left (center of revolution)
  else if (tflatness == 1) {
    //x-field is not used for the plot
    mX = 0;
    
    //Plot edge (x-axis) starts at bottom, 1/10 of screen width
    //x-axis is actually the y-field value
    mY = (mouseX-xScreen/10)/zoom;
    
    //Plot edge starts at bottom 500+(screen height - 500)/2
    //y-axis is actually the z-field value
    float offset = 500+(yScreen-500)/2;
    mZ = (offset-mouseY)/zoom;
  }
}

public void calcBlink() {
  float t = blink+tBlink;
  if (t>250 || t<150) {
    tBlink *= -1;
  }
  t = max(150,t);
  t = min(250,t);
  blink = t;
}

public void sortBySize() {
  // Raise the planets off of the plane according to their size
  for (int i = 0; i < planets.size(); i++) {
    planets.get(i).tz = map(planets.get(i).radius, 0, maxSize, 0, 500);
  }
}

public void sortByTemp() {
  // Raise the planets off of the plane according to their temperature
  for (int i = 0; i < planets.size(); i++) {
    planets.get(i).tz = map(planets.get(i).temp, minTemp, maxTemp, 0, 500);
  }
}

public void unSort() {
  // Put all of the planets back onto the plane
  for (int i = 0; i < planets.size(); i++) {
    planets.get(i).tz = 0;
  }
}

public void keyPressed() {
  String timeStamp = hour() + "_"  + minute() + "_" + second();
  if (key == 's') {
    save("out/Kepler" + timeStamp + ".png");
  } else if (key == 'c'){
     showControls = -1 * showControls;
  }

  if (keyCode == UP) {
    //tzoom += 0.025;
  } 
  else if (keyCode == DOWN) {
    //tzoom -= 0.025;
  }

  else if (key == '`') {
    unSort(); 
    toggleFlatness(0);
  }
}

public void toggleFlatness(float f) {
  tflatness = f;
  if (tflatness == 1) {
    trot.x = PI/2;
    trot.z = -PI/2;
  }
  else {
    trot.x = 0;
    trot.z = 0;
    //unSort();
  }
}

public void mouseReleased() {
  draggingZoomSlider = false;
}

public void mouseClicked() {
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


/*

    Button Class: Simple Button Class


*/

class Button {
  
  //Standard Parameters
  float x;
  float y;
  float xSize;
  float ySize;
  
  String description; //Description for button
  
  //Constructor
  Button(float x, float y, float xSize, float ySize, String description) {
    this.x = x;
    this.y = y;
    this.xSize = xSize;
    this.ySize = ySize;
    this.description = description;
  }
  
  //Checks if we've clicked on box given that mouse has clicked
  public boolean isClicked(boolean mouseClicked) {
    if (mouseClicked) {
      return contains(mouseX,mouseY);
    }
    return false;
  }
  
  public void update(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  //Check if (x,y) contained in coordinates (remember using CENTER rectMode)
  public boolean contains(float xOther, float yOther) {
    return abs(xOther-x) <= xSize/2 && abs(yOther-y) <= ySize/2;
  }
  
   //Draw: Very Basic
  public void render() {
    rectMode(CENTER);
    noFill();
    rect(x,y,xSize,ySize);
    mouseOver();
  }
  
  //Displays the description when mouse goes over
  public void mouseOver() {
    if (contains(mouseX,mouseY)) {
      float fSize = 14;
      float x = mouseX;
      float y = mouseY;
      float w = description.length()*fSize/1.75f;
      float h = fSize*1.5f;
      
      //Make sure text doesn't go off screen
      y -= h;
      x = min(xScreen-w,x);
      x = max(0,x);
      y = min(yScreen-h,y);
      y = max(0,y);
      
      rectMode(CORNER);
      textAlign(LEFT);
      stroke(255,100);
      strokeWeight(1);
      fill(0,0,0);
      rect(x,y,w,h);
      fill(255);
      textSize(fSize);
      text(description,x,y,w,h);
    }
  }
}
/* Specific type of Button */

class CloseBox extends Button {
  
  //Constructor
  CloseBox(float x, float y, float xSize, float ySize, String description) {
    super(x,y,xSize,ySize,description);
  }
  
  public void render() {
    rectMode(CENTER); 
    //Turns red if mouse highlights
    if (super.contains(mouseX,mouseY)) {
      stroke(255,0,0,200);
    } else {
      stroke(255,200);
    }
    strokeWeight(2);
    super.render();
    line(x-xSize/2,y-ySize/2,x+xSize/2,y+ySize/2);
    line(x+xSize/2,y-ySize/2,x-xSize/2,y+ySize/2);
    
    
  }
}
/*

 Kepler Visualization - Controls
 
 GUI controls added by Lon Riesberg, Laboratory for Atmospheric and Space Physics
 lon@ieee.org
 
 April, 2012
 
 Current release consists of a vertical slider for zoom control.  The slider can be toggled
 on/off by pressing the 'c' key.
 
 Slide out controls that map to the other key bindings is currently being implemented and
 will be released soon.
 
*/

class Controls {
   
   int barWidth;   
   int barX;                          // x-coordinate of zoom control
   int minY, maxY;                    // y-coordinate range of zoom control
   float minZoomValue, maxZoomValue;  // values that map onto zoom control
   float valuePerY;                   // zoom value of each y-pixel 
   int sliderY;                       // y-coordinate of current slider position
   float sliderValue;                 // value that corresponds to y-coordinate of slider
   int sliderWidth, sliderHeight;
   int sliderX;                       // x-coordinate of left-side slider edge                     
   
   Controls () {
      
      barX = 40;
      barWidth = 15;
 
      minY = 40;
      maxY = minY + height/3 - sliderHeight/2;
           
      minZoomValue = 0.0f;
      maxZoomValue = 3.0f;   // 300 percent
      valuePerY = (maxZoomValue - minZoomValue) / (maxY - minY);
      
      sliderWidth = 25;
      sliderHeight = 10;
      sliderX = (barX + (barWidth/2)) - (sliderWidth/2);      
      sliderValue = minZoomValue; 
      sliderY = minY;     
   }
   
   
   public void render() {
      rectMode(CENTER);

      strokeWeight(0.5f);     
      stroke(105, 105, 105); 
      
      // zoom control bar
      fill(0, 0, 0, 0);
      rect(barX+barWidth/2, minY+(maxY-minY)/2, barWidth, maxY-minY);
      
      // slider
      fill(105, 105, 105);
      rect(sliderX+sliderWidth/2, sliderY+sliderHeight/2, sliderWidth, sliderHeight);
   }
   
   
   public float getZoomValue(int y) {
      if ((y >= minY) && (y <= (maxY - sliderHeight/2))) {
         sliderY = (int) (y - (sliderHeight/2));     
         if (sliderY < minY) { 
            sliderY = minY; 
         } 
         sliderValue = (y - minY) * valuePerY + minZoomValue;
      }     
      return sliderValue;
   }
   
   
   public void updateZoomSlider(float value) {
      int tempY = (int) (value / valuePerY) + minY;
      if ((tempY >= minY) && (tempY <= (maxY-sliderHeight))) {
         sliderValue = value;
         sliderY = tempY;
      }
   }
   
   
   public boolean isZoomSliderEvent(int x, int y) {
      int slop = 50;  // number of pixels above or below slider that's acceptable.  provided for ease of use.
      int sliderTop = (int) (sliderY - (sliderHeight/2)) - slop;
      int sliderBottom = sliderY + sliderHeight + slop;
      return ((x >= sliderX) && (x <= (sliderX    + sliderWidth)) && (y >= sliderTop)  && (y <= sliderBottom));
   } 
}



/*

ExoPlanet Class
blprnt@blprnt.com
Spring, 2011 - new data added Spring 2012

There are two separate formats for the data - both are listed below.

 //  2011 Batch
 
 KOI,
 Dur,           : [1] Transit duration, first contact to last contact - HOURS
 Depth,         : [2] Transit depth at center of transit - PULSE POSITION MODULATION
 SNR,
 t0,t0_unc,
 Period,P_unc,  : [6,7] Average interval between transits based on a linear fit to all observed transits and uncertainty - DAYS 
 a/R*,a/R*_unc,
 r/R*,r/R*_unc, : [10,11] Ratio of planet radius to stellar radius and uncertainty 
 b,b_unc,
 Rp,            :[14] Radius of the planet - EARTH RADII
 a,             :[15] Semi-major axis of orbit based - AU (?)
 Teq,           :[16]Equilibrium temperature of the planet - KELVIN
 EB prob,
 V,             :[18] Vetting flag: 
                         1 Confirmed and published planet 
                         2 Strong probability candidate, cleanly passes tests that were applied 
                         3 Moderate probability candidate, not all tests cleanly passed but no definite test failures 
                         4 Insufficient follow-up to perform full suite of vetting tests 
 FOP,
 N,
 
 // 2012 Batch
 
 --------------------------------------------------------------------------------
 1-  7 F7.2   ---   KOI    Kepler Object of Interest number
 9- 20 F12.7  d     Per    Average interval between transits (1)
 22- 27 F6.2   ---   Rad    Planetary radius in Earth radii=6378 km (2)
 29- 34 F6.3   AU    a      Semi-major axis of orbit (3)
 36- 40 I5     K     Teq    Equilibrium temperature of planet (4)
 42- 47 F6.2   ---   O/E_1  Ratio of odd to even numbered transit depths (5)
 49- 54 F6.2   ---   O/E_2  Ratio of odd to even numbered transit depths (6)
 56- 63 F8.2   ---   Occ    Relative flux level at phase=0.5 divided by noise
 65- 71 F7.2   as    dra    Source position in RA relative to target (7)
 73- 79 F7.2   as  e_dra    Uncertainty in source position
 81- 87 F7.2   as    ddec   Source position in DEC relative to target (7)
 89- 95 F7.2   as  e_ddec   Uncertainty in source position
 97-102 F6.1   ---   dist   Distance to source position divided by noise
 104-109 F6.1   ---   MES    Multiple Event Statistic (MES) (8)
 --------------------------------------------------------------------------------
 
 */



class ExoPlanet {
  // Data from the imported files
  String KOI;

  float period;
  float radius;
  float temp;
  float axis;
  int vFlag = 1;
  
  // Real movement/render properties
  float theta = 0;
  float thetaSpeed = 0;
  float PixelDiam = 0;
  float pixelAxis;

  float z = 0;
  float tz = 0;

  int col;

  boolean feature = false;
  String label = "";
  
  boolean isSelected = false;
  
  float x;
  float y;

  // Constructor function
  ExoPlanet() {};
  
  ExoPlanet(boolean marker) {isSelected = marker;}
  
  // Load exoplanet data from a comma-delimited string (see key at top of class)
  public ExoPlanet fromCSV2012(String[] sa) {
    KOI = sa[0];
    period = PApplet.parseFloat(sa[1]);
    radius = PApplet.parseFloat(sa[2]);
    axis = PApplet.parseFloat(sa[3]);
    temp = PApplet.parseFloat(sa[4]);
    return(this);
  }

  // Load exoplanet data from a comma-delimited string (see key at top of class)
  public ExoPlanet fromCSV(String[] sa) {
    KOI = sa[0];
    period = PApplet.parseFloat(sa[6]);
    radius = PApplet.parseFloat(sa[14]);
    axis = PApplet.parseFloat(sa[15]);
    temp = PApplet.parseFloat(sa[16]);
    vFlag = PApplet.parseInt(sa[18]);
    return(this);
  }

  // Initialize pixel-based motion data, color, etc. from exoplanet data
  public ExoPlanet init() {
    PixelDiam = radius * ER;
    pixelAxis = axis * AU;

    float periodInYears = period/365;
    float periodInFrames = periodInYears * YEAR;
    theta = random(2 * PI);
    thetaSpeed = (2 * PI) / periodInFrames;

    return(this);
  }

  // Update
  public void update() {
    theta += thetaSpeed;
    z += (tz - z) * 0.1f;
  }
  
  public void markPlanet() {
    markedPlanet = this;
  }

  // Draw
  public void render(SidePanel panel) {
    if (markedPlanet != null && markedPlanet == this) {
      isSelected = true;
    }
    else {
      isSelected = false;
    }
    float apixelAxis = pixelAxis;
    
    if (axis > 1.06f && feature) {
      apixelAxis = ((1.06f + ((axis - 1.06f) * ( 1 - flatness))) * AU) + axis * 10;
    }
    x = sin(theta * (1 - flatness)) * apixelAxis;
    y = cos(theta * (1 - flatness)) * apixelAxis;
    
    float dist = 0;
    boolean mouseOnTop = false;
    dist = sqrt(pow(mX-x,2)+pow(mY-y,2)+pow(mZ-z,2));
    if (dist <= PixelDiam/2) {
      mouseOnTop = true;
    }
    if(mouseOnTop && mouseClicked && !isSelected) {
      if (panel.getPlanet() != null) {
        panel.refreshPanel();
      }
      panel.setPlanet(this);
      markPlanet();
      mouseClicked = false;
    }
    
    pushMatrix();
    translate(x, y, z);
    // Billboard
    rotateZ(-rot.z);
    rotateX(-rot.x);
    noStroke();
    if (feature) {
      translate(0, 0, 1);
      stroke(255, 255);
      strokeWeight(2);
      noFill();
      ellipse(0, 0, PixelDiam + 10, PixelDiam + 10); 
      strokeWeight(1);
      pushMatrix();
      if (label.equals("Earth")) {
        stroke(0xff01FFFD, 50);
        line(0, 0, -pixelAxis * flatness, 0);
      }
      rotate((1 - flatness) * PI/2);
      stroke(255, 100);
      float r = max(50, 100 + ((1 - axis) * 200));
      r *= sqrt(1/zoom);
      if (zoom > 0.5f || label.charAt(0) != '3') {
        line(0, 0, 0, -r);
        translate(0, -r - 5);
        rotate(-PI/2);
        scale(1/zoom);
        fill(255, 200);
        text(label, 0, 4);
      }
      popMatrix();
    }
    fill(col);
    noStroke();
    if (isSelected && panel.getPlanet() != null && panel.getPlanet() == this) {    
      fill(220,blink);
      strokeWeight(1);
      stroke(255);
    }
    
    if (mouseOnTop || isSelected) {
      strokeWeight(1);
      stroke(255);
    }
    
    ellipse(0, 0, PixelDiam, PixelDiam);
    popMatrix();
  }
}

class ModeButton extends Button {
  
  ModeButton(float x, float y, float xSize, float ySize, String description) {
    super(x,y,xSize,ySize,description);
  }
  
  public void render() {
    rectMode(CENTER);
    noFill();
    strokeWeight(5);
    //Turns brighter if mouse highlights
    if (super.contains(mouseX,mouseY)) {
      stroke(200);
    } else {
      stroke(100);
    }
    super.render();
    super.mouseOver();
  }
}
/*
    
   SidePanel Class for displaying Planet data. The display
   is designed specifically for displaying the data for these
   Exoplanets. Modification will be needed if this class is to
   be used in a different project.

  SidePanel will be implemented in CENTER rectMode.
  
 */
class SidePanel {
  
  //Coordinate values
  float x;
  float y;
  float xMin; //Some portion of the screen size
  float xMax;
  
  float xInit; //Variable needed for refresh function
  
  //Size Variables
  float xSize;
  float ySize;
  
  //Variables to move box
  float xMove;
  float txMove;
  
  float fontH = 30; //Spacing for alignment
  
  ExoPlanet p;
  CloseBox b;
  
  //Constructor
  SidePanel(float xScreen, float yScreen, float xWidth) {
    this.x = xScreen+xWidth/2;
    this.y = yScreen/2;
    
    this.xSize = xWidth;
    this.ySize = yScreen*3.0f/5;
    
    this.xMin = xScreen-xSize/2-2;
    this.xMax = xScreen+xSize/2;
    
    this.xMove = 0;
    this.txMove = 0;
    
    p = null;
    
    this.xInit = this.x;
    
    b = new CloseBox(x+xSize/2-11,y-ySize/2+10,20,20,"closeBox");
  }
  
  //Add in an ExoPlanet to generate data from
  //Also sets move param
  public void setPlanet(ExoPlanet p) {
    this.p = p;
    txMove = -1.5f*xSize;
  }
  
  public ExoPlanet getPlanet() {
    return p;
  }
  
  public void clearPanel() {
    p = null;
    txMove = 1.5f*xSize;
  }
  
  //Resets parameters (for when Planet changes)
  public void refreshPanel() {
    clearPanel();
    x = xInit;
    xMove = 0;
  }
  
  //Print the ExoPlanet data onto the panel
  public void printText() {
    if(p == null) {
      println("Error: No Exoplanet data was found!");
      return;
    }
    stroke(255,150);
    strokeWeight(1);
    float startX = x-xSize/2+fontH-10;
    float startY = y-ySize/2+fontH*1.5f;
    line(startX-10, startY, x+xSize/2-fontH+10, startY);
    
    float textW = x+xSize/2-fontH+10-startX;
    startY+=10; //Slightly shift the y-values
    
    fill(255,200);
    rectMode(CORNER);
    
    textSize(20);
    textAlign(CENTER);
    text("KOI ID: "+p.KOI,startX,startY-fontH*1.5f,textW,fontH);
    
    //Left Column: Data Name
    textSize(14);
    textAlign(LEFT);
    text("Period (days)", startX,startY+fontH*0,textW,fontH);
    text("Radius (Earth radii)", startX,startY+fontH*1,textW,fontH);
    text("Semi-Major Axis (AU)", startX,startY+fontH*3,textW,fontH);
    text("Equilibrium Temperature (K)", startX,startY+fontH*2,textW,fontH);
    text("---", startX,startY+fontH*4,textW,fontH);
    text("---", startX,startY+fontH*5,textW,fontH);
    text("---", startX,startY+fontH*6,textW,fontH);
    text("---", startX,startY+fontH*7,textW,fontH);
    text("---", startX,startY+fontH*8,textW,fontH);
    text("---", startX,startY+fontH*9,textW,fontH);
    text("---", startX,startY+fontH*10,textW,fontH);
    text("---", startX,startY+fontH*11,textW,fontH);
    text("---", startX,startY+fontH*12,textW,fontH);
    text("---", startX,startY+fontH*13,textW,fontH);
    
    //Right Column: Data
    textAlign(RIGHT);
    text(p.period+"", startX,startY+fontH*0,textW,fontH);
    text(p.radius+"", startX,startY+fontH*1,textW,fontH);
    text(p.axis+"", startX,startY+fontH*3,textW,fontH);
    text(p.temp+"", startX,startY+fontH*2,textW,fontH);
    text("---", startX,startY+fontH*4,textW,fontH);
    text("---", startX,startY+fontH*5,textW,fontH);
    text("---", startX,startY+fontH*6,textW,fontH);
    text("---", startX,startY+fontH*7,textW,fontH);
    text("---", startX,startY+fontH*8,textW,fontH);
    text("---", startX,startY+fontH*9,textW,fontH);
    text("---", startX,startY+fontH*8,textW,fontH);
    text("---", startX,startY+fontH*9,textW,fontH);
    text("---", startX,startY+fontH*10,textW,fontH);
    text("---", startX,startY+fontH*11,textW,fontH);
    text("---", startX,startY+fontH*12,textW,fontH);
    text("---", startX,startY+fontH*13,textW,fontH);
  }
  
  //Draws a line with the Planet's coordinates
  public void connect() {
    stroke(255);
    strokeWeight(1);
    line(this.x,this.y,p.x,y);
  }
  
  //Draw the panel
  public void render() {
    rectMode(CENTER);
    //Update the movement;
    xMove += (txMove - xMove) * 0.06f;
    
    x = xInit+xMove;
    x = max(xMin,x);
    x = min(xMax,x);
    
    stroke(255,100);
    fill(10,250);
    rect(x,y,xSize,ySize);
    
    //Close Button
    b.update(x+xSize/2-11,y-ySize/2+10);
    b.render();
    if (mouseClicked && b.isClicked(mouseClicked)) {
      clearPanel();
      mouseClicked = false;
    }
    
    //Text
    if (p != null) {
      printText();
    }
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Kepler2012" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
