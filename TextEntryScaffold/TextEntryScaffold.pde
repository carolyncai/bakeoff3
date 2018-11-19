import java.util.Arrays;
import java.util.Collections;

String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 277; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
PImage watch;

// which keyboard half am i doing
boolean isLeftKeyboard = true;
// uhh lol
boolean mouseDown = false;

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  frameRate(60);
  watch = loadImage("watchhand3smaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases)); //randomize the order of the phrases

  orientation(LANDSCAPE); //can also be PORTRAIT -- sets orientation on android device
  size(1280, 720); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  //textFont(createFont("Arial", 24)); //set the font to arial 24
  noStroke(); //my code doesn't use any strokes.
  
  println(width);
  println(height);
  println(sizeOfInputArea);
  println(leftHeight);
  println("row1y = " + topLeftY);
  initKeyboards();
}

class KeyButton {
  String letter;
  
  float buttonHeight;
  float buttonWidth;
  float locationX;
  float locationY;
  
  int outline = 35;
  color shader = 217;
  color shader_held = 152;
  
  
  public KeyButton(String letter, 
            float buttonWidth, float buttonHeight, 
            float locationX, float locationY) {
    this.letter = letter;
    
    this.buttonWidth = buttonWidth;
    this.buttonHeight = buttonHeight;
    this.locationX = locationX;
    this.locationY = locationY;
        
  }

  public void drawButton () {
    stroke(outline);
    
    //if (this.isMouseInKey()) fill(shader_held);
    //else fill(shader);
    
    // it's laggy if you color it differently when button is held...
    // hmm
    fill(shader);
    
    rect(this.locationX, this.locationY, 
         this.buttonWidth, this.buttonHeight);
    
    fill(outline);
    textFont(createFont("Arial", 18));
    text(this.letter, 
         this.locationX + this.buttonWidth/2, 
         this.locationY + this.buttonHeight/2);
    
    //if (this.isMouseInKey()) this.drawButtonFloat();
  }
  
  public void drawButtonFloat() {
    stroke(0,10,255);
    fill(255);

    rect(this.locationX, this.locationY - this.buttonHeight/2, // offset height
         this.buttonWidth, this.buttonHeight, 2); // give it a radius
         
    fill(0,10,255);
    text(this.letter, 
         this.locationX + this.buttonWidth/2, 
         this.locationY - this.buttonHeight/2 + this.buttonHeight/2);
  }
  
  public boolean isMouseInKey() {
    return mouseDown && didMouseClick(this.locationX, this.locationY, this.buttonWidth, this.buttonHeight);
  }
  
  public void inputKey() {
    currentTyped += this.letter;
  }

}

class SpaceButton extends KeyButton {
  
  public SpaceButton(float buttonWidth, float buttonHeight, 
                         float locationX, float locationY) {
    super("_", buttonWidth, buttonHeight, locationX, locationY);
  }
  
  @Override
  public void drawButtonFloat() {}
  
  @Override
  public void inputKey() {
    currentTyped += " ";
  }
}

class BackspaceButton extends KeyButton {
  
  public BackspaceButton(float buttonWidth, float buttonHeight, 
                         float locationX, float locationY) {
    super("<x", buttonWidth, buttonHeight, locationX, locationY);
    
    this.shader = color(255,92,78);
    this.shader_held = color(192,70,58);
  }
  
  @Override
  public void drawButtonFloat() {}
  
  @Override
  // delete the last inputted thing
  public void inputKey() {
    currentTyped = currentTyped.substring(0, currentTyped.length()-1);;
  }
}

class SwitchKey extends KeyButton {
  
  public SwitchKey(String text, 
                   float buttonWidth, float buttonHeight, 
                   float locationX, float locationY) {
    super(text, buttonWidth, buttonHeight, locationX, locationY);
    
    this.shader = color(150, 235, 230);
    this.shader_held = color(105, 195, 190);
  }
  
  @Override
  public void drawButtonFloat() {}
  
  @Override
  // switch the keyboard
  public void inputKey() {
    isLeftKeyboard = !isLeftKeyboard;
  }
}

// initialize keys *************************************************************

float topLeftX = 500; //(width/2) - sizeOfInputArea; i guess
float topLeftY = 225; //(height/2) - sizeOfInputArea;

float bottomRightX = 775;
float bottomRightY = 500;

// keyboard left half
ArrayList<KeyButton> leftKeyboard = new ArrayList<KeyButton>();

float leftWidth = sizeOfInputArea/6;
float leftHeight = sizeOfInputArea/5.5;

