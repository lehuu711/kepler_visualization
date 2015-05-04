/*

 ExoPlanet Class
 blprnt@blprnt.com
 Spring, 2011 - new data added Spring 2012

 There are two separate formats for the data - both are listed below.

  --------------------------------------------------------------------------------

  //  2011 Batch
  KOI,
  Dur,           :[1]     Transit duration, first contact to last contact - HOURS
  Depth,         :[2]     Transit depth at center of transit - PULSE POSITION MODULATION
  SNR,
  t0,t0_unc,
  Period,P_unc,  :[6,7]   Average interval between transits based on a linear fit to all observed transits and uncertainty - DAYS 
  a/R*,a/R*_unc,
  r/R*,r/R*_unc, :[10,11] Ratio of planet radius to stellar radius and uncertainty 
  b,b_unc,
  Rp,            :[14]    Radius of the planet - EARTH RADII
  a,             :[15]    Semi-major axis of orbit based - AU (?)
  Teq,           :[16]    Equilibrium temperature of the planet - KELVIN
  EB prob,
  V,             :[18]    Vetting flag: 
                            1 Confirmed and published planet 
                            2 Strong probability candidate, cleanly passes tests that were applied 
                            3 Moderate probability candidate, not all tests cleanly passed but no definite test failures 
                            4 Insufficient follow-up to perform full suite of vetting tests 
  FOP,
  N,
  
  --------------------------------------------------------------------------------
  
  // 2012 Batch
    1 - 7   F7.2   ---   KOI    [0] Kepler Object of Interest number
    9 - 20  F12.7  d     Per    [1] Average interval between transits 
   22 - 27  F6.2   ---   Rad    [2] Planetary radius in Earth radii=6378 km 
   29 - 34  F6.3   AU    a      [3] Semi-major axis of orbit 
   36 - 40  I5     K     Teq    [4] Equilibrium temperature of planet 
   42 - 47  F6.2   ---   O/E_1  [5] Ratio of odd to even numbered transit depths 
   49 - 54  F6.2   ---   O/E_2  [6] Ratio of odd to even numbered transit depths 
   56 - 63  F8.2   ---   Occ        Relative flux level at phase=0.5 divided by noise
   65 - 71  F7.2   as    dra    [7] Source position in RA relative to target 
   73 - 79  F7.2   as  e_dra        Uncertainty in source position
   81 - 87  F7.2   as    ddec   [7] Source position in DEC relative to target 
   89 - 95  F7.2   as  e_ddec       Uncertainty in source position
   97 - 102 F6.1   ---   dist       Distance to source position divided by noise
  104 - 109 F6.1   ---   MES    [8] Multiple Event Statistic (MES) 
  
  --------------------------------------------------------------------------------
  
  // Kepler Candidates (Spring 2011 - Spring 2015)
   0 rowid:            (not found)
   1 kepid:            (not found)
   2 kepoi_name:       KOI Name
   3 kepler_name:      Kepler Name
   4 koi_disposition:  Exoplanet Archive Disposition
   5 koi_pdisposition: Disposition Using Kepler Data
   6 koi_period:       Orbital Period                           [days]
   7 koi_period_err1:  Orbital Period Upper Unc.                [days]
   8 koi_period_err2:  Orbital Period Lower Unc.                [days]
   9 koi_eccen:        Eccentricity
  10 koi_eccen_err1:   Eccentricity Upper Unc.
  11 koi_eccen_err2:   Eccentricity Lower Unc.
  12 koi_prad:         Planetary Radius                         [Earth radii]
  13 koi_prad_err1:    Planetary Radius Upper Unc.              [Earth radii]
  14 koi_prad_err2:    Planetary Radius Lower Unc.              [Earth radii]
  15 koi_sma:          Orbit Semi-Major Axis                    [AU]
  16 koi_sma_err1:     Orbit Semi-Major Axis Upper Unc.         [AU]
  17 koi_sma_err2:     Orbit Semi-Major Axis Lower Unc.         [AU]
  18 koi_incl:         Inclination                              [deg]
  19 koi_incl_err1:    Inclination Upper Unc.                   [deg]
  20 koi_incl_err2:    Inclination Lower Unc.                   [deg]
  21 koi_teq:          Equilibrium Temperature                  [K]
  22 koi_teq_err1:     Equilibrium Temperature Upper Unc.       [K]
  23 koi_teq_err2:     Equilibrium Temperature Lower Unc.       [K]
  24 koi_steff:        Stellar Effective Temperature            [K]
  25 koi_steff_err1:   Stellar Effective Temperature Upper Unc. [K]
  26 koi_steff_err2:   Stellar Effective Temperature Lower Unc. [K]
  27 koi_srad:         Stellar Radius                           [Solar radii]
  28 koi_srad_err1:    Stellar Radius Upper Unc.                [Solar radii]
  29 koi_srad_err2:    Stellar Radius Lower Unc.                [Solar radii]
  30 koi_smass:        Stellar Mass                             [Solar mass]
  31 koi_smass_err1:   Stellar Mass Upper Unc.                  [Solar mass]
  32 koi_smass_err2:   Stellar Mass Lower Unc.                  [Solar mass]
 
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

  color col;

  boolean feature = false;
  String label = "";
  
  boolean isSelected = false;
  
  float x;
  float y;
  
  float eggN = random(2);
  color eggC;

  // Constructor function
  ExoPlanet() {};
  
  ExoPlanet(boolean marker) {isSelected = marker;}
  
  // Load exoplanet data from a comma-delimited string (see key at top of class)
  ExoPlanet fromCSV2012(String[] sa) {
    KOI = sa[0];
    period = float(sa[1]);
    radius = float(sa[2]);
    axis = float(sa[3]);
    temp = float(sa[4]);
    return(this);
  }

  // Load exoplanet data from a comma-delimited string (see key at top of class)
  ExoPlanet fromCSV2011(String[] sa) {
    KOI = sa[0];
    period = float(sa[6]);
    radius = float(sa[14]);
    axis = float(sa[15]);
    temp = float(sa[16]);
    vFlag = int(sa[18]);
    return(this);
  }

  // Initialize pixel-based motion data, color, etc. from exoplanet data
  ExoPlanet init() {
    PixelDiam = radius * ER;
    pixelAxis = axis * AU;

    float periodInYears = period/365;
    float periodInFrames = periodInYears * YEAR;
    theta = random(2 * PI);
    thetaSpeed = (2 * PI) / periodInFrames;

    return(this);
  }

  // Update
  void update() {
    theta += thetaSpeed;
    z += (tz - z) * 0.1;
  }
  
  void markPlanet() {
    markedPlanet = this;
  }

  // Draw
  void render(SidePanel panel) {
    if (markedPlanet != null && markedPlanet == this) {
      isSelected = true;
    }
    else {
      isSelected = false;
    }
    float apixelAxis = pixelAxis;
    
    if (axis > 1.06 && feature) {
      apixelAxis = ((1.06 + ((axis - 1.06) * ( 1 - flatness))) * AU) + axis * 10;
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
        stroke(#01FFFD, 50);
        line(0, 0, -pixelAxis * flatness, 0);
      }
      rotate((1 - flatness) * PI/2);
      stroke(255, 100);
      float r = max(50, 100 + ((1 - axis) * 200));
      r *= sqrt(1/zoom);
      if (zoom > 0.5 || label.charAt(0) != '3') {
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
    eggC = col;
    noStroke();
    if (isSelected && panel.getPlanet() != null && panel.getPlanet() == this) {    
      fill(220,blink);
      eggC = color(220,blink);
      strokeWeight(1);
      stroke(255);
    }
    
    if (mouseOnTop || isSelected) {
      strokeWeight(1);
      stroke(255);
    }
    if (easterEgg) {
      tint(eggC);
      imageMode(CENTER);
      if (eggN < 1) {
        image(egg1,0,0,PixelDiam,PixelDiam);
      } else {
        image(egg2,0,0,PixelDiam,PixelDiam);
      }
      eggN = (eggN+0.05)%2;
    }
    else {
      ellipse(0, 0, PixelDiam, PixelDiam);
    }
    popMatrix();
  }
}

