package away3dlite.primitives
{
	import away3dlite.arcane;
	import away3dlite.materials.*;
	
	import flash.geom.*;

	use namespace arcane;

	/**
	 * Creates a single 3D line.
	 * TODO : add line segment
	 */
	public class Lines3D extends AbstractPrimitive
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
		 * Creates a new <code>LineSegment</code> object.
		 *
		 * @param material	Defines the global material used on the faces in the plane.
		 * @param paths		vertices
		 */
		public function Lines3D(material:LineMaterial, vertices:Vector.<Number>)
		{
			super(material);
			
			_paths = vertices;

			bothsides = true;
			mouseEnabled = mouseChildren = false;
		}
	}
}