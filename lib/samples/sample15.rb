=begin
  This example shows how to create a small body of water
  Also implements adding in small structures
=end
java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.asset.plugins.HttpZipLocator"
java_import "com.jme3.asset.plugins.ZipLocator"
java_import "com.jme3.input.controls.ActionListener"
java_import "com.jme3.input.controls.KeyTrigger"
java_import "com.jme3.input.KeyInput"
java_import "com.jme3.light.DirectionalLight"
java_import "com.jme3.math.ColorRGBA"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.post.FilterPostProcessor"
java_import "com.jme3.scene.Spatial"
java_import "com.jme3.util.SkyFactory"
java_import "com.jme3.water.WaterFilter"

class Sample15 < SimpleApplication
  include ActionListener
  field_accessor :flyCam
  field_reader :cam
  
  def simpleInitApp
    flyCam.move_speed = 10
    cam.set_location(Vector3f.new(-27.0, 1.0, 75.0))
    root_node.attach_child(SkyFactory.create_sky(asset_manager, File.join("Textures", "Sky", "Bright", "BrightSky.dds"), false))
    asset_manager.register_locator(File.join('assets', 'wildhouse.zip'), ZipLocator.java_class.name)
    scene = asset_manager.load_model("main.scene")
    root_node.attach_child(scene)
    
    sun = DirectionalLight.new
    lightdir = Vector3f.new(-0.37352666, -0.50444174, -0.7784704)
    sun.direction = lightdir
    sun.color = ColorRGBA::White.clone.mult_local(2)
    scene.add_light(sun)
    
    fpp = FilterPostProcessor.new(asset_manager)
    water = WaterFilter.new(root_node, lightdir)
    water.water_height = -20
    water.use_foam = false
    water.use_ripples = false
    water.deep_water_color = ColorRGBA::Brown
    water.water_color = ColorRGBA::Brown.mult(2.0)
    water.water_transparency = 0.2
    water.max_amplitude = 0.3
    water.wave_scale = 0.008
    water.speed = 0.7
    water.shore_hardness = 1.0
    water.refraction_constant = 0.2
    water.shininess = 0.3
    water.sun_scale = 1.0
    water.color_extinction = Vector3f.new(10.0, 20.0, 30.0)
    fpp.add_filter(water)
    view_port.add_processor(fpp)
    input_manager.add_listener(ControllerAction.new(self), "HQ")
    input_manager.add_mapping("HQ", KeyTrigger.new(KeyInput::KEY_SPACE))
  end
  
  def simpleUpdate(tpf)
  end
  
  class ControllerAction
    include ActionListener
    
    def initialize(obj)
      @parent = obj
    end
    
    def on_action(name, key_pressed, time_per_frame)
      if key_pressed
        if @parent.water.use_h_q_shoreline?
          @parent.water.use_h_q_shoreline = false
        else
          @parent.water.use_h_q_shoreline = true
        end
      end
    end
    
  end
  
end