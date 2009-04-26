package away3d.loaders
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.base.VectorInstructionType;
	import away3d.core.base.Vertex;
	import away3d.materials.WireColorMaterial;
	
	public class VectorMeshLoader
	{
		public function VectorMeshLoader()
		{
			
		}
		
		public function createObject(vectorData:Array, scaling:Number = 1):ObjectContainer3D
		{
			var container:ObjectContainer3D = new ObjectContainer3D();
			
			var s:uint;
			var i:uint;
			for(s = 0; s<vectorData.length; s++)
			{
				var shapeVectorData:Array = vectorData[s][0];
				var shapeFillData:Array = vectorData[s][1];
				
				if(shapeVectorData.length == 0)
					continue;
				
				var mesh:Mesh = new Mesh();
				var face:Face = new Face();
				
				for(i = 0; i<shapeVectorData.length; i++)
				{
					var instructionData:Array = shapeVectorData[i];
					var instructionType:String = instructionData[0];
					
					switch(instructionType)
					{
						case VectorInstructionType.MOVE:
						{
							face.moveTo(new Vertex(instructionData[1]*scaling, instructionData[2]*scaling, 0));
							break;
						}
						case VectorInstructionType.LINE:
						{
							face.lineTo(new Vertex(instructionData[1]*scaling, instructionData[2]*scaling, 0));
							break;	
						}
						case VectorInstructionType.CURVE:
						{
							face.curveTo(new Vertex(instructionData[1]*scaling, instructionData[2]*scaling, 0), new Vertex(instructionData[3]*scaling, instructionData[4]*scaling, 0));
							break;
						}
					}
				}
				
				mesh.bothsides = true;
				
				// TODO: Extend material recognition here, in each material and in the injector component.
				var material:WireColorMaterial = new WireColorMaterial(shapeFillData[0]);
				material.wirealpha = 0;
				mesh.material = material;
				
				mesh.geometry.addFace(face);
				container.addChild(mesh);
			}
			
			return container;
		}
	}
}