float rowOneY = topLeftY + (float)sizeOfInputArea * 0.2;
KeyButton qKey = new KeyButton("q", leftWidth, leftHeight, topLeftX, rowOneY);
KeyButton wKey = new KeyButton("w", leftWidth, leftHeight, topLeftX + leftWidth, rowOneY);
KeyButton eKey = new KeyButton("e", leftWidth, leftHeight, topLeftX + 2 * leftWidth, rowOneY);
KeyButton rKey = new KeyButton("r", leftWidth, leftHeight, topLeftX + 3 * leftWidth, rowOneY);
KeyButton tKey = new KeyButton("t", leftWidth, leftHeight, topLeftX + 4 * leftWidth, rowOneY);

float leftRowTwoX = topLeftX + leftWidth/2;
float rowTwoY = rowOneY + leftHeight + 2;
KeyButton aKey = new KeyButton("a", leftWidth, leftHeight, leftRowTwoX, rowTwoY);
KeyButton sKey = new KeyButton("s", leftWidth, leftHeight, leftRowTwoX + leftWidth, rowTwoY);
KeyButton dKey = new KeyButton("d", leftWidth, leftHeight, leftRowTwoX + 2 * leftWidth, rowTwoY);
KeyButton fKey = new KeyButton("f", leftWidth, leftHeight, leftRowTwoX + 3 * leftWidth, rowTwoY);
KeyButton gKey = new KeyButton("g", leftWidth, leftHeight, leftRowTwoX + 4 * leftWidth, rowTwoY);

float leftRowThreeX = leftRowTwoX + leftWidth/2;
float rowThreeY = rowTwoY + leftHeight + 2;
KeyButton zKey = new KeyButton("z", leftWidth, leftHeight, leftRowThreeX, rowThreeY);
KeyButton xKey = new KeyButton("x", leftWidth, leftHeight, leftRowThreeX + leftWidth, rowThreeY);
KeyButton cKey = new KeyButton("c", leftWidth, leftHeight, leftRowThreeX + 2 * leftWidth, rowThreeY);
KeyButton vKey = new KeyButton("v", leftWidth, leftHeight, leftRowThreeX + 3 * leftWidth, rowThreeY);
KeyButton bKey = new KeyButton("b", leftWidth, leftHeight, leftRowThreeX + 4 * leftWidth, rowThreeY);

float rowFourY = bottomRightY - leftHeight;
BackspaceButton leftBackspace = new BackspaceButton(sizeOfInputArea * 0.3, leftHeight, bottomRightX - sizeOfInputArea, rowFourY);
SpaceButton leftSpace = new SpaceButton(sizeOfInputArea * 0.4, leftHeight, bottomRightX - sizeOfInputArea * 0.7, rowFourY);
SwitchKey leftSwitch = new SwitchKey(">>>", sizeOfInputArea * 0.3, leftHeight, bottomRightX - sizeOfInputArea * 0.3, rowFourY);

// keyboard right half
ArrayList<KeyButton> rightKeyboard = new ArrayList<KeyButton>();
float rightWidth = sizeOfInputArea/5;
float rightHeight = sizeOfInputArea/5.5;

KeyButton yKey = new KeyButton("y", rightWidth, rightHeight, topLeftX, rowOneY);
KeyButton uKey = new KeyButton("u", rightWidth, rightHeight, topLeftX + rightWidth, rowOneY);
KeyButton iKey = new KeyButton("i", rightWidth, rightHeight, topLeftX + 2 * rightWidth, rowOneY);
KeyButton oKey = new KeyButton("o", rightWidth, rightHeight, topLeftX + 3 * rightWidth, rowOneY);
KeyButton pKey = new KeyButton("p", rightWidth, rightHeight, topLeftX + 4 * rightWidth, rowOneY);

float rightRowTwoX = topLeftX + rightWidth/2;
KeyButton hKey = new KeyButton("h", rightWidth, rightHeight, rightRowTwoX, rowTwoY);
KeyButton jKey = new KeyButton("j", rightWidth, rightHeight, rightRowTwoX + rightWidth, rowTwoY);
KeyButton kKey = new KeyButton("k", rightWidth, rightHeight, rightRowTwoX + 2 * rightWidth, rowTwoY);
KeyButton lKey = new KeyButton("l", rightWidth, rightHeight, rightRowTwoX + 3 * rightWidth, rowTwoY);

float rightRowThreeX = rightRowTwoX + rightWidth/2;
KeyButton nKey = new KeyButton("n", rightWidth, rightHeight, rightRowThreeX, rowThreeY);
KeyButton mKey = new KeyButton("m", rightWidth, rightHeight, rightRowThreeX + rightWidth, rowThreeY);

BackspaceButton rightBackspace = new BackspaceButton(rightWidth * 1.5 + 14, rightHeight, rightRowThreeX + 2 * rightWidth + 5, rowThreeY);
SpaceButton rightSpace = new SpaceButton(sizeOfInputArea * 0.6, rightHeight, bottomRightX - sizeOfInputArea * 0.6, rowFourY);
SwitchKey rightSwitch = new SwitchKey("<<<", sizeOfInputArea * 0.4, rightHeight, bottomRightX - sizeOfInputArea, rowFourY);

