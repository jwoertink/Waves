=begin
  Sample using NiftyGui with XML and erb templating
=end
java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.niftygui.NiftyJmeDisplay"
java_import "de.lessvoid.nifty.Nifty"
java_import "de.lessvoid.nifty.screen.Screen"
java_import "de.lessvoid.nifty.screen.ScreenController"
java_import "java.util.logging.Level"
java_import "java.util.logging.Logger"
java_import "StartScreenController"

require 'erb'
require 'pathname'

class Sample13 < SimpleApplication
  field_accessor :flyCam
  
  def initialize
    Logger.get_logger("").level = Level::WARNING
    @game_state = 0
  end
  
  def simpleInitApp
    if @game_state.zero?
      load_start_screen
    end
    
  end
  
  def load_start_screen
    flyCam.drag_to_rotate = true
    nifty_display = NiftyJmeDisplay.new(asset_manager, input_manager, audio_renderer, gui_view_port)
    nifty = nifty_display.nifty
    controller = StartScreenController.new(self)
    screen_controller = "StartScreenController"
    player_name = "Jeremy"
    xml_result = ERB.new(IO.read(File.join(PROJECT_ROOT, 'assets', 'Interface', 'screen.xml.erb'))).result(binding)
    @controller_path = File.open(File.join(PROJECT_ROOT, 'assets', 'Interface', "screen-#{Time.now.strftime("%s")}.xml"), 'w+') do |f|
      f.write(xml_result)
      f.path
    end
    
    nifty.from_xml(@controller_path[@controller_path.index("assets/"), @controller_path.size], "start", controller)
    gui_view_port.add_processor(nifty_display)
  end
  
end