/* Specific type of Button */

class CloseBox extends Button {
  
  //Constructor
  CloseBox(float x, float y, float xSize, float ySize, String description) {
    super(x,y,xSize,ySize,description);
  }
  
  void render() {
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
