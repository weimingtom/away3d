package away3dlite.primitives
{
	import away3dlite.arcane;
	import away3dlite.materials.*;
	
	use namespace arcane;

	/**
	 * Creates a 3D line from line segment.
	 * TODO : add line segment
	 */
	public class Path3D extends AbstractPrimitive
	{
		private var _paths:Vector.<Number>;
		
		/**
		 * @inheritDoc
		 */
		protected override function buildPrimitive():void
		{
			super.buildPrimitive();
			
			buildLines(_paths);
		}

		private function buildLines(paths:Vector.<Number>):void
		{
			var _length:int = paths.length;
			var i:int = 0;
			
			while(i<_length)
			{
				buildLineData(
					paths[int(i++)],
					paths[int(i++)],
					paths[int(i++)]
				);
			}
		}
		
		private function buildLineData(x:Number, y:Number, z:Number):void
		{
			_vertices.push(x, y, z);
			_uvtData.push(0, 0, 0);
			_indices.push(0, 1, 1);
			_faceLengths.push(3);
		}

		/**
		 * Creates a new <code>Lines3D</code> object.
		 *
		 * @param material	Defines the material used on the line.
		 * @param vertices	List of x0,y0,z0,x1,y1,z1,...,xn,yn,zn vertices to draw line through.
		 */
		public function Path3D(material:PathMaterial, vertices:Vector.<Number>)
		{
			super(material);
			
			_paths = vertices;

			bothsides = true;
			mouseEnabled = mouseChildren = false;
		}
	}
}