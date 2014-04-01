=begin
  This sample shows a walking character with a 3rd person view camera
=end

java_import "com.jme3.animation.AnimChannel"
java_import "com.jme3.animation.AnimControl"
java_import "com.jme3.animation.AnimEventListener"
java_import "com.jme3.animation.LoopMode"
java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.bullet.BulletAppState"
java_import "com.jme3.bullet.PhysicsSpace"
java_import "com.jme3.bullet.collision.PhysicsCollisionEvent"
java_import "com.jme3.bullet.collision.PhysicsCollisionListener"
java_import "com.jme3.bullet.collision.shapes.CapsuleCollisionShape"
java_import "com.jme3.bullet.collision.shapes.SphereCollisionShape"
java_import "com.jme3.bullet.control.CharacterControl"
java_import "com.jme3.bullet.control.RigidBodyControl"
java_import "com.jme3.bullet.util.CollisionShapeFactory"
java_import "com.jme3.effect.ParticleEmitter"
java_import "com.jme3.effect.ParticleMesh$Type"
java_import "com.jme3.effect.shapes.EmitterSphereShape"
java_import "com.jme3.input.ChaseCamera"
java_import "com.jme3.input.KeyInput"
java_import "com.jme3.input.controls.ActionListener"
java_import "com.jme3.input.controls.KeyTrigger"
java_import "com.jme3.light.DirectionalLight"
java_import "com.jme3.material.Material"
java_import "com.jme3.math.ColorRGBA"
java_import "com.jme3.math.Vector2f"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.post.FilterPostProcessor"
java_import "com.jme3.post.filters.BloomFilter"
java_import "com.jme3.renderer.Camera"
java_import "com.jme3.renderer.queue.RenderQueue$ShadowMode"
java_import "com.jme3.scene.Geometry"
java_import "com.jme3.scene.Node"
java_import "com.jme3.scene.Spatial"
java_import "com.jme3.scene.shape.Box"
java_import "com.jme3.scene.shape.Sphere"
java_import "com.jme3.scene.shape.Sphere$TextureMode"
java_import "com.jme3.terrain.geomipmap.TerrainLodControl"
java_import "com.jme3.terrain.geomipmap.TerrainQuad"
java_import "com.jme3.terrain.heightmap.AbstractHeightMap"
java_import "com.jme3.terrain.heightmap.ImageBasedHeightMap"
java_import "com.jme3.texture.Texture"
java_import "com.jme3.texture.Texture$WrapMode"
java_import "com.jme3.util.SkyFactory"
java_import "java.util.ArrayList"
java_import "java.util.List"

require 'lib/samples/bomb_control'

