package away3dlite.materials
{
	import away3dlite.core.utils.Cast;
	
	import flash.display.*;

	/**
	 * Outline material.
	 */
	public class WireframeMaterial extends Material
	{
		protected var _color:uint;
		protected var _alpha:Number;
		protected var _thickness:Number;

		/**
		 * Defines the color of the outline.
		 */
		public function get color():uint
		{
			return _color;
		}

		public function set color(val:uint):void
		{
			if (_color == val)
				return;

			_color = val;

			(_graphicsStroke.fill as GraphicsSolidFill).color = _color;
			
			dirty = true;
		}

		/**
		 * Defines the transparency of the outline.
		 */
		public function get alpha():Number
		{
			return _alpha;
		}

		public function set alpha(val:Number):void
		{
			if (_alpha == val)
				return;

			_alpha = val;

			(_graphicsStroke.fill as GraphicsSolidFill).alpha = _alpha;
			
			dirty = true;
		}
		
		/**
		 * Defines the thickness of the outline.
		 */
		public function get thickness():Number
		{
			return _thickness;
		}
		
		public function set thickness(val:Number):void
		{
			if (_thickness == val)
				return;
			
			_thickness = val;
			
			_graphicsStroke.thickness = _thickness;
			
			dirty = true;
		}

		/**
		 * Creates a new <code>WireframeMaterial</code> object.
		 *
		 * @param	color		The color of the outline.
		 * @param	alpha		The transparency of the outline.
		 * @param	thickness	The thickness of the outline.
		 */
		public function WireframeMaterial(color:* = null, alpha:Number = 1, thickness:uint = 1)
		{
			super();

			_color = Cast.color((color == null) ? "random" : color);
			_alpha = alpha;

			_graphicsStroke.fill = new GraphicsSolidFill(_color, _alpha);
			_graphicsStroke.thickness = _thickness = thickness;

			graphicsData = Vector.<IGraphicsData>([_graphicsStroke, _triangles]);
			graphicsData.fixed = true;

			trianglesIndex = 1;
		}
	}
}