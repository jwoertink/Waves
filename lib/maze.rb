require 'rubygems'
require 'bundler'
Bundler.require
require File.join(Dir.pwd, 'lib', 'waves.rb')

java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.system.AppSettings"
java_import "com.jme3.asset.TextureKey"
java_import "com.jme3.font.BitmapText"
java_import "com.jme3.audio.AudioNode"
java_import "com.jme3.bullet.BulletAppState"
java_import "com.jme3.bullet.control.CharacterControl"
java_import "com.jme3.bullet.control.RigidBodyControl"
java_import "com.jme3.bullet.util.CollisionShapeFactory"
java_import "com.jme3.bullet.collision.shapes.CapsuleCollisionShape"
java_import "com.jme3.bullet.collision.shapes.CollisionShape"
java_import "com.jme3.collision.CollisionResult"
java_import "com.jme3.collision.CollisionResults"
java_import "com.jme3.input.KeyInput"
java_import "com.jme3.input.controls.ActionListener"
java_import "com.jme3.input.controls.KeyTrigger"
java_import "com.jme3.input.MouseInput"
java_import "com.jme3.input.controls.MouseButtonTrigger"
java_import "com.jme3.light.AmbientLight"
java_import "com.jme3.light.DirectionalLight"
java_import "com.jme3.math.ColorRGBA"
java_import "com.jme3.math.Vector2f"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.math.Ray"
java_import "com.jme3.scene.Node"
java_import "com.jme3.scene.Spatial"
java_import "com.jme3.scene.shape.Box"
java_import "com.jme3.scene.shape.Sphere"
java_import "com.jme3.scene.Geometry"
java_import "com.jme3.material.Material"
java_import "com.jme3.util.SkyFactory"
java_import "com.jme3.texture.Texture"
java_import "java.util.logging.Level"
java_import "java.util.logging.Logger"


