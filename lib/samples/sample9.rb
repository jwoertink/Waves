=begin
  This sample creates a full landscape with hills, dirt trails, and rocks from 3 jpg images.
  TODO: this isn't loading for some reason.
=end

java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.material.Material"
java_import "com.jme3.terrain.geomipmap.TerrainLodControl"
java_import "com.jme3.terrain.heightmap.AbstractHeightMap"
java_import "com.jme3.terrain.geomipmap.TerrainQuad"
java_import "com.jme3.terrain.geomipmap.lodcalc.DistanceLodCalculator"
java_import "com.jme3.terrain.heightmap.HillHeightMap"
java_import "com.jme3.terrain.heightmap.ImageBasedHeightMap"
java_import "com.jme3.texture.Texture" # ::WrapMode
java_import "jme3tools.converters.ImageToAwt"

class Sample9 < SimpleApplication
  field_accessor :flyCam
  def simpleInitApp
    begin
      flyCam.move_speed = 50
    
      @mat_terrain = Material.new(asset_manager, File.join("Common", "MatDefs", "Terrain", "Terrain.j3md"))
      @mat_terrain.set_texture("Alpha", asset_manager.load_texture(File.join("Textures", "Terrain", "splat", "alphamap.png")))

      grass = asset_manager.load_texture(File.join("Textures", "Terrain", "splat", "grass.jpg"))
      grass.wrap = Texture::WrapMode::Repeat
      @mat_terrain.set_texture("Tex1", grass)
      @mat_terrain.set_float("Tex1Scale", 64.0)
      
      dirt = asset_manager.load_texture(File.join("Textures", "Terrain", "splat", "dirt.jpg"))
      dirt.wrap = Texture::WrapMode::Repeat
      @mat_terrain.set_texture("Tex2", dirt)
      @mat_terrain.set_float("Tex2Scale", 32.0)

      rock = asset_manager.load_texture(File.join("Textures", "Terrain", "splat", "road.jpg"))
      rock.wrap = Texture::WrapMode::Repeat
      @mat_terrain.set_texture("Tex3", rock)
      @mat_terrain.set_float("Tex3Scale", 128.0)

      height_map_image = asset_manager.load_texture(File.join("Textures", "Terrain", "splat", "mountains512.png"))
      heightmap = ImageBasedHeightMap.new(ImageToAwt.convert(height_map_image.image, false, true, 0))
      heightmap.load
      
      patch_size = 65
      @terrain = TerrainQuad.new("my terrain", patch_size, 513, heightmap.height_map)
      @terrain.material = @mat_terrain
      @terrain.set_local_translation(0, -100, 0)
      @terrain.set_local_scale(2.0, 1.0, 2.0)
      
      root_node.attach_child(@terrain)
      control = TerrainLodControl.new(@terrain, get_camera)
      
      # FAILS HERE....
      #control.lod_calculator = DistanceLodCalculator.new(patch_size, 2.7)
      @terrain.add_control(control)
      puts "finish...."
    rescue => e
      puts "#{e}"
    end
  end
  
end