=begin
  This sample takes 2 boxes, and makes them rotate at different speeds
  You can use 'W' 'A' 'S' 'D' to move around. 'Q' and 'Z' allow you to move up and down.
=end


java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.material.Material"
java_import "com.jme3.math.ColorRGBA"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.scene.Geometry"
java_import "com.jme3.scene.shape.Box"

class Sample3 < SimpleApplication
  
  def simpleInitApp
    b = Box.new(Vector3f::ZERO, 1, 1, 1)
    @player = Geometry.new("blue cube", b)
    mat = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    mat.set_color("Color", ColorRGBA::Blue)
    @player.material = mat
    root_node.attach_child(@player)
    
    b2 = Box.new(Vector3f.new(1, 3, 1), 1, 1, 1)
    @player2 = Geometry.new("red cube", b2)
    mat2 = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    mat2.set_color("Color", ColorRGBA::Red)
    @player2.material = mat2
    root_node.attach_child(@player2)   
  end
  
  def simpleUpdate(time_per_frame)
    @player.rotate(0, 2 * time_per_frame, 0)
    @player2.rotate(0, time_per_frame, 0)
  end
  
end
