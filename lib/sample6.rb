java_import "com.jme3.animation.AnimChannel"
java_import "com.jme3.animation.AnimControl"
java_import "com.jme3.animation.AnimEventListener"
java_import "com.jme3.animation.LoopMode"
java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.input.KeyInput"
java_import "com.jme3.input.controls.ActionListener"
java_import "com.jme3.input.controls.KeyTrigger"
java_import "com.jme3.light.DirectionalLight"
java_import "com.jme3.math.ColorRGBA"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.scene.Node"
java_import "com.jme3.scene.debug.SkeletonDebugger"
java_import "com.jme3.material.Material"

class Sample6 < SimpleApplication
  include AnimEventListener
  
  attr_accessor :channel, :control
  
  def initialize
    @player = nil
  end
  
  # This method has to be camelCase ... No clue why.
  def simpleInitApp
    view_port.background_color = ColorRGBA::LightGray
    dl = DirectionalLight.new
    dl.direction = Vector3f.new(-0.1, -1.0, -1).normalize_local
    root_node.add_light(dl)
    @player = asset_manager.load_model(File.join("Models", "Oto", "Oto.mesh.xml"))
    @player.local_scale = 0.5
    root_node.attach_child(@player)
    self.control = @player.get_control(AnimControl.java_class)
    control.add_listener(self)
    self.channel = control.create_channel
    channel.anim = "stand"
    
    skeleton_debug = SkeletonDebugger.new("skeleton", control.skeleton)
    mat = Material.new(asset_manager, "Common/MatDefs/Misc/Unshaded.j3md")
    mat.set_color("Color", ColorRGBA::Green)
    mat.additional_render_state.depth_test = false
    skeleton_debug.material = mat
    @player.attach_child(skeleton_debug)
    init_keys!
  end
  
  def onAnimCycleDone(control, channel, anim_name)
    if anim_name.eql?("Walk")
      channel.set_anim("stand", 0.50)
      channel.loop_mode = LoopMode::DontLoop
      channel.speed = 1.0
    end
  end
  
  def onAnimChange(control, channel, anim_name)
    puts "\n\nControl: #{control}"
    puts "Channel: #{channel}"
    puts "AnimName: #{anim_name}\n\n"
  end
  
  def init_keys!
    input_manager.add_mapping("Walk", KeyTrigger.new(KeyInput::KEY_SPACE))
    input_manager.add_listener(ControllerAction.new(self), "Walk")
  end
  
  class ControllerAction
    include ActionListener
    
    def initialize(obj)
      @parent = obj
    end
    
    def on_action(name, key_pressed, time_per_frame)
      if name.eql?("Walk") && !key_pressed
        if !@parent.channel.animation_name.eql?("Walk")
          @parent.channel.set_anim("Walk", 0.50)
          @parent.channel.loop_mode = LoopMode::Loop
        end
      end
    end
    
  end

end