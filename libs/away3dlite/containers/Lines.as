package away3dlite.containers
{
	import away3dlite.arcane;
	import away3dlite.cameras.Camera3D;
	import away3dlite.core.base.IRenderableList;
	import away3dlite.core.base.Line3D;
	import away3dlite.core.base.Object3D;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix3D;

	use namespace arcane;

	/**
	 * Lines
	 * @author katopz
	 */
	public class Lines extends Object3D implements IRenderableList
	{
		private var _animate:Boolean;
		public var isDirty:Boolean;

		// linklist
		private var _firstLine:Line3D;
		private var _lastLine:Line3D;

		// still need array for sortOn
		private var _lists:Array;

		public function get renderableList():Array
		{
			return _lists;
		}

		// bitmap
		private var _bitmap:Bitmap;

		public function get bitmap():Bitmap
		{
			return _bitmap;
		}

		public function set bitmap(value:Bitmap):void
		{
			_bitmap = value;

			if (_bitmap)
				_bitmapData = _bitmap.bitmapData;
			else
				_bitmapData = null;

			if (!_firstLine)
				return;

			var line:Line3D = _firstLine;
			if (line)
				do
				{
					// bitmap dirty
					if (line.bitmapData != _bitmapData)
						line.bitmapData = _bitmapData;
				} while (line = line.next);
		}

		protected var _bitmapData:BitmapData;

		override public function set layer(value:Sprite):void
		{
			super.layer = value;

			if (!_firstLine)
				return;

			var line:Line3D = _firstLine;
			if (line)
				do
				{
					// layer dirty
					if (line.graphics != value.graphics)
						line.graphics = value.graphics;
				} while (line = line.next);
		}

		public function Lines()
		{

		}

		arcane override function updateScene(val:Scene3D):void
		{
			_scene = val;
		}

		/** @private */
		arcane override function project(camera:Camera3D, parentSceneMatrix3D:Matrix3D = null):void
		{
			super.project(camera, parentSceneMatrix3D);

			if (_bitmapData)
				_bitmapData.fillRect(_bitmapData.rect, 0x00000000);

			// by pass
			var _transform_matrix3D:Matrix3D = transform.matrix3D;
			var _line:Line3D = _firstLine;
			if (_line)
				do
				{
					_line.update(_viewMatrix3D, _transform_matrix3D);
				} while (_line = _line.next);

			if (_scene && (_animate || isDirty))
			{
				_scene.isDirty = true;
				isDirty = false;
			}
		}

		public function addLine(line:Line3D):Line3D
		{
			// add to lists
			if (!_lists)
				_lists = [];

			_lists.push(line);

			//link list
			if (!_firstLine)
				_firstLine = line;

			if (_lastLine)
				_lastLine.next = line;

			line.prev = _lastLine;

			_lastLine = line;

			line.parent = this;
			line.bitmapData = _bitmapData;

			return line;
		}

		public function removeLine(line:Line3D):Line3D
		{
			if (!_lists)
				return null;

			_lists.splice(_lists.indexOf(line), 1);
			line.parent = null;

			// prev, line, next // prev -> next
			line.prev = line.next;

			return line;
		}

		public function getLineByID(id:String):Line3D
		{
			var line:Line3D = _firstLine;
			if (line)
				do
				{
					if (line.id == id)
						return line;
				} while (line = line.next);
			return null;
		}

		override public function destroy():void
		{
			if (_isDestroyed)
				return;

			for each (var _line:Line3D in _lists)
				_line.destroy();

			_firstLine = null;
			_lastLine = null;
			_lists = null;

			super.destroy();
		}
	}
}