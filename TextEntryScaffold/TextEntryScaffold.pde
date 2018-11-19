import java.util.Arrays;
import java.util.Collections;

// ** copypaste accelerometerManager here // ctrl+F "ACTUAL BAKEOFF CODE" for bakeoff code.
import processing.core.PApplet;

import java.lang.reflect.*;
import java.util.List;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;


/**
 * Android Accelerometer Sensor Manager Archetype
 * @author antoine vianey
 * under GPL v3 : http://www.gnu.org/licenses/gpl-3.0.html
 */
public class AccelerometerManager {
  /** Accuracy configuration */
  private float threshold = 0.2f;
  private int interval = 1000;

  private Sensor sensor;
  private SensorManager sensorManager;
  // you could use an OrientationListener array instead
  // if you plans to use more than one listener
//  private AccelerometerListener listener;

  Method shakeEventMethod;
  Method accelerationEventMethod;

  /** indicates whether or not Accelerometer Sensor is supported */
  private Boolean supported;
  /** indicates whether or not Accelerometer Sensor is running */
  private boolean running = false;

  PApplet parent;
  Context context;  

  public AccelerometerManager(PApplet parent) {
    this.parent = parent;
    this.context = parent.getActivity();
    
    try {
      shakeEventMethod =
        parent.getClass().getMethod("shakeEvent", new Class[] { Float.TYPE });
    } catch (Exception e) {
      // no such method, or an error.. which is fine, just ignore
    }

    try {
      accelerationEventMethod =
        parent.getClass().getMethod("accelerationEvent", new Class[] { Float.TYPE, Float.TYPE, Float.TYPE });
    } catch (Exception e) {
      // no such method, or an error.. which is fine, just ignore
    }
//    System.out.println("shakeEventMethod is " + shakeEventMethod);
//    System.out.println("accelerationEventMethod is " + accelerationEventMethod);
    resume();
  }


  public AccelerometerManager(PApplet parent, int threshold, int interval) {
    this(parent);
    this.threshold = threshold;
    this.interval = interval;
  }


  public void resume() {
    if (isSupported()) {
      startListening();
    }
  }
  
  
  public void pause() {
    if (isListening()) {
      stopListening();
    }
  }


  /**
   * Returns true if the manager is listening to orientation changes
   */
  public boolean isListening() {
    return running;
  }


  /**
   * Unregisters listeners
   */
  public void stopListening() {
    running = false;
    try {
      if (sensorManager != null && sensorEventListener != null) {
        sensorManager.unregisterListener(sensorEventListener);
      }
    } 
    catch (Exception e) {
    }
  }


  /**
   * Returns true if at least one Accelerometer sensor is available
   */
  public boolean isSupported() {
    if (supported == null) {
      sensorManager = (SensorManager) context.getSystemService(Context.SENSOR_SERVICE);
      List<Sensor> sensors = sensorManager.getSensorList(Sensor.TYPE_ACCELEROMETER);
      supported = new Boolean(sensors.size() > 0);
    }
    return supported;
  }


//  /**
//   * Configure the listener for shaking
//   * @param threshold
//   *       minimum acceleration variation for considering shaking
//   * @param interval
//   *       minimum interval between to shake events
//   */
//  public static void configure(int threshold, int interval) {
//    AccelerometerManager.threshold = threshold;
//    AccelerometerManager.interval = interval;
//  }


  /**
   * Registers a listener and start listening
   * @param accelerometerListener callback for accelerometer events
   */
  public void startListening() {
//    AccelerometerListener accelerometerListener = (AccelerometerListener) context;
    sensorManager = (SensorManager) context.getSystemService(Context.SENSOR_SERVICE);
    List<Sensor> sensors = sensorManager.getSensorList(Sensor.TYPE_ACCELEROMETER);
    if (sensors.size() > 0) {
      sensor = sensors.get(0);
      running = sensorManager.registerListener(sensorEventListener, sensor, SensorManager.SENSOR_DELAY_GAME);
//      listener = accelerometerListener;
    }
  }


//  /**
//   * Configures threshold and interval
//   * And registers a listener and start listening
//   * @param accelerometerListener
//   *       callback for accelerometer events
//   * @param threshold
//   *       minimum acceleration variation for considering shaking
//   * @param interval
//   *       minimum interval between to shake events
//   */
//  public void startListening(int threshold, int interval) {
//    configure(threshold, interval);
//    startListening();
//  }


