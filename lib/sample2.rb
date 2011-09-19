=begin
  This sample takes a ninja, teapot, and a brick wall, and positions them on screen
  You can use 'W' 'A' 'S' 'D' to move around. 'Q' and 'Z' allow you to move up and down.
=end


java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.font.BitmapText"
java_import "com.jme3.light.DirectionalLight"
java_import "com.jme3.material.Material"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.scene.Geometry"
java_import "com.jme3.scene.shape.Box"

class Sample2 < SimpleApplication
  
  def simpleInitApp
    teapot = asset_manager.load_model(File.join('Models', 'Teapot', 'Teapot.obj'))
    mat_default = Material.new(asset_manager, File.join('Common', 'MatDefs', 'Misc', 'ShowNormals.j3md'))
    teapot.material = mat_default
    root_node.attach_child(teapot)
    
    box = Box.new(Vector3f::ZERO, 2.5, 2.5, 1.0)
    wall = Geometry.new("Box", box)
    mat_brick = Material.new(asset_manager, File.join('Common', 'MatDefs', 'Misc', 'Unshaded.j3md'))
    mat_brick.set_texture("ColorMap", asset_manager.load_texture(File.join('Textures', 'Terrain', 'BrickWall', 'BrickWall.jpg')))
    wall.material = mat_brick
    wall.set_local_translation(2.0, -2.5, 0.0)
    root_node.attach_child(wall)
    
    gui_node.detach_all_children #this method should have a !
    gui_font = asset_manager.load_font(File.join('Interface', 'Fonts', 'Default.fnt'))
    hello_text = BitmapText.new(gui_font, false)
    hello_text.size = gui_font.char_set.rendered_size
    hello_text.text = "Hello World"
    hello_text.set_local_translation(300, hello_text.line_height, 0)
    gui_node.attach_child(hello_text)
    
    ninja = asset_manager.load_model(File.join("Models", "Ninja", "Ninja.mesh.xml"))
    ninja.scale(0.05, 0.05, 0.05)
    ninja.rotate(0.0, -3.0, 0.0)
    ninja.set_local_translation(0.0, -5.0, -2.0)
    root_node.attach_child(ninja)
    
    sun = DirectionalLight.new
    sun.direction = Vector3f.new(-0.1, -0.7, -1.0)
    root_node.add_light(sun)
  end
  
end
