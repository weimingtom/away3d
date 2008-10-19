package away3d.primitives
{
	import away3d.core.base.Shape3D;
	import away3d.loaders.TTFLoader;
	import away3d.materials.ShapeMaterial;
	import away3d.parsers.ttf.TTFAsParser;
	import away3d.parsers.ttf.TTFBinaryParser;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class TextField3D extends Sprite3D
	{
		private var _text:String;
		private var _textSize:Number;
		
		private var _glyfData:Dictionary;
		private var _effectiveScaling:Number;
		private var _fontRange:String;
		private var _xOffset:Number = 0;
		private var _yOffset:Number = 0;
		
		public function TextField3D(text:String, fontSource:*, init:Object = null)
		{
			super(init);
			
			_textSize = ini.getNumber("textSize", 20, {min:1, max:160});
			
			_text = text;
			_fontRange = text;
			this.font = fontSource;
		}
		
		public function get textSize():Number
		{
			return _textSize;
		}
		public function set textSize(value:Number):void
		{
			_textSize = value;
			generateText();
		}
		
		public function get text():String
		{
			return _text;	
		}
		public function set text(value:String):void
		{
			_text = value;
			_fontRange = value;
		}
		
		private function generateText():void
		{
			var i:uint
			/* for(i = 0; i<shapes.length; i++)
				removeChild(shapes[i]); */
			
			for(i = 0; i<_text.length; i++)
				addGlyf(text.charAt(i));
		}
		
		public function set font(fontSource:*):void
		{ 
			_glyfData = new Dictionary();
			
			if(typeof(fontSource) == "string")
			{
				//Its an external TTF file for loading.
				var loader:TTFLoader = new TTFLoader(fontSource, parseBinaryFile);
			}
			else
			{
				var sourceFile:* = new fontSource();
				
				//Check to see if the source is a ByteArray.
				var passed:Boolean;
				try
				{
					var bytes:int = sourceFile.bytesAvailable;
					passed = true;
				}
				catch(error:Error){}
				if(passed)
					parseBinaryFile(sourceFile);
				else
					parseAsFile(fontSource);
			}
		}
		
		private function addGlyf(char:String, X:Number = 0, Y:Number = 0):void
		{
			var shp:Shape3D = new Shape3D();
			shp.material = ShapeMaterial(this.material);
			
			var glyf:Object = _glyfData[char];
			for(var i:uint; i<glyf.instructions.length; i++)
			{
				var instruction:Object = glyf.instructions[i];
				var tX:Number = instruction.x*_effectiveScaling + _xOffset;
				var tY:Number = instruction.y*_effectiveScaling;
				
				switch(instruction.type)
				{	
					case 0:
						shp.graphicsMoveTo(tX, tY);
						break;
					case 1:
						shp.graphicsLineTo(tX, tY);
						break;
					case 2:
						var cX:Number = instruction.cx*_effectiveScaling + _xOffset;
						var cY:Number = instruction.cy*_effectiveScaling;
						shp.graphicsCurveTo(cX, cY, tX, tY);  
						break;
				}
			}
			_xOffset += glyf.width*_effectiveScaling;
			
			addChild(shp);
		}
		
		private function parseBinaryFile(fontSource:ByteArray):void
		{
			var ttfBinaryParser:TTFBinaryParser = new TTFBinaryParser(fontSource, _fontRange);
			_glyfData = ttfBinaryParser.glyfs;
			
			_effectiveScaling = _textSize*50/ttfBinaryParser.unitsPerEm;
			
			generateText();
		}
		
		private function parseAsFile(source:Class):void
		{
			var ttfAsParser:TTFAsParser = new TTFAsParser(source);
			_glyfData = ttfAsParser.glyfs;
			
			_effectiveScaling = _textSize/2;
			
			generateText();
		}
	}
}