class Sample17 < SimpleApplication
  include ActionListener
  include PhysicsCollisionListener
  include AnimEventListener
  field_accessor :flyCam
  field_reader :cam
  
  attr_accessor :bullet_app_state, :model, :character, :animation_channel, :shooting_channel, :bullet, :effect
  
  def initialize
    @walk_direction = Vector3f.new
    @air_time = 0
    @left = @right = @up = @down = false
    @b_length = 0.8
    @b_width = 0.4
    @b_height = 0.4
  end
  
  def simpleInitApp
    self.bullet_app_state = BulletAppState.new
    bullet_app_state.threading_type = BulletAppState::ThreadingType::PARALLEL
    state_manager.attach(bullet_app_state)
    setup_keys!
    prepare_bullet
    prepare_effect
    create_light
    create_sky
    create_terrain
    create_wall
    create_character
    setup_chase_camera
    setup_animation_controller
    setup_filter
  end
  
  def setup_filter
    fpp = FilterPostProcessor.new(asset_manager)
    bloom = BloomFilter.new(BloomFilter::GlowMode::Objects)
    fpp.add_filter(bloom)
    view_port.add_processor(fpp)
  end
  
  def physics_space
    bullet_app_state.physics_space
  end
  
  def setup_keys!
    input_manager.add_mapping("wireframe", KeyTrigger.new(KeyInput::KEY_T))
    input_manager.add_mapping("CharLeft", KeyTrigger.new(KeyInput::KEY_A))
    input_manager.add_mapping("CharRight", KeyTrigger.new(KeyInput::KEY_D))
    input_manager.add_mapping("CharUp", KeyTrigger.new(KeyInput::KEY_W))
    input_manager.add_mapping("CharDown", KeyTrigger.new(KeyInput::KEY_S))
    input_manager.add_mapping("CharSpace", KeyTrigger.new(KeyInput::KEY_RETURN))
    input_manager.add_mapping("CharShoot", KeyTrigger.new(KeyInput::KEY_SPACE))
    input_manager.add_listener(ControllerAction.new(self), "wireframe")
    input_manager.add_listener(ControllerAction.new(self), "CharLeft")
    input_manager.add_listener(ControllerAction.new(self), "CharRight")
    input_manager.add_listener(ControllerAction.new(self), "CharUp")
    input_manager.add_listener(ControllerAction.new(self), "CharDown")
    input_manager.add_listener(ControllerAction.new(self), "CharSpace")
    input_manager.add_listener(ControllerAction.new(self), "CharShoot")
  end
  
  def create_wall
    x_off = -144
    z_off = -40
    startpt = @b_length / 4 - x_off
    height = 6.1
    @brick = Box.new(Vector3f::ZERO, @b_length, @b_height, @b_width)
    @brick.scale_texture_coordinates(Vector2f.new(1.0, 0.5))
    15.times do |j|
      5.times do |i|
        vt = Vector3f.new(i * @b_length * 2 + startpt, @b_height + height, z_off)
        add_brick(vt)
      end
      startpt = -startpt
      height += 1.0 * @b_height
    end
  end
  
  def add_brick(ori)
    re_boxg = Geometry.new("brick", @brick)
    re_boxg.material = @mat_bullet
    re_boxg.local_translation = ori
    re_boxg.add_control(RigidBodyControl.new(1.5))
    re_boxg.shadow_mode = ShadowMode::CastAndReceive
    root_node.attach_child(re_boxg)
    physics_space.add(re_boxg)
  end
  
  def prepare_bullet
    self.bullet = Sphere.new(32, 32, 0.4, true, false)
    bullet.texture_mode = TextureMode::Projected
    @bullet_collision_shape = SphereCollisionShape.new(0.4)
    @mat_bullet = Material.new(asset_manager, "Common/MatDefs/Misc/Unshaded.j3md")
    @mat_bullet.set_color("Color", ColorRGBA::Green)
    @mat_bullet.set_color("GlowColor", ColorRGBA::Green)
    physics_space.add_collision_listener(self)
  end
  
  def prepare_effect
    count_factor = 1
    count_factor_f = 1.0
    self.effect = ParticleEmitter.new("Flame", Type::Triangle, 32 * count_factor)
    effect.select_random_image = true
    effect.start_color = ColorRGBA.new(1.0, 0.4, 0.05, 1.0 / count_factor_f)
    effect.end_color = ColorRGBA.new(0.4, 0.22, 0.12, 0.0)
    effect.start_size = 1.3
    effect.end_size = 2.0
    effect.shape = EmitterSphereShape.new(Vector3f::ZERO, 1.0)
    effect.particles_per_sec = 0
    effect.set_gravity(0, -5, 0)
    effect.low_life = 0.4
    effect.high_life = 0.5
    effect.initial_velocity = Vector3f.new(0, 7, 0)
    effect.velocity_variation = 1.0
    effect.images_x = 2
    effect.images_y = 2
    mat = Material.new(asset_manager, "Common/MatDefs/Misc/Particle.j3md")
    mat.set_texture("Texture", asset_manager.load_texture("Effects/Explosion/flame.png"))
    effect.material = mat
    root_node.attach_child(effect)
  end
  
  def create_light
    direction = Vector3f.new(-0.1, -0.7, -1).normalize_local
    dl = DirectionalLight.new
    dl.direction = direction
    dl.color = ColorRGBA.new(1.0, 1.0, 1.0, 1.0)
    root_node.add_light(dl)
  end
  
  def create_sky
    root_node.attach_child(SkyFactory.create_sky(asset_manager, "Textures/Sky/Bright/BrightSky.dds", false))
  end
  
  def create_terrain
    mat_rock = Material.new(asset_manager, "Common/MatDefs/Terrain/TerrainLighting.j3md")
    mat_rock.set_boolean("useTriPlanarMapping", false)
    mat_rock.set_boolean("WardIso", true)
    mat_rock.set_texture("AlphaMap", asset_manager.load_texture("Textures/Terrain/splat/alphamap.png"))
    height_map_image = asset_manager.load_texture("Textures/Terrain/splat/mountains512.png")
    
    grass = asset_manager.load_texture("Textures/Terrain/splat/grass.jpg")
    grass.wrap = WrapMode::Repeat
    mat_rock.set_texture("DiffuseMap", grass)
    mat_rock.set_float("DiffuseMap_0_scale", 64)
    
    dirt = asset_manager.load_texture("Textures/Terrain/splat/dirt.jpg")
    dirt.wrap = WrapMode::Repeat
    mat_rock.set_texture("DiffuseMap_1", dirt)
    mat_rock.set_float("DiffuseMap_1_scale", 16)
    
    rock = asset_manager.load_texture("Textures/Terrain/splat/road.jpg")
    rock.wrap = WrapMode::Repeat
    mat_rock.set_texture("DiffuseMap_2", rock)
    mat_rock.set_float("DiffuseMap_2_scale", 128)
    
    normal_map0 = asset_manager.load_texture("Textures/Terrain/splat/grass_normal.jpg")
    normal_map0.wrap = WrapMode::Repeat
    normal_map1 = asset_manager.load_texture("Textures/Terrain/splat/dirt_normal.png")
    normal_map1.wrap = WrapMode::Repeat
    normal_map2 = asset_manager.load_texture("Textures/Terrain/splat/road_normal.png")
    normal_map2.wrap = WrapMode::Repeat
    mat_rock.set_texture("NormalMap", normal_map0)
    mat_rock.set_texture("NormalMap_1", normal_map1)
    mat_rock.set_texture("NormalMap_2", normal_map2)
    heightmap = ImageBasedHeightMap.new(height_map_image.image, 0.25)
    heightmap.load
    terrain = TerrainQuad.new("terrain", 65, 513, heightmap.height_map)
    cameras = []
    cameras << camera
    control = TerrainLodControl.new(terrain, cameras)
    terrain.add_control(control)
    terrain.material = mat_rock
    terrain.local_scale = Vector3f.new(2, 2, 2)
    terrain_physics_node = RigidBodyControl.new(CollisionShapeFactory.create_mesh_shape(terrain), 0)
    terrain.add_control(terrain_physics_node)
    root_node.attach_child(terrain)
    physics_space.add(terrain_physics_node)
  end
  
  def create_character
    capsule = CapsuleCollisionShape.new(3.0, 4.0)
    self.character = CharacterControl.new(capsule, 0.01)
    character.jump_speed = 20.0
    self.model = asset_manager.load_model("Models/Oto/Oto.mesh.xml")
    model.add_control(character)
    character.physics_location = Vector3f.new(-140, 15, -10)
    root_node.attach_child(model)
    physics_space.add(character)
  end
  
  def setup_chase_camera
    flyCam.enabled = false
    chase_cam = ChaseCamera.new(cam, model, input_manager)
  end
  
  def setup_animation_controller
    animation_control = model.control(AnimControl.java_class)
    animation_control.add_listener(self)
    self.animation_channel = animation_control.create_channel
    self.shooting_channel = animation_control.create_channel
    shooting_channel.add_bone(animation_control.skeleton.bone('uparm.right'))
    shooting_channel.add_bone(animation_control.skeleton.bone('arm.right'))
    shooting_channel.add_bone(animation_control.skeleton.bone('hand.right'))
  end
  
  def simpleUpdate(tpf)
    cam_dir = cam.direction.clone.mult_local(0.5)
    cam_left = cam.left.clone.mult_local(0.5)
    cam_dir.y = 0
    cam_left.y = 0
    @walk_direction.set(0, 0, 0)
    @walk_direction.add_local(cam_left) if @left
    @walk_direction.add_local(cam_left.negate) if @right
    @walk_direction.add_local(cam_dir) if @up
    @walk_direction.add_local(cam_dir.negate) if @down
    if !character.on_ground
      @air_time += tpf
    else
      @air_time = 0
    end
    
    if @walk_direction.length.zero?
      unless animation_channel.animation_name.eql?('stand')
        animation_channel.set_anim('stand', 1.0)
      end
    else
      character.view_direction = @walk_direction
      if @air_time > 0.3
        unless animation_channel.animation_name.eql?('stand')
          animation_channel.set_anim('stand')
        end
      elsif animation_channel.animation_name.eql?('Walk')
        animation_channel.set_anim('Walk', 0.7)
      end
    end
    character.walk_direction = @walk_direction
  end
  
  def bullet_control
    shooting_channel.set_anim("Dodge", 0.1)
    shooting_channel.loop_mode = LoopMode::DontLoop
    bulletg = Geometry.new("bullet", bullet)
    bulletg.material = @mat_bullet
    bulletg.shadow_mode = ShadowMode::CastAndReceive
    bulletg.local_translation = character.physics_location.add(cam.direction.mult(5))
    bullet_control = BombControl.new(@bullet_collision_shape, 1)
    bullet_control.ccd_motion_threshold = 0.1
    bullet_control.linear_velocity = cam.direction.mult(80)
    bulletg.add_control(bullet_control)
    root_node.attach_child(bulletg)
    physics_space.add(bullet_control)
  end
  
  def collision(event)
    if event.object_a.kind_of? BombControl
      node = event.node_a
      effect.kill_all_particles
      effect.local_translation = node.local_translation
      effect.emit_all_particles
    elsif event.object_b.kind_of? BombControl
      node = event.node_b
      effect.kill_all_particles
      effect.local_translation = node.local_translation
      effect.emit_all_particles
    end
  end
  
  def onAnimCycleDone(control, channel, anim_name)
    channel.set_anim("stand") if channel == shooting_channel
  end
  
  def onAnimChange(control, channel, anim_name)
    
  end
  
  class ControllerAction
    include ActionListener
    
    def initialize(obj)
      @parent = obj
    end
    
    def on_action(name, key_pressed, time_per_frame)
      case name
      when 'CharLeft'
        @parent.instance_variable_set(:@left, key_pressed)
      when 'CharRight'
        @parent.instance_variable_set(:@right, key_pressed)
      when 'CharUp'
        @parent.instance_variable_set(:@up, key_pressed)
      when 'CharDown'
        @parent.instance_variable_set(:@down, key_pressed)
      when 'CharSpace'
        @parent.character.jump
      when 'CharShoot'
        @parent.bullet_control
      end
        
    end
  end
end
