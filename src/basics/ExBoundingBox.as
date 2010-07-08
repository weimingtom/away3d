package basics
{
	import away3dlite.animators.MovieMesh;
	import away3dlite.events.Loader3DEvent;
	import away3dlite.loaders.Loader3D;
	import away3dlite.loaders.MD2;
	import away3dlite.materials.BitmapFileMaterial;
	import away3dlite.primitives.BoundingBox;
	import away3dlite.primitives.Trident;
	import away3dlite.templates.BasicTemplate;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	[SWF(backgroundColor="#CCCCCC", frameRate="30", width="800", height="600")]
	/**
	 * Example : BoundingBox AABB, OBB
	 * @author katopz
	 */
	public class ExBoundingBox extends BasicTemplate
	{
		private var _model:MovieMesh;
		private var _boundingBox:BoundingBox;
		
		override protected function onInit():void
		{
			title += " : BoundingBox click to toggle AABB <-> OBB";
			
			// better view angle
			camera.y = -500;
			camera.lookAt(new Vector3D());
			
			var md2:MD2 = new MD2();
			md2.scaling = 5;
			md2.material = new BitmapFileMaterial("../src/loaders/assets/md2/pg.png");
			
			var loader:Loader3D = new Loader3D();
			loader.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);
			loader.loadGeometry("../src/loaders/assets/md2/pg.md2", md2);
			
			scene.addChild(new Trident);
			
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onSuccess(event:Loader3DEvent):void
		{
			_model = event.loader.handle as MovieMesh;
			_model.fps = 16;
			_model.x = 100;
			_model.rotationX = 90;
			_model.play("walk");
			scene.addChild(_model);
			
			scene.addChild(_boundingBox = new BoundingBox(_model, 1, 0x0000FF));
		}
		
		private function onClick(event:Event):void
		{
			if (!_boundingBox)
				return;
			
			if (_boundingBox.boundingType != 2)
				_boundingBox.boundingType = 2;
			else
				_boundingBox.boundingType = 1;
		}
		
		override protected function onPreRender():void
		{
			scene.rotationY++;
			if(_model)
				_model.rotationY--;
		}
	}
}