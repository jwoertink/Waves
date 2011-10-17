=begin
  This example shows physics. A wall of bricks that can fall down.
  Use space to shoot a ball at the wall. Also demonstrates changing the logging level
=end
java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.asset.TextureKey"
java_import "com.jme3.bullet.BulletAppState"
java_import "com.jme3.bullet.control.RigidBodyControl"
java_import "com.jme3.font.BitmapText"
java_import "com.jme3.input.KeyInput"
java_import "com.jme3.input.controls.ActionListener"
java_import "com.jme3.input.controls.KeyTrigger"
java_import "com.jme3.material.Material"
java_import "com.jme3.math.Vector2f"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.scene.Geometry"
java_import "com.jme3.scene.shape.Box"
java_import "com.jme3.scene.shape.Sphere"
java_import "com.jme3.texture.Texture"
java_import "java.util.logging.Level"
java_import "java.util.logging.Logger"

class Sample12 < SimpleApplication
  include ActionListener
  field_accessor :flyCam
  field_reader :cam, :settings
  attr_accessor :bullet_app_state, :wall_mat, :stone_mat, :floor_mat, :brick_phy, :ball_phy, :floor_phy
  
  def initialize
    Logger.get_logger("").level = Level::WARNING
    @brick_length = 0.48
    @brick_width = 0.24
    @brick_height = 0.12
    @sphere = Sphere.new(32, 32, 0.4, true, false)
    @sphere.texture_mode = Sphere::TextureMode::Projected
    @box = Box.new(Vector3f::ZERO, @brick_length, @brick_height, @brick_width)
    @box.scale_texture_coordinates(Vector2f.new(1.0, 0.5))
    @floor = Box.new(Vector3f::ZERO, 10.0, 0.1, 5.0)
    @floor.scale_texture_coordinates(Vector2f.new(3, 6))
  end
  
  def simpleInitApp
    flyCam.move_speed = 30
    self.bullet_app_state = BulletAppState.new
    state_manager.attach(bullet_app_state)
    cam.location = Vector3f.new(0, 4.0, 6.0)
    cam.look_at(Vector3f.new(2, 2, 0), Vector3f::UNIT_Y)
    
    init_materials
    init_wall
    init_floor
    init_cross_hairs
    input_manager.add_mapping("Shoot", KeyTrigger.new(KeyInput::KEY_SPACE))
    input_manager.add_listener(ControllerAction.new(self), "Shoot")
  end
  
  def init_materials
    self.wall_mat = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    key = TextureKey.new(File.join('Textures', 'Terrain', 'BrickWall', 'BrickWall.jpg'))
    key.generate_mips = true
    tex = asset_manager.load_texture(key)
    wall_mat.set_texture("ColorMap", tex)
    
    self.stone_mat = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    key2 = TextureKey.new(File.join("Textures", "Terrain", "Rock", "Rock.PNG"))
    key2.generate_mips = true
    tex2 = asset_manager.load_texture(key2)
    stone_mat.set_texture("ColorMap", tex2)
    
    self.floor_mat = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    key3 = TextureKey.new(File.join("Textures", "Terrain", "Pond", "Pond.jpg"))
    key3.generate_mips = true
    tex3 = asset_manager.load_texture(key3)
    tex3.wrap = Texture::WrapMode::Repeat
    floor_mat.set_texture("ColorMap", tex3)
  end
  
  def init_wall
    startpt = @brick_length / 4
    height = 0
    20.times do
      0.upto(5) do |i|
        vt = Vector3f.new(i * @brick_length * 2 + startpt, @brick_height + height, 0)
        make_brick(vt)
      end
      startpt = -startpt
      height += 2 * @brick_height
    end
  end
  
  def make_brick(loc)
    brick_geo = Geometry.new("brick", @box)
    brick_geo.material = wall_mat
    root_node.attach_child(brick_geo)
    brick_geo.set_local_translation(loc)
    self.brick_phy = RigidBodyControl.new(2.0)
    brick_geo.add_control(brick_phy)
    bullet_app_state.physics_space.add(brick_phy)
  end
  
  def make_cannon_ball
    ball_geo = Geometry.new("cannon ball", @sphere)
    ball_geo.material = stone_mat
    root_node.attach_child(ball_geo)
    ball_geo.local_translation = cam.location
    self.ball_phy = RigidBodyControl.new(1.0)
    ball_geo.add_control(ball_phy)
    bullet_app_state.physics_space.add(ball_phy)
    ball_phy.linear_velocity = cam.direction.mult(25)
  end
  
  def init_floor
    floor_geo = Geometry.new("Floor", @floor)
    floor_geo.material = floor_mat
    floor_geo.set_local_translation(0, -0.1, 0)
    root_node.attach_child(floor_geo)
    self.floor_phy = RigidBodyControl.new(0.0)
    floor_geo.add_control(floor_phy)
    bullet_app_state.physics_space.add(floor_phy)
  end
  
  def init_cross_hairs
    gui_node.detach_all_children
    gui_font = asset_manager.load_font(File.join("Interface", "Fonts", "Default.fnt"))
    ch = BitmapText.new(gui_font, false)
    ch.size = gui_font.char_set.rendered_size * 2
    ch.text = "+"
    ch.set_local_translation(settings.width / 2 - gui_font.char_set.rendered_size / 3 * 2, settings.height / 2 + ch.line_height / 2, 0)
    gui_node.attach_child(ch)
  end
  
  class ControllerAction
    include ActionListener
    
    def initialize(obj)
      @parent = obj
    end
    
    def on_action(name, key_pressed, tpf)
      if name.eql?("Shoot") && !key_pressed
        @parent.make_cannon_ball 
      end
    end
  end
  
end