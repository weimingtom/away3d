package away3dlite.animators
{
	import away3dlite.arcane;
	import away3dlite.containers.ObjectContainer3D;
	import away3dlite.core.*;
	import away3dlite.core.base.*;
	
	import flash.events.*;
	import flash.geom.Vector3D;
	import flash.utils.*;

	use namespace arcane;

	public class MovieMeshContainer3D extends ObjectContainer3D implements IDestroyable
	{
		public var isPlaying:Boolean;
		private var _currentLabel:String;

		public function get currentLabel():String
		{
			return _currentLabel;
		}

		public function get currentTime():Number
		{
			return _ctime;
		}

		private var _ctime:Number = 0;
		private var _otime:Number = 0;

		public function MovieMeshContainer3D()
		{
			super();
		}

		private function onEnterFrame(event:Event = null):void
		{
			seek(_ctime = getTimer(), _otime);
		}

		public function seek(ctime:Number, otime:Number):void
		{
			isPlaying = true;

			_otime = otime = otime ? otime : getTimer();

			if (children)
				for each (var _mesh:MovieMesh in children)
					_mesh.seek(ctime, otime);
			_otime = ctime;
		}

		public function play(label:String = "frame"):void
		{
			_currentLabel = label;

			isPlaying = true;

			if (children)
				for each (var _mesh:MovieMesh in children)
				{
					_mesh.isParentControl = true;
					_mesh.play(label);
				}

			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		public function stop():void
		{
			isPlaying = false;

			if (children)
				for each (var _mesh:MovieMesh in children)
					_mesh.stop();

			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		public function get totalFrames():int
		{
			var result:int = 0;
			if (children)
			for each (var _mesh:MovieMesh in children)
				result = result > _mesh.totalFrames? result:_mesh.totalFrames;
			
			return result;
		}

		override public function updateBoundingBox(minBounding:Vector3D, maxBounding:Vector3D):void
		{
			var minX:Number, minY:Number, minZ:Number, maxX:Number, maxY:Number, maxZ:Number;

			minBounding.x = minBounding.y = minBounding.z = minX = minZ = minY = Infinity;
			maxBounding.x = maxBounding.y = maxBounding.z = maxX = maxY = maxZ = -Infinity;

			for each (var _mesh:Mesh in children)
				_mesh.updateBoundingBox(minBounding, maxBounding);

			// callback if exist
			if (onBoundingBoxUpdate is Function)
				onBoundingBoxUpdate(minBounding, maxBounding);
		}

		override public function clone(object:Object3D = null):Object3D
		{
			var _container:MovieMeshContainer3D = new MovieMeshContainer3D();
			super.clone(_container);

			return _container;
		}

		override public function destroy():void
		{
			if (_isDestroyed)
				return;

			removeEventListener(Event.ENTER_FRAME, onEnterFrame);

			super.destroy();
		}
	}
}