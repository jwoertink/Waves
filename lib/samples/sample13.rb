=begin
  Sample using NiftyGui
=end
java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.math.ColorRGBA"
java_import "com.jme3.niftygui.NiftyJmeDisplay"
java_import "de.lessvoid.nifty.Nifty"
java_import "de.lessvoid.nifty.builder.ScreenBuilder"
java_import "de.lessvoid.nifty.builder.LayerBuilder"
java_import "de.lessvoid.nifty.builder.PanelBuilder"
java_import "de.lessvoid.nifty.controls.button.builder.ButtonBuilder"
java_import "de.lessvoid.nifty.screen.DefaultScreenController"

class Sample13 < SimpleApplication
  
  field_accessor :flyCam
  
  def simpleInitApp
    view_port.background_color = ColorRGBA.new(0.7, 0.8, 1.0, 1.0)
    nifty_display = NiftyJmeDisplay.new(asset_manager, input_manager, audio_renderer, gui_view_port)
    nifty = nifty_display.nifty
    gui_view_port.add_processor(nifty_display)
    flyCam.drag_to_rotate = true
    nifty.load_style_file("nifty-default-styles.xml")
    nifty.load_control_file("nifty-default-controls.xml")
    
    
    
    nifty.addScreen("Screen_ID", ScreenBuilder.new("Hello Nifty Screen") {
      controller(DefaultScreenController.new)
      layer(LayerBuilder.new("Layer_ID") {
        childLayoutVertical
        panel(PanelBuilder.new("Panel_ID") {
          childLayoutCenter
          control(ButtonBuilder.new("Button_ID", "Hello Nifty") {
            alignCenter
            valignCenter
            height("5%")
            width("15%")
          })
        })
      })
    }.build(nifty))
    nifty.goto_screen("Screen_ID")
  end
  
end