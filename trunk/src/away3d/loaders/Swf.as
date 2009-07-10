package away3d.loaders
{
	import away3d.arcane;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.core.base.Vertex;
	import away3d.core.utils.Init;
	import away3d.loaders.utils.MaterialLibrary;
	
	import flash.utils.ByteArray;
	
	import wumedia.vector.VectorShapes;
	
	use namespace arcane;
	
	/**
    * File loader for swfs with injected vector data.
    */
	public class Swf extends AbstractParser
	{
		/** @private */
    	arcane var ini:Init;
		
		private var _materialLibrary:MaterialLibrary;
		private var _scaling:Number;
		private var _data:ByteArray;
		private var _libraryClips:Array;
		private var _perspectiveOffset:Number;
		private var _perspectiveFocus:Number;
		
		public function Swf(data:*, init:Object = null)
		{
			ini = Init.parse(init);
			
			_data = data;
			
			_libraryClips = ini.getArray("libraryClips");
			_scaling = ini.getNumber("scaling", 1);
			_perspectiveOffset = ini.getNumber("perspectiveOffset", 0);
			_perspectiveFocus = ini.getNumber("perspectiveFocus", 1000);
			
			container = new ObjectContainer3D();
			_materialLibrary = container.materialLibrary = new MaterialLibrary();
			
			parseVectorData();
			applyPerspective();
		}
		
		private function applyPerspective():void
		{
			if(_perspectiveOffset == 0)
				return;
			
			var faceCounter:uint;
			for each(var child:Object3D in ObjectContainer3D(container).children)
			{
				if(child is Mesh)
				{
					var mesh:Mesh = child as Mesh;
					for each(var face:Face in mesh.faces)
					{
						for each(var vertex:Vertex in face.vertices)
						{
							vertex.x *= 1 + _perspectiveOffset*faceCounter/_perspectiveFocus;
							vertex.y *= 1 + _perspectiveOffset*faceCounter/_perspectiveFocus;
							vertex.z += _perspectiveOffset*faceCounter;
						}
						
						faceCounter++;
					}
				}
			} 
		}
		
		private function parseVectorData():void
		{
			if(_libraryClips.length > 0)
				getAllLibraryClips();
			else
				getAllClipsFromStage();
		}
		
		private function getAllLibraryClips():void
		{
			VectorShapes.extractFromLibrary(_data, _libraryClips);
			
			for each(var id:String in _libraryClips)
				generateMesh(id);
		}
		
		private function getAllClipsFromStage():void
		{
			VectorShapes.extractFromStage(_data, "shapes");
			generateMesh("shapes");
		}
		
		private function generateMesh(shapeId:String):void
		{
			var clipMesh:Mesh = new Mesh();
			clipMesh.bothsides = true;
			ObjectContainer3D(container).addChild(clipMesh);
			
			VectorShapes.draw(clipMesh.geometry.graphics, shapeId, _scaling);
		}
		
		public static function parse(data:*, init:Object = null):ObjectContainer3D
        {
        	return Object3DLoader.parseGeometry(data, Swf, init).handle as ObjectContainer3D;
        }
        
        public static function load(url:String, init:Object = null):Object3DLoader
        {
			return Object3DLoader.loadGeometry(url, Swf, true, init);
        }
	}
}