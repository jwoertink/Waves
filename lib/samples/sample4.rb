=begin
  This shows a normal blue box with fire coming out of the top. The camera can be moved like normal,
  but in this sample, the box can be moved left with "J" and right with "K" and rotated with space. 
  It also shows an example of a custom load screen by editing the settings.
=end


java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.system.AppSettings"
java_import "com.jme3.material.Material"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.scene.Geometry"
java_import "com.jme3.scene.shape.Box"
java_import "com.jme3.math.ColorRGBA"
java_import "com.jme3.input.KeyInput"
java_import "com.jme3.input.MouseInput"
java_import "com.jme3.input.controls.ActionListener"
java_import "com.jme3.input.controls.AnalogListener"
java_import "com.jme3.input.controls.KeyTrigger"
java_import "com.jme3.input.controls.MouseButtonTrigger"
java_import "com.jme3.effect.ParticleEmitter"
java_import "com.jme3.effect.ParticleMesh"

class Sample4 < SimpleApplication
  field_accessor :speed, :paused
  field_reader :settings
  
  class << self
    attr_accessor :running
  end
  
  def initialize
    super #must call super for the settings to run. it's a JRuby thing
    $player = nil # Use a global player object so it's accessible to the ControllerAnalog
    self.class.running = true
    config = AppSettings.new(true)
    config.settings_dialog_image = File.join("assets", "Interface", "maze_craze_logo.png")
    self.settings = config
    self.show_settings = true
  end
  
  def simpleInitApp
    b = Box.new(Vector3f::ZERO, 1, 1, 1)
    $player = Geometry.new("Player", b)
    mat = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    mat.set_color("Color", ColorRGBA::Blue)
    $player.material = mat
    root_node.attach_child($player)
    fire = ParticleEmitter.new("Emitter", ParticleMesh::Type::Triangle, 30)
    mat_red = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Particle.j3md"))
    mat_red.set_texture("Texture", asset_manager.load_texture(File.join("Effects", "Explosion", "flame.png")))
    fire.material = mat_red
    fire.images_x = 2
    fire.images_y = 2
    fire.end_color = ColorRGBA.new(1.0, 0.0, 0.0, 1.0)
    fire.start_color = ColorRGBA.new(1.0, 1.0, 0.0, 0.5)
    fire.particle_influencer.initial_velocity = Vector3f.new(0, 2, 0)
    fire.start_size = 0.6
    fire.end_size = 0.1
    fire.set_gravity(0, 0, 0)
    fire.low_life = 0.5
    fire.high_life = 3.0
    fire.velocity_variation = 0.3
    fire
    root_node.attach_child(fire)
    initKeys
  end
  
  def initKeys
    input_manager.add_mapping("Pause", KeyTrigger.new(KeyInput::KEY_P))
    input_manager.add_mapping("Left", KeyTrigger.new(KeyInput::KEY_J))
    input_manager.add_mapping("Right", KeyTrigger.new(KeyInput::KEY_K))
    input_manager.add_mapping("Rotate", KeyTrigger.new(KeyInput::KEY_SPACE), MouseButtonTrigger.new(MouseInput::BUTTON_LEFT))
    
    input_manager.add_listener(ControllerAction.new(self), ["Pause"].to_java(:string))
    input_manager.add_listener(ControllerAnalog.new(self), ["Left", "Right", "Rotate"].to_java(:string))
  end
  
  class ControllerAction
    include ActionListener
    
    def initialize(parent)
      @parent = parent
    end
    
    def on_action(name, key_pressed, time_per_frame)
      if name.eql?("Pause") && !key_pressed
        Sample4.running = !Sample4.running
      end
    end
  end
  
  class ControllerAnalog  
    include AnalogListener
    
    def initialize(parent)
      @parent = parent
    end
    
    def on_analog(name, value, time_per_frame)
      if Sample4.running
        case name
        when "Rotate"
          $player.rotate(0, value * @parent.speed, 0)
        when "Right"
          v = $player.local_translation
          $player.set_local_translation(v.x + value * @parent.speed, v.y, v.z)
        when "Left"
          v = $player.local_translation
          $player.set_local_translation(v.x - value * @parent.speed, v.y, v.z)
        else
          puts "Press P to unpause."
        end
      end
    end
  end
          
end
