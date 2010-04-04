package away3dlite.animators
{
	import away3dlite.arcane;
	import away3dlite.containers.ObjectContainer3D;
	import away3dlite.core.*;
	import away3dlite.core.base.*;
	
	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.utils.*;

	use namespace arcane;

	public class MovieMeshContainer3D extends ObjectContainer3D implements IDestroyable
	{
		public var isPlaying:Boolean;
		public var currentLabel:String;
		
		public function MovieMeshContainer3D()
		{
			super();
		}

		public function play(label:String = "frame"):void
		{
			currentLabel = label;
			
			isPlaying = true;
			
			// TODO: take over each mesh enterframe to global meshes enterframe
			
			if (children)
			{
				for each (var _mesh:MovieMesh in children)
					_mesh.play(label);
			}
		}

		public function stop():void
		{
			isPlaying = false;
			
			if (children)
				for each (var _mesh:MovieMesh in children)
					_mesh.stop();
		}
		
		public override function clone(object:Object3D = null):Object3D
		{
			var _container:MovieMeshContainer3D = new MovieMeshContainer3D();
			super.clone(_container);
			
			return _container;
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