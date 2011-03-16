package away3dlite.animators
{
	import away3dlite.arcane;
	import away3dlite.containers.ObjectContainer3D;
	import away3dlite.core.*;
	import away3dlite.core.base.*;

	import flash.geom.Vector3D;
	import flash.utils.getTimer;

	use namespace arcane;

	public class MovieMeshContainer3D extends ObjectContainer3D implements IDestroyable
	{
		private var _type:int;

		public function get status():int
		{
			return _type;
		}

		private var _currentLabel:String;

		public function get currentLabel():String
		{
			return _currentLabel;
		}

		private var _ctime:int = 0;

		public function get currentTime():Number
		{
			return _ctime;
		}

		private var _otime:int;

		public function MovieMeshContainer3D()
		{
			super();
		}

		public function seek(ctime:int):void
		{
			_ctime = ctime;
			_otime = isNaN(_otime) ? getTimer() : _otime;

			if (children)
				for each (var _mesh:MovieMesh in children)
					_mesh.seek(ctime, _otime);
		}

		public function gotoAndPlay(label:String = "frame"):void
		{
			_currentLabel = label;

			if (children)
				for each (var _mesh:MovieMesh in children)
					_mesh.gotoAndPlay(label);

			_type = MovieMesh.ANIM_NORMAL;
		}

		public function play():void
		{
			if (children)
				for each (var _mesh:MovieMesh in children)
					_mesh.play();

			_type = MovieMesh.ANIM_NORMAL;
		}

		public function stop():void
		{
			if (children)
				for each (var _mesh:MovieMesh in children)
					_mesh.stop();

			_type = MovieMesh.ANIM_STOP;
		}

		public function get totalFrames():int
		{
			var result:int = 0;
			if (children)
				for each (var _mesh:MovieMesh in children)
					result = result > _mesh.totalFrames ? result : _mesh.totalFrames;

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

			super.destroy();
		}
	}
}