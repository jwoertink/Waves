=begin
  This is an example of how to create a vehicle.
  TODO: currently not working.
=end

java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.bounding.BoundingBox"
java_import "com.jme3.bullet.BulletAppState"
java_import "com.jme3.bullet.PhysicsSpace"
java_import "com.jme3.bullet.collision.shapes.CollisionShape"
java_import "com.jme3.bullet.control.VehicleControl"
java_import "com.jme3.bullet.objects.VehicleWheel"
java_import "com.jme3.bullet.util.CollisionShapeFactory"
java_import "com.jme3.bullet.collision.shapes.MeshCollisionShape"
java_import "com.jme3.bullet.control.PhysicsControl"
java_import "com.jme3.input.KeyInput"
java_import "com.jme3.input.controls.ActionListener"
java_import "com.jme3.input.controls.KeyTrigger"
java_import "com.jme3.light.DirectionalLight"
java_import "com.jme3.math.FastMath"
java_import "com.jme3.math.Matrix3f"
java_import "com.jme3.math.Vector2f"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.renderer.queue.RenderQueue$ShadowMode"
java_import "com.jme3.texture.Texture"
java_import "com.jme3.scene.shape.Box"
java_import "com.jme3.scene.Geometry"
java_import "com.jme3.scene.Node"
java_import "com.jme3.scene.Spatial"
java_import "com.jme3.shadow.BasicShadowRenderer"


