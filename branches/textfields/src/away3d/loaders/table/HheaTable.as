package away3d.loaders.table
{
	import flash.utils.ByteArray;
	
	public class HheaTable
	{
		private var _version:int;
		private var _ascender:int;
		private var _descender:int;
		private var _lineGap:int;
		private var _advanceWidthMax:int;
		private var _minLeftSideBearing:int;
		private var _minRightSideBearing:int;
		private var _xMaxExtent:int;
		private var _caretSlopeRise:int;
		private var _caretSlopeRun:int;
		private var _metricDataFormat:int;
		private var _numberOfHorMetrics:int;
		
		public function HheaTable(data:ByteArray, offset:int)
		{
			data.position = offset;
			
			_version = data.readInt();
	        _ascender = data.readShort();
	        _descender = data.readShort();
	        _lineGap = data.readShort();
	        _advanceWidthMax = data.readShort();
	        _minLeftSideBearing = data.readShort();
	        _minRightSideBearing = data.readShort();
	        _xMaxExtent = data.readShort();
	        _caretSlopeRise = data.readShort();
	        _caretSlopeRun = data.readShort();
	        for(var i:uint; i < 5; i++) //4 reserved data entries.
	            data.readShort();
	        _metricDataFormat = data.readShort();
	        _numberOfHorMetrics = data.readShort();
		}
		
		public function get numberOfHorMetrics():int
		{
			return _numberOfHorMetrics;
		}
	}
}