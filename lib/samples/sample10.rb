=begin
  This is the sound sample. You should hear ambient background noise.
  Clicking left mouse button will cause a gunshot to fire.
=end

java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.audio.AudioNode"
java_import "com.jme3.input.controls.ActionListener"
java_import "com.jme3.input.controls.MouseButtonTrigger"
java_import "com.jme3.material.Material"
java_import "com.jme3.math.ColorRGBA"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.scene.Geometry"
java_import "com.jme3.scene.shape.Box"

class Sample10 < SimpleApplication
  field_accessor :flyCam
  field_reader :cam
  attr_accessor :audio_gun, :audio_nature, :player
  
  def initialize
    
  end
  
  def simpleInitApp
    flyCam.move_speed = 40
    
    box1 = Box.new(Vector3f::ZERO, 1, 1, 1)
    player = Geometry.new("Player", box1)
    matl = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    player.material = matl
    root_node.attach_child(player)
    
    init_keys!
    init_audio!
  end
  
  def init_keys!
    input_manager.add_mapping("Shoot", MouseButtonTrigger.new(0))
    input_manager.add_listener(ControllerAction.new(self), "Shoot")
  end
  
  def init_audio!
    self.audio_gun = AudioNode.new(asset_manager, File.join("Sound", "Effects", "Gun.wav"), false)
    audio_gun.looping = false
    audio_gun.volume = 2
    root_node.attach_child(audio_gun)
    
    self.audio_nature = AudioNode.new(asset_manager, File.join("Sound", "Environment", "Nature.ogg"), false)
    audio_nature.looping = true
    audio_nature.positional = true
    audio_nature.local_translation = Vector3f::ZERO.clone
    audio_nature.volume = 3
    root_node.attach_child(audio_nature)
    audio_nature.play
  end
  
  def simpleUpdate(tpf)
    listener.location = cam.location
    listener.rotation = cam.rotation
  end
  
  class ControllerAction
    include ActionListener
    
    def initialize(obj)
      @parent = obj
    end
    
    def on_action(name, key_pressed, tpf)
      if name.eql?("Shoot") && !key_pressed
        @parent.audio_gun.play_instance
      end
    end
    
  end
  
end