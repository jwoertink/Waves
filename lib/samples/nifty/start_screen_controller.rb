java_import "com.jme3.app.Application"
java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.app.state.AbstractAppState"
java_import "com.jme3.app.state.AppStateManager"
java_import "de.lessvoid.nifty.Nifty"
java_import "de.lessvoid.nifty.screen.Screen"
java_import "de.lessvoid.nifty.screen.ScreenController"

class StartScreenController < AbstractAppState
  include ScreenController
  
  attr_accessor :nifty, :screen, :app
  
  def initialize(data = "")
    
  end
  
  def bind(nifty, screen)
    self.nifty = nifty
    self.screen = screen
  end
  
  def on_start_screen
    
  end
  
  def on_end_screen
    
  end
  
  # How do I do this?!
  def app_initialize(state_manager, app)
    super.initialize(state_manager, app)
    self.app = app
  end
  
  def update(tpf)
    # jme update loop
  end
  
end