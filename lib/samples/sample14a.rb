=begin
  This is more advanced Rag Doll sample
=end
module ComJme3Animation
  include_package "com.jme3.animation"
end
#java_import "com.jme3.animation.*"
java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.asset.TextureKey"
java_import "com.jme3.bullet.BulletAppState"
java_import "com.jme3.bullet.PhysicsSpace"
java_import "com.jme3.bullet.collision.PhysicsCollisionEvent"
java_import "com.jme3.bullet.collision.PhysicsCollisionObject"
java_import "com.jme3.bullet.collision.RagdollCollisionListener"
java_import "com.jme3.bullet.collision.shapes.SphereCollisionShape"
java_import "com.jme3.bullet.control.KinematicRagdollControl"
java_import "com.jme3.bullet.control.RigidBodyControl"
java_import "com.jme3.font.BitmapText"
java_import "com.jme3.input.KeyInput"
java_import "com.jme3.input.MouseInput"
java_import "com.jme3.input.controls.ActionListener"
java_import "com.jme3.input.controls.KeyTrigger"
java_import "com.jme3.input.controls.MouseButtonTrigger"
java_import "com.jme3.light.DirectionalLight"
java_import "com.jme3.material.Material"
java_import "com.jme3.math.ColorRGBA"
java_import "com.jme3.math.FastMath"
java_import "com.jme3.math.Quaternion"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.scene.Geometry"
java_import "com.jme3.scene.Node"
java_import "com.jme3.scene.debug.SkeletonDebugger"
java_import "com.jme3.scene.shape.Sphere"
java_import "com.jme3.scene.shape.Sphere$TextureMode"
java_import "com.jme3.texture.Texture"

