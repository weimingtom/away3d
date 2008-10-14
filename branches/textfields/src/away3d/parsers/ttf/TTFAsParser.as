package away3d.parsers.ttf
{
	import flash.utils.Dictionary;
	
	public class TTFAsParser
	{
		public var glyfs:Dictionary;
		
		public function TTFAsParser(Source:*)
		{
			glyfs = new Dictionary();
			
			Source.initialize();
			
			var motifs:Object = Source.__motifs;
			var widths:Object = Source.__widths;
			var height:Number = Source.__height;
			
			var i:Object;
			var j:uint;
			for(i in motifs)
			{
				var motif:Array = motifs[i];
				var width:Number = widths[i];
				
				//Extract instructions data.
				var instructions:Array = [];
				for(j = 0; j<motif.length; j++)
				{
					var entry:Array = motif[j];
					switch(entry[0])
					{
						case "M":
							instructions.push({type:0, x:entry[1][0], y:entry[1][1]});
							break;
						case "L":
							instructions.push({type:1, x:entry[1][0], y:entry[1][1]});
							break;
						case "C":
							instructions.push({type:2, cx:entry[1][0], cy:entry[1][1], x:entry[1][2], y:entry[1][3]});
							break;
					}
				}
				
				//Build glyf object.
				glyfs[i] = {instructions:instructions, width:width, height:height};
			}
		}
	}
}