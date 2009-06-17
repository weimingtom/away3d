package away3d.loaders
{
	import away3d.arcane;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.base.Vertex;
	import away3d.core.utils.Init;
	import away3d.loaders.utils.MaterialLibrary;
	import away3d.materials.WireColorMaterial;
	
	import flash.utils.ByteArray;
	
	import wumedia.vector.VectorShapes;
	
	use namespace arcane;
	
	/**
    * File loader for swfs with injected vector data.
    */
	public class Swf extends AbstractParser
	{
		//--------------------------------------------------------------------------------
		// Private variables.
		//--------------------------------------------------------------------------------
		
		/** @private */
    	arcane var ini:Init;
		
		private var _materialLibrary:MaterialLibrary;
		private var _scaling:Number;
		private var _data:ByteArray;
		private var _libraryClips:Array;
		
		//--------------------------------------------------------------------------------
		// Constructor and init.
		//--------------------------------------------------------------------------------
		
		public function Swf(data:*, init:Object = null)
		{
			ini = Init.parse(init);
			
			_data = data;
			
			_libraryClips = ini.getArray("libraryClips");
			_scaling = ini.getNumber("scaling", 1);
			
			container = new ObjectContainer3D();
			
			_materialLibrary = container.materialLibrary = new MaterialLibrary();
			
			parseVectorData();
		}
		
        //--------------------------------------------------------------------------------
		// Private methods.
		//--------------------------------------------------------------------------------
		
		private function parseVectorData():void
		{
			VectorShapes.extractFromStage(_data, "shapes");
			
			var clipMesh:Mesh = new Mesh();
			clipMesh.bothsides = true;
			ObjectContainer3D(container).addChild(clipMesh);
			
			VectorShapes.draw(clipMesh.geometry.graphics, "shapes", _scaling);
			clipMesh.geometry.graphics.apply();
			
			//trace("Container has " + clipMesh.faces.length + " faces.");
		}
		
		//--------------------------------------------------------------------------------
		// Public, static methods.
		//--------------------------------------------------------------------------------
		
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