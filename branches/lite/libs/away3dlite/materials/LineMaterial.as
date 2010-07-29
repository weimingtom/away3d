package away3dlite.materials
{
	/**
	 * Base line material class.
	 */
	public class LineMaterial
	{
		/** @private */
		protected var _isDestroyed:Boolean;

		public var isDirty:Boolean;

		private var _color:uint;

		public function get color():uint
		{
			return _color;
		}

		public function set color(value:uint):void
		{
			_color = value;
		}

		private var _alpha:Number;

		public function get alpha():Number
		{
			return _alpha;
		}

		public function set alpha(value:Number):void
		{
			_alpha = value;
		}

		private var _thickness:Number;

		public function get thickness():Number
		{
			return _thickness;
		}

		public function set thickness(value:Number):void
		{
			_thickness = value;
		}

		
		/**
		 * Creates a new <code>LineMaterial</code> object.
		 */
		public function LineMaterial(color:* = null, alpha:Number = 1, thickness:Number = 1)
		{
			_color = int(alpha * 0xFF) << 24 | color;
			_alpha = alpha;
			_thickness = thickness;
			
			isDirty = true;
		}

		public function clone():LineMaterial
		{
			return new LineMaterial(_color, _alpha, _thickness);
		}

		public function get destroyed():Boolean
		{
			return _isDestroyed;
		}

		public function destroy():void
		{
			_isDestroyed = true;
		}
	}
}