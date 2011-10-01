java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.asset.plugins.ZipLocator"
java_import "com.jme3.bullet.BulletAppState"
java_import "com.jme3.bullet.collision.shapes.CapsuleCollisionShape"
java_import "com.jme3.bullet.collision.shapes.CollisionShape"
java_import "com.jme3.bullet.control.CharacterControl"
java_import "com.jme3.bullet.control.RigidBodyControl"
java_import "com.jme3.bullet.util.CollisionShapeFactory"
java_import "com.jme3.input.KeyInput"
java_import "com.jme3.input.controls.ActionListener"
java_import "com.jme3.input.controls.KeyTrigger"
java_import "com.jme3.light.AmbientLight"
java_import "com.jme3.light.DirectionalLight"
java_import "com.jme3.math.ColorRGBA"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.scene.Node"
java_import "com.jme3.scene.Spatial"

class Sample8 < SimpleApplication
  include ActionListener
  
  field_reader :cam
  field_accessor :flyCam
  attr_accessor :scene_model, :bullet_app_state, :landscape, :player
  
  def initialize
    @walk_direction = Vector3f.new
    @left = false
    @right = false
    @up = false
    @down = false
  end
  
  def simpleInitApp
    self.bullet_app_state = BulletAppState.new
    state_manager.attach(bullet_app_state)
    view_port.background_color = ColorRGBA.new(0.7, 0.8, 1.0, 1.0)
    flyCam.move_speed = 100
    asset_manager.register_locator(File.join("assets", "town.zip"), ZipLocator.java_class.name)
    self.scene_model = asset_manager.load_model("main.scene")
    scene_model.local_scale = 2.0
    scene_shape = CollisionShapeFactory.create_mesh_shape(scene_model)
    self.landscape = RigidBodyControl.new(scene_shape, 0)
    scene_model.add_control(landscape)
    capsule_shape = CapsuleCollisionShape.new(1.5, 6.0, 1)
    self.player = CharacterControl.new(capsule_shape, 0.05)
    player.jump_speed = 20
    player.fall_speed = 30
    player.gravity = 30
    player.physics_location = Vector3f.new(0, 10, 0)
    root_node.attach_child(scene_model)
    bullet_app_state.physics_space.add(landscape)
    bullet_app_state.physics_space.add(player)
    bullet_app_state.physics_space.enable_debug(asset_manager)
    setup_keys!
    setup_light!
  end
  
  def setup_keys!
    input_manager.add_mapping("Left",  KeyTrigger.new(KeyInput::KEY_A))
    input_manager.add_mapping("Right", KeyTrigger.new(KeyInput::KEY_D))
    input_manager.add_mapping("Up",    KeyTrigger.new(KeyInput::KEY_W))
    input_manager.add_mapping("Down",  KeyTrigger.new(KeyInput::KEY_S))
    input_manager.add_mapping("Jump",  KeyTrigger.new(KeyInput::KEY_SPACE))
    input_manager.add_listener(ControllerAction.new(self), "Left")
    input_manager.add_listener(ControllerAction.new(self), "Right")
    input_manager.add_listener(ControllerAction.new(self), "Up")
    input_manager.add_listener(ControllerAction.new(self), "Down")
    input_manager.add_listener(ControllerAction.new(self), "Jump")
  end
  
  def setup_light!
    al = AmbientLight.new
    al.color = ColorRGBA::White.mult(1.3)
    root_node.add_light(al)
    dl = DirectionalLight.new
    dl.color = ColorRGBA::White
    dl.direction = Vector3f.new(2.8, -2.8, -2.8).normalize_local
    root_node.add_light(dl)
  end
  
  def simpleUpdate(tpf)
    cam_dir = cam.direction.clone.mult_local(0.6)
    cam_left = cam.left.clone.mult_local(0.4)
    @walk_direction.set(0, 0, 0)
    @walk_direction.add_local(cam_left) if @left
    @walk_direction.add_local(cam_left.negate) if @right
    @walk_direction.add_local(cam_dir) if @up
    @walk_direction.add_local(cam_dir.negate) if @down
    player.walk_direction = @walk_direction
    cam.location = player.physics_location
  end
  
  class ControllerAction
    include ActionListener
    
    def initialize(obj)
      @parent = obj
    end
    
    def on_action(binding, value, tpf)
      if binding == "Jump"
        @parent.player.jump
      else
        @parent.instance_variable_set("@#{binding.downcase}", value)
      end
    end
    
  end
    
end