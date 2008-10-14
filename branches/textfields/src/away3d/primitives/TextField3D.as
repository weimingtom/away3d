package away3d.primitives
{
	import away3d.core.base.Shape3D;
	import away3d.parsers.ttf.TTFAsParser;
	import away3d.parsers.ttf.TTFBinaryParser;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class TextField3D extends Sprite3D
	{
		private var _glyfData:Dictionary;
		private var _fontRange:String;
		private var _text:String;
		private var _xOffset:Number = 0;
		private var _yOffset:Number = 0;
		
		public function TextField3D(text:String, fontSource:*, fontRange:String = null)
		{
			_text = text;
			
			if(_fontRange)
				_fontRange = fontRange;
			else
				_fontRange = text;
			
			setFont(fontSource);
		}
		
		public function setText(text:String):void
		{
			_text = text;
			
			//Clear previous glyfs shapes here...
			//Reset values...
			
			for(var i:uint; i<_text.length; i++)
				addGlyf(text.charAt(i));
		}
		
		private function addGlyf(char:String, X:Number = 0, Y:Number = 0):void
		{
			var shp:Shape3D = new Shape3D();
			
			var glyf:Object = _glyfData[char];
			for(var i:uint; i<glyf.instructions.length; i++)
			{
				var instruction:Object = glyf.instructions[i];
				var tempScale:Number = 0.1; //Provisory...
				var tX:Number = instruction.x*tempScale + _xOffset;
				var tY:Number = instruction.y*tempScale;
				
				switch(instruction.type)
				{	
					case 0:
						shp.graphicsMoveTo(tX, tY);
						break;
					case 1:
						shp.graphicsLineTo(tX, tY);
						break;
					case 2:
						var cX:Number = instruction.cx*tempScale + _xOffset;
						var cY:Number = instruction.cy*tempScale;
						//trace("curve: " + cX + ", " + cY + ", " + tX + ", " + tY);
						shp.graphicsCurveTo(cX, cY, tX, tY);  
						break;
				}
			}
			
			addChild(shp);
			
			_xOffset += glyf.width*tempScale;
		}
		
		public function setFont(fontSource:*):void
		{ 
			_glyfData = new Dictionary();
			
			//Determine which type of source is passed.
			if(typeof(fontSource) == "string")
			{
				//Its an external TTF file for loading.
				//var loader:TTFLoader = new TTFLoader(source, parseBinaryFile);
			}
			else
			{
				var sourceFile:* = new fontSource();
				
				//Check to see if the source is a ByteArray.
				var passed:Boolean;
				try
				{
					//Test...
					var bytes:int = sourceFile.bytesAvailable;
					passed = true;
				}
				catch(error:Error){}
				if(passed)
					parseBinaryFile(sourceFile);
				else
					parseAsFile(fontSource);
			}
			
			setText(_text);
		}
		
		private function parseBinaryFile(fontSource:ByteArray):void
		{
			var ttfBinaryParser:TTFBinaryParser = new TTFBinaryParser(fontSource, _fontRange);
			_glyfData = ttfBinaryParser.glyfs;
		}
		
		private function parseAsFile(source:Class):void
		{
			var ttfAsParser:TTFAsParser = new TTFAsParser(source);
			_glyfData = ttfAsParser.glyfs;
		}
	}
}