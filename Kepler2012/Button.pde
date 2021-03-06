/*

 Kepler Visualization - Button Class
 
 @ASTR051 Squirtle Squad
 @May 2015
 Simple buttons class. 

 */

class Button {
  
  // Standard Parameters
  float x;
  float y;
  float xSize;
  float ySize;
  boolean showDesc = true;
  
  String description; //Description for button
  
  // Constructor
  Button(float x, float y, float xSize, float ySize, String description) {
    this.x = x;
    this.y = y;
    this.xSize = xSize;
    this.ySize = ySize;
    this.description = description;
  }
  
  // Checks if we've clicked on box given that mouse has clicked
  boolean isClicked(boolean mouseClicked) {
    if (mouseClicked) {
      return contains(mouseX,mouseY);
    }
    return false;
  }
  
  // Show or hide the description box
  void setDesc(boolean desc) {
    showDesc = desc;
  }
  
  void update(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  // Check if (x,y) contained in coordinates (remember using CENTER rectMode)
  boolean contains(float xOther, float yOther) {
    return abs(xOther-x) <= xSize/2 && abs(yOther-y) <= ySize/2;
  }
  
   // Draw: Very Basic
  void render() {
    rectMode(CENTER);
    noFill();
    rect(x,y,xSize,ySize);
    if (showDesc) {
      mouseOver();
    }
  }
  
  // Displays the description when mouse goes over
  void mouseOver() {
    if (contains(mouseX,mouseY)) {
      float fSize = 14;
      float x = mouseX;
      float y = mouseY;
      float w = description.length()*fSize/1.75;
      float h = fSize*1.5;
      
      //Make sure text doesn't go off screen
      y -= h;
      x = min(xScreen-w,x);
      x = max(0,x);
      y = min(yScreen-h,y);
      y = max(0,y);
      
      rectMode(CORNER);
      textAlign(CENTER);
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
