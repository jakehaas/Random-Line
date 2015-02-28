import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.io.File;
import java.awt.*;
import java.awt.event.*;
import javax.swing.JOptionPane;

// ABOUT PROGRAM
// EX -> version = 3, subVersion = 1.7, releaseType = s
// TOTAL version number = 3.1.7s
// -----------------
int version = 0;
float subVersion = 0.1;
char releaseType = 'a'; // a = alpha, b = beta, s = stable

// Current Settings
float curSW = 0.0;
color _color = color(255, 204, 0);

// GUI
HScrollbar rSB, gSB, bSB;
HButton colorButton, saveButton, loadButton;
HCheckbox cb;

// Flags
boolean showRGBSliders = false;
boolean canPaint = true;
boolean doRandomStrokeWidth = false;



// SAVE VARIABLES
// -----------------
List<List<Integer>> lines = new ArrayList<List<Integer>>();
List<List<Integer>> ellipses = new ArrayList<List<Integer>>();
List<List<Integer>> triangles = new ArrayList<List<Integer>>();
int lineIndex = 0;
int eIndex = 0;
int trisIndex = 0;

/*
----- EXAMPLE OF SDS2D file -----
StartSave [FILENAME.sds2d] {

ObjectType [Line] {
0 [x, y, x2, y2, cR1, cG1, cB1, sw1]
1 [x3, y3, x4, y4, cR2, cG2, cB2, sw2]
} [EndType]

ObjectType [Eclipse] {
0 [x, y, w, h, cR1, cG1, cB1, sw1]
1 [x2, y2, w2, h2, cR2, cG2, cB2, sw2]
} [EndType]

} [EndSave]

*/


void setup() {
 smooth();
 size(displayWidth, displayHeight);
 background(255);
 curSW = random(25);
 
 rSB = new HScrollbar (48, 100, 255, 16, 16);
 gSB = new HScrollbar (48, 130, 255, 16, 16);
 bSB = new HScrollbar (48, 160, 255, 16, 16);
 
 cb = new HCheckbox ((((width - 40) - (textWidth("Random Stroke Width?") / 2)) + 25), 10, 40, 40, "Random Stroke Width?", false, 1);
 
 colorButton = new HButton ("Change Color", 10, 10, 90, 40, 2);
 saveButton = new HButton ("Save", (((width - 40) - textWidth("Random Stroke Width?")) - 250), 10, 80, 40, 2);
 loadButton = new HButton ("Load", (((width - 40) - textWidth("Random Stroke Width?")) - 150), 10, 80, 40, 2);
 
 doRandomStrokeWidth = false;
}



void draw() {
   _color = color(rSB.getPos(), gSB.getPos(), bSB.getPos());

  if (showRGBSliders) {
    // Dropdown box
    stroke(0);
    fill(150, 150, 150, 10.0);
    rect(0, 0, 315, 190);
    
    colorButton.label = "Close";
    
    if (rectContainsPoint (mouseX, mouseY, 0, 0, 330, 205)) {
       canPaint = false;
    } else {
      canPaint = true;
    }
    
    fill(0, 0, 0);
    text("Current Color:", ((200 - textWidth("Current Color")) - 0), 45);
    
    text("Red", 10, 105);
    text("Green", 10, 135);
    text("Blue", 10, 165);
    
    // Update and display GUI
    rSB.update();
    gSB.update();
    bSB.update();
    rSB.display();
    gSB.display();
    bSB.display();
  
    fill(_color);
    stroke(0, 0, 0);
    
    rect(215, 10, 60, 60);
    
  } else {
    colorButton.label = "Change Color";
    fill(_color);
    stroke(_color);
    canPaint = true;
  }
  
  if (!cb.ticked()) {
     doRandomStrokeWidth = true;
   } else {
     doRandomStrokeWidth = false;
   }
  
   if (canPaint) {
     fill(_color);
     stroke(_color);
 
     float sWeight;
      
     if (mousePressed && (mouseButton == LEFT)) {
       if (doRandomStrokeWidth) {
          sWeight = (curSW + random(-9, 9));
          if (sWeight <= 0) {
           sWeight = 9;
          }
       } else {
         sWeight = 9;
       }
       
        strokeWeight((int)sWeight);
        basicLine(mouseX, mouseY, pmouseX, pmouseY, rSB.getPos(), gSB.getPos(), bSB.getPos(), sWeight);
     }
     
     /*
     if (mousePressed && (mouseButton == RIGHT)) {
       if (doRandomStrokeWidth) {
          sWeight = (curSW + random(-9, 9));
          if (sWeight <= 0) {
           sWeight = 9;
          }
       } else {
         sWeight = 9;
       }
       ellipseMode(CENTER);
       basicEllipse(mouseX, mouseY, random(random(40)), random(25), rSB.getPos(), gSB.getPos(), bSB.getPos(), sWeight);
     }*/
     
     if (mousePressed && (mouseButton == RIGHT)) {
       if (doRandomStrokeWidth) {
          sWeight = (curSW + random(-9, 9));
          if (sWeight <= 0) {
           sWeight = 9;
          }
       } else {
         sWeight = 9;
       }
       basicTriangle(mouseX + random(-5, 5), mouseY + random(-5, 5),
                     mouseX + random(-5, 5), mouseY + random(-5, 5),
                     mouseX + random(-5, 5), mouseY + random(-5, 5), rSB.getPos(), gSB.getPos(), bSB.getPos(), sWeight);
     }
     
   }
   
  // Update and display GUI
  colorButton.update();
  colorButton.display();
  
  saveButton.update();
  saveButton.display();
  
  loadButton.update();
  loadButton.display();
  
  cb.update();
  cb.display();
   
}