  /**
   * The listener that listen to events from the accelerometer listener
   */
  //private static SensorEventListener sensorEventListener = new SensorEventListener() {
  private SensorEventListener sensorEventListener = new SensorEventListener() {
    private long now = 0;
    private long timeDiff = 0;
    private long lastUpdate = 0;
    private long lastShake = 0;

    private float x = 0;
    private float y = 0;
    private float z = 0;
    private float lastX = 0;
    private float lastY = 0;
    private float lastZ = 0;
    private float force = 0;

    public void onAccuracyChanged(Sensor sensor, int accuracy) {
    }

    public void onSensorChanged(SensorEvent event) {
      // use the event timestamp as reference
      // so the manager precision won't depends 
      // on the AccelerometerListener implementation
      // processing time
      now = event.timestamp;

      x = event.values[0];
      y = event.values[1];
      z = event.values[2];

      // if not interesting in shake events
      // just remove the whole if then else bloc
      if (lastUpdate == 0) {
        lastUpdate = now;
        lastShake = now;
        lastX = x;
        lastY = y;
        lastZ = z;

      } else {
        timeDiff = now - lastUpdate;
        if (timeDiff > 0) {
          force = Math.abs(x + y + z - lastX - lastY - lastZ) 
            / timeDiff;
          if (force > threshold) {
            if (now - lastShake >= interval) {
              // trigger shake event
//              listener.onShake(force);
              if (shakeEventMethod != null) {
                try {
                  shakeEventMethod.invoke(parent, new Object[] { new Float(force) });
                } catch (Exception e) {
                  e.printStackTrace();
                  shakeEventMethod = null;
                }
              }
            }
            lastShake = now;
          }
          lastX = x;
          lastY = y;
          lastZ = z;
          lastUpdate = now;
        }
      }
      // trigger change event
//      listener.onAccelerationChanged(x, y, z);
      if (accelerationEventMethod != null) {
        try {
          accelerationEventMethod.invoke(parent, new Object[] { x, y, z });
        } catch (Exception e) {
          e.printStackTrace();
          accelerationEventMethod = null;
        }
      }
    }
  };
}

// **************** ACTUAL BAKEOFF CODE BEGINS HERE *********************
// **********************************************************************

int pred1x = 500;
int pred1y = 220;
int pred1_width = 90;
int pred1_height = 35;
int pred2x = 595;
int pred2y = 220;
int pred2_width = 90;
int pred2_height = 35;
int pred3x = 690;
int pred3y = 220;
int pred3_width = 90;
int pred3_height = 35;
//String[] common_words;
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

// which keyboard half am i doing
boolean isLeftKeyboard = true;
// uhh lol
boolean mouseDown = false;

AccelerometerManager accel;
float ax = 0;
float ay = 0;
float az = 0;

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  accel = new AccelerometerManager(this);
  //common_words = loadStrings("common_words.txt");
  assert(common_words != null);
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