// *****************************************************************************

void initKeyboards() {
  leftKeyboard.add(qKey);
  leftKeyboard.add(wKey);
  leftKeyboard.add(eKey);
  leftKeyboard.add(rKey);
  leftKeyboard.add(tKey);
  
  leftKeyboard.add(aKey);
  leftKeyboard.add(sKey);
  leftKeyboard.add(dKey);
  leftKeyboard.add(fKey);
  leftKeyboard.add(gKey);
  
  leftKeyboard.add(zKey);
  leftKeyboard.add(xKey);
  leftKeyboard.add(cKey);
  leftKeyboard.add(vKey);
  leftKeyboard.add(bKey);
  
  leftKeyboard.add(leftBackspace);
  leftKeyboard.add(leftSpace);
  leftKeyboard.add(leftSwitch);
  
  rightKeyboard.add(yKey);
  rightKeyboard.add(uKey);
  rightKeyboard.add(iKey);
  rightKeyboard.add(oKey);
  rightKeyboard.add(pKey);
  
  rightKeyboard.add(hKey);
  rightKeyboard.add(jKey);
  rightKeyboard.add(kKey);
  rightKeyboard.add(lKey);
  
  rightKeyboard.add(nKey);
  rightKeyboard.add(mKey);
  
  rightKeyboard.add(rightBackspace);
  rightKeyboard.add(rightSpace);
  rightKeyboard.add(rightSwitch);
}

void drawFinished() {
  fill(0);
  int textX = 300;
  int textY = 300;
  textFont(createFont("Arial", 24));
  text("==================", textX, textY);
  text("Trials complete!", textX, textY + 30); //output
  text("Total time taken: " + (finishTime - startTime), textX, textY + 2 * 30); //output
  text("Total letters entered: " + lettersEnteredTotal, textX, textY + 3 * 30); //output
  text("Total letters expected: " + lettersExpectedTotal, textX, textY + 4 * 30); //output
  text("Total errors entered: " + errorsTotal, textX, textY + 5 * 30); //output

  float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
  text("Raw WPM: " + wpm, textX, textY + 7 * 30); //output

  float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars

  text("Freebie errors: " + freebieErrors, textX, textY + 9 * 30); //output
  float penalty = max(errorsTotal-freebieErrors, 0) * .5f;

  text("Penalty: " + penalty, textX, textY + 10 * 30);
  text("WPM w/ penalty: " + (wpm-penalty), textX, textY + 11 * 30); //yes, minus, becuase higher WPM is better
  text("==================", textX, textY + 12 * 30);
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(255); //clear background

  drawWatch();
  fill(100);
  rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"

  if (isLeftKeyboard) {
    for (KeyButton k: leftKeyboard) {
      k.drawButton();
    }
  }
  else {
    for (KeyButton k: rightKeyboard) {
      k.drawButton();
    }
  }
  
  textFont(createFont("Arial", 24)); //set the font to arial 24
  
  if (finishTime!=0)
  {
    fill(128);
    textAlign(CENTER);
    text("Finished", 280, 150);
    drawFinished();
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(128);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(LEFT); //align the text left
    fill(100);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 300, 50); //draw the trial count
    fill(100);
    text(" Target:  " + currentPhrase, 300, 80); //draw the target string
    text("Entered:  " + currentTyped +"|", 300, 120); //draw what the user has entered thus far 
    
    //draw very basic next button
    fill(255, 0, 0);
    rect(600, 600, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", 650, 650); //draw next label

    //my draw code
    //fill(255, 0, 0); //red button
    //rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw left red button
    //fill(0, 255, 0); //green button
    //rect(width/2-sizeOfInputArea/2+sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw right green button
    //textAlign(CENTER);
    //fill(200);
    //text("" + currentLetter, width/2, height/2-sizeOfInputArea/4); //draw current letter
  }
}

boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}


void mousePressed()
{

  mouseDown = true;
  println("mouseX = " + mouseX + "mouseY = " + mouseY);
  
  //You are allowed to have a next button outside the 1" area
  if (didMouseClick(600, 600, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}

void mouseReleased()
{
  if (isLeftKeyboard) {
    for (KeyButton k: leftKeyboard) {
      if (k.isMouseInKey()) k.inputKey();
    }
  }
  else {
    for (KeyButton k: rightKeyboard) {
      if (k.isMouseInKey()) k.inputKey();
    }
  }
  mouseDown = false;
}


void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    System.out.println("Raw WPM: " + wpm); //output

    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars

    System.out.println("Freebie errors: " + freebieErrors); //output
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;

    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } else
  {
    currTrialNum++; //increment trial number
  }

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}


void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0;
  pushMatrix();
  translate(width/2,height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch,0,0);
  popMatrix();
}

//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
