package away3d.parsers.ttf.table
{
	import flash.utils.ByteArray;
	
	public class HeadTable
	{
		private var _versionNumber:int;
        private var _fontRevision:int;
        private var _checkSumAdjustment:int;
        private var _magicNumber:int;
        private var _flags:int;
        private var _unitsPerEm:int;
        private var _created:Number;
        private var _modified:Number;
        private var _xMin:int;
        private var _yMin:int;
        private var _xMax:int;
        private var _yMax:int;
        private var _macStyle:int;
        private var _lowestRecPPEM:int;
        private var _fontDirectionHint:int;
        private var _indexToLocFormat:int;
        private var _glyphDataFormat:int;
		
		public function HeadTable(data:ByteArray, offset:int)
		{
			data.position = offset;
			
			_versionNumber = data.readInt();
	        _fontRevision = data.readInt();
	        _checkSumAdjustment = data.readInt();
	        _magicNumber = data.readInt();
	        _flags = data.readShort();
	        _unitsPerEm = data.readShort();
	        _created = data.readDouble();
	        _modified = data.readDouble();
	        _xMin = data.readShort();
	        _yMin = data.readShort();
	        _xMax = data.readShort();
	        _yMax = data.readShort();
	        _macStyle = data.readShort();
	        _lowestRecPPEM = data.readShort();
	        _fontDirectionHint = data.readShort();
	        _indexToLocFormat = data.readShort();
	        _glyphDataFormat = data.readShort();
		}
		
		public function get indexToLocFormat():int
		{
			return _indexToLocFormat;
		}
		
		public function get unitsPerEm():int
		{
			return _unitsPerEm;
		}
	}
}