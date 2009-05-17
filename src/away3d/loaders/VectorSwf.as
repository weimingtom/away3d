package away3d.loaders
{
	import away3d.arcane;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.base.VectorInstructionType;
	import away3d.core.base.Vertex;
	import away3d.core.utils.Init;
	import away3d.loaders.utils.MaterialLibrary;
	import away3d.materials.WireColorMaterial;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	use namespace arcane;
	
	/**
    * File loader for swfs with injected vector data.
    */
	public class VectorSwf extends AbstractParser
	{
		//--------------------------------------------------------------------------------
		// Private variables.
		//--------------------------------------------------------------------------------
		
		/** @private */
    	arcane var ini:Init;
		
		private var _loader:Loader;
		private var _materialLibrary:MaterialLibrary;
		private var _scaling:Number;
		private var _zOffset:Number;
		
		//--------------------------------------------------------------------------------
		// Constructor and init.
		//--------------------------------------------------------------------------------
		
		public function VectorSwf(data:*, init:Object = null)
		{
			ini = Init.parse(init);
			
			_scaling = ini.getNumber("scaling", 1);
			_zOffset = ini.getNumber("zOffset", 0);
			
			container = new ObjectContainer3D();
			
			_materialLibrary = container.materialLibrary = new MaterialLibrary();
			
			_loader = new Loader();
			_loader.loadBytes(data as ByteArray, new LoaderContext(false, ApplicationDomain.currentDomain));
			setTimeout(parseVectorData, 500);
		}
		
        //--------------------------------------------------------------------------------
		// Private methods.
		//--------------------------------------------------------------------------------
		
		private function parseVectorData():void
		{
			var swfStage:MovieClip = _loader.content as MovieClip;
			var child:DisplayObject;
			var clip:MovieClip;
			for(var i:uint; i<swfStage.numChildren; i++)
			{
				child = swfStage.getChildAt(swfStage.numChildren - i - 1);
				if(child is MovieClip)
				{
					clip = child as MovieClip;
					var clipContainer:ObjectContainer3D = createContainerFromVectorClip(clip, _scaling, i*_zOffset);
					ObjectContainer3D(container).addChild(clipContainer);
				}
			}
		}
		
		private function createContainerFromVectorClip(clip:MovieClip, scaling:Number, zOffset:Number):ObjectContainer3D
		{
			var vectorData:Object = clip.vectorData;
			
			if(!vectorData)
				return null;
			
			var clipContainer:ObjectContainer3D = new ObjectContainer3D();
			clipContainer.name = clip.name;
			clipContainer.x = clip.x*scaling;
			clipContainer.y = -clip.y*scaling;
			
			for(var i:uint; i<vectorData.length; i++)
			{
				var mesh:Mesh = createShapeMesh(vectorData[i].shapeData, vectorData[i].fillData, scaling, zOffset);
				clipContainer.addChild(mesh);
			}
			
			return clipContainer;
		}
		
		private function createShapeMesh(shapeData:Array, fillData:Object, scaling:Number, zOffset:Number):Mesh
		{
			var mesh:Mesh = new Mesh();
			mesh.bothsides = true;
			mesh.name = "vectorMesh";
			
			var face:Face = new Face();
			
			for(var i:uint; i<shapeData.length; i++)
			{
				var instructionData:Array = shapeData[i];
				var instructionType:String = instructionData[0];
				
				//trace(instructionType);
				
				switch(instructionType)
				{
					case VectorInstructionType.MOVE:
					{
						face.moveTo(new Vertex(instructionData[1]*scaling, -instructionData[2]*scaling, zOffset));
						break;
					}
					case VectorInstructionType.LINE:
					{
						face.lineTo(new Vertex(instructionData[1]*scaling, -instructionData[2]*scaling, zOffset));
						break;	
					}
					case VectorInstructionType.CURVE:
					{
						face.curveTo(new Vertex(instructionData[1]*scaling, -instructionData[2]*scaling, zOffset), new Vertex(instructionData[3]*scaling, -instructionData[4]*scaling, zOffset));
						break;
					}
				}
			}
			
			// TODO: Extend material recognition here, in each material and in the injector component.
			var material:WireColorMaterial = new WireColorMaterial();
			material.color = fillData.color;
			material.alpha = fillData.alpha;
			
			// No support for strokes yet.
			material.wirealpha = 0;
			
			mesh.material = material;
			
			mesh.geometry.addFace(face);
			
			return mesh;
		}
		
		//--------------------------------------------------------------------------------
		// Public, static methods.
		//--------------------------------------------------------------------------------
		
		public static function parse(data:*, init:Object = null):ObjectContainer3D
        {
        	return Object3DLoader.parseGeometry(data, VectorSwf, init).handle as ObjectContainer3D;
        }
        
        public static function load(url:String, init:Object = null):Object3DLoader
        {
			return Object3DLoader.loadGeometry(url, VectorSwf, true, init);
        }
	}
}