import java.util.Arrays;
import java.util.Collections;

int pred1x = 620;
int pred1y = 330;
int pred1_width = 70;
int pred1_height = 25;
int pred2x = 620;
int pred2y = 355;
int pred2_width = 70;
int pred2_height = 25;
String[] common_words;
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
String currentWord = "";
final int DPIofYourDeviceScreen = 277; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
PImage watch;

boolean selectingCharacter = false;
char currentLetter = 'a';

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  // frameRate(60);
  common_words = loadStrings("common_words.txt");
  watch = loadImage("watchhand3smaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases)); //randomize the order of the phrases

  orientation(LANDSCAPE); //can also be PORTRAIT -- sets orientation on android device
  size(1280, 720); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 24)); //set the font to arial 24
  noStroke(); //my code doesn't use any strokes.
  
  initKeywheel(); // set up the wheel
  
}

color watchBackground = (100);
float topLeftX = 502; //(width/2) - sizeOfInputArea; i guess
float topLeftY = 223; //(height/2) - sizeOfInputArea;
float bottomRightX = 779;
float bottomRightY = 499; 
float watch_centerX = 640;
float watch_centerY = 360;

float rOuter = 240 / 2;
float rInner = 180 / 2;

class KeyButton {
  int letterNo; // 0-index it
  char letter;
  
  float startAngle;
  float midAngle;
  float endAngle;
  
  color shader;
  color shader_held;
  color outline;
  color outline_held;
  
  float centerX;
  float centerY;
  
  public KeyButton(int letterNo) {
    this.letter = (char)(97 + letterNo);
    
    this.startAngle = (360/26.0) * letterNo - 90;
    this.endAngle = (360/26.0) * (letterNo + 1) - 90;
    this.midAngle = (startAngle + endAngle) / 2;
    
    colorMode(HSB, 360, 100, 100); // change it to hsv
    int hue = (int) midAngle;
    this.shader = color(hue, 30, 100);
    this.shader_held = color(hue, 70, 100);
    this.outline = color(hue, 40, 20);
    this.outline_held = color(hue, 100, 50);
    colorMode(RGB, 255, 255, 255);
    
    this.centerX = watch_centerX + ((rOuter + rInner) / 2) * cos(radians(midAngle));
    this.centerY = watch_centerY + ((rOuter + rInner) / 2) * sin(radians(midAngle));
        
  }

  public void drawButton (boolean isCurrentLetter) {
    if (selectingCharacter && isCurrentLetter) {
      float rad_offset = 8; // make it a bit bigger
      stroke(outline_held);
      // outer circle edge & borders
      fill(shader_held);
      arc(watch_centerX, watch_centerY, 
          2 * (rOuter + rad_offset), 2 * (rOuter + rad_offset), 
          radians(startAngle), radians(endAngle), PIE);
      // inner circle edge
      noFill();
      arc(watch_centerX, watch_centerY, 2 * rInner, 2 * rInner, radians(startAngle), radians(endAngle));
      // letter
      textFont(createFont("Arial", 14));
      fill(outline_held);
      text(("" + this.letter), this.centerX - 3, this.centerY + 2); 
    }
    else {
      stroke(outline);
      // outer circle edge & borders
      fill(shader);
      arc(watch_centerX, watch_centerY, 2 * rOuter, 2 * rOuter, radians(startAngle), radians(endAngle), PIE);
      // inner circle edge
      noFill();
      arc(watch_centerX, watch_centerY, 2 * rInner, 2 * rInner, radians(startAngle), radians(endAngle));
      // letter
      fill(outline);
      textFont(createFont("Arial", 14));
      text(("" + this.letter), this.centerX - 3, this.centerY + 2); // offset it a bit so text looks centered
    }
  }

}

// curved corner buttons
class SpaceButton {
  color shader = color(107, 194, 255);
  color shader_held = color(32, 163, 255);
  color text = 255;
  
  float centerX = bottomRightX;
  float centerY = bottomRightY;
  float radius = 65;
  
  public SpaceButton() {
  }
  
  public void drawButton(boolean isHeld) {
    noStroke();
    if (isHeld) fill(shader_held);
    else fill(shader);
    arc(centerX, centerY, 2 * radius, 2 * radius, PI, 3*PI/2);
    
    fill(text);
    textFont(createFont("Arial", 15));
    text("space", this.centerX - 50, this.centerY - 15);
  }
  
  public boolean inButton(float x, float y) {
    return (x < centerX && x > centerX - radius && y < centerY && y > centerY - radius
    && dist(x, y, centerX, centerY) < radius);
  }
}

class DeleteButton {
  color shader = color(255, 112, 100);
  color shader_held = color(229, 54, 38);
  color text = 255;
  
  float centerX = bottomRightX - sizeOfInputArea;
  float centerY = bottomRightY;
  float radius = 65;
  
  public DeleteButton() {
  }
  
  public void drawButton(boolean isHeld) {
    noStroke();
    if (isHeld) fill(shader_held);
    else fill(shader);
    arc(centerX, centerY, 2 * radius, 2 * radius, 3*PI/2, 2*PI);
    
    fill(text);
    textFont(createFont("Arial", 15));
    text("back", this.centerX + 12, this.centerY - 15);
  }
  
  public boolean inButton(float x, float y) {
    return (x > centerX && x < centerX + radius && y < centerY && y > centerY - radius
    && dist(x, y, centerX, centerY) < radius);
  }
}