void mouseClicked () {
  if (colorButton.clicked()) { // WORKAROUND / FIX FOR SCREEN REDAW
     showRGBSliders = !showRGBSliders;
     
     // Delete old backup
     String fileName = sketchPath("backup.sds2d");
     File f = new File(fileName);
     
     if (f.exists()) {
       print("deleted");
        f.delete();
      }
      
      saveDrawing("backup.sds2d");
      
      lines.clear();
      ellipses.clear();
      triangles.clear();
      
      lineIndex = 0;
      eIndex = 0;
      trisIndex = 0;
      
      background(255);
      loadDrawing("backup.sds2d");
   }
   
  if (loadButton.clicked()) {
    dummyLoadFile();
  }

  if (saveButton.clicked()) {
    String filePath = saveFile(new Frame(), "Save File (.sds2d)", "~/Desktop", "Untitled.sds2d");
    print(filePath);
      
      if (filePath != null) {
          String last3;
          if (filePath == null || filePath.length() < 6) {
            last3 = filePath;
          } else {
            last3 = filePath.substring(filePath.length() - 6);
          }
    
          if (!last3.equals(".sds2d")) {
          filePath += ".sds2d";
        }
        
        saveDrawing(filePath);
      }
  }
   
//    Required to make checkboxes work
  cb.checkTick();
}

void dummyLoadFile () {
   String filePath = loadFile(new Frame(), "Open File (.sds2d)", "~/Desktop", "sds2d");
   File f = new File(filePath);
   
   if (f.exists()) {
     if (checkValidFile(filePath)) {
      loadDrawing(filePath);
     } else {
       JOptionPane.showMessageDialog(null, "The file you have supplied is invalid, please try again.", "Error: Invalid File!", JOptionPane.INFORMATION_MESSAGE);
      dummyLoadFile();  
     }
   }
}

