java_import "com.jme3.bullet.PhysicsSpace"
java_import "com.jme3.bullet.PhysicsTickListener"
java_import "com.jme3.bullet.collision.PhysicsCollisionEvent"
java_import "com.jme3.bullet.collision.PhysicsCollisionListener"
java_import "com.jme3.bullet.collision.PhysicsCollisionObject"
java_import "com.jme3.bullet.collision.shapes.CollisionShape"
java_import "com.jme3.bullet.collision.shapes.SphereCollisionShape"
java_import "com.jme3.bullet.control.RigidBodyControl"
java_import "com.jme3.bullet.objects.PhysicsGhostObject"
java_import "com.jme3.bullet.objects.PhysicsRigidBody"
java_import "com.jme3.math.Vector3f"
java_import "java.util.Iterator"


class BombControl < RigidBodyControl
  include PhysicsCollisionListener
  include PhysicsTickListener
  attr_accessor :ghost_object
  
  def initialize(shape, mass)
    super
    @explosion_radius = 10
    @vector = Vector3f.new
    @vector2 = Vector3f.new
    @force_factor = 1
    create_ghost_object
  end
  
  def create_ghost_object
    self.ghost_object = PhysicsGhostObject.new(SphereCollisionShape.new(@explosion_radius))
  end
  
  def physical_space=(space)
    super(space)
    space.add_collision_listener(self) unless space.nil?
  end
  
  def collision(event)
    return if space.nil?
    if event.object_a == self || event.object_b == self
      space.add(ghost_object)
      ghost_object.physics_location = physics_location(@vector)
      space.add_tick_listener(self)
      space.remove(self)
      spatial.remove_from_parent
    end
  end
  
  def physics_tick(space, f)
    # get all overlapping objects and apply impulse to them
    # for (Iterator<PhysicsCollisionObject> it = ghostObject.getOverlappingObjects().iterator(); it.hasNext();)
    ghost_object.overlapping_objects.each do |physics_collision_object|
      if physics_collision_object.kind_of? PhysicsRigidBody
        r_body = physics_collision_object
        @vector2.subtract_local(@vector)
        force = @explosion_radius - @vector2.length
        force *= @force_factor
        @vector2.normalize_local
        @vector2.mult_local(force)
        physics_collision_object.apply_impulse(@vector2, Vector3f::ZERO)
      end
    end
    space.remove_collision_listener(self)
    space.remove_tick_listener(self)
    space.remove(ghost_obect)    
  end
  
  def explosion_radius
    @explosion_radius
  end
  
  def explosion_radius=(radius)
    @explosion_radius = radius
    create_ghost_object
  end
 
end
