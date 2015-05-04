/*
 
 Kepler Visualization - ModeButton Class
 
 @ASTR051 Squirtle Squad
 @May 2015
 Specific type of button used to switch between modes.
 
 */

class ModeButton extends Button {
  
  ModeButton(float x, float y, float xSize, float ySize, String description) {
    super(x,y,xSize,ySize,description);
  }
  
  void render() {
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
