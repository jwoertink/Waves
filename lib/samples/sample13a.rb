=begin
  Sample using Nifty the "JRuby" way.
=end

java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.niftygui.NiftyJmeDisplay"
java_import "de.lessvoid.nifty.Nifty"
java_import "de.lessvoid.nifty.builder.ScreenBuilder"
java_import "de.lessvoid.nifty.builder.LayerBuilder"
java_import "de.lessvoid.nifty.builder.PanelBuilder"
java_import "de.lessvoid.nifty.controls.button.builder.ButtonBuilder"
java_import "de.lessvoid.nifty.screen.DefaultScreenController"

 
class Sample13a < SimpleApplication
 field_accessor :flyCam
  
  def simpleInitApp()
    niftyDisplay = NiftyJmeDisplay.new(assetManager, inputManager, audioRenderer, guiViewPort)
    nifty = niftyDisplay.getNifty
    guiViewPort.addProcessor(niftyDisplay)
    flyCam.setDragToRotate(true)
 
    nifty.loadStyleFile("nifty-default-styles.xml")
    nifty.loadControlFile("nifty-default-controls.xml")
    
    screen_builder = MyScreenBuilder.new("Hello Nifty Screen")
    screen_builder.controller(DefaultScreenController.new)
    screen_builder.layer(MyLayerBuilder.new("Layer_ID"))
    
    nifty.addScreen("Screen_ID", screen_builder.build(nifty))
    nifty.gotoScreen("Screen_ID")
  end
end

class MyScreenBuilder < ScreenBuilder
  
end

class MyLayerBuilder < LayerBuilder
  
  def initialize(id)
    super
    childLayoutVertical
    panel(MyPanelBuilder.new("Panel_ID"))
  end
  
end

class MyPanelBuilder < PanelBuilder
  
  def initialize(id)
    super
    childLayoutCenter
    control(MyButtonBuilder.new("Button_ID", "Hello Nifty"))
  end
  
end

class MyButtonBuilder < ButtonBuilder
  
  def initialize(id, text)
    super
    alignCenter
    valignCenter
    height("5%")
    width("15%")
  end
  
end