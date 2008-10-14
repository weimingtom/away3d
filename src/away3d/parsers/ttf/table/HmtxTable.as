package away3d.parsers.ttf.table
{
	import flash.utils.ByteArray;
	
	public class HmtxTable
	{
		private var _metrics:Array = [];
		
		public function HmtxTable(data:ByteArray, offset:int, numGlyfs:uint, numberOfHorMetrics:int)
		{
			data.position = offset;
			
			var i:uint;
			for(i = 0; i<numGlyfs; i++)
				_metrics.push({advanceWidth:0, leftSideBearing:0});
			
			for(i = 0; i<numGlyfs; i++)
				_metrics[i].advanceWidth = data.readUnsignedByte() << 24 | data.readUnsignedByte() << 16 | data.readUnsignedByte() << 8 | data.readUnsignedByte();
			
			for(i = 0; i<numGlyfs; i++)
				_metrics[i].leftSideBearing = data.readShort();
		}
		
		public function get metrics():Array
		{
			return _metrics;
		}
	}
}