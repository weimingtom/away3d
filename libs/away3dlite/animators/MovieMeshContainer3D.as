package away3dlite.animators
{
	import away3dlite.arcane;
	import away3dlite.core.*;
	import away3dlite.core.base.*;

	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.utils.*;
	import away3dlite.containers.ObjectContainer3D;

	use namespace arcane;

	public class MovieMeshContainer3D extends ObjectContainer3D implements IDestroyable
	{
		private var _meshes:Vector.<MovieMesh>;

		public function MovieMeshContainer3D()
		{
			super();
		}

		public override function addChild(child:DisplayObject):DisplayObject
		{
			super.addChild(child);

			if (!_meshes)
				_meshes = new Vector.<MovieMesh>();

			_meshes.fixed = false;
			_meshes.splice(_meshes.indexOf(child), 1);
			_meshes.push(child);
			_meshes.fixed = true;

			return child;
		}

		public override function removeChild(child:DisplayObject):DisplayObject
		{
			super.removeChild(child);

			_meshes.fixed = false;
			_meshes.splice(_meshes.indexOf(child), 1);
			_meshes.fixed = true;

			return child;
		}

		public function play(label:String = "frame"):void
		{
			if (_meshes)
				for each (var _mesh:MovieMesh in _meshes)
					_mesh.play();
		}

		public function stop():void
		{
			if (_meshes)
				for each (var _mesh:MovieMesh in _meshes)
					_mesh.stop();
		}

		override public function destroy():void
		{
			if (_isDestroyed)
				return;

			if (_meshes)
				for each (var _mesh:MovieMesh in _meshes)
					_mesh.stop();

			_meshes = null;

			super.destroy();
		}
	}
}