class Maze < SimpleApplication
  include ActionListener
  
  field_accessor :flyCam, :paused
  field_reader :cam, :settings
  attr_accessor :playtime, :playing, :bullet_app_state, :player, :mark, :shootables, :gun_sound, :ambient_noise
  
  def initialize
    super
    [:up, :down, :left, :right].each { |direction| self.instance_variable_set("@#{direction}", false) }
    @walk_direction = Vector3f.new
    @floor = {:width => 200, :height => 100}
    @wall = {:width => 10, :height => 20}
    self.playing = false
    config = AppSettings.new(true)
    config.settings_dialog_image = File.join("assets", "Interface", "maze_craze_logo.png")
    self.settings = config
    @time_text = nil
    @counter = 0
    @targets = []
    @targets_generated = 0
    Logger.get_logger("").level = Level::WARNING
  end
  
  def simpleInitApp
    self.bullet_app_state = BulletAppState.new
    state_manager.attach(bullet_app_state)
    
    capsule_shape = CapsuleCollisionShape.new(1.5, 15.0, 1)
    self.player = CharacterControl.new(capsule_shape, 0.05)
    player.jump_speed = 20
    player.fall_speed = 30
    player.gravity = 30
    player.physics_location = Vector3f.new(-185, 15, -95)
    # This isn't being used yet.
    player_model = asset_manager.load_model(File.join("Models", "Oto", "Oto.mesh.xml"))
    player_model.local_scale = 0.5
    player_model.local_translation = Vector3f.new(-185, 15, -95)
    player_model.add_control(player)
    bullet_app_state.physics_space.add(player_model)
    
    
    sphere = Sphere.new(30, 30, 0.2)
    self.mark = Geometry.new("BOOM!", sphere)
    mark_mat = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    mark_mat.set_color("Color", ColorRGBA::Red)
    mark.material = mark_mat
    
    setup_text!
    setup_camera!
    setup_floor!
    setup_sky!
    setup_keys!
    setup_light!
    setup_audio!
    
    generate_maze

    self.playing = true
    self.playtime = Time.now
  end
  
  def static_maze
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
  
  def generate_maze(maze = nil)
    maze = Theseus::OrthogonalMaze.generate(:width => 10)
    rows = maze.to_s.split("\n")
    starting_left = -(@floor[:width] - @wall[:width])
    us_start = -@floor[:height]
    pipe_start = us_start - @wall[:width]
    create_wall(starting_left, 10, pipe_start + 20, 0, 10, 10, {:image => "start.jpg"}) #Start wall
    create_wall(@floor[:width] + 10, 0, @floor[:height] - 10, 10, 0, 10, {:image => "stop.jpg"}) #End wall
    rows.each_with_index do |step, row|
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
          # Randomly generate a target
          if row > 0 && col > 11 && rand(100) > 90
            create_wall(move_right, @wall[:height], us_move_down, @wall[:width], @wall[:height], 0, {:image => "target.png", :name => "Target"})
            @targets_generated += 1
          end
        end
      end
    end
    
    #puts "\n\n#{maze}\n\n"
  end
  
  
  def setup_camera!
    flyCam.move_speed = 100
    cam.look_at_direction(Vector3f.new(10, 0, 0).normalize_local, Vector3f::UNIT_Y)
  end
  
  def setup_floor!
    floor = Box.new(Vector3f::ZERO, @floor[:width], 0.2, @floor[:height])
    floor.scale_texture_coordinates(Vector2f.new(3, 6))
    floor_mat = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    key = TextureKey.new(File.join('assets', 'Textures', 'hardwood.jpg'))
    key.generate_mips = true
    texture = asset_manager.load_texture(key)
    texture.wrap = Texture::WrapMode::Repeat
    floor_mat.set_texture("ColorMap", texture)
    floor_geo = Geometry.new("Floor", floor)
    floor_geo.material = floor_mat
    floor_geo.set_local_translation(0, -0.1, 0)
    root_node.attach_child(floor_geo)
    floor_phy = RigidBodyControl.new(0.0)
    floor_geo.add_control(floor_phy)
    bullet_app_state.physics_space.add(floor_phy)
  end
  
  def setup_sky!
    root_node.attach_child(SkyFactory.create_sky(asset_manager, File.join("Textures", "Sky", "Bright", "BrightSky.dds"), false))
    #view_port.background_color = ColorRGBA.new(ColorRGBA.random_color)
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
  def create_wall(vx, vy, vz, bx, by, bz, options = {})
    image = options[:image] || 'brickwall.jpg'
    name = options[:name] || "a Wall"
    box = Box.new(Vector3f.new(vx, vy, vz), bx, by, bz)
    wall = Geometry.new(name, box)
    matl = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
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
    input_manager.add_listener(ControllerAction.new(self), ["Left", "Right", "Up", "Down", "Shoot"].to_java(:string))
  end
  
  def setup_text!
    gui_node.detach_all_children
    gui_font = asset_manager.load_font(File.join("Interface", "Fonts", "Default.fnt"))
    ch = BitmapText.new(gui_font, false)
    ch.size = gui_font.char_set.rendered_size * 2
    ch.text = "+"
    ch.set_local_translation(settings.width / 2 - gui_font.char_set.rendered_size / 3 * 2, settings.height / 2 + ch.line_height / 2, 0)
    gui_node.attach_child(ch)
    
    @time_text = BitmapText.new(gui_font, false)
    @time_text.size = 20
    @time_text.color = ColorRGBA::Blue
    @time_text.text = "PLAY TIME:"
    @time_text.set_local_translation(50, 50, 0)
    gui_node.attach_child(@time_text)
  end
  
  def setup_audio!
    self.gun_sound = AudioNode.new(asset_manager, File.join("Sound", "Effects", "Gun.wav"), false)
    gun_sound.looping = false
    gun_sound.volume = 3
    root_node.attach_child(gun_sound)
    
    self.ambient_noise = AudioNode.new(asset_manager, File.join("Sound", "Environment", "Nature.ogg"), false)
    ambient_noise.looping = true
    ambient_noise.positional = true
    ambient_noise.local_translation = Vector3f::ZERO.clone
    ambient_noise.volume = 2
    root_node.attach_child(ambient_noise)
    ambient_noise.play
  end
  
  def simpleUpdate(tpf)
    @time_text.text = "PLAY TIME: #{(@counter += 1) / 1000}" if playing?
    cam_dir = cam.direction.clone.mult_local(0.6)
    cam_left = cam.left.clone.mult_local(0.4)
    @walk_direction.set(0, 0, 0)
    @walk_direction.add_local(cam_left) if @left
    @walk_direction.add_local(cam_left.negate) if @right
    @walk_direction.add_local(cam_dir) if @up
    @walk_direction.add_local(cam_dir.negate) if @down
    player.walk_direction = @walk_direction
    cam.location = player.physics_location
    if cam.location.x > (@floor[:width]) && cam.location.z > (@floor[:height] - 20) && playing?
      if @targets.empty? && @targets_generated > 0
        @time_text.text = "YOU MUST SHOOT A TARGET FIRST!"
      else
        puts "finish"
        self.playing = false
        finish_time = Time.now - playtime
        # finish_time != (@counter / 1000)
        # @targets.size == actual targets shot * 2 ....
        @time_text.text = "FINISH TIME: #{finish_time.ceil} seconds. You shot #{@targets.size}/#{@targets_generated} targets"
        self.paused = true
        input_manager.cursor_visible = true
        flyCam.enabled = false
        # use nifty
      end
      
    end
  end
  
  def playing?
    playing
  end
  
  class ControllerAction
    include ActionListener
    
    def initialize(obj)
      @parent = obj
    end
    
    def on_action(binding, value, tpf)
      @parent.instance_variable_set("@#{binding.downcase}", value)
      if binding.eql?("Shoot") && !value
        @parent.gun_sound.play_instance
        results = CollisionResults.new
        ray = Ray.new(@parent.cam.location, @parent.cam.direction)
        @parent.root_node.collide_with(ray, results)
        results.each_with_index do |result, index|
          collision = results.get_collision(index)
          dist = collision.distance
          pt = collision.contact_point
          spacial = collision.geometry
          hit = spacial.name
          if hit.eql?("Target")
            @parent.instance_variable_get("@targets") << spacial
            spacial.remove_from_parent
            @parent.bullet_app_state.physics_space.remove(spacial.get_control(RigidBodyControl.java_class))
            @parent.root_node.detach_child(@parent.mark)
          end
        end
        #Remove bullet mark after target is destroyed
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
Waves.echo("Booting Maze Craze", :green)
Maze.new.start