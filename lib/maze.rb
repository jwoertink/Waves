require 'java'
PROJECT_ROOT = File.expand_path('..', File.dirname(__FILE__))
require File.join(PROJECT_ROOT, 'vendor', 'jme3_2011-08-29.jar')

java_import "com.jme3.app.SimpleApplication"
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
java_import "com.jme3.scene.shape.Box"
java_import "com.jme3.scene.Geometry"
java_import "com.jme3.material.Material"

class Maze < SimpleApplication
  include ActionListener
  
  field_accessor :flyCam
  field_reader :cam
  attr_accessor :bullet_app_state, :player
  
  def initialize
    [:up, :down, :left, :right].each { |direction| self.instance_variable_set("@#{direction}", false) }
    @walk_direction = Vector3f.new
  end
  
  def simpleInitApp
    self.bullet_app_state = BulletAppState.new
    state_manager.attach(bullet_app_state)
    view_port.background_color = ColorRGBA.new(ColorRGBA.random_color)
    
    
    capsule_shape = CapsuleCollisionShape.new(1.5, 6.0, 1)
    self.player = CharacterControl.new(capsule_shape, 0.05)
    player.jump_speed = 20
    player.fall_speed = 30
    player.gravity = 30
    player.physics_location = Vector3f.new(0, 10, 0)
    bullet_app_state.physics_space.add(player)
    bullet_app_state.physics_space.enable_debug(asset_manager)
    
    setup_camera!
    setup_floor!
    create_wall(0, 0, 100, 100, 10, 0)
    create_wall(0, 0, -100, 100, 10, 0)
    create_wall(100, 0, 0, 0, 10, 100)
    create_wall(-100, 0, 0, 0, 10, 100)
    
    setup_keys!
    setup_light!
  end
  
  def setup_camera!
    flyCam.move_speed = 100
  end
  
  def setup_floor!
    box = Box.new(Vector3f.new(0, 0, 0), 100, 0.2, 100)
    floor = Geometry.new("the Floor", box)
    matl = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    matl.set_texture("ColorMap", asset_manager.load_texture(File.join('assets', 'Textures', 'hardwood.jpg')))
    floor.material = matl    
    scene_shape = CollisionShapeFactory.create_mesh_shape(floor)
    landscape = RigidBodyControl.new(scene_shape, 0)
    floor.add_control(landscape)
    bullet_app_state.physics_space.add(landscape)
    root_node.attach_child(floor)
  end
  
  #  vx = x position
  #  vy = elevation
  #  vz = y position
  #  bx = x width
  #  by = thickness (height)
  #  bz = y width
  def create_wall(vx, vy, vz, bx, by, bz)
    box = Box.new(Vector3f.new(vx, vy, vz), bx, by, bz)
    wall = Geometry.new("a Wall", box)
    matl = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    #matl.set_color("Color", ColorRGBA::Gray)
    matl.set_texture("ColorMap", asset_manager.load_texture(File.join('assets', 'Textures', 'brickwall.jpg')))
    wall.material = matl
    scene_shape = CollisionShapeFactory.create_mesh_shape(wall)
    landscape = RigidBodyControl.new(scene_shape, 0)
    wall.add_control(landscape)
    bullet_app_state.physics_space.add(landscape)
    root_node.attach_child(wall)
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
  
  def setup_keys!
    input_manager.add_mapping("Left",  KeyTrigger.new(KeyInput::KEY_A))
    input_manager.add_mapping("Right", KeyTrigger.new(KeyInput::KEY_D))
    input_manager.add_mapping("Up",    KeyTrigger.new(KeyInput::KEY_W))
    input_manager.add_mapping("Down",  KeyTrigger.new(KeyInput::KEY_S))
    input_manager.add_listener(ControllerAction.new(self), "Left")
    input_manager.add_listener(ControllerAction.new(self), "Right")
    input_manager.add_listener(ControllerAction.new(self), "Up")
    input_manager.add_listener(ControllerAction.new(self), "Down")
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
      @parent.instance_variable_set("@#{binding.downcase}", value)
    end
    
  end
  
end

Maze.new.start