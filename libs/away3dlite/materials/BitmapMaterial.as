package away3dlite.materials
{
	import flash.display.*;

	/**
	 * Basic bitmapData material
	 */
	public class BitmapMaterial extends Material
	{
		/**
		 * Returns the source url of the Material, or the name of the Material if not loaded from an external source.
		 */
		public var url:String;

		/**
		 * Defines the bitmapData object to be used as the material's texture.
		 */
		public function get bitmapData():BitmapData
		{
			return _graphicsBitmapFill.bitmapData;
		}

		public function set bitmapData(val:BitmapData):void
		{
			_graphicsBitmapFill.bitmapData = val;
			dirty = true;
		}

		/**
		 * Defines whether repeat is used when drawing the material.
		 */
		public function get repeat():Boolean
		{
			return _graphicsBitmapFill.repeat;
		}

		public function set repeat(val:Boolean):void
		{
			_graphicsBitmapFill.repeat = val;
			dirty = true;
		}

		/**
		 * Defines whether smoothing is used when drawing the material.
		 */
		public function get smooth():Boolean
		{
			return _graphicsBitmapFill.smooth;
		}

		public function set smooth(val:Boolean):void
		{
			_graphicsBitmapFill.smooth = val;
			dirty = true;
		}

		/**
		 * Returns the width of the material's bitmapDatadata object.
		 */
		public function get width():int
		{
			return _graphicsBitmapFill.bitmapData.width;
		}

		/**
		 * Returns the height of the material's bitmapDatadata object.
		 */
		public function get height():int
		{
			return _graphicsBitmapFill.bitmapData.height;
		}

		/**
		 * Creates a new <code>BitmapMaterial</code> object.
		 *
		 * @param	bitmapData		The bitmapData object to be used as the material's texture.
		 */
		public function BitmapMaterial(bitmapData:BitmapData = null)
		{
			super();

			_graphicsBitmapFill.bitmapData = bitmapData || new BitmapData(100, 100, false, 0x000000);

			graphicsData = Vector.<IGraphicsData>([_graphicsStroke, _graphicsBitmapFill, _triangles, _graphicsEndFill]);
			graphicsData.fixed = true;

			trianglesIndex = 2;
			_graphicsBitmapFill.smooth = true;
		}
	}
}