require 'java'

PROJECT_ROOT = File.expand_path('..', File.dirname(__FILE__))
COMMON_DIR = File.join(PROJECT_ROOT, 'vendor', 'Common')

require File.join(PROJECT_ROOT, 'vendor', 'jme3_2011-08-29.jar')

java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.font.BitmapText"
java_import "com.jme3.light.DirectionalLight"
java_import "com.jme3.material.Material"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.scene.Geometry"
java_import "com.jme3.scene.shape.Box"
java_import "com.jme3.math.ColorRGBA"
java_import "com.jme3.scene.Node"

class Waves < SimpleApplication
  
  # This is the initial sample
  def simpleInitApp_old
    box1 = Box.new(Vector3f.new(1,-1,1), 1, 1, 1)
    blue = Geometry.new("Box", box1)
    material1 = Material.new(self.asset_manager, File.join('Common', 'MatDefs', 'Misc', 'Unshaded.j3md'))
    material1.set_color("Color", ColorRGBA::Blue)
    blue.material = material1
    
    box2 = Box.new(Vector3f.new(1,3,1), 1, 1, 1)
    red = Geometry.new("Box", box2)
    material2 = Material.new(self.asset_manager, File.join('Common', 'MatDefs', 'Misc', 'Unshaded.j3md'))
    material2.set_color("Color", ColorRGBA::Red)
    red.material = material2
    
    mesh = Box.new(Vector3f::ZERO, 1, 1, 1)
    thing = Geometry.new("thing", mesh)
    mat = Material.new(asset_manager, File.join('Common', 'MatDefs', 'Misc', 'ShowNormals.j3md'))
    thing.set_material(mat)
    self.root_node.attach_child(thing)
    
    pivot = Node.new("pivot")
    self.root_node.attach_child(pivot)
    pivot.attach_child(blue)
    pivot.attach_child(red)
    pivot.rotate(0.4, 0.4, 0.0)
  end
  
  # This method is ran after calling start()
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