ArrayList<KeyButton> keywheel = new ArrayList<KeyButton>();
SpaceButton space = new SpaceButton();
DeleteButton delete = new DeleteButton();
void initKeywheel() {
  for(int i = 0; i < 26; i++) {
    // KeyButton k = new KeyButton(i);
    // println("key " + k.letter + " centerX = " + k.centerX + " centerY = " + k.centerY);
    keywheel.add(new KeyButton(i));
  }
}

char findClosestChar() {
  float closestDist = 99999;
  char closestChar = ',';
  for (KeyButton k : keywheel) {
    float distToKey = dist(mouseX, mouseY, k.centerX, k.centerY);
    if (distToKey < closestDist) {
      closestDist = distToKey;
      closestChar = k.letter;
    }
  }
  currentLetter = closestChar; // set this here
  return closestChar;
}

// my draw code
void drawInterface() {
  // draw keywheel
  if (selectingCharacter) {
    char closestChar = findClosestChar();
    for (KeyButton k : keywheel) {
      if (closestChar == k.letter) k.drawButton(true);
      else k.drawButton(false);
    }
    // draw the letter
    fill(255);
    textFont(createFont("Arial", 50));
    text("" + currentLetter, topLeftX + 10, topLeftY + 45);
    text("" + currentLetter, bottomRightX - 40, topLeftY + 45);
    
  }
  else {
    for (KeyButton k : keywheel) {
      k.drawButton(false);
    }
  }
  
  // fill in center of wheel
  fill(watchBackground);
  noStroke();
  ellipse(watch_centerX, watch_centerY, 2 * rInner, 2 * rInner);
  
  // draw space & delete
  space.drawButton(!selectingCharacter && space.inButton(mouseX, mouseY));
  delete.drawButton(!selectingCharacter && delete.inButton(mouseX, mouseY));
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

void draw()
{
  background(255); //clear background

  noStroke();
  drawWatch();
  fill(watchBackground);
  rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"

  drawInterface();
  
  if (finishTime!=0)
  {
    drawFinished();
    fill(128);
    textAlign(CENTER);
    text("Finished", 280, 150);
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
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(128);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    fill(255);
    text("Entered:  " + currentTyped +"|", 70, 140); //draw what the user has entered thus far 
    ////////////////////////////
    if (currentWord.contains(" "))
    {
      currentWord = "";
    }
    String[] a = predictions(currentWord, 9);
    textSize(20);
    fill(255);
    text(a[0], pred1x, pred1y, pred1_width, pred1_height);
    if (a.length > 1 && a[1] != null)
      text(a[1], pred2x, pred2y, pred2_width, pred2_height);
    //if (a.length > 2)
    //  text(a[2], 380, 370, 400, 395); 
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
  if (startTime != 0 && didMouseClick(topLeftX, topLeftY, sizeOfInputArea, sizeOfInputArea)) 
    selectingCharacter = true;
    
  if (didMouseClick(600, 325, 100, 60))
  {
    selectingCharacter = false;
  }
  //You are allowed to have a next button outside the 1" area
  if (didMouseClick(600, 600, 200, 200)) //check if click is in next button
  {
    selectingCharacter = false;
    nextTrial(); //if so, advance to next trial
  }
  
  //println("mouseX = " + mouseX + " mouseY = " + mouseY);
  else if (space.inButton(mouseX, mouseY) || delete.inButton(mouseX, mouseY)) {
    selectingCharacter = false;
  }


}

void mouseReleased() 
{
  if (!selectingCharacter) {
    if (didMouseClick(pred1x, pred1y, pred1_width, pred1_height)) //check if click in left button
        {
          String[] a = predictions(currentWord, 9);
          if (a.length > 0)
             if (a[0] != null){
            currentTyped+=a[0].substring(currentWord.length(), a[0].length());
          //currentLetter='_';
          currentWord = currentWord + " ";
          currentTyped+=" ";
        }
      }
   if (didMouseClick(pred2x, pred2y, pred2_width, pred2_height)) //check if click in left button
      {
          String[] a = predictions(currentWord, 9);
          if (a.length > 1 && a[1] != null)
            currentTyped+=a[1].substring(currentWord.length(), a[1].length());
          //currentLetter='_';
          currentWord = currentWord + " ";
          currentTyped+=" ";
      }
    if (space.inButton(mouseX, mouseY)) { // input space
      currentTyped += " ";
      currentWord+=" ";
    }
    else if (delete.inButton(mouseX, mouseY)) { // delete character
      currentTyped = currentTyped.substring(0, currentTyped.length()-1);
      if (currentWord.length()>0)
      currentWord = currentWord.substring(0, currentWord.length() -1);
    }
  }
  // else, input the current letter
  else {
    currentTyped += currentLetter;
    currentWord += currentLetter;
    selectingCharacter = false;
  }
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

String[] predictions(String word, int num){
  String[] empty = new String[1];
  empty[0] = "";
  String[] answer = new String[10];
  //String[] actual_answer = new String[10];
  int index = 0;
  
  for (int i = 0; i < common_words.length; i ++)
  {

    if (common_words[i].length() > word.length())
    {
      if (common_words[i].substring(0,word.length()).equals(word))
      {
        answer[index] = common_words[i];
        index += 1;
        if (index == num)
        {
          //System.out.println(Arrays.toString(answer));
            //System.out.println(Arrays.toString(actual_answer));
            //answer = new String[10];
            return answer;
          
        }
      }
    }
  }
  //System.out.println(Arrays.toString(answer));
  if (answer[0] != null)
  {
    return answer;
  }
  return empty;
  
}
