package away3d.parsers.ttf
{
	import away3d.parsers.ttf.table.CmapTable;
	import away3d.parsers.ttf.table.GlyfTable;
	import away3d.parsers.ttf.table.HeadTable;
	import away3d.parsers.ttf.table.HheaTable;
	import away3d.parsers.ttf.table.HmtxTable;
	import away3d.parsers.ttf.table.LocaTable;
	import away3d.parsers.ttf.table.MaxpTable;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class TTFBinaryParser
	{
		private var _data:ByteArray;
		private var _range:String;
		private var _rangeArray:Array = [];
		private var _tables:Dictionary;
		private var _fontName:String;
		private var _subFontName:String;
		private var _glyfs:Dictionary;
		
		public function TTFBinaryParser(source:ByteArray, range:String)
		{
			_data = source;
			_range = range;
			init();
		}
		
		private function init():void
		{	
			//Prepare rangeArray.
			var i:uint
			for(i = 0; i<_range.length; i++)
				_rangeArray.push(_range.charAt(i));
			
			//Read general data from binary file.
			var version:int = _data.readInt();
	        var numTables:int = _data.readShort();
	        var searchRange:int = _data.readShort();
	        var entrySelector:int = _data.readShort();
	        var rangeShift:int = _data.readShort();
	        
	        //Read table locations from binary file.
	        _tables = new Dictionary();
	        for(i = 0; i<numTables; i++)
			{
				var tag:int = _data.readInt();
		        var checksum:int = _data.readInt();
		        var offset:int = _data.readInt();
		        var length:int = _data.readInt();
		        var name:String = (String.fromCharCode((tag >> 24) & 0xff) +  
	  							   String.fromCharCode((tag >> 16) & 0xff) + 
	            				   String.fromCharCode((tag >> 8) & 0xff) + 
	            				   String.fromCharCode((tag) & 0xff)).toString();
		        
		        _tables[name] = {tag:tag, checksum:checksum, offset:offset, length:length};
	  		}
	  		
	  		//Extract number of glyfs in file .
	  		var maxpTable:MaxpTable = new MaxpTable(_data, _tables["maxp"].offset);
	  		var numGlyfs:uint = maxpTable.numGlyfs;
	  		
	  		//Extract head data.
	  		var headTable:HeadTable = new HeadTable(_data, _tables["head"].offset);
	  		var indexToLocFormat:int = headTable.indexToLocFormat;
	  		
	  		//Extract loca data.
	  		var locaTable:LocaTable = new LocaTable(_data, _tables["loca"].offset, numGlyfs, indexToLocFormat);
	  		var locaOffsets:Array = locaTable.offsets;
	  		
	  		//Extract cmap data.
	  		var cmapTable:CmapTable = new CmapTable(_data, _tables["cmap"].offset, numGlyfs, _rangeArray);
	  		var mappings:Array = cmapTable.mappings;
	  		
	  		//Extract hhea data.
	  		var hheaTable:HheaTable = new HheaTable(_data, _tables["hhea"].offset);
	  		var numberOfHorMetrics:int = hheaTable.numberOfHorMetrics;
	  		
	  		//Extract hmtx data.
	  		var hmtxTable:HmtxTable = new HmtxTable(_data, _tables["hmtx"].offset, numGlyfs, numberOfHorMetrics);
	  		var metrics:Array = hmtxTable.metrics;
	  		
	  		//Extract glyf data.
	  		var glyfTable:GlyfTable = new GlyfTable(_data, _tables["glyf"].offset, numGlyfs, locaOffsets, mappings, _rangeArray, metrics);
	  		_glyfs = glyfTable.glyfs;
		}
		
		public function get glyfs():Dictionary
		{
			return _glyfs;
		}
	}
}