boolean checkValidFile(String filePath) {
  if (filePath != null) {
    String last3;
    if (filePath == null || filePath.length() < 6) {
      last3 = filePath;
    } else {
      last3 = filePath.substring(filePath.length() - 6);
    }
    
    if (last3.equals(".sds2d")) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}


String loadFile (Frame f, String title, String defDir, String fileType) {
  FileDialog fd = new FileDialog(f, title, FileDialog.LOAD);
  fd.setFile(fileType);
  fd.setDirectory(defDir);
  fd.setLocation(50, 50);
  fd.show();
  
  String path = fd.getDirectory() + fd.getFile();
  return path;
}

String saveFile (Frame f, String title, String defDir, String fileType) {
  FileDialog fd = new FileDialog(f, title,    FileDialog.SAVE);
  fd.setFile(fileType);
  fd.setDirectory(defDir);
  fd.setLocation(50, 50);
  fd.show();
  
  String path = fd.getDirectory()+fd.getFile();
  return path;
}


boolean rectContainsPoint (float x, float y, float rX, float rY, float w, float h) {
  if ( (x >= rX) && (x <= w) && (y >= rY) && (y <= h) ) {
     return true;
  } else {
     return false;
  }
}

void basicLine (float xZero, float yZero, float xOne, float yOne, float cR, float cG, float cB, float sw) {
  color tmpColor = color(cR, cG, cB);
  fill(tmpColor);
  stroke(tmpColor);
  strokeWeight((int)sw);
  
  line(xZero, yZero, xOne, yOne);
  
  if (lines != null) {
     lines.add(Arrays.asList( (int)xZero, (int)yZero, (int)xOne, (int)yOne, (int)cR, (int)cG, (int)cB, (int)sw ));
  }
  
  lineIndex++;
}

void basicEllipse (float x, float y, float w, float h, float cR, float cG, float cB, float sw) {
  color tmpColor = color(cR, cG, cB);
  fill(tmpColor);
  stroke(tmpColor);
  strokeWeight((int)sw);
  
  ellipse(x, y, w, h);
  
  if (ellipses != null) {
     ellipses.add(Arrays.asList( (int)x, (int)y, (int)w, (int)h, (int)cR, (int)cG, (int)cB, (int)sw ));
  }
  
  eIndex++;
}

void basicTriangle (float x, float y, float xTwo, float yTwo, float xThree, float yThree, float cR, float cG, float cB, float sw) {
  color tmpColor = color(cR, cG, cB);
  fill(tmpColor);
  stroke(tmpColor);
  strokeWeight((int)sw);
  
  triangle(x, y, xTwo, yTwo, xThree, yThree);
  
  if (triangles != null) {
    triangles.add(Arrays.asList( (int)x, (int)y, (int)xTwo, (int)yTwo, (int)xThree, (int)yThree, (int)cR, (int)cG, (int)cB, (int)sw ));
  }
  
  trisIndex++;
}

void saveDrawing (String filename) {
   // Make sure the user can't do more work while we are saving
   canPaint = false;
   String tmpFileName = filename; // + ".sds2d";
  
   PrintWriter writer = createWriter(tmpFileName);
    
   // Add header
   writer.println("// SDS2D format by Jake Haas");
   writer.println("// Exported with Abstract Draw " + version + "." + subVersion + releaseType + "");
   writer.println("");
   writer.println("");
   
   writer.println("StartSave [" + tmpFileName + "] {");
   writer.println("");
   
   writer.println("numLines [" + lineIndex + "]");
   writer.println("numEllipses [" + eIndex + "]");
   writer.println("numTriangles [" + trisIndex + "]");
   writer.println("");
   
  // LINES
  writer.println("Lines {");
  for (int i = 0; i < lineIndex; i++) {
     writer.println ("" + i + " [" + lines.get(i).get(0) + "," + lines.get(i).get(1) + "," 
                         + lines.get(i).get(2) + "," + lines.get(i).get(3) + "," + lines.get(i).get(4) 
                         + "," + lines.get(i).get(5) + "," + lines.get(i).get(6) + "," + lines.get(i).get(7) + "]");
  }
  
  writer.println ("}");
  writer.println("");
  
  
  // ELLIPSES
  writer.println("Ellipses {");
  
  if (eIndex > 0) {
    for (int i = 0; i < eIndex; i++) {
       writer.println ("" + i + " [" + ellipses.get(i).get(0) + "," + ellipses.get(i).get(1) + "," + ellipses.get(i).get(2) + "," + ellipses.get(i).get(3) + "," 
                             + ellipses.get(i).get(4) + "," + ellipses.get(i).get(5) + "," + ellipses.get(i).get(6) + "," + ellipses.get(i).get(7) + "]");
    } 
  }
  
  writer.println ("}");
  writer.println("");
  
  
  // TRIANGLES
  writer.println("Triangles {");
    for (int i = 0; i < trisIndex; i++) {
       writer.println ("" + i + " [" + triangles.get(i).get(0) + "," + triangles.get(i).get(1) + "," + triangles.get(i).get(2) + "," + triangles.get(i).get(3) + "," 
                             + triangles.get(i).get(4) + "," + triangles.get(i).get(5) + "," + triangles.get(i).get(6) + "," 
                             + triangles.get(i).get(7) + "," + triangles.get(i).get(8) + "," + triangles.get(i).get(9) + "]");
  } 
  
  writer.println ("}");
  
  
  writer.println("");
  writer.println ("} [EndSave]");
  
  writer.flush();
  writer.close();
}
 
void loadDrawing (String filename) {
  background(255);
  
  if (filename == null) {
    return;
  }
  
  String saveName; 
  int numLines;
  int numEllipses;
  int numTriangles;
  
  String fileLines[] = loadStrings(filename);
  
  for (int i = 0 ; i < fileLines.length; i++) {
    if ((match(fileLines[i], "StartSave") != null)) {
      String[] temp = split(fileLines[i], "[");
      String[] subTemp = split(temp[1], "]");
      saveName = subTemp[0];
      
    } else if ((match(fileLines[i], "numLines") != null)) {
      String[] temp = split(fileLines[i], "[");
      String[] subTemp = split(temp[1], "]");
      numLines = parseInt(subTemp[0]);
      
    } else if ((match(fileLines[i], "numEllipses") != null)) {
      String[] temp = split(fileLines[i], "[");
      String[] subTemp = split(temp[1], "]");
      numEllipses = parseInt(subTemp[0]);
      
    } else if ((match(fileLines[i], "numTriangles") != null)) {
      String[] temp = split(fileLines[i], "[");
      String[] subTemp = split(temp[1], "]");
      numTriangles = parseInt(subTemp[0]);
      
    } else if ((match(fileLines[i], "Lines") != null)) {
      i++;
      while (match(fileLines[i], "}") == null) {
        String[] temp = split(fileLines[i], "[");
        String[] subTemp = split(temp[1], ",");
       
        int x1 = parseInt(subTemp[0]);
        int y1 = parseInt(subTemp[1]);
        
        int x2 = parseInt(subTemp[2]);
        int y2 = parseInt(subTemp[3]);
        
        int cR = parseInt(subTemp[4]);
        int cG = parseInt(subTemp[5]);
        int cB = parseInt(subTemp[6]);
        
        int sw = parseInt( (subTemp[7].substring(0, subTemp[7].length()-1)) );

        // Redraw lines
        basicLine(x1, y1, x2, y2, cR, cG, cB, sw);
        
        i++;
      }
      

    } else if ((match(fileLines[i], "Ellipses") != null)) {
      i++;
      while (match(fileLines[i], "}") == null) {
        String[] temp = split(fileLines[i], "[");
        String[] subTemp = split(temp[1], ",");
        
        int x = parseInt(subTemp[0]);
        int y = parseInt(subTemp[1]);
        
        int w = parseInt(subTemp[2]);
        int h = parseInt(subTemp[3]);
        
        int cR = parseInt(subTemp[4]);
        int cG = parseInt(subTemp[5]);
        int cB = parseInt(subTemp[6]);
        
        int sw = parseInt( (subTemp[7].substring(0, subTemp[7].length()-1)) );

        basicEllipse(x, y, w, h, cR, cG, cB, sw);
        
        i++;
      }
      

    } else if ((match(fileLines[i], "Triangles") != null)) {
      i++;
      while (match(fileLines[i], "}") == null) {
        String[] temp = split(fileLines[i], "[");
        String[] subTemp = split(temp[1], ",");
        
        int x = parseInt(subTemp[0]);
        int y = parseInt(subTemp[1]);
        
        int xTwo = parseInt(subTemp[2]);
        int yTwo = parseInt(subTemp[3]);
        
        int xThree = parseInt(subTemp[4]);
        int yThree = parseInt(subTemp[5]);
        
        int cR = parseInt(subTemp[6]);
        int cG = parseInt(subTemp[7]);
        int cB = parseInt(subTemp[8]);
        
        int sw = parseInt( (subTemp[9].substring(0, subTemp[9].length()-1)) );

        basicTriangle(x, y, xTwo, yTwo, xThree, yThree, cR, cG, cB, sw);
        
        i++;
      }
    }
  }
}







// -------------- CUSTOM GUI ------------------

class HScrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;

  HScrollbar (float xp, float yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }

  void update() {
    if(overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if(mousePressed && over) {
      locked = true;
    }
    if(!mousePressed) {
      locked = false;
    }
    if(locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if(abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if(mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    noStroke();
    fill(204);
    rect(xpos, ypos, swidth, sheight);
    if(over || locked) {
      fill(0, 0, 0);
    } else {
      fill(102, 102, 102);
    }
    rect(spos, ypos, sheight, sheight);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
}




class HButton {
  float xPos, yPos;       // x and y position of button
  int bWidth, bHeight;    // width and height of button
  boolean isButtonDown;   // is the user clicking the button
  boolean isMouseOver;    // is the mouse of the button
  String label;
  float borderThinkness;

  HButton (String l, float xp, float yp, int bw, int bh, float bt) {
    xPos = xp;
    yPos = yp;
    bWidth = bw;
    bHeight = bh;
    label = l;
    borderThinkness = bt;
  }

  void update() {
    if(overEvent()) {
      isMouseOver = true;
    } else {
      isMouseOver = false;
    }
    if(mousePressed && isMouseOver) {
      isButtonDown = true;
    } else {
      isButtonDown = false;
    }

  }


  boolean overEvent() {
    if((mouseX > xPos) && (mouseX < (xPos + bWidth)) &&
       (mouseY > yPos) && (mouseY < (yPos + bHeight))) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    stroke(0);
    strokeWeight(borderThinkness);
    if (isMouseOver) { // just mouse over
      fill (104, 104, 104);
    }
    if (isMouseOver && isButtonDown) { // user clicked
      fill (130, 130, 130);
    }
    if (!isMouseOver) { // normal
      fill (90, 90, 90);
    }
    rect(xPos, yPos, bWidth, bHeight);
    fill(0);
    float yOffset = (((bHeight / 2) + yPos) + 5);
    float xOffset = (((bWidth - textWidth(label)) / 2) + xPos);
    text(label, xOffset, yOffset);
    
    
  }
  

  boolean clicked () {
    if (isButtonDown) {
     // clicked = true;
      return true;
    } else {
      //clicked = true;
      return false;
    }
  }
  
}


class HCheckbox {
  float xPos, yPos;       // x and y position of checkbox
  int bWidth, bHeight;    // width and height of checkbox
  boolean isButtonDown;   // is the user clicking the checkbox
  boolean isMouseOver;    // is the mouse on the button
  String label;
  boolean isTicked = false;
  boolean textSide = true;     // TRUE is RIGHT, FALSE is LEFT
  float borderThinkness;

  HCheckbox (float xp, float yp, int bw, int bh, String l, boolean ts, float bt) {
    xPos = xp;
    yPos = yp;
    bWidth = bw;
    bHeight = bh;
    label = l;
    textSide = ts;
    borderThinkness = bt;
  }

  void update() {
    if(overEvent()) {
      isMouseOver = true;
    } else {
      isMouseOver = false;
    }
    if(mousePressed && isMouseOver) {
      isButtonDown = true;
    } else {
      isButtonDown = false;
    }

  }



  boolean overEvent() {
    if((mouseX > xPos) && (mouseX < (xPos + bWidth)) &&
       (mouseY > yPos) && (mouseY < (yPos + bHeight))) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    noStroke();
    //stroke(50);
    //strokeWeight(borderThinkness);
    
    fill (150, 150, 150);
    rect(xPos, yPos, bWidth, bHeight, 18);
    
    if (isTicked) {
      fill (70, 70, 70);
    } else {
      fill (150, 150, 150);
    }
    
    stroke(0);
    strokeWeight(2);
    rect(((xPos + (bWidth / 2)) - (bWidth / 4)), ((yPos + (bHeight / 2)) - (bHeight / 4)), (bWidth / 2), (bHeight / 2), 18);

    fill(0);
    
    float yOffset = (yPos + ((bHeight / 2) + 5));
    float xOffset;
    
    
    // TRUE is RIGHT, FALSE is LEFT
    if (textSide) {
      xOffset = (xPos + ((bWidth + textWidth(label)) - 20));
    } else {
      xOffset = ((xPos - textWidth(label)) - 20);
    }
    
    text(label, xOffset, yOffset);
    
  }
  
  void checkTick () {
    if (isButtonDown) {
      isTicked = !isTicked;
    }
  }
  
  boolean ticked () {
    return !isTicked;
  } 
  
  
  float getX () {
    return xPos;
  }
  
  float getY () {
    return yPos;
  }

  
}



