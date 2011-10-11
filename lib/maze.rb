require 'rubygems'
require 'bundler'
Bundler.require
require 'java'
PROJECT_ROOT = File.expand_path('..', File.dirname(__FILE__))
require File.join(PROJECT_ROOT, 'vendor', 'jme3_2011-08-29.jar')

java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.font.BitmapText"
java_import "com.jme3.bullet.BulletAppState"
java_import "com.jme3.bullet.collision.shapes.CapsuleCollisionShape"
java_import "com.jme3.bullet.collision.shapes.CollisionShape"
java_import "com.jme3.collision.CollisionResult"
java_import "com.jme3.collision.CollisionResults"
java_import "com.jme3.bullet.control.CharacterControl"
java_import "com.jme3.bullet.control.RigidBodyControl"
java_import "com.jme3.bullet.util.CollisionShapeFactory"
java_import "com.jme3.input.KeyInput"
java_import "com.jme3.input.controls.ActionListener"
java_import "com.jme3.input.controls.KeyTrigger"
java_import "com.jme3.input.MouseInput"
java_import "com.jme3.input.controls.MouseButtonTrigger"
java_import "com.jme3.light.AmbientLight"
java_import "com.jme3.light.DirectionalLight"
java_import "com.jme3.math.ColorRGBA"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.math.Ray"
java_import "com.jme3.scene.Node"
java_import "com.jme3.scene.Spatial"
java_import "com.jme3.scene.shape.Box"
java_import "com.jme3.scene.shape.Sphere"
java_import "com.jme3.scene.Geometry"
java_import "com.jme3.material.Material"

