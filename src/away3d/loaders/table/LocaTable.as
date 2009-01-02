package away3d.loaders.table
{
	import flash.utils.ByteArray;
	
	/*
		This table should be extended in order to support additional characters found in a font file.
	*/
	public class LocaTable
	{
		private var _offsets:Array = [];
		
		public function LocaTable(data:ByteArray, offset:int, numGlyfs:uint, format:int)
		{
			data.position = offset;
			
			var i:uint;
			if(format == 0)
				for(i = 0; i<=numGlyfs; i++) 
	                offsets.push(data.readUnsignedInt());
			else
				for(i = 0; i<=numGlyfs; i++)
	                offsets.push(data.readInt());
		}
		
		public function get offsets():Array
		{
			return _offsets;
		}
	}
}