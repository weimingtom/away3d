﻿/*

Skybox example in away3dlite

Demonstrates:

How to import a QTVR texture as a single image.
How to use the SkyBox6 object with a skybox texture.

Code by Rob Bateman
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk

Graphics by Peter Kapelyan
flashnine@gmail.com
http://www.flashten.com/

This code is distributed under the MIT License

Copyright (c)  

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

package
{
	import away3dlite.cameras.*;
	import away3dlite.containers.*;
	import away3dlite.core.clip.*;
	import away3dlite.core.utils.*;
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	
	import net.hires.debug.Stats;
	
	[SWF(backgroundColor="#000000", frameRate="60", quality="MEDIUM", width="800", height="600")]
	
	public class Intermediate_Skybox extends Sprite
	{
		//signature swf
    	[Embed(source="assets/signature_lite_peter.swf", symbol="Signature")]
    	private var SignatureSwf:Class;
    	
		//skybox image 1
		[Embed(source="assets/peterskybox1.jpg")]
    	public var SkyImage1:Class;
    	
    	//skybox image 2
		[Embed(source="assets/peterskybox2.jpg")]
    	public var SkyImage2:Class;
    	
    	//engine variables
    	private var scene:Scene3D;
		private var camera:HoverCamera3D;
		private var clipping:RectangleClipping;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var material:BitmapMaterial;
		
		//scene objects
		private var skybox:Skybox6;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		/**
		 * Constructor
		 */
		public function Intermediate_Skybox()
		{
			init();
		}
		
		/**
		 * Global initialise function
		 */
		private function init():void
		{
			initEngine();
			initMaterials();
			initObjects();
			initListeners();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			scene = new Scene3D();
			
			camera = new HoverCamera3D();
			camera.focus = 50;
			camera.minTiltAngle = -90;
			camera.maxTiltAngle = 90;
			camera.panAngle = 0;
			camera.tiltAngle = 0;
			camera.hover(true);
			
			clipping = new RectangleClipping();
			clipping.minX = -400;
			clipping.minY = -300;
			clipping.maxX = 400;
			clipping.maxY = 300;
			
			view = new View3D();
			view.scene = scene;
			view.camera = camera;
			view.clipping = clipping;
			
			//view.addSourceURL("srcview/index.html");
			addChild(view);
			
			//add signature
            Signature = Sprite(new SignatureSwf());
            SignatureBitmap = new Bitmap(new BitmapData(Signature.width, Signature.height, true, 0));
            stage.quality = StageQuality.HIGH;
            SignatureBitmap.bitmapData.draw(Signature);
            stage.quality = StageQuality.MEDIUM;
            addChild(SignatureBitmap);
            
            addChild(new Stats);
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			material = new BitmapMaterial(Cast.bitmap(SkyImage2));
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			skybox = new Skybox6();
			skybox.material = material;
			scene.addChild(skybox);
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			if (move) {
				camera.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
				camera.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
			}
			
			camera.hover();
			view.render();
		}
		
		/**
		 * Mouse down listener for navigation
		 */
		private function onMouseDown(event:MouseEvent):void
        {
            lastPanAngle = camera.panAngle;
            lastTiltAngle = camera.tiltAngle;
            lastMouseX = stage.mouseX;
            lastMouseY = stage.mouseY;
        	move = true;
        	stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
        }
		
		/**
		 * Mouse up listener for navigation
		 */
        private function onMouseUp(event:MouseEvent):void
        {
        	move = false;
        	stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);     
        }
        
		/**
		 * Mouse stage leave listener for navigation
		 */
        private function onStageMouseLeave(event:Event):void
        {
        	move = false;
        	stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);     
        }
        
        /**
		 * Stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			view.x = stage.stageWidth / 2;
            view.y = stage.stageHeight / 2;
            SignatureBitmap.y = stage.stageHeight - Signature.height;
		}
	}
}