class Maze < SimpleApplication
  include ActionListener
  
  field_accessor :flyCam
  field_reader :cam, :settings
  attr_accessor :bullet_app_state, :player, :mark, :shootables
  
  def initialize
    [:up, :down, :left, :right].each { |direction| self.instance_variable_set("@#{direction}", false) }
    @walk_direction = Vector3f.new
    @floor = {:width => 200, :height => 100}
    @wall = {:width => 10, :height => 20}
  end
  
  def simpleInitApp
    self.bullet_app_state = BulletAppState.new
    state_manager.attach(bullet_app_state)
    view_port.background_color = ColorRGBA.new(ColorRGBA.random_color)
    
    capsule_shape = CapsuleCollisionShape.new(1.5, 15.0, 1)
    self.player = CharacterControl.new(capsule_shape, 0.05)
    player.jump_speed = 20
    player.fall_speed = 30
    player.gravity = 30
    player.physics_location = Vector3f.new(-185, 15, -95)
    bullet_app_state.physics_space.add(player)
    
    sphere = Sphere.new(30, 30, 0.2)
    self.mark = Geometry.new("BOOM!", sphere)
    mark_mat = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    mark_mat.set_color("Color", ColorRGBA::Red)
    mark.material = mark_mat
    
    setup_text!
    setup_camera!
    setup_floor!
    setup_keys!
    setup_light!
    
    generate_dynamic_maze
    #generate_static_maze    
  end
  
  def generate_static_maze
    # Row 1
    create_wall(-190, 20, -100, 10, 20, 0) # _
    create_wall(-170, 20, -100, 10, 20, 0) # _
    create_wall(-150, 20, -100, 10, 20, 0) # _
    create_wall(-130, 20, -100, 10, 20, 0) # _
    create_wall(-110, 20, -100, 10, 20, 0) # _
    create_wall(-90, 20, -100, 10, 20, 0) # _
    create_wall(-70, 20, -100, 10, 20, 0) # _
    create_wall(-50, 20, -100, 10, 20, 0) # _
    create_wall(-30, 20, -100, 10, 20, 0) # _
    create_wall(-10, 20, -100, 10, 20, 0) # _
    create_wall( 10, 20, -100, 10, 20, 0) # _
    create_wall( 30, 20, -100, 10, 20, 0) # _
    create_wall( 50, 20, -100, 10, 20, 0) # _
    create_wall( 70, 20, -100, 10, 20, 0) # _
    create_wall( 90, 20, -100, 10, 20, 0) # _
    create_wall(110, 20, -100, 10, 20, 0) # _
    create_wall(130, 20, -100, 10, 20, 0) # _
    create_wall(150, 20, -100, 10, 20, 0) # _
    create_wall(170, 20, -100, 10, 20, 0) # _
    create_wall(190, 20, -100, 10, 20, 0) # _
    create_wall(210, 20, -100, 10, 20, 0) # _
    
    # Row 2
    ' '
    ' '
    create_wall(-150, 20, -90, 10, 20, 10) # |
    ' '
    ' '
    create_wall(-90, 20, -80, 10, 20, 0) # _
    create_wall(-70, 20, -80, 10, 20, 0) # _
    create_wall(-50, 20, -80, 10, 20, 0) # _
    create_wall(-30, 20, -80, 10, 20, 0) # _
    create_wall(-10, 20, -80, 10, 20, 0) # _
    ' '
    ' '
    ' '
    create_wall(70, 20, -80, 10, 20, 0) # _
    create_wall(90, 20, -80, 10, 20, 0) # _
    create_wall(110, 20, -80, 10, 20, 0) # _
    create_wall(130, 20, -80, 10, 20, 0) # _
    create_wall(150, 20, -80, 10, 20, 0) # _
    ' '
    ' '
    create_wall(210, 20, -90, 10, 20, 10) # |
    
    # Row 3
    create_wall(-190, 20, -70, 10, 20, 10) # |
    ' '
    create_wall(-150, 20, -70, 10, 20, 10) # |
    create_wall(-130, 20, -60, 10, 20, 0) # _
    ' '
    ' '
    create_wall(-70, 20, -70, 10, 20, 10) # |
    create_wall(-50, 20, -60, 10, 20, 0) # _
    ' '
    ' '
    create_wall(10, 20, -70, 10, 20, 10) # |
    ' '
    create_wall(50, 20, -70, 10, 20, 10) # |
    ' '
    ' '
    ' '
    create_wall(130, 20, -70, 10, 20, 10) # |
    ' '
    create_wall(170, 20, -70, 10, 20, 10) # |
    ' '
    create_wall(210, 20, -70, 10, 20, 10) # |
    
    # Row 4
    create_wall(-190, 20, -50, 10, 20, 10) # |
    ' '
    ' '
    create_wall(-130, 20, -40, 10, 20, 0) # _
    create_wall(-110, 20, -50, 10, 20, 10) # |
    ' '
    create_wall(-70, 20, -50, 10, 20, 10) # |
    ' '
    ' '
    ' '
    create_wall(10, 20, -50, 10, 20, 10) # |
    create_wall(30, 20, -40, 10, 20, 0) # _
    create_wall(50, 20, -40, 10, 20, 0) # _
    create_wall(70, 20, -40, 10, 20, 0) # _
    create_wall(90, 20, -50, 10, 20, 10) # |
    ' '
    create_wall(130, 20, -50, 10, 20, 10) # |
    create_wall(150, 20, -40, 10, 20, 0) # _
    create_wall(170, 20, -40, 10, 20, 0) # _
    create_wall(190, 20, -40, 10, 20, 0) # _
    create_wall(210, 20, -50, 10, 20, 10) # |
    
    # Row 5
    create_wall(-190, 20, -30, 10, 20, 10) # |
    ' '
    ' '
    ' '
    create_wall(-110, 20, -30, 10, 20, 10) # |
    create_wall(-90, 20, -20, 10, 20, 0) # _
    create_wall(-70, 20, -20, 10, 20, 0) # _
    create_wall(-50, 20, -20, 10, 20, 0) # _
    create_wall(-30, 20, -30, 10, 20, 10) # |
    ' '
    create_wall(10, 20, -30, 10, 20, 10) # |
    ' '
    ' '
    ' '
    create_wall(90, 20, -30, 10, 20, 10) # |
    create_wall(110, 20, -20, 10, 20, 0) # _
    create_wall(130, 20, -20, 10, 20, 0) # _
    create_wall(150, 20, -20, 10, 20, 0) # _
    ' '
    ' '
    create_wall(210, 20, -30, 10, 20, 10) # |
    
    # Row 6
    create_wall(-190, 20, -10, 10, 20, 10) # |
    create_wall(-170, 20,  0, 10, 20, 0) # _
    create_wall(-150, 20, -10, 10, 20, 10) # |
    ' '
    ' '
    ' '
    create_wall(-70, 20, -10, 10, 20, 10) # |
    ' '
    ' '
    create_wall(-10, 20,  0, 10, 20, 0) # _
    create_wall(10, 20, -10, 10, 20, 10) # |
    create_wall(30, 20,  0, 10, 20, 0) # _
    create_wall(50, 20, -10, 10, 20, 10) # |
    ' '
    ' '
    ' '
    ' '
    ' '
    create_wall(170, 20, -10, 10, 20, 10) # |
    ' '
    create_wall(210, 20, -10, 10, 20, 10) # |
    
    # Row 7
    create_wall(-190, 20, 10, 10, 20, 10) # |
    ' '
    ' '
    create_wall(-130, 20, 20, 10, 20, 0) # _
    create_wall(-110, 20, 10, 10, 20, 10) # |
    create_wall(-90, 20, 20, 10, 20, 0) # _
    create_wall(-70, 20, 10, 10, 20, 10) # |
    create_wall(-50, 20, 20, 10, 20, 0) # _
    create_wall(-30, 20, 20, 10, 20, 0) # _
    create_wall(-10, 20, 20, 10, 20, 0) # _
    ' '
    ' '
    create_wall(50, 20, 10, 10, 20, 10) # |
    ' '
    create_wall(90, 20, 10, 10, 20, 10) # |
    ' '
    create_wall(130, 20, 10, 10, 20, 10) # |
    create_wall(150, 20, 20, 10, 20, 0) # _
    create_wall(170, 20, 10, 10, 20, 10) # |
    create_wall(190, 20, 20, 10, 20, 0) # _
    create_wall(210, 20, 10, 10, 20, 10) # |
    
    # Row 8
    create_wall(-190, 20, 30, 10, 20, 10) # |
    ' '
    create_wall(-150, 20, 30, 10, 20, 10) # |
    ' '
    ' '
    ' '
    create_wall(-70, 20, 30, 10, 20, 10) # |
    ' '
    ' '
    create_wall(-10, 20, 40, 10, 20, 0) # _
    create_wall(10, 20, 40, 10, 20, 0) # _
    create_wall(30, 20, 40, 10, 20, 0) # _
    create_wall(50, 20, 30, 10, 20, 10) # |
    create_wall(70, 20, 40, 10, 20, 0) # _
    create_wall(90, 20, 30, 10, 20, 10) # |
    create_wall(110, 20, 40, 10, 20, 0) # _
    ' '
    ' '
    ' '
    ' '
    create_wall(210, 20, 30, 10, 20, 10) # |
    
    # Row 9
    create_wall(-190, 20, 50, 10, 20, 10) # |
    ' '
    
    
    # Row 10
    create_wall(-190, 20, 70, 10, 20, 10) # |
    
    # Row 11
    create_wall(-190, 20, 90, 10, 20, 10) # |
        maze = 
    <<-MAZE
    _____________________
      |  _____   _____  |
    | |_  |_  | |   | | |
    |  _| |   |___| |___|
    |   |___| |   |___  |
    |_|   |  _|_|     | |
    |  _|_|___  | | |_|_|
    | |   |  ___|_|_    |
    | | |___|  ___  |_| |
    | | |  ___|  _| |   |
    |_____|___________|__
    MAZE
  end
  
  def generate_dynamic_maze
    maze = Theseus::OrthogonalMaze.generate(:width => 10)
    rows = maze.to_s.split("\n")
    starting_left = -(@floor[:width] - @wall[:width])
    us_start = -@floor[:height]
    pipe_start = us_start - @wall[:width]
    create_wall(starting_left, 10, pipe_start + 20, 0, 10, 10, "start.jpg")
    rows.each_with_index do |step, row|
      puts "Row #{row + 1}"
      step.split(//).each_with_index do |type, col|
        move_right = starting_left + (col * 20) # May need that 20 to be dynamic....
        pipe_move_down = pipe_start + (row * 20)
        us_move_down = us_start + (row * 20)
        case type
        when "_"
          create_wall(move_right, @wall[:height], us_move_down, @wall[:width], @wall[:height], 0)
        when "|"
          create_wall(move_right, @wall[:height], pipe_move_down, @wall[:width], @wall[:height], 10)
        when " "
          # This is a space
        end
      end
    end
    
    puts "\n\n#{maze}\n\n"
  end
  
  
  def setup_camera!
    flyCam.move_speed = 100
  end
  
  def setup_floor!
    box = Box.new(Vector3f.new(0, 0, 0), @floor[:width], 0.2, @floor[:height])
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
  #   '_' => -(floor_width - wall_width)
  #   '|' => -floor_height
  #  vy = elevation
  #   vy == by  
  #  vz = y position
  #   '_' = -floor_height
  #   '|' = -(floor_height - wall_width)
  #  bx = x width
  #  by = height
  #  bz = y width
  def create_wall(vx, vy, vz, bx, by, bz, image = 'brickwall.jpg')
    box = Box.new(Vector3f.new(vx, vy, vz), bx, by, bz)
    wall = Geometry.new("a Wall", box)
    matl = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    #matl.set_color("Color", ColorRGBA::Gray)
    matl.set_texture("ColorMap", asset_manager.load_texture(File.join('assets', 'Textures', image)))
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
    input_manager.add_mapping("Shoot", KeyTrigger.new(KeyInput::KEY_SPACE), MouseButtonTrigger.new(MouseInput::BUTTON_LEFT))
    input_manager.add_listener(ControllerAction.new(self), "Left")
    input_manager.add_listener(ControllerAction.new(self), "Right")
    input_manager.add_listener(ControllerAction.new(self), "Up")
    input_manager.add_listener(ControllerAction.new(self), "Down")
    input_manager.add_listener(ControllerAction.new(self), "Shoot")
  end
  
  def setup_text!
    gui_node.detach_all_children
    gui_font = asset_manager.load_font(File.join("Interface", "Fonts", "Default.fnt"))
    ch = BitmapText.new(gui_font, false)
    ch.size = gui_font.char_set.rendered_size * 2
    ch.text = "+"
    ch.set_local_translation(settings.width / 2 - gui_font.char_set.rendered_size / 3 * 2, settings.height / 2 + ch.line_height / 2, 0)
    gui_node.attach_child(ch)
    
    ch2 = BitmapText.new(gui_font, false)
    ch2.size = 20
    ch2.text = "PLAY TIME:"
    ch2.set_local_translation(0, 0, 0)
    gui_node.attach_child(ch2)
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
    if cam.location.x > (@floor[:width] - 10) && cam.location.z > (@floor[:height] - 10)
      puts "FINISH!"
    end
  end
  
  class ControllerAction
    include ActionListener
    
    def initialize(obj)
      @parent = obj
    end
    
    def on_action(binding, value, tpf)
      @parent.instance_variable_set("@#{binding.downcase}", value)
      if binding.eql?("Shoot") && !value
        results = CollisionResults.new
        ray = Ray.new(@parent.cam.location, @parent.cam.direction)
        @parent.root_node.collide_with(ray, results)
        results.each_with_index do |result, index|
          dist = results.get_collision(index).distance
          pt = results.get_collision(index).contact_point
          hit = results.get_collision(index).geometry.name
        end
        
        if results.size > 0
          closest = results.closest_collision
          @parent.mark.local_translation = closest.contact_point
          @parent.root_node.attach_child(@parent.mark)
        else
          @parent.root_node.detach_child(@parent.mark)
        end
      end
    end
    
  end
  
end

Maze.new.start