// DETECT ACCELERATION HERE
boolean canFlipKeyboard = true;
public void accelerationEvent(float x, float y, float z) {
  ax = x;
  ay = y;
  az = z;
  
  // not sure how i feel about these values. can adjust
  float flipThreshold = 2;
  float neutral = 1;
  if ((ay < -1*flipThreshold || ay > flipThreshold) && canFlipKeyboard) {
    isLeftKeyboard = !isLeftKeyboard;
    canFlipKeyboard = false;
  } else if (ay > -1*neutral && ay < neutral){ // 'neutral' position
    canFlipKeyboard = true;
  }

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
    fill(shader);
    
    rect(this.locationX, this.locationY, 
         this.buttonWidth, this.buttonHeight);
    
    fill(outline);
    textFont(createFont("Arial", 18));
    text(this.letter, 
         this.locationX + this.buttonWidth/2 - 4, 
         this.locationY + this.buttonHeight/2);
    
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
    currentWord += this.letter;
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
    currentWord += " ";
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
    currentTyped = currentTyped.substring(0, currentTyped.length()-1);
    if (currentWord.length()>0)
      currentWord = currentWord.substring(0, currentWord.length() -1);
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

float topLeftX = 502; //(width/2) - sizeOfInputArea; i guess
float topLeftY = 225; //(height/2) - sizeOfInputArea;

float bottomRightX = 777;
float bottomRightY = 500;

// keyboard left half
ArrayList<KeyButton> leftKeyboard = new ArrayList<KeyButton>();

float leftWidth = sizeOfInputArea/6;
float leftHeight = sizeOfInputArea/5;

float rowOneY = topLeftY + (float)sizeOfInputArea * 0.2;
KeyButton qKey = new KeyButton("q", leftWidth, leftHeight, topLeftX, rowOneY);
KeyButton wKey = new KeyButton("w", leftWidth, leftHeight, topLeftX + leftWidth, rowOneY);
KeyButton eKey = new KeyButton("e", leftWidth, leftHeight, topLeftX + 2 * leftWidth, rowOneY);
KeyButton rKey = new KeyButton("r", leftWidth, leftHeight, topLeftX + 3 * leftWidth, rowOneY);
KeyButton tKey = new KeyButton("t", leftWidth, leftHeight, topLeftX + 4 * leftWidth, rowOneY);

float leftRowTwoX = topLeftX + leftWidth/2;
float rowTwoY = rowOneY + leftHeight + 4;
KeyButton aKey = new KeyButton("a", leftWidth, leftHeight, leftRowTwoX, rowTwoY);
KeyButton sKey = new KeyButton("s", leftWidth, leftHeight, leftRowTwoX + leftWidth, rowTwoY);
KeyButton dKey = new KeyButton("d", leftWidth, leftHeight, leftRowTwoX + 2 * leftWidth, rowTwoY);
KeyButton fKey = new KeyButton("f", leftWidth, leftHeight, leftRowTwoX + 3 * leftWidth, rowTwoY);
KeyButton gKey = new KeyButton("g", leftWidth, leftHeight, leftRowTwoX + 4 * leftWidth, rowTwoY);

float leftRowThreeX = leftRowTwoX + leftWidth/2;
float rowThreeY = rowTwoY + leftHeight + 4;
KeyButton zKey = new KeyButton("z", leftWidth, leftHeight, leftRowThreeX, rowThreeY);
KeyButton xKey = new KeyButton("x", leftWidth, leftHeight, leftRowThreeX + leftWidth, rowThreeY);
KeyButton cKey = new KeyButton("c", leftWidth, leftHeight, leftRowThreeX + 2 * leftWidth, rowThreeY);
KeyButton vKey = new KeyButton("v", leftWidth, leftHeight, leftRowThreeX + 3 * leftWidth, rowThreeY);
KeyButton bKey = new KeyButton("b", leftWidth, leftHeight, leftRowThreeX + 4 * leftWidth, rowThreeY);

float rowFourY = bottomRightY - leftHeight * .7;
BackspaceButton leftBackspace = new BackspaceButton(sizeOfInputArea * 0.3, leftHeight * .7, bottomRightX - sizeOfInputArea * 0.3, rowFourY);
SpaceButton leftSpace = new SpaceButton(sizeOfInputArea * 0.7, leftHeight * .7, bottomRightX - sizeOfInputArea, rowFourY);
//SwitchKey leftSwitch = new SwitchKey(">>>", sizeOfInputArea * 0.3, leftHeight, bottomRightX - sizeOfInputArea * 0.3, rowFourY);

// keyboard right half
ArrayList<KeyButton> rightKeyboard = new ArrayList<KeyButton>();
float rightWidth = sizeOfInputArea/5;
float rightHeight = sizeOfInputArea/5;

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

BackspaceButton rightBackspace = new BackspaceButton(sizeOfInputArea * 0.3, rightHeight * .7, bottomRightX - sizeOfInputArea * 0.3, rowFourY);
SpaceButton rightSpace = new SpaceButton(sizeOfInputArea * 0.7, rightHeight * .7, bottomRightX - sizeOfInputArea, rowFourY);
//SwitchKey rightSwitch = new SwitchKey("<<<", sizeOfInputArea * 0.4, rightHeight, bottomRightX - sizeOfInputArea, rowFourY);

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
  //leftKeyboard.add(leftSwitch);
  
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
  //rightKeyboard.add(rightSwitch);
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

  noStroke();
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
    text("Target : " + currentPhrase, 300, 80); //draw the target string
    text("Entered: " + currentTyped +"|", 300, 120); //draw what the user has entered thus far 
    //////////////////////////////
    if (currentWord.contains(" "))
    {
      currentWord = "";
    }
    String[] a = predictions(currentWord, 9);
    textSize(20);
    noFill();
    stroke(255);
    rect(pred1x, pred1y, pred1_width, pred1_height);
    rect(pred2x, pred2y, pred2_width, pred2_height);
    rect(pred3x, pred3y, pred3_width, pred3_height);

    fill(255);
    text(a[0], pred1x + 5, pred1y + 3, pred1_width, pred1_height);
    if (a.length > 1 && a[1] != null)
      text(a[1], pred2x + 5, pred2y + 3, pred2_width, pred2_height);
    if (a.length > 2 && a[2] != null)
      text(a[2], pred3x + 5, pred3y + 3, pred3_width, pred3_height); 
    
    //draw very basic next button
    fill(255, 0, 0);
    rect(600, 600, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", 650, 650); //draw next label
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
   if (didMouseClick(pred3x, pred3y, pred3_width, pred3_height)) //check if click in left button
      {
          String[] a = predictions(currentWord, 9);
          if (a.length > 2 && a[2] != null)
            currentTyped+=a[2].substring(currentWord.length(), a[2].length());
          //currentLetter='_';
          currentWord = currentWord + " ";
          currentTyped+=" ";
      }
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


String[] predictions(String word, int num){
  String[] empty = new String[1];
  empty[0] = "";
  String[] answer = new String[10];
  //String[] actual_answer = new String[10];
  int index = 0;
  
  for (int i = 0; i < 1000; i ++) // fine! hard code it
  {
    println("I got here");
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

// oh my goddddddddd
String[] common_words = {
"the",
"of",
"to",
"and",
"a",
"in",
"is",
"it",
"you",
"that",
"he",
"was",
"for",
"on",
"are",
"with",
"as",
"I",
"his",
"they",
"be",
"at",
"one",
"have",
"this",
"from",
"or",
"had",
"by",
"hot",
"word",
"but",
"what",
"some",
"we",
"can",
"out",
"other",
"were",
"all",
"there",
"when",
"up",
"use",
"your",
"how",
"said",
"an",
"each",
"she",
"which",
"do",
"their",
"time",
"if",
"will",
"way",
"about",
"many",
"then",
"them",
"write",
"would",
"like",
"so",
"these",
"her",
"long",
"make",
"thing",
"see",
"him",
"two",
"has",
"look",
"more",
"day",
"could",
"go",
"come",
"did",
"number",
"sound",
"no",
"most",
"people",
"my",
"over",
"know",
"water",
"than",
"call",
"first",
"who",
"may",
"down",
"side",
"been",
"now",
"find",
"any",
"new",
"work",
"part",
"take",
"get",
"place",
"made",
"live",
"where",
"after",
"back",
"little",
"only",
"round",
"man",
"year",
"came",
"show",
"every",
"good",
"me",
"give",
"our",
"under",
"name",
"very",
"through",
"just",
"form",
"sentence",
"great",
"think",
"say",
"help",
"low",
"line",
"differ",
"turn",
"cause",
"much",
"mean",
"before",
"move",
"right",
"boy",
"old",
"too",
"same",
"tell",
"does",
"set",
"three",
"want",
"air",
"well",
"also",
"play",
"small",
"end",
"put",
"home",
"read",
"hand",
"port",
"large",
"spell",
"add",
"even",
"land",
"here",
"must",
"big",
"high",
"such",
"follow",
"act",
"why",
"ask",
"men",
"change",
"went",
"light",
"kind",
"off",
"need",
"house",
"picture",
"try",
"us",
"again",
"animal",
"point",
"mother",
"world",
"near",
"build",
"self",
"earth",
"father",
"head",
"stand",
"own",
"page",
"should",
"country",
"found",
"answer",
"school",
"grow",
"study",
"still",
"learn",
"plant",
"cover",
"food",
"sun",
"four",
"between",
"state",
"keep",
"eye",
"never",
"last",
"let",
"thought",
"city",
"tree",
"cross",
"farm",
"hard",
"start",
"might",
"story",
"saw",
"far",
"sea",
"draw",
"left",
"late",
"run",
"don't",
"while",
"press",
"close",
"night",
"real",
"life",
"few",
"north",
"open",
"seem",
"together",
"next",
"white",
"children",
"begin",
"got",
"walk",
"example",
"ease",
"paper",
"group",
"always",
"music",
"those",
"both",
"mark",
"often",
"letter",
"until",
"mile",
"river",
"car",
"feet",
"care",
"second",
"book",
"carry",
"took",
"science",
"eat",
"room",
"friend",
"began",
"idea",
"fish",
"mountain",
"stop",
"once",
"base",
"hear",
"horse",
"cut",
"sure",
"watch",
"color",
"face",
"wood",
"main",
"enough",
"plain",
"girl",
"usual",
"young",
"ready",
"above",
"ever",
"red",
"list",
"though",
"feel",
"talk",
"bird",
"soon",
"body",
"dog",
"family",
"direct",
"pose",
"leave",
"song",
"measure",
"door",
"product",
"black",
"short",
"numeral",
"class",
"wind",
"question",
"happen",
"complete",
"ship",
"area",
"half",
"rock",
"order",
"fire",
"south",
"problem",
"piece",
"told",
"knew",
"pass",
"since",
"top",
"whole",
"king",
"space",
"heard",
"best",
"hour",
"better",
"true",
"during",
"hundred",
"five",
"remember",
"step",
"early",
"hold",
"west",
"ground",
"interest",
"reach",
"fast",
"verb",
"sing",
"listen",
"six",
"table",
"travel",
"less",
"morning",
"ten",
"simple",
"several",
"vowel",
"toward",
"war",
"lay",
"against",
"pattern",
"slow",
"center",
"love",
"person",
"money",
"serve",
"appear",
"road",
"map",
"rain",
"rule",
"govern",
"pull",
"cold",
"notice",
"voice",
"unit",
"power",
"town",
"fine",
"certain",
"fly",
"fall",
"lead",
"cry",
"dark",
"machine",
"note",
"wait",
"plan",
"figure",
"star",
"box",
"noun",
"field",
"rest",
"correct",
"able",
"pound",
"done",
"beauty",
"drive",
"stood",
"contain",
"front",
"teach",
"week",
"final",
"gave",
"green",
"oh",
"quick",
"develop",
"ocean",
"warm",
"free",
"minute",
"strong",
"special",
"mind",
"behind",
"clear",
"tail",
"produce",
"fact",
"street",
"inch",
"multiply",
"nothing",
"course",
"stay",
"wheel",
"full",
"force",
"blue",
"object",
"decide",
"surface",
"deep",
"moon",
"island",
"foot",
"system",
"busy",
"test",
"record",
"boat",
"common",
"gold",
"possible",
"plane",
"stead",
"dry",
"wonder",
"laugh",
"thousand",
"ago",
"ran",
"check",
"game",
"shape",
"equate",
"hot",
"miss",
"brought",
"heat",
"snow",
"tire",
"bring",
"yes",
"distant",
"fill",
"east",
"paint",
"language",
"among",
"grand",
"ball",
"yet",
"wave",
"drop",
"heart",
"am",
"present",
"heavy",
"dance",
"engine",
"position",
"arm",
"wide",
"sail",
"material",
"size",
"vary",
"settle",
"speak",
"weight",
"general",
"ice",
"matter",
"circle",
"pair",
"include",
"divide",
"syllable",
"felt",
"perhaps",
"pick",
"sudden",
"count",
"square",
"reason",
"length",
"represent",
"art",
"subject",
"region",
"energy",
"hunt",
"probable",
"bed",
"brother",
"egg",
"ride",
"cell",
"believe",
"fraction",
"forest",
"sit",
"race",
"window",
"store",
"summer",
"train",
"sleep",
"prove",
"lone",
"leg",
"exercise",
"wall",
"catch",
"mount",
"wish",
"sky",
"board",
"joy",
"winter",
"sat",
"written",
"wild",
"instrument",
"kept",
"glass",
"grass",
"cow",
"job",
"edge",
"sign",
"visit",
"past",
"soft",
"fun",
"bright",
"gas",
"weather",
"month",
"million",
"bear",
"finish",
"happy",
"hope",
"flower",
"clothe",
"strange",
"gone",
"jump",
"baby",
"eight",
"village",
"meet",
"root",
"buy",
"raise",
"solve",
"metal",
"whether",
"push",
"seven",
"paragraph",
"third",
"shall",
"held",
"hair",
"describe",
"cook",
"floor",
"either",
"result",
"burn",
"hill",
"safe",
"cat",
"century",
"consider",
"type",
"law",
"bit",
"coast",
"copy",
"phrase",
"silent",
"tall",
"sand",
"soil",
"roll",
"temperature",
"finger",
"industry",
"value",
"fight",
"lie",
"beat",
"excite",
"natural",
"view",
"sense",
"ear",
"else",
"quite",
"broke",
"case",
"middle",
"kill",
"son",
"lake",
"moment",
"scale",
"loud",
"spring",
"observe",
"child",
"straight",
"consonant",
"nation",
"dictionary",
"milk",
"speed",
"method",
"organ",
"pay",
"age",
"section",
"dress",
"cloud",
"surprise",
"quiet",
"stone",
"tiny",
"climb",
"cool",
"design",
"poor",
"lot",
"experiment",
"bottom",
"key",
"iron",
"single",
"stick",
"flat",
"twenty",
"skin",
"smile",
"crease",
"hole",
"trade",
"melody",
"trip",
"office",
"receive",
"row",
"mouth",
"exact",
"symbol",
"die",
"least",
"trouble",
"shout",
"except",
"wrote",
"seed",
"tone",
"join",
"suggest",
"clean",
"break",
"lady",
"yard",
"rise",
"bad",
"blow",
"oil",
"blood",
"touch",
"grew",
"cent",
"mix",
"team",
"wire",
"cost",
"lost",
"brown",
"wear",
"garden",
"equal",
"sent",
"choose",
"fell",
"fit",
"flow",
"fair",
"bank",
"collect",
"save",
"control",
"decimal",
"gentle",
"woman",
"captain",
"practice",
"separate",
"difficult",
"doctor",
"please",
"protect",
"noon",
"whose",
"locate",
"ring",
"character",
"insect",
"caught",
"period",
"indicate",
"radio",
"spoke",
"atom",
"human",
"history",
"effect",
"electric",
"expect",
"crop",
"modern",
"element",
"hit",
"student",
"corner",
"party",
"supply",
"bone",
"rail",
"imagine",
"provide",
"agree",
"thus",
"capital",
"won't",
"chair",
"danger",
"fruit",
"rich",
"thick",
"soldier",
"process",
"operate",
"guess",
"necessary",
"sharp",
"wing",
"create",
"neighbor",
"wash",
"bat",
"rather",
"crowd",
"corn",
"compare",
"poem",
"string",
"bell",
"depend",
"meat",
"rub",
"tube",
"famous",
"dollar",
"stream",
"fear",
"sight",
"thin",
"triangle",
"planet",
"hurry",
"chief",
"colony",
"clock",
"mine",
"tie",
"enter",
"major",
"fresh",
"search",
"send",
"yellow",
"gun",
"allow",
"print",
"dead",
"spot",
"desert",
"suit",
"current",
"lift",
"rose",
"continue",
"block",
"chart",
"hat",
"sell",
"success",
"company",
"subtract",
"event",
"particular",
"deal",
"swim",
"term",
"opposite",
"wife",
"shoe",
"shoulder",
"spread",
"arrange",
"camp",
"invent",
"cotton",
"born",
"determine",
"quart",
"nine",
"truck",
"noise",
"level",
"chance",
"gather",
"shop",
"stretch",
"throw",
"shine",
"property",
"column",
"molecule",
"select",
"wrong",
"gray",
"repeat",
"require",
"broad",
"prepare",
"salt",
"nose",
"plural",
"anger",
"claim",
"continent",
"oxygen",
"sugar",
"death",
"pretty",
"skill",
"women",
"season",
"solution",
"magnet",
"silver",
"thank",
"branch",
"match",
"suffix",
"especially",
"fig",
"afraid",
"huge",
"sister",
"steel",
"discuss",
"forward",
"similar",
"guide",
"experience",
"score",
"apple",
"bought",
"led",
"pitch",
"coat",
"mass",
"card",
"band",
"rope",
"slip",
"win",
"dream",
"evening",
"condition",
"feed",
"tool",
"total",
"basic",
"smell",
"valley",
"nor",
"double",
"seat",
"arrive",
"master",
"track",
"parent",
"shore",
"division",
"sheet",
"substance",
"favor",
"connect",
"post",
"spend",
"chord",
"fat",
"glad",
"original",
"share",
"station",
"dad",
"bread",
"charge",
"proper",
"bar",
"offer",
"segment",
"slave",
"duck",
"instant",
"market",
"degree",
"populate",
"chick",
"dear",
"enemy",
"reply",
"drink",
"occur",
"support",
"speech",
"nature",
"range",
"steam",
"motion",
"path",
"liquid",
"log",
"meant",
"quotient",
"teeth",
"shell",
"neck"
};
