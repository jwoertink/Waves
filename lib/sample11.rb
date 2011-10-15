=begin
  This example shows 3 particle effects. A fire with a smoke ball going around it, and debris falling from the fire.
=end

java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.effect.ParticleEmitter"
java_import "com.jme3.effect.ParticleMesh"
java_import "com.jme3.material.Material"
java_import "com.jme3.math.ColorRGBA"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.effect.shapes.EmitterSphereShape"
java_import "com.jme3.input.KeyInput"
java_import "com.jme3.input.controls.ActionListener"
java_import "com.jme3.input.controls.InputListener"
java_import "com.jme3.input.controls.KeyTrigger"
java_import "com.jme3.math.FastMath"


class Sample11 < SimpleApplication
  include ActionListener
  
  attr_accessor :emit, :angle
  
  def initialize
    self.angle = 0.0
  end
  
  def simpleInitApp
    fire = ParticleEmitter.new("Emitter", ParticleMesh::Type::Triangle, 30)
    mat_red = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Particle.j3md"))
    mat_red.set_texture("Texture", asset_manager.load_texture(File.join("Effects", "Explosion", "flame.png")))
    fire.material = mat_red
    fire.images_x = 2
    fire.images_y = 2
    fire.end_color = ColorRGBA.new(1.0, 0.0, 0.0, 1.0) #red
    fire.start_color = ColorRGBA.new(1.0, 1.0, 0.0, 0.5) #yellow
    fire.particle_influencer.initial_velocity = Vector3f.new(0, 2, 0)
    fire.start_size = 1.5
    fire.end_size = 0.1
    fire.set_gravity(0, 0, 0)
    fire.low_life = 1.0
    fire.high_life = 3.0
    fire.particle_influencer.velocity_variation = 0.3
    root_node.attach_child(fire)
    
    debris = ParticleEmitter.new("Debris", ParticleMesh::Type::Triangle, 10)
    debris_mat = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Particle.j3md"))
    debris_mat.set_texture("Texture", asset_manager.load_texture(File.join("Effects", "Explosion", "Debris.png")))
    debris.material = debris_mat
    debris.images_x = 3
    debris.images_y = 3 #3x3 texture animation
    debris.rotate_speed = 4
    debris.select_random_image = true
    debris.particle_influencer.initial_velocity = Vector3f.new(0, 4, 0)
    debris.start_color = ColorRGBA::White
    debris.set_gravity(0, 6, 0)
    debris.particle_influencer.velocity_variation = 0.6
    root_node.attach_child(debris)
    debris.emit_all_particles
    
    self.emit = ParticleEmitter.new("Smoke", ParticleMesh::Type::Triangle, 300)
    emit.set_gravity(0, 0, 0)
    emit.velocity_variation = 1
    emit.low_life = 1
    emit.high_life = 1
    emit.initial_velocity = Vector3f.new(0, 0.5, 0)
    emit.images_x = 15
    mat = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Particle.j3md"))
    mat.set_texture("Texture", asset_manager.load_texture(File.join("Effects", "Smoke", "Smoke.png")))
    emit.material = mat
    root_node.attach_child(emit)
    
    init_keys!
  end
  
  def init_keys!
    input_manager.add_mapping("setNum", KeyTrigger.new(KeyInput::KEY_SPACE))
    input_manager.add_listener(ControllerAction.new(self), "setNum")
  end
  
  def simpleUpdate(tpf)
    self.angle += tpf
    self.angle %= FastMath::TWO_PI
    x = FastMath.cos(angle) * 2
    y = FastMath.sin(angle) * 2
    emit.set_local_translation(x, 0, y)
  end
  
  class ControllerAction
    
    def initialize(obj)
      @parent = obj
    end
    
    def on_action(name, is_pressed, tpf)
      if name.eql?("setNum") && is_pressed
        @parent.emit.num_particles = 1000
      end
    end
    
  end
  
end