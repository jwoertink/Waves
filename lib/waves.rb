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

class Waves < SimpleApplication
  
  def simpleInitApp
    box = Box.new(Vector3f::ZERO, 1, 1, 1)
    geometry = Geometry.new("Box", box)
    material = Material.new(self.asset_manager, File.join('Common', 'MatDefs', 'Misc', 'Unshaded.j3md'))
    material.set_color("Color", ColorRGBA::Red)
    geometry.material = material
    self.root_node.attach_child(geometry)
  end
  
end