package away3d.loaders.table
{
	import flash.utils.ByteArray;
	
	public class MaxpTable
	{
		private var _versionNumber:int;
		private var _numGlyfs:int;
		
		public function MaxpTable(data:ByteArray, offset:int)
		{
			data.position = offset;
			
			_versionNumber = data.readInt();
			_numGlyfs = data.readUnsignedShort();
		}
		
		public function get numGlyfs():int
		{
			return _numGlyfs;
		}
	}
}