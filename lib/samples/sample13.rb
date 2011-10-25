=begin
  Sample using NiftyGui with XML
=end
java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.niftygui.NiftyJmeDisplay"
java_import "de.lessvoid.nifty.Nifty"
java_import "de.lessvoid.nifty.screen.Screen"
java_import "de.lessvoid.nifty.screen.ScreenController"

class Sample13 < SimpleApplication
  
  field_accessor :flyCam
  
  def initialize
    @game_state = 0
  end
  
  def simpleInitApp
    if @game_state.zero?
      load_start_screen
    end
    
  end
  
  def load_start_screen
    nifty_display = NiftyJmeDisplay.new(asset_manager, input_manager, audio_renderer, gui_view_port)
    nifty = nifty_display.nifty
    nifty.from_xml(File.join("assets", "Interface", "screen.xml"), "start")
    
    gui_view_port.add_processor(nifty_display)
    #flyCam.enabled = false
    flyCam.drag_to_rotate = true
  end
  
end