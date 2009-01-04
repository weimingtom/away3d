package away3d.loaders
{
	import away3d.loaders.data.FontData;
	import away3d.loaders.table.CmapTable;
	import away3d.loaders.table.GlyfTable;
	import away3d.loaders.table.HeadTable;
	import away3d.loaders.table.HheaTable;
	import away3d.loaders.table.HmtxTable;
	import away3d.loaders.table.LocaTable;
	import away3d.loaders.table.MaxpTable;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class TTF
	{
		private static var _loader:URLLoader;
		private static var _loadingFont:FontData;
		private static var _data:ByteArray;
		private static var _characters:String;
		
		private static var _fontScaling:Number = 0.1;
		
		public function TTF()
		{
			
		}
		
		public static function parse(data:ByteArray, characters:String, init:Object = null):FontData
		{
			_data = data;
			_characters = characters;
			
			_loadingFont = new FontData();
			
			parseFont();
			
			return _loadingFont;
		}
			
		public static function load(url:String, characters:String, init:Object = null):FontData
        {
        	_characters = characters;
        	
        	_loader = new URLLoader(new URLRequest(url));
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener(ProgressEvent.PROGRESS, loadProgressHandler);
			_loader.addEventListener(Event.COMPLETE, loadCompleteHandler);
        	
        	_loadingFont = new FontData();
        	
			return _loadingFont;
        }
        
        private static function loadProgressHandler(evt:ProgressEvent):void
        {
        	//trace(evt.bytesLoaded/evt.bytesTotal);
        }
        
        private static function loadCompleteHandler(evt:Event):void
        {
        	_data = _loader.data;
        	
        	parseFont();
        }
        
        private static function parseFont():void
        {
        	//Vars.
        	var range:Array = [];
        	var tables:Dictionary = new Dictionary();
        	var unitsPerEm:uint;
        	var glyfs:Dictionary = new Dictionary();
        	
        	//Prepare rangeArray.
			var i:uint
			for(i = 0; i<_characters.length; i++)
				range.push(_characters.charAt(i));
			
			//Read general data from binary file.
			var version:int = _data.readInt();
	        var numTables:int = _data.readShort();
	        var searchRange:int = _data.readShort();
	        var entrySelector:int = _data.readShort();
	        var rangeShift:int = _data.readShort();
	        
	        //Read table locations from binary file.
	        tables = new Dictionary();
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
		        
		        tables[name] = {tag:tag, checksum:checksum, offset:offset, length:length};
	  		}
	  		
	  		//Extract number of glyfs in file .
	  		var maxpTable:MaxpTable = new MaxpTable(_data, tables["maxp"].offset);
	  		var numGlyfs:uint = maxpTable.numGlyfs;
	  		
	  		//Extract head _data.
	  		var headTable:HeadTable = new HeadTable(_data, tables["head"].offset);
	  		var indexToLocFormat:int = headTable.indexToLocFormat;
	  		unitsPerEm = headTable.unitsPerEm;
	  		
	  		//Extract loca _data.
	  		var locaTable:LocaTable = new LocaTable(_data, tables["loca"].offset, numGlyfs, indexToLocFormat);
	  		var locaOffsets:Array = locaTable.offsets;
	  		
	  		//Extract cmap _data.
	  		var cmapTable:CmapTable = new CmapTable(_data, tables["cmap"].offset, numGlyfs, range);
	  		var mappings:Array = cmapTable.mappings;
	  		
	  		//Extract hhea _data.
	  		var hheaTable:HheaTable = new HheaTable(_data, tables["hhea"].offset);
	  		var numberOfHorMetrics:int = hheaTable.numberOfHorMetrics;
	  		
	  		//Extract hmtx _data.
	  		var hmtxTable:HmtxTable = new HmtxTable(_data, tables["hmtx"].offset, numGlyfs, numberOfHorMetrics);
	  		var metrics:Array = hmtxTable.metrics;
	  		
	  		//Extract glyf _data.
	  		var glyfTable:GlyfTable = new GlyfTable(_data, tables["glyf"].offset, numGlyfs, locaOffsets, mappings, range, metrics);
	  		glyfs = glyfTable.glyfs;
	  		
	  		//Construct FontData element.
	  		for each(var element:Object in glyfs)
	  		{
	  			var instructionsArray:Array = [];
	  			
	  			var instructions:Array = element.instructions;
	  			var width:Number = _fontScaling*element.width;
	  			var height:Number = _fontScaling*element.height;
	  			var char:String = element.char;
	  			for(i = 0; i<instructions.length; i++)
	  			{
	  				var elementArray:Array = [];
	  				
	  				var type:uint = instructions[i].type;
	  				switch(type)
					{
						case 0:
							elementArray = ['M', _fontScaling*instructions[i].x, _fontScaling*instructions[i].y];
							break;
						case 1:
							elementArray = ['L', _fontScaling*instructions[i].x, _fontScaling*instructions[i].y];
							break;
						case 2:
							elementArray = ['C', _fontScaling*instructions[i].x, _fontScaling*instructions[i].y, _fontScaling*instructions[i].cx, _fontScaling*instructions[i].cy];
							break;
					}
					instructionsArray.push(elementArray);
	  			}
	  			
	  			_loadingFont.glyfs[char] = instructionsArray;
	  			_loadingFont.dims[char] = [width, height];
	  			
	  			//Provisory...
		  		_loadingFont.glyfs[" "] = [];
		  		_loadingFont.dims[" "] = _loadingFont.dims[char];
	  		}
	  		
	  		_loadingFont.reportChanges();
        }
	}
}