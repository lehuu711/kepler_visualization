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
    this.ySize = yScreen*3.0/5;
    
    this.xMin = xScreen-xSize/2-2;
    this.xMax = xScreen+xSize/2;
    
    this.xMove = 0;
    this.txMove = 0;
    
    p = null;
    
    this.xInit = this.x;
    
    b = new CloseBox(x+xSize/2-11,y-ySize/2+10,20,20,"closeBox");
    b.setDesc(false);
  }
  
  //Add in an ExoPlanet to generate data from
  //Also sets move param
  void setPlanet(ExoPlanet p) {
    this.p = p;
    txMove = -1.5*xSize;
  }
  
  ExoPlanet getPlanet() {
    return p;
  }
  
  void clearPanel() {
    p = null;
    txMove = 1.5*xSize;
  }
  
  //Resets parameters (for when Planet changes)
  void refreshPanel() {
    clearPanel();
    x = xInit;
    xMove = 0;
  }
  
  //Print the ExoPlanet data onto the panel
  void printText() {
    if(p == null) {
      println("Error: No Exoplanet data was found!");
      return;
    }
    
    stroke(255,150);
    strokeWeight(1);
    float startX = x-xSize/2+fontH-10;
    float startY = y-ySize/2+fontH*1.5;
    line(startX-10, startY, x+xSize/2-fontH+10, startY);
    
    float textW = x+xSize/2-fontH+10-startX;
    startY+=10; //Slightly shift the y-values
    
    fill(255,200);
    rectMode(CORNER);
    
    textSize(20);
    textAlign(CENTER);
    text("KOI ID: "+p.KOI,startX,startY-fontH*1.5,textW,fontH);
    
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
  void connect() {
    stroke(255);
    strokeWeight(1);
    line(this.x,this.y,p.x,y);
  }
  
  //Draw the panel
  void render() {
    rectMode(CENTER);
    //Update the movement;
    xMove += (txMove - xMove) * 0.06;
    
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
