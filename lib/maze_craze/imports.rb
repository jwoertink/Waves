require 'rubygems'
require 'java'
require 'jruby/core_ext'
require 'bundler'
Bundler.require

GAME_ROOT_PATH = File.expand_path(File.dirname(__FILE__))
$CLASSPATH << File.join(GAME_ROOT_PATH, "java", "classes")

$: << File.join(GAME_ROOT_PATH)

require File.join(GAME_ROOT_PATH, '..', '..', 'vendor', 'jme3_2011-11-13.jar')

java_import "com.jme3.app.SimpleApplication"
java_import "com.jme3.system.AppSettings"
java_import "com.jme3.system.NanoTimer"
java_import "com.jme3.asset.TextureKey"
java_import "com.jme3.font.BitmapText"
java_import "com.jme3.audio.AudioNode"
java_import "com.jme3.bullet.BulletAppState"
java_import "com.jme3.bullet.control.CharacterControl"
java_import "com.jme3.bullet.control.RigidBodyControl"
java_import "com.jme3.bullet.util.CollisionShapeFactory"
java_import "com.jme3.bullet.collision.shapes.CapsuleCollisionShape"
java_import "com.jme3.bullet.collision.shapes.CollisionShape"
java_import "com.jme3.collision.CollisionResult"
java_import "com.jme3.collision.CollisionResults"
java_import "com.jme3.input.KeyInput"
java_import "com.jme3.input.controls.ActionListener"
java_import "com.jme3.input.controls.KeyTrigger"
java_import "com.jme3.input.MouseInput"
java_import "com.jme3.input.controls.MouseButtonTrigger"
java_import "com.jme3.light.AmbientLight"
java_import "com.jme3.light.DirectionalLight"
java_import "com.jme3.math.ColorRGBA"
java_import "com.jme3.math.Vector2f"
java_import "com.jme3.math.Vector3f"
java_import "com.jme3.math.Ray"
java_import "com.jme3.scene.Node"
java_import "com.jme3.scene.Spatial"
java_import "com.jme3.scene.shape.Box"
java_import "com.jme3.scene.shape.Sphere"
java_import "com.jme3.scene.Geometry"
java_import "com.jme3.material.Material"
java_import "com.jme3.util.SkyFactory"
java_import "com.jme3.texture.Texture"
java_import "com.jme3.material.RenderState"
java_import "com.jme3.niftygui.NiftyJmeDisplay"
java_import "de.lessvoid.nifty.Nifty"
java_import "de.lessvoid.nifty.screen.Screen"
java_import "de.lessvoid.nifty.screen.ScreenController"
java_import "java.util.logging.Level"
java_import "java.util.logging.Logger"

java_import "java.awt.DisplayMode"
java_import "java.awt.GraphicsDevice"
java_import "java.awt.GraphicsEnvironment"

java_import "StartScreenController"
# java_import "HudScreenController"
# java_import "PauseScreenController"
# java_import "EndScreenController"
