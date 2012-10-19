import com.jme3.app.Application;
import com.jme3.app.SimpleApplication;
import com.jme3.app.state.AbstractAppState;
import com.jme3.app.state.AppStateManager;
import de.lessvoid.nifty.Nifty;
import de.lessvoid.nifty.screen.Screen;
import de.lessvoid.nifty.screen.ScreenController;
 
public class StartScreenController extends AbstractAppState implements ScreenController {
 
  private Nifty nifty;
  private Screen screen;
  private SimpleApplication app;
 
  /** custom methods */ 
 
  public StartScreenController(Application app) { 
    /** You custom constructor, can accept arguments */
    this.app = (SimpleApplication) app;
  } 
 
  /** Nifty GUI ScreenControl methods */ 
 
  public void bind(Nifty nifty, Screen screen) {
    this.nifty = nifty;
    this.screen = screen;
  }
 
  public void onStartScreen() { }
 
  public void onEndScreen() { }
 
  /** jME3 AppState methods */ 
 
  @Override
  public void initialize(AppStateManager stateManager, Application app) {
    super.initialize(stateManager, app);
  }
 
  @Override
  public void update(float tpf) { 
    /** jME update loop! */ 
  }
  
  public void startGame(String nextScreen) {
    System.out.println("\n\n startGame called\n\n");
    nifty.gotoScreen(nextScreen);  // switch to another screen
    // start the game and do some more stuff...
  }

  public void quitGame() {
    System.out.println("\n\n quitGame called\n\n");
    app.stop();
    // TODO:
    // find app instance variable @controller_path and delete that file.
  }
 
}