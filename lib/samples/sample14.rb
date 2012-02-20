=begin
  This is a Ragdoll Sample
=end
java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.bullet.BulletAppState"
java_import "com.jme3.bullet.PhysicsSpace"
java_import "com.jme3.bullet.collision.shapes.CapsuleCollisionShape"
java_import "com.jme3.bullet.control.RigidBodyControl"
java_import "com.jme3.bullet.joints.ConeJoint"
java_import "com.jme3.bullet.joints.PhysicsJoint"
java_import "com.jme3.input.controls.ActionListener"
java_import "com.jme3.input.controls.MouseButtonTrigger"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.scene.Node"

class Sample14 < SimpleApplication
  include ActionListener
  java_alias :simpleInitApp, :simple_init_app
  
  def simple_init_app
    
  end
  
  def create_rag_doll
    
  end
  
  def create_limb(width, height, location, rotate)
    
  end
  
  def join(node_a, node_b, connection_point)
    
  end
  
  def simpleUpdate
    
  end
  
  class ControllerAction
    include ActionListener
  end
  
  
end
