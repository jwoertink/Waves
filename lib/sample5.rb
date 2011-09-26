java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.light.DirectionalLight"
java_import "com.jme3.material.Material"
java_import "com.jme3.material.RenderState"
java_import "com.jme3.math.ColorRGBA"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.scene.Geometry"
java_import "com.jme3.scene.shape.Box"
java_import "com.jme3.scene.shape.Sphere"
java_import "com.jme3.texture.Texture"
java_import "com.jme3.util.TangentBinormalGenerator"
java_import "com.jme3.renderer.queue.RenderQueue"

class Sample5 < SimpleApplication
  
  def simpleInitApp
    boxshape1 = Box.new(Vector3f.new(-3.0, 1.1, 0.0), 1.0, 1.0, 1.0)
    cube = Geometry.new("My Textured Box", boxshape1)
    mat_stl = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    tex_ml = asset_manager.load_texture(File.join("Interface", "Logo", "Monkey.jpg"))
    mat_stl.set_texture("ColorMap", tex_ml)
    cube.material = mat_stl
    root_node.attach_child(cube)
    
    boxshape3 = Box.new(Vector3f.new(0.0, 0.0, 0.0), 1.0, 1.0, 0.01)
    window_frame = Geometry.new("window frame", boxshape3)
    mat_tt = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    mat_tt.set_texture("ColorMap", asset_manager.load_texture(File.join("Textures", "ColoredTex", "Monkey.png")))
    mat_tt.additional_render_state.blend_mode = RenderState::BlendMode::Alpha
    window_frame.material = mat_tt
    window_frame.queue_bucket = RenderQueue::Bucket::Transparent
    root_node.attach_child(window_frame)
    
    boxshape4 = Box.new(Vector3f.new(3.0, -1.0, 0.0), 1.0, 1.0, 1.0)
    cube_leak = Geometry.new("Leak-through color cube", boxshape4)
    mat_tl = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    mat_tl.set_texture("ColorMap", asset_manager.load_texture(File.join("Textures", "ColoredTex", "Monkey.png")))
    mat_tl.set_color("Color", ColorRGBA.new(1.0, 0.0, 1.0, 1.0))
    cube_leak.material = mat_tl
    root_node.attach_child(cube_leak)
    
    rock = Sphere.new(32, 32, 2.0);
    shiny_rock = Geometry.new("Shiny rock", rock);
    rock.texture_mode = Sphere::TextureMode::Projected
    TangentBinormalGenerator.generate(rock)
    mat_lit = Material.new(asset_manager, File.join("Common", "MatDefs", "Light", "Lighting.j3md"))
    # This texture seems to be missing....
    mat_lit.set_texture("DiffuseMap", asset_manager.load_texture(File.join("Textures", "Terrain", "Pond", "Pond.jpg")))
    mat_lit.set_texture("NormalMap", asset_manager.load_texture(File.join("Textures", "Terrain", "Pond", "Pond_normal.png")))
    mat_lit.set_float("Shininess", 5.0)
    shiny_rock.material = mat_lit
    shiny_rock.set_local_translation(0, 2, -2)
    shiny_rock.rotate(1.6, 0, 0)
    root_node.attach_child(shiny_rock)
    
    sun = DirectionalLight.new
    sun.direction = Vector3f.new(1, 0, -2).normalize_local
    sun.color = ColorRGBA::White
    root_node.add_light(sun)
  end
  
end
