=begin
  This is a Ragdoll Sample
  The ragdoll currently shakes in rapid convultions. Not sure why yet.
=end
java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.bullet.BulletAppState"
java_import "com.jme3.bullet.PhysicsSpace"
java_import "com.jme3.bullet.collision.shapes.CapsuleCollisionShape"
java_import "com.jme3.bullet.control.RigidBodyControl"
java_import "com.jme3.bullet.joints.ConeJoint"
java_import "com.jme3.bullet.joints.PhysicsJoint"
java_import "com.jme3.input.controls.ActionListener"
java_import "com.jme3.input.controls.MouseButtonTrigger"
java_import "com.jme3.input.MouseInput"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.scene.Node"
java_import "com.jme3.light.AmbientLight"
java_import "com.jme3.font.BitmapText"
java_import "com.jme3.scene.shape.Box"
java_import "com.jme3.scene.Geometry"
java_import "com.jme3.math.ColorRGBA"
java_import "com.jme3.material.Material"

class Sample14 < SimpleApplication
  include ActionListener
  field_reader :cam, :settings
  field_accessor :flyCam
  attr_accessor :bullet_app_state, :shoulders, :upforce, :applyforce, :rag_doll
  
  def simpleInitApp
    self.upforce = Vector3f.new(0, 200, 0)
    self.applyforce = false
    self.rag_doll = Node.new
    self.bullet_app_state = BulletAppState.new
    state_manager.attach(bullet_app_state)
    bullet_app_state.physics_space.enable_debug(asset_manager)
    input_manager.add_mapping("Pull ragdoll up", MouseButtonTrigger.new(MouseInput::BUTTON_LEFT))
    input_manager.add_listener(ControllerAction.new(self), "Pull ragdoll up")
    create_world
    create_rag_doll
  end
  
  def create_world
    light = AmbientLight.new
    light.color = ColorRGBA::LightGray
    root_node.add_light(light)
    
    material = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    material.set_texture("ColorMap", asset_manager.load_texture(File.join("Interface", "Logo", "Monkey.jpg")))
    
    box = Box.new(Vector3f.new(0, -4, -5), 100, 0.2, 100)
    floor = Geometry.new("the Floor", box)
    floor.material = material
    floor.set_local_translation(0, -0.1, 0)
    floor_phy = RigidBodyControl.new(0.0)
    floor.add_control(floor_phy)
    root_node.attach_child(floor)
    bullet_app_state.physics_space.add(floor)
  end
  
  def create_rag_doll
    self.shoulders = create_limb(0.2, 1.0, Vector3f.new(0.00, 1.5, 0), true)
    uArmL = create_limb(0.2, 0.5, Vector3f.new(-0.75, 0.8, 0), false)
    uArmR = create_limb(0.2, 0.5, Vector3f.new( 0.75, 0.8, 0), false)
    lArmL = create_limb(0.2, 0.5, Vector3f.new(-0.75,-0.2, 0), false)
    lArmR = create_limb(0.2, 0.5, Vector3f.new( 0.75,-0.2, 0), false)
    body = create_limb(0.2, 1.0, Vector3f.new( 0.00, 0.5, 0), false)
    hips = create_limb(0.2, 0.5, Vector3f.new( 0.00,-0.5, 0), true)
    uLegL = create_limb(0.2, 0.5, Vector3f.new(-0.25,-1.2, 0), false)
    uLegR = create_limb(0.2, 0.5, Vector3f.new( 0.25,-1.2, 0), false)
    lLegL = create_limb(0.2, 0.5, Vector3f.new(-0.25,-2.2, 0), false)
    lLegR = create_limb(0.2, 0.5, Vector3f.new( 0.25,-2.2, 0), false)
    join(body,  shoulders, Vector3f.new( 0.00,  1.4, 0))
    join(body,       hips, Vector3f.new( 0.00, -0.5, 0))
    join(uArmL, shoulders, Vector3f.new(-0.75,  1.4, 0))
    join(uArmR, shoulders, Vector3f.new( 0.75,  1.4, 0))
    join(uArmL,     lArmL, Vector3f.new(-0.75,  0.4, 0))
    join(uArmR,     lArmR, Vector3f.new( 0.75,  0.4, 0))
    join(uLegL,      hips, Vector3f.new(-0.25, -0.5, 0))
    join(uLegR,      hips, Vector3f.new( 0.25, -0.5, 0))
    join(uLegL,     lLegL, Vector3f.new(-0.25, -1.7, 0))
    join(uLegR,     lLegR, Vector3f.new( 0.25, -1.7, 0))
    rag_doll.attach_child(shoulders)
    rag_doll.attach_child(body)
    rag_doll.attach_child(hips)
    rag_doll.attach_child(uArmL)
    rag_doll.attach_child(uArmR)
    rag_doll.attach_child(lArmL)
    rag_doll.attach_child(lArmR)
    rag_doll.attach_child(uLegL)
    rag_doll.attach_child(uLegR)
    rag_doll.attach_child(lLegL)
    rag_doll.attach_child(lLegR)
    root_node.attach_child(rag_doll)
    bullet_app_state.physics_space.add_all(rag_doll)
  end
  
  def create_limb(width, height, location, rotate)
    axis = rotate ? PhysicsSpace::AXIS_X : PhysicsSpace::AXIS_Y
    shape = CapsuleCollisionShape.new(width, height, axis)
    node = Node.new("Limb")
    rigid_body_control = RigidBodyControl.new(shape, 1)
    node.local_translation = location
    node.add_control(rigid_body_control)
    node
  end
  
  def join(node_a, node_b, connection_point)
    pivot_a = node_a.world_to_local(connection_point, Vector3f.new)
    pivot_b = node_b.world_to_local(connection_point, Vector3f.new)
    joint = ConeJoint.new(node_a.get_control(RigidBodyControl.java_class), 
                          node_b.get_control(RigidBodyControl.java_class),
                          pivot_a, pivot_b)
    joint.set_limit(1.0, 1.0, 0)
    joint
  end
  
  def simpleUpdate(tpf)
    if applyforce
      shoulders.get_control(RigidBodyControl.java_class).apply_force(upforce, Vector3f::ZERO) 
    end
  end
  
  class ControllerAction
    include ActionListener
    
    def initialize(obj)
      @parent = obj
    end
    
    def on_action(name, key_pressed, time_per_frame)
      if name.eql?("Pull ragdoll up")
        if key_pressed
          @parent.shoulders.get_control(RigidBodyControl.java_class).activate
          @parent.applyforce = true
        else
          @parent.applyforce = false
        end
      end
    end
    
  end
  
  
end
