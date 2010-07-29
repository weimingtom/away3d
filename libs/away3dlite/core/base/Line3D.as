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

		private var _position:Vector3D;
		private var _beginPosition:Vector3D;
		private var _endPosition:Vector3D;

		public var id:String;
		public var visible:Boolean = true;

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

		// projected position
		private var _projectedPosition:Vector3D;
		private var _beginProjectedPosition:Vector3D;
		private var _endProjectedPosition:Vector3D;

		private var _point:Point = new Point();
		private var _point0:Point = new Point();
		private var _rect:Rectangle = new Rectangle();

		public var material:LineMaterial;

		public function Line3D(beginPosition:Vector3D, endPosition:Vector3D, material:LineMaterial)
		{
			_position = new Vector3D(endPosition.x - beginPosition.x, endPosition.y - beginPosition.y, endPosition.z - beginPosition.z);

			_projectedPosition = _position.clone();
			_beginPosition = beginPosition;
			_endPosition = endPosition;

			this.material = material;

			updateMaterial();
		}

		private function updateMaterial():void
		{
			material.isDirty = false;

			if (parent)
				parent.isDirty = true;
		}

		public function get position():Vector3D
		{
			return _projectedPosition;
		}

		public function set position(value:Vector3D):void
		{
			// position
			_screenZ = value.w;
			_projectedPosition = value.clone();
		}

		public function update(viewMatrix3D:Matrix3D, transformMatrix3D:Matrix3D = null):void
		{
			// dirty
			if (material.isDirty)
				updateMaterial();

			// bypass
			var Utils3D_projectVector:Function = Utils3D.projectVector;

			// update position
			position = Utils3D_projectVector(viewMatrix3D, Utils3D_projectVector(transformMatrix3D, _position));

			_beginProjectedPosition = Utils3D_projectVector(transformMatrix3D, _beginPosition);
			_beginProjectedPosition = Utils3D_projectVector(viewMatrix3D, _beginProjectedPosition);

			_endProjectedPosition = Utils3D_projectVector(transformMatrix3D, _endPosition);
			_endProjectedPosition = Utils3D_projectVector(viewMatrix3D, _endProjectedPosition);
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
			graphics.moveTo(_beginProjectedPosition.x, _beginProjectedPosition.y);
			graphics.lineTo(_endProjectedPosition.x, _endProjectedPosition.y);
			graphics.endFill();
		}

		protected function drawLine(x:Number, y:Number):void
		{
			var color:int = int(material.color);

			var deltaY:int = _endProjectedPosition.y - _beginProjectedPosition.y;
			var deltaX:int = _endProjectedPosition.x - _beginProjectedPosition.x;
			var isYLonger:Boolean = false;

			x += _beginProjectedPosition.x;
			y += _beginProjectedPosition.y;

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

			_projectedPosition = null;
			_beginProjectedPosition = null;
			_endProjectedPosition = null;

			_point = null;
			_point0 = null;
			_rect = null;

			if (material)
				material.destroy();
			material = null;
		}
	}
}