class Sample16 < SimpleApplication
  include ActionListener
  field_reader :settings, :cam
  field_accessor :flyCam
  attr_accessor :bullet_app_state, :steering_value, :acceleration_value, :player, :car_node
  
  def initialize
    self.steering_value = 0
    self.acceleration_value = 0
  end
  
  def simpleInitApp
    self.bullet_app_state = BulletAppState.new
    state_manager.attach(bullet_app_state)
    bullet_app_state.physics_space.enable_debug(asset_manager)
    if settings.renderer.include?('LWJGL')
      bsr = BasicShadowRenderer.new(asset_manager, 512)
      bsr.direction = Vector3f.new(-0.5, -0.3, -0.3).normalize_local
      view_port.add_processor(bsr)
    end
    cam.frustum_far = 150.0
    flyCam.move_speed = 10
    setup_keys!
    setup_floor!
    build_player
    dl = DirectionalLight.new
    dl.direction = Vector3f.new(-0.5, -1.0, -0.3).normalize_local
    root_node.add_light(dl)
    dl = DirectionalLight.new
    dl.direction = Vector3f.new(0.5, -0.1, 0.3).normalize_local
    root_node.add_light(dl)
  end
  
  def simpleUpdate(tpf)
    cam.look_at(car_node.world_translation, Vector3f::UNIT_Y)
  end
  
  def setup_keys!
    input_manager.add_mapping("Lefts", KeyTrigger.new(KeyInput::KEY_H))
    input_manager.add_mapping("Rights", KeyTrigger.new(KeyInput::KEY_K))
    input_manager.add_mapping("Ups", KeyTrigger.new(KeyInput::KEY_U))
    input_manager.add_mapping("Downs", KeyTrigger.new(KeyInput::KEY_J))
    input_manager.add_mapping("Space", KeyTrigger.new(KeyInput::KEY_SPACE))
    input_manager.add_mapping("Reset", KeyTrigger.new(KeyInput::KEY_RETURN))
    input_manager.add_listener(ControllerAction.new(self), "Lefts");
    input_manager.add_listener(ControllerAction.new(self), "Rights");
    input_manager.add_listener(ControllerAction.new(self), "Ups");
    input_manager.add_listener(ControllerAction.new(self), "Downs");
    input_manager.add_listener(ControllerAction.new(self), "Space");
    input_manager.add_listener(ControllerAction.new(self), "Reset");
  end
  
  def setup_floor!
    mat = asset_manager.load_material(File.join("Textures", "Terrain", "BrickWall", "BrickWall.j3m"))
    mat.get_texture_param("DiffuseMap").texture_value.wrap = Texture::WrapMode::Repeat
    mat.get_texture_param("NormalMap").texture_value.wrap = Texture::WrapMode::Repeat
    mat.get_texture_param("ParallaxMap").texture_value.wrap = Texture::WrapMode::Repeat
    
    floor = Box.new(Vector3f::ZERO, 140, 1.0, 140)
    floor.scale_texture_coordinates(Vector2f.new(112.0, 112.0))
    floor_geom = Geometry.new("Floor", floor)
    floor_geom.shadow_mode = ShadowMode::Receive
    floor_geom.material = mat
    
    # This API has changed
    #tb = PhysicsControl.new(floor_geom, MeshCollisionShape.new(floor_geom.mesh), 0)
    #tb.local_translation = Vector3f.new(0.0, -6, 0.0)
    #tb.attach_debug_shape(asset_manager)
    #root_node.attach_child(tb)
    #bullet_app_state.physics_space.add(tb)
  end
  
  def build_player
    stiffness = 120.0
    comp_value = 0.2
    damp_value = 0.3
    mass = 400
    
    self.car_node = asset_manager.load_model(File.join('Models', 'Ferrari', 'Car.scene'))
    car_node.shadow_mode = ShadowMode::Cast
    chasis = find_geom(car_node, "Car")
    box = chasis.model_bound
    
    car_hull = CollisionShapeFactory.create_dynamic_mesh(chasis)
    
    self.player = VehicleControl.new(car_hull, mass)
    car_node.add_control(player)
    
    player.suspension_compression = comp_value * 2.0 * FastMath.sqrt(stiffness)
    player.suspension_damping = damp_value * 2.0 * FastMath.sqrt(stiffness)
    player.suspension_stiffness = stiffness
    player.max_suspension_force = 10000

    wheel_direction = Vector3f.new(0, -1, 0)
    wheel_axle = Vector3f.new(-1, 0, 0)

    wheel_fr = find_geom(carNode, "WheelFrontRight")
    wheel_fr.center
    box = wheel_fr.model_bound
    wheel_radius = box.y_extent
    back_wheel_h = (wheel_radius * 1.7) - 1.0
    front_wheel_h = (wheelRadius * 1.9) - 1.0
    player.add_wheel(wheel_fr.parent, box.center.add(0, -front_wheel_h, 0), wheel_direction, wheel_axle, 0.2, wheel_radius, true)

    wheel_fl = find_geom(car_node, "WheelFrontLeft")
    wheel_fl.center
    box = wheel_fl.model_bound
    player.add_wheel(wheel_fl.parent, box.center.add(0, -front_wheel_h, 0), wheel_direction, wheel_axle, 0.2, wheel_radius, true)

    wheel_br = find_geom(car_node, "WheelBackRight")
    wheel_br.center
    box = wheel_br.model_bound
    player.addWheel(wheel_br.getParent(), box.getCenter().add(0, -back_wheel_h, 0), wheel_direction, wheel_axle, 0.2, wheel_radius, false)

    wheel_bl = find_geom(car_node, "WheelBackLeft")
    wheel_bl.center
    box = wheel_bl.model_bound
    player.add_wheel(wheel_bl.parent, box.center.add(0, -back_wheel_h, 0), wheel_direction, wheel_axle, 0.2, wheel_radius, false)

    player.get_wheel(2).friction_slip = 4
    player.get_wheel(3).friction_slip = 4

    root_node.attach_child(car_node)
    bullet_app_state.physics_space.add(player)
  end
  
  class ControllerAction
    include ActionListener
    
    def initialize(obj)
      @parent = obj
    end
    
    def on_action(name, key_pressed, time_per_frame)
      if name.eql?("Lefts")
        if key_pressed
          @parent.steering_value += 0.5
        else
          @parent.steering_value -= 0.5
        end
        @parent.player.steer(@parent.steering_value);
      elsif name.eql?("Rights")
        if key_pressed
          @parent.steering_value -= 0.5
        else
          @parent.steering_value += 0.5
        end
        player.steer(@parent.steering_value)
      elsif name.eql?("Ups")
        if key_pressed
          @parent.acceleration_value -= 800
        else
          @parent.acceleration_value += 800;
        end
        @parent.player.accelerate(@parent.acceleration_value)
        @parent.player.collision_shape = CollisionShapeFactory.create_dynamic_mesh_shape(@parent.find_geom(carNode, "Car"))
      elsif name.eql?("Downs")
        if key_pressed
          @parent.player.brake(40.0)
        else
          @parent.player.brake(0.0)
        end
      elsif name.eql?("Reset")
        if key_pressed
          puts "Reset"
          @parent.player.physics_location = Vector3f::ZERO
          @parent.player.physics_rotation = Matrix3f.new
          @parent.player.linear_velocity = Vector3f::ZERO
          @parent.player.angular_velocity = Vector3f::ZERO
          @parent.player.reset_suspension
        end
      end    
    end
    
  end
  
  #private (kinda, but not really)
    
    def find_geom(spatial, name)
      if spatial.is_a? Node
        node = spatial
        0.upto(node.quantity) do |i|
          child = node.child(i)
          result = find_geom(child, name)
          return result unless result.nil?
        end
      elsif spatial.is_a? Geometry
        return spatial if spatial.name.include?(name)
      end
      
      nil
    end
  
end
