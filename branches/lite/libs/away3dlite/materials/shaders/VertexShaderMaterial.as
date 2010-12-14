package away3dlite.materials.shaders
{
	import away3dlite.core.base.Vertex;
	import away3dlite.lights.Light;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;

	/**
	 * @author kris@neuroproductions.be
	 */
	public class VertexShaderMaterial extends ShaderMaterial implements IShader
	{
		public function VertexShaderMaterial(light:Light, bitmapData:BitmapData)
		{
			super(light, bitmapData);
		}

		override public function calculateNormals(verticesIn:Vector.<Number>, indices:Vector.<int>, uvtData:Vector.<Number> = null, vertexNormals:Vector.<Number> = null):void
		{
			// TODO if vertex normals, use them
			super.calculateNormals(verticesIn, indices);
			calculateVertexNormals();
		}

		private function calculateVertexNormals():void
		{
			var vertices_length:int = vertices.length;
			for (var i:int = 0; i < vertices_length; i++)
			{
				//BUG:null
				if (!vertices[int(i)])
				{
					vertices[int(i)] = new Vertex();
				}
				else
				{
					vertices[int(i)].calculateNormal();
				}
			}
		}

		override public function getUVData(m:Matrix3D):Vector.<Number>
		{
			var projectMatrix:Matrix3D = m.clone();
			projectMatrix.position = new Vector3D(0, 0, 0);

			var uvData:Vector.<Number> = new Vector.<Number>();
			var projectedNormal:Vector3D;

			var texCoord:Point = new Point();
			// projecting vertex normals
			// TODO: optimize: keep normals in a Vector and use Matrix.transformVectors
			//BUG:null
			if (vertices)
			{
				var vertices_length:int = vertices.length;
				for (var i:int = 0; i < vertices_length; i++)
				{
					projectedNormal = vertices[int(i)].getProjectedNormal(projectMatrix);

					calculateTexCoord(texCoord, projectedNormal, false);
					uvData.push(texCoord.x, texCoord.y, 1);
				}
			}

			return uvData;
		}

		protected function calculateTexCoord(texCoord:Point, normal:Vector3D, doubleSided:Boolean = false):void
		{
			// override
		}
	}
}
