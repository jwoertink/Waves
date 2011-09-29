java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.collision.CollisionResult"
java_import "com.jme3.collision.CollisionResults"
java_import "com.jme3.font.BitmapText"
java_import "com.jme3.input.KeyInput"
java_import "com.jme3.input.MouseInput"
java_import "com.jme3.input.controls.ActionListener"
java_import "com.jme3.input.controls.KeyTrigger"
java_import "com.jme3.input.controls.MouseButtonTrigger"
java_import "com.jme3.light.DirectionalLight"
java_import "com.jme3.material.Material"
java_import "com.jme3.math.ColorRGBA"
java_import "com.jme3.math.Ray"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.scene.Geometry"
java_import "com.jme3.scene.Node"
java_import "com.jme3.scene.Spatial"
java_import "com.jme3.scene.shape.Box"
java_import "com.jme3.scene.shape.Sphere"

class Sample7 < SimpleApplication
  field_reader :settings, :cam
  attr_accessor :shootables, :mark
  
  def simpleInitApp
    begin
    self.shootables = Node.new("Shootables")
    root_node.attach_child(shootables)
    shootables.attach_child(make_cube("a Dragon", -2.0, 0.0, 1.0))
    shootables.attach_child(make_cube("a tin can", 1.0, -2.0, 0.0))
    shootables.attach_child(make_cube("the Sheriff", 0.0, 1.0, -2.0))
    shootables.attach_child(make_cube("the Deputy", 1.0, 0.0, -4.0))
    shootables.attach_child(make_floor)
    shootables.attach_child(make_character)
    init_cross_hairs!
    init_keys!
    init_mark!
    rescue => e
      puts "\n\nFAIL! #{e}"
    end
  end
  
  def init_keys!
    input_manager.add_mapping("Shoot", KeyTrigger.new(KeyInput::KEY_SPACE), MouseButtonTrigger.new(MouseInput::BUTTON_LEFT))
    input_manager.add_listener(ControllerAction.new(self), "Shoot")
  end
  
  def init_mark!
    sphere = Sphere.new(30, 30, 0.2)
    self.mark = Geometry.new("BOOM!", sphere)
    mark_mat = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    mark_mat.set_color("Color", ColorRGBA::Red)
    mark.material = mark_mat
  end
  
  def init_cross_hairs!
    gui_node.detach_all_children
    gui_font = asset_manager.load_font(File.join("Interface", "Fonts", "Default.fnt"))
    ch = BitmapText.new(gui_font, false)
    ch.size = gui_font.char_set.rendered_size * 2
    ch.text = "+"
    ch.set_local_translation(settings.width / 2 - gui_font.char_set.rendered_size / 3 * 2, settings.height / 2 + ch.line_height / 2, 0)
    gui_node.attach_child(ch)
  end
  
  def make_character
    golem = asset_manager.load_model(File.join("Models", "Oto", "Oto.mesh.xml"))
    golem.scale(0.5)
    golem.set_local_translation(-1.0, -1.5, -0.6)
    sun = DirectionalLight.new
    sun.direction = Vector3f.new(-0.1, -0.7, -1.0)
    golem.add_light(sun)
    golem
  end
  
  def make_cube(name, x, y, z)
    box = Box.new(Vector3f.new(x, y, z), 1, 1, 1)
    cube = Geometry.new(name, box)
    matl = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    matl.set_color("Color", ColorRGBA.random_color)
    cube.material = matl
    cube
  end
  
  def make_floor
    box = Box.new(Vector3f.new(0, -4, -5), 15, 0.2, 15)
    floor = Geometry.new("the Floor", box)
    matl = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    matl.set_color("Color", ColorRGBA::Gray)
    floor.material = matl
    floor
  end
  
  class ControllerAction
    include ActionListener
    
    def initialize(obj)
      @parent = obj
    end
    
    def on_action(name, key_pressed, time_per_frame)
      if name.eql?("Shoot") && !key_pressed
        results = CollisionResults.new
        ray = Ray.new(@parent.cam.location, @parent.cam.direction)
        @parent.shootables.collide_with(ray, results)
        puts "\n\n Collisions? #{results.size} \n\n"
        results.each_with_index do |result, index|
          dist = results.get_collision(index).distance
          pt = results.get_collision(index).contact_point
          hit = results.get_collision(index).geometry.name
          puts "\n\n* Collision # #{index}"
          puts " You shot #{hit} at #{pt}, #{dist} wu away.\n\n"
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
