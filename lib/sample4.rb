java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.material.Material"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.scene.Geometry"
java_import "com.jme3.scene.shape.Box"
java_import "com.jme3.math.ColorRGBA"
java_import "com.jme3.input.KeyInput"
java_import "com.jme3.input.MouseInput"
java_import "com.jme3.input.controls.ActionListener"
java_import "com.jme3.input.controls.AnalogListener"
java_import "com.jme3.input.controls.KeyTrigger"
java_import "com.jme3.input.controls.MouseButtonTrigger"

class Sample4 < SimpleApplication
  
  def initialize
    @is_running = true
  end
  
  def simpleInitApp
    b = Box.new(Vector3f::ZERO, 1, 1, 1)
    @player = Geometry.new("Player", b)
    mat = Material.new(asset_manager, File.join("Common", "MatDefs", "Misc", "Unshaded.j3md"))
    mat.set_color("Color", ColorRGBA::Blue)
    @player.material = mat
    root_node.attach_child(@player)
    initKeys
  end
  
  def initKeys
    input_manager.add_mapping("Pause", KeyTrigger.new(KeyInput::KEY_P))
    input_manager.add_mapping("Left", KeyTrigger.new(KeyInput::KEY_J))
    input_manager.add_mapping("Right", KeyTrigger.new(KeyInput::KEY_K))
    input_manager.add_mapping("Rotate", KeyTrigger.new(KeyInput::KEY_SPACE), MouseButtonTrigger.new(MouseInput::BUTTON_LEFT))
    
    input_manager.add_listener(action_listener, ["Pause"].to_java(:string))
    input_manager.add_listener(analog_listener, ["Left", "Right", "Rotate"].to_java(:string))
  end
    
    # def action_listener 
    #   Class.new {
    #     include ActionListener
    #     def on_action(name, key_pressed, time_per_frame)
    #       if name.eql?("Pause") && !key_pressed
    #         @is_running = !@is_running
    #       end
    #     end
    #   }.new
    # end
    # 
    # def action_listener 
    #   ActionListener.new {
    #     def on_action(name, key_pressed, time_per_frame)
    #       @is_running = !@is_running if name.eql?("Pause") && !key_pressed
    #     end
    #   }
    # end
    
    def action_listener
      ActionListener.impl {
        def on_action(name, key_pressed, time_per_frame)
          @is_running = !@is_running if name.eql?("Pause") && !key_pressed
        end
      }
    end
    
    def analog_listener 
      Class.new {
        include AnalogListener
        def on_analog(name, value, time_per_frame)
          if @is_running
            case name
            when "Rotate"
              @player.rotate(0, value * speed, 0)
            when "Right"
              v = @player.local_translation
              @player.set_local_translation(v.x + value * speed, v.y, v.z)
            when "Left"
              v = @player.local_translation
              @player.set_local_translation(v.x - value * speed, v.y, v.z)
            else
              puts "Press P to unpause."
            end
          end
        end
      }.new
    end
  
end