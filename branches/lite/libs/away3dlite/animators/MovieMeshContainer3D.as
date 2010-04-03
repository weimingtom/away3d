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
		public var isPlaying:Boolean;
		
		public function MovieMeshContainer3D()
		{
			super();
		}

		public function play(label:String = "frame"):void
		{
			isPlaying = true;
			
			if (children)
				for each (var _mesh:MovieMesh in children)
					_mesh.play(label);
		}

		public function stop():void
		{
			isPlaying = false;
			
			if (children)
				for each (var _mesh:MovieMesh in children)
					_mesh.stop();
		}

		override public function destroy():void
		{
			if (_isDestroyed)
				return;

			if (children)
				for each (var _mesh:MovieMesh in children)
					_mesh.stop();

			super.destroy();
		}
	}
}