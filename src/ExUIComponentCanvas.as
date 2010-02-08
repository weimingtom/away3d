package
{
	import away3dlite.cameras.Camera3D;
	import away3dlite.containers.Scene3D;
	import away3dlite.containers.View3D;
	import away3dlite.materials.WireColorMaterial;
	import away3dlite.primitives.Sphere;

	import flash.events.Event;

	import mx.core.UIComponent;

	public class ExUIComponentCanvas extends UIComponent
	{
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;

		public function ExUIComponentCanvas()
		{
			super();
		}

		override protected function childrenCreated():void
		{
			super.childrenCreated();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		protected function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			init();
		}

		/**
		 * Global initialise function
		 */
		private function init():void
		{
			initEngine();
			initObjects();
			initListeners();
		}

		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			scene = new Scene3D();
			camera = new Camera3D();
			camera.z = -1000;

			view = new View3D(scene, camera);
			view.x = 800 / 2;
			view.y = 600 / 2;
			addChild(view);
		}

		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			scene.addChild(new Sphere(new WireColorMaterial(0xFF0000), 100, 6, 6));
		}

		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		/**
		 * Render loop
		 */
		private function onEnterFrame(e:Event):void
		{
			scene.rotationY++;
			view.render();
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			if (!view)
				return;

			if (width * .5 != view.x)
				view.x = width * .5;
			if (height * .5 != view.y)
				view.y = height * .5;
		}
	}
}