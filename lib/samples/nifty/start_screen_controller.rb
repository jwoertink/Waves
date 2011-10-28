java_import "com.jme3.app.Application"
java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.app.state.AbstractAppState"
java_import "com.jme3.app.state.AppStateManager"
java_import "de.lessvoid.nifty.Nifty"
java_import "de.lessvoid.nifty.screen.Screen"
java_import "de.lessvoid.nifty.screen.ScreenController"

class StartScreenController < AbstractAppState
  include ScreenController
  field_accessor :initialized
  
  # Java method not found: com.jme3.app.state.AbstractAppState.initialize()
  #java_alias :init_with, :initialize
  
  attr_accessor :nifty, :screen, :app
  
  def initialize
  end
  
  def init_with(data = {})
    #init = java_method(:initialize, [com.jme3.app.state.AppStateManager, com.jme3.app.SimpleApplication])
    #init.call(data[:state_manager], data[:app])
    @state_manager = data[:state_manager]
    self.app = data[:app]
    self.initialized = true
    return self # mocking a "initialize" method
  end
  
  def bind(nifty, screen)
    puts "\n\n BINDING \n\n"
    self.nifty = nifty
    self.screen = screen
  end
  
  def onStartScreen
    puts "\n\n on_start_screen called: #{initialized}\n\n"
  end
  
  def onEndScreen
    puts "\n\n on_end_screen called\n\n"
  end
  
  def update(tpf)
    puts "\n\n UPDATING\n\n"
    # jme update loop
  end
  
  def startGame(next_screen)
    puts "\n\n Called start for #{next_screen}\n\n"
    nifty.goto_screen(next_screen)
  end
  
  def quitGame()
    puts "\n\n Called quit\n\n"
    app.stop
  end
  
end