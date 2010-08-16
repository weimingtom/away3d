package away3dlite.templates
{
	import away3dlite.arcane;
	import away3dlite.cameras.*;
	import away3dlite.containers.*;
	import away3dlite.core.IDestroyable;
	import away3dlite.debug.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.Rectangle;
	import flash.text.*;

	use namespace arcane;

	/**
	 * Base template class.
	 */
	public class Template extends Sprite implements IDestroyable
	{
		/** @private */
		protected var _isDestroyed:Boolean;

		// stage
		protected var _stageWidth:Number = stage ? stage.stageWidth : NaN;
		protected var _stageHeight:Number = stage ? stage.stageHeight : NaN;
		protected var _screenRect:Rectangle;

		public function get screenRect():Rectangle
		{
			return _screenRect;
		}

		public function set screenRect(value:Rectangle):void
		{
			scrollRect = _screenRect;
			_screenRect = value;
		}

		// debug
		protected var _debugLayer:Sprite;
		protected var _stats:AwayStats;
		protected var _debugText:TextField;
		private var _title:String = "Away3DLite";
		private var _debug:Boolean = true;

		protected function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			// setup stage
			initStage();

			// init 3D
			init();

			// init debug
			initDebug();
		}

		protected function initStage():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.MEDIUM;

			if (!_screenRect)
			{
				_screenRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
				_screenRect.width = _stageWidth ? _stageWidth : _screenRect.width;
				_screenRect.height = _stageHeight ? _stageHeight : _screenRect.height;
			}

			scrollRect = _screenRect;

			onStage();
		}

		protected function onStage():void
		{
			// override me
		}

		/** @private */
		arcane function init():void
		{
			// init view
			addChild(view = new View3D(scene = new Scene3D(), camera = _camera?_camera:new Camera3D()));

			// default camera setting
			camera.z = -1000;

			// screen size
			if (_screenRect && _screenRect.width && _screenRect.height)
			{
				// init size
				view.setSize(_screenRect.width, _screenRect.height);

				// center view to stage
				view.x = _screenRect.width / 2;
				view.y = _screenRect.height / 2;
			}

			// add enterframe listener
			start();

			// trigger onInit method
			onInit();
		}

		protected function initDebug():void
		{
			if(!_debug)
				return;
			
			addChild(_debugLayer = new Sprite());
			_debugLayer.addChild(_stats = new AwayStats());

			// init debug textfield
			_debugText = new TextField();
			_debugText.selectable = false;
			_debugText.mouseEnabled = false;
			_debugText.mouseWheelEnabled = false;
			_debugText.defaultTextFormat = new TextFormat("Tahoma", 12, 0x000000);
			_debugText.autoSize = "left";
			_debugText.x = _stats.width + 10;
			_debugText.textColor = 0xFFFFFF;
			_debugText.filters = [new GlowFilter(0x000000, 1, 4, 4, 2, 1)];

			// add debug textfield to the displaylist
			_debugLayer.addChild(_debugText);

			// set default debug
			debug = true;

			// set default title
			title = _title;
		}

		protected function onEnterFrame(event:Event):void
		{
			onPreRender();

			view.render();

			if (_debug)
			{
				_debugText.text = _title + " Object3D(s) : " + view.totalObjects + ", Face(s) : " + view.totalFaces;
				onDebug();
			}

			onPostRender();
		}

		/**
		 * Fired on instantiation of the template.
		 */
		protected function onInit():void
		{
			// override me
		}

		/**
		 * Fired at the beginning of a render loop.
		 */
		protected function onPreRender():void
		{
			// override me
		}

		/**
		 * Fired if debug is set to true.
		 *
		 * @see #debug
		 */
		protected function onDebug():void
		{
			// override me
		}

		/**
		 * Fired at the end of a render loop.
		 */
		protected function onPostRender():void
		{
			// override me
		}

		/**
		 * Defines the text appearing in the template title.
		 */
		public function get title():String
		{
			return _title;
		}

		public function set title(val:String):void
		{
			if (_title == val)
				return;

			_title = val;
		}

		/**
		 * Defines if the template is run in debug mode.
		 */
		public function get debug():Boolean
		{
			return _debug;
		}

		public function set debug(val:Boolean):void
		{
			if (_debug == val)
				return;

			_debug = val;

			if (_debugLayer && !_debugLayer.parent)
			{
				if (_debug)
					_debugLayer.parent.addChild(_debugLayer);
				else
					_debugLayer.parent.removeChild(_debugLayer);
			}
		}

		/**
		 * The scene object used in the template.
		 */
		public var scene:Scene3D;

		/** @private */
		protected var _camera:Camera3D;
		
		/**
		 * The camera object used in the template.
		 */
		public function get camera():Camera3D
		{
			return _camera;
		}

		public function set camera(value:Camera3D):void
		{
			_camera = value;
			
			if(view)
				view.camera = value;
		}

		/**
		 * The view object used in the template.
		 */
		public var view:View3D;

		/**
		 * Creates a new <code>Template</code> object.
		 */
		public function Template()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
		}

		/**
		 * Starts the view rendering.
		 */
		public function start():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
		}

		/**
		 * Stops the view rendering.
		 */
		public function stop():void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		public function get destroyed():Boolean
		{
			return _isDestroyed;
		}

		public function destroy():void
		{
			_isDestroyed = true;
			
			stop();

			if (_debugText && _debugText.parent)
				_debugText.parent.removeChild(_debugText);
			_debugText = null;

			if(_stats)
				_stats.destroy();
			_stats = null;

			if (_debugLayer && _debugLayer.parent)
				_debugLayer.parent.removeChild(_debugLayer);
			_debugLayer = null;

			if(scene)
				scene.destroy();
			scene = null;
			
			if(camera)
				camera.destroy();
			camera = null;

			if(view)
				view.destroy();
			view = null;
		}
	}
}