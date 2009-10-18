package away3dlite.containers
{
	import away3dlite.arcane;
	import away3dlite.core.base.Object3D;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix3D;
	import flash.geom.Utils3D;

	use namespace arcane;

	public class Sprite2D extends Object3D
	{
		// temp
		//private var _temp:Shape = new Shape();
		public static var displayObjects:Array;
		public static var sprites:Array;
		
		// target
		public var displayObject:DisplayObject;
		
		private var displayObjectMatrix3D:Matrix3D;
		
		// link list
		//public var nextParticle:Sprite2D;
		
		/** @private */
		arcane override function project(projectionMatrix3D:Matrix3D, parentSceneMatrix3D:Matrix3D = null):void
		{
			/*
			// temp position
			var _position:Vector3D = transform.matrix3D.position.clone();
			
			// invert rotation
			_temp.rotationX = parent.rotationX;
			_temp.rotationY = parent.rotationY;
			_temp.rotationZ = parent.rotationZ;
			_temp.transform.matrix3D.invert();
			
			// billboard rotation
			transform.matrix3D = _temp.transform.matrix3D.clone();

			// billboard position
			position = _position.clone();
			
			// camera position
			super.project(projectionMatrix3D, parentSceneMatrix3D);
			
			_position = Utils3D.projectVector(_viewMatrix3D, displayObjectPosition);
			_position.decrementBy(_sceneMatrix3D.position);
			
			//TODO : apply camera matrix
			//displayObject.transform.matrix3D.position = _position.clone();
			*/
			
			if(!displayObject.parent && parent)
				parent.parent.addChild(displayObject);
			
			super.project(projectionMatrix3D, parentSceneMatrix3D);
			
			displayObjectMatrix3D.position = Utils3D.projectVector(_viewMatrix3D, transform.matrix3D.position);
		}
		
		private function sortObject():void
		{
			for each (var sprite2d:Sprite2D in sprites)
			{
				var _parent:DisplayObjectContainer = sprite2d.displayObject.parent;
				//_parent.setChildIndex(_displayObject, _parent.indexOf(child));
			}
		}
		
		public function Sprite2D(displayObject:DisplayObject)
		{
			super();
			
			if(!displayObjects)
				displayObjects = [];
				
			if (displayObject)
			{
				this.displayObject = displayObject;
				displayObjectMatrix3D = displayObject.transform.matrix3D = new Matrix3D();
				displayObjects.push(displayObject);
			}
			
			if(!sprites)
				sprites = [];
				
			sprites.push(this);
		}
	}
}