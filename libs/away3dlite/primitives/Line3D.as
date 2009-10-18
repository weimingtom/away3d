package away3dlite.primitives
{
	import away3dlite.arcane;
	import away3dlite.core.base.Mesh;
	import away3dlite.materials.WireColorMaterial;
	import away3dlite.materials.WireframeMaterial;
	
	import flash.display.*;
	import flash.geom.*;
	
	use namespace arcane;

	/**
	 * Line3D
	 * @author katopz
	 */
	public class Line3D extends Mesh
	{
		public function Line3D(lines:Vector.<Vector3D>, color:Number = 0xFFFFFF, alpha:Number = 1, material:WireframeMaterial = null):void
		{
			super();

			// Only one point param P1(x,y,z), so add P0(0,0,0) --> P1(x,y,z)
			if (lines.length == 1)
				lines.unshift(new Vector3D(0, 0, 0));

			var i:int = 0;
			var _line:Vector3D;
			for each (var line:Vector3D in lines)
			{
				// P0 --> (P0+P1)/2 --> P1
				if (lines.length == 2)
				if ((i + 1) % 2 == 0)
				{
					_vertices.push((line.x + _line.x) / 2, (line.y + _line.y) / 2, (line.z + _line.z) / 2);
				}

				_vertices.push(line.x, line.y, line.z);
				_line = line;
				i++;
			}

			// With UV values alone, uvtData.length = vertices.length.
			_uvtData = new Vector.<Number>(_vertices.length, true);

			// material
			this.material = material ? material : new WireframeMaterial(color, alpha);
			
			bothsides = true;
		}
	}
}