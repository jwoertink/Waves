require 'java'

PROJECT_ROOT = File.expand_path('..', File.dirname(__FILE__))
COMMON_DIR = File.join(PROJECT_ROOT, 'vendor', 'Common')

require File.join(PROJECT_ROOT, 'vendor', 'jme3_2011-08-29.jar')

java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.material.Material"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.scene.Geometry"
java_import "com.jme3.scene.shape.Box"
java_import "com.jme3.math.ColorRGBA"
java_import "com.jme3.scene.Node"

class Waves < SimpleApplication
  
  def simpleInitApp
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
    
    pivot = Node.new("pivot")
    self.root_node.attach_child(pivot)
    pivot.attach_child(blue)
    pivot.attach_child(red)
    pivot.rotate(0.4, 0.4, 0.0)
  end
  
end