package away3dlite.core.base
{
	import away3dlite.arcane;
	import away3dlite.containers.Lines;
	import away3dlite.core.IDestroyable;
	import away3dlite.materials.LineMaterial;

	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;

	use namespace arcane;

	/**
	 * Line
	 * @author katopz
	 */
	public class Line3D implements IRenderable, IDestroyable
	{
		/** @private */
		protected var _isDestroyed:Boolean;

		public var id:String;
		public var visible:Boolean = true;
		protected var _isClip:Boolean = false;

		public function get isClip():Boolean
		{
			return _isClip;
		}

		private var _screenZ:Number;
		public function get screenZ():Number
		{
			return _screenZ;
		}

		// link list
		public var next:Line3D;
		public var prev:Line3D;

		public var parent:Lines;
		public var graphics:Graphics;
		public var bitmapData:BitmapData;

		// position
		private var _position:Vector3D;
		private var _beginPosition:Vector3D;

		public function get beginPosition():Vector3D
		{
			return _beginPosition;
		}

		public function set beginPosition(value:Vector3D):void
		{
			_beginPosition = value;
		}

		private var _endPosition:Vector3D;

		public function get endPosition():Vector3D
		{
			return _endPosition;
		}

		public function set endPosition(value:Vector3D):void
		{
			_endPosition = value;
		}

		private var _transformPosition:Vector3D;
		private var _beginTransformedPosition:Vector3D;
		private var _endTransformedPosition:Vector3D;

		private var _point:Point = new Point();
		private var _point0:Point = new Point();
		private var _rect:Rectangle = new Rectangle();

		public var material:LineMaterial;

		public function Line3D(beginPosition:Vector3D, endPosition:Vector3D, material:LineMaterial)
		{
			// middle of line
			_position = beginPosition.add(endPosition);
			_position.scaleBy(.5);

			_beginPosition = beginPosition;
			_endPosition = endPosition;
			_transformPosition = beginPosition.length < _endPosition.length ? beginPosition : _endPosition;

			this.material = material;
			updateMaterial();
		}

		private function updateMaterial():void
		{
			material.isDirty = false;

			if (parent)
				parent.isDirty = true;
		}

		public function get transformPosition():Vector3D
		{
			return _transformPosition;
		}

		public function update(viewMatrix3D:Matrix3D, transformMatrix3D:Matrix3D = null):void
		{
			// dirty
			if (material.isDirty)
				updateMaterial();

			// bypass
			var Utils3D_projectVector:Function = Utils3D.projectVector;

			_beginTransformedPosition = Utils3D_projectVector(viewMatrix3D, Utils3D_projectVector(transformMatrix3D, _beginPosition));
			_endTransformedPosition = Utils3D_projectVector(viewMatrix3D, Utils3D_projectVector(transformMatrix3D, _endPosition));

			// update position
			_transformPosition = Utils3D_projectVector(viewMatrix3D, Utils3D_projectVector(transformMatrix3D, _position));
			_screenZ = _transformPosition.w;
		}

		public function render(x:Number, y:Number, graphics:Graphics, zoom:Number, focus:Number):void
		{
			if (!visible)
				return;

			// draw to bitmap?
			if (bitmapData)
			{
				drawLine(x, y);
				return;
			}

			// or draw to parent or child canvas?
			if (!this.graphics)
				this.graphics = graphics;

			// draw
			graphics.lineStyle(material.thickness, material.color);
			graphics.moveTo(_beginTransformedPosition.x, _beginTransformedPosition.y);
			graphics.lineTo(_endTransformedPosition.x, _endTransformedPosition.y);
			graphics.endFill();
		}

		protected function drawLine(x:Number, y:Number):void
		{
			var color:int = int(material.color);

			var deltaY:int = _endTransformedPosition.y - _beginTransformedPosition.y;
			var deltaX:int = _endTransformedPosition.x - _beginTransformedPosition.x;
			var isYLonger:Boolean = false;

			x += _beginTransformedPosition.x;
			y += _beginTransformedPosition.y;

			if ((deltaY ^ (deltaY >> 31)) - (deltaY >> 31) > (deltaX ^ (deltaX >> 31)) - (deltaX >> 31))
			{
				deltaY ^= deltaX;
				deltaX ^= deltaY;
				deltaY ^= deltaX;

				isYLonger = true;
			}

			var inc:int = deltaX < 0 ? -1 : 1;
			var multDiff:Number = deltaX == 0 ? deltaY : deltaY / deltaX;

			bitmapData.lock();

			if (isYLonger)
			{
				for (var i:int = 0; i != deltaX; i += inc)
					bitmapData.setPixel32(int(x + i * multDiff), int(y + i), color);
			}
			else
			{
				for (i = 0; i != deltaX; i += inc)
					bitmapData.setPixel32(int(x + i), int(y + i * multDiff), color);
			}

			bitmapData.unlock();
		}

		public function get destroyed():Boolean
		{
			return _isDestroyed;
		}

		public function destroy():void
		{
			_isDestroyed = true;

			next = null;
			prev = null;

			parent = null;

			if (graphics)
				graphics.clear();
			graphics = null;

			if (bitmapData)
				bitmapData.dispose();
			bitmapData = null;

			_beginPosition = null;
			_endPosition = null;

			_transformPosition = null;
			_beginTransformedPosition = null;
			_endTransformedPosition = null;

			_point = null;
			_point0 = null;
			_rect = null;

			if (material)
				material.destroy();
			material = null;
		}
	}
}