class Sample14a < SimpleApplication
  include RagdollCollisionListener
  include ComJme3Animation::AnimEventListener
  
  field_reader :cam, :settings
  field_accessor :flyCam
  
  attr_accessor :bullet_app_state, :mat_bullet, :model, :ragdoll, :bullet_size, :mat, :mat2, :bullet, :bullet_collision_shape, :anim_channel
  
  def initialize
    self.bullet_size = 1.0
    # float elTime = 0;
    # boolean forward = true;
    # AnimControl animControl;
    # AnimChannel animChannel;
    # Vector3f direction = new Vector3f(0, 0, 1);
    # Quaternion rotate = new Quaternion().fromAngleAxis(FastMath.PI / 8, Vector3f.UNIT_Y);
    # boolean dance = true;
  end
  
  def simpleInitApp
    init_cross_hairs
    init_material
    cam.location = Vector3f.new(0.26924422, 6.646658, 22.265987)
    # Note: -2.302544E-4 == -0.0002302544
    cam.rotation = Quaternion.new(-2.302544E-4, 0.99302495, -0.117888905, -0.0019395084)
    self.bullet_app_state = BulletAppState.new
    bullet_app_state.enabled = true
    state_manager.attach(bullet_app_state)
    
    self.bullet = Sphere.new(32, 32, 1.0, true, false)
    bullet.texture_mode = TextureMode::Projected
    self.bullet_collision_shape = SphereCollisionShape.new(1.0)
    
    init_world
    setup_light
    
    self.model = asset_manager.load_model("Models/Sinbad/Sinbad.mesh.xml")
    
    control = model.get_control(AnimControl.java_class)
    skeleton_debug = SkeletonDebugger.new("skeleton", control.skeleton)
    self.mat2 = Material.new(asset_manager, "Common/MatDefs/Misc/Unshaded.j3md")
    mat2.additional_render_state.wireframe = true
    mat2.set_color("Color", ColorRGBA::Green)
    mat2.additional_render_state.depth_test = false
    skeleton_debug.material = mat2
    skeleton_debug.local_translation = model.local_translation
    
    self.ragdoll = KinematicRagdollControl.new(0.5)
    setup_sinbad(ragdoll)
    ragdoll.add_collision_listener(self) # May need internal class here
    model.add_control(ragdoll)
    
    eighth_pi = FastMath::PI * 0.125
    ragdoll.set_joint_limit("Waist", eighth_pi, eighth_pi, eighth_pi, eighth_pi, eighth_pi, eighth_pi)
    ragdoll.set_joint_limit("Chest", eighth_pi, eighth_pi, 0, 0, eighth_pi, eighth_pi)
    
    bullet_app_state.physics_space.add(ragdoll)
    speed = 1.3
    
    root_node.attach_child(model)
    flyCam.move_speed = 50
    
    self.anim_channel = control.create_channel
    anim_channel.anim = "Dance"
    control.add_listener(self)
    input_manager.add_listener(ControllerAction.new(self), "toggle", "shoot", "stop", "bullet+", "bullet-", "boom")
    input_manager.add_mapping("toggle", KeyTrigger.new(KeyInput::KEY_SPACE))
    input_manager.add_mapping("shoot", MouseButtonTrigger.new(MouseInput::BUTTON_LEFT))
    input_manager.add_mapping("boom", MouseButtonTrigger.new(MouseInput::BUTTON_RIGHT))
    input_manager.add_mapping("stop", KeyTrigger.new(KeyInput::KEY_H))
    input_manager.add_mapping("bullet-", KeyTrigger.new(KeyInput::KEY_COMMA))
    input_manager.add_mapping("bullet+", KeyTrigger.new(KeyInput::KEY_PERIOD))
  end
  
  def init_cross_hairs
    gui_font = asset_manager.load_font("Interface/Fonts/Default.fnt")
    ch = BitmapText.new(gui_font, false)
    ch.size = gui_font.char_set.rendered_size * 2
    ch.text = "+"
    ch.set_local_translation(
      settings.width / 2 - gui_font.char_set.rendered_size / 3 * 2,
      settings.height / 2 + ch.line_height / 2, 0)
    gui_node.attach_child(ch)
  end
  
  def init_material
    self.mat_bullet = Material.new(asset_manager, "Common/MatDefs/Misc/Unshaded.j3md")
    key2 = TextureKey.new("Common/MatDefs/Misc/Unshaded.j3md")
    key2.generate_mips = true
    tex2 = asset_manager.load_texture(key2)
    mat_bullet.set_texture("ColorMap", text2)
  end
  
  def init_world
    
  end
  
  def setup_light
    dl = DirectionalLight.new
    dl.direction = Vector3f.new(-0.1, -0.7, -1).normalize_local
    dl.color = ColorRGBA.new(1.0, 1.0, 1.0, 1.0)
    root_node.add_light(dl)
  end
  
  def setup_sinbad(sinbad)
    sinbad.add_bone_name("Ulna.L")
    sinbad.add_bone_name("Ulna.R")
    sinbad.add_bone_name("Chest")
    sinbad.add_bone_name("Foot.L")
    sinbad.add_bone_name("Foot.R")
    sinbad.add_bone_name("Hand.R")
    sinbad.add_bone_name("Hand.L")
    sinbad.add_bone_name("Neck")
    sinbad.add_bone_name("Root")
    sinbad.add_bone_name("Stomach")
    sinbad.add_bone_name("Waist")
    sinbad.add_bone_name("Humerus.L")
    sinbad.add_bone_name("Humerus.R")
    sinbad.add_bone_name("Thigh.L")
    sinbad.add_bone_name("Thigh.R")
    sinbad.add_bone_name("Calf.L")
    sinbad.add_bone_name("Calf.R")
    sinbad.add_bone_name("Clavicle.L")
    sinbad.add_bone_name("Clavicle.R")
  end
  
  def on_anim_cycle_done(control, channel, anim_name)
    if channel.animation_name.eql?("StandUpBack") || channel.animation_name.eql?("StandUpFront")
      channel.loop_mode = LoopMode::DontLoop
      channel.set_anim("IdleTop", 5)
      channel.loop_mode = LoopMode::Loop
    end
  end
  
  class ControllerAction
    include ActionListener 
    
    def initialize(parent)
      @parent = parent
    end
    
    def on_action(name, is_pressed, tpf)
      if name.eql?("toggle") && is_pressed
        v = Vector3f.new
        v.set(@parent.model.local_translation)
        v.y = 0
        @parent.model.local_translation = v
        q = Quaternion.new
        angles = [0.0, 0.0, 0.0]
        @parent.model.local_rotation.to_angles(angles)
        q.from_angle_axis(angles[1], Vector3f::UNIT_Y)
        @parent.model.local_rotation = q
        if angles[0] < 0
          @parent.anim_channel.anim = "StandUpBack"
          @parent.ragdoll.blendToKinematicMode(0.5)
        else
          @parent.anim_channel.anim = "StandUpFront"
          @parent.ragdoll.blend_to_kinematic_mode(0.5)
        end
      end
      
      if name.eql?("bullet+") && is_pressed
        @parent.bullet_size += 0.1
      end
      if name.eql?("bullet-") && is_pressed
        @parent.bullet_size -= 0.1
      end
      if name.eql?("stop") && is_pressed
        @parent.ragdoll.enabled = !@parent.ragdoll.enabled?
        @parent.ragdoll.setRagdollMode # set it to nil?
      end
      if name.eql?("shoot") && !is_pressed
        bulletg = Geometry.new("bullet", @parent.bullet)
        bulletg.material = @parent.mat_bullet
        bulletg.local_translation = @parent.cam.location
        bulletg.local_scale = @parent.bullet_size
        @parent.bullet_collision_shape = SphereCollisionShape.new(@parent.bullet_size)
        bullet_node = RigidBodyControl.new(@parent.bullet_collision_shape, @parent.bullet_size * 10)
        bullet_node.ccd_motion_threshold = 0.001
        bullet_node.linear_velocity = @parent.cam.direction.mult(80)
        bulletg.add_control(bullet_node)
        root_node.attach_child(bulletg)
        @parent.bullet_app_state.physics_space.add(bullet_node)
      end
      if name.eql?("boom") && !is_pressed
        bulletg = Geometry.new("bullet", @parent.bullet)
        bulletg.material = @parent.mat_bullet
        bulletg.local_translation = @parent.cam.location
        bulletg.local_scale = @parent.bullet_size
        @parent.bullet_collision_shape = SphereCollisionShape.new(@parent.bullet_size)
        bullet_node = BombControl.new(@parent.asset_manager, @parent.bullet_collision_shape, 1)
        bullet_node.force_factor = 8
        bullet_node.explosion_radius = 20
        bullet_node.ccd_motion_threshold = 0.001
        bullet_node.linear_velocity = @parent.cam.direction.mult(180)
        bulletg.add_control(bulletNode)
        @parent.root_node.attach_child(bulletg)
        @parent.bullet_app_state.physics_space.add(bullet_node)
      end
    end  
  end
  
end