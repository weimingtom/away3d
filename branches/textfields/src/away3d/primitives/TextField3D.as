package away3d.primitives
{
	import away3d.core.base.Shape3D;
	import away3d.loaders.data.FontData;
	
	import flash.geom.Point;
	
	public class TextField3D extends Sprite3D
	{
		/////////////////////////////////////////////////////////////////////////////////////
		//Private variables.
		/////////////////////////////////////////////////////////////////////////////////////
		
		//Have getters and/or setters.
		private var _text:String;
		private var _font:FontData;
		private var _textSize:Number;
		private var _letterSpacing:Number;
		private var _lineSpacing:Number;
		private var _width:Number;
		
		private var _penPosition:Point;
		private var _fontScaling:Number = 0.02;
		private var _lineCount:uint;
		private var _maxPosition:Point;
		private var _minPosition:Point;
		
		/////////////////////////////////////////////////////////////////////////////////////
		//Constructor.
		/////////////////////////////////////////////////////////////////////////////////////
		
		public function TextField3D(text:String, font:FontData, init:Object = null)
		{
			super(init);
			
			_textSize = ini.getNumber("textSize", 20, {min:1});
			_letterSpacing = ini.getNumber("letterSpacing", 0);
			_lineSpacing = ini.getNumber("lineSpacing", 0);
			_width = ini.getNumber("width", 500);
			
			_text = text;
			_font = font;
			
			generateText();
		}
		
		/////////////////////////////////////////////////////////////////////////////////////
		//Setters and getters.
		/////////////////////////////////////////////////////////////////////////////////////
		
		public function get textSize():Number
		{
			return _textSize;
		}
		public function set textSize(value:Number):void
		{
			if(value == _textSize)
				return;
			
			_textSize = value;
			
			generateText();
		}
		
		public function get text():String
		{
			return _text;	
		}
		public function set text(value:String):void
		{
			if(value == _text)
				return;
			
			_text = value;
			
			generateText();
		}
		
		public function get letterSpacing():Number
		{
			return _letterSpacing;	
		}
		public function set letterSpacing(value:Number):void
		{
			if(value == _letterSpacing)
				return;
			
			_letterSpacing = value;
			
			generateText();
		}
		
		public function get lineSpacing():Number
		{
			return _lineSpacing;	
		}
		public function set lineSpacing(value:Number):void
		{
			if(value == _lineSpacing)
				return;
			
			_lineSpacing = value;
			
			generateText();
		}
		
		public function get font():FontData
		{ 
			return _font;
		}
		public function set font(value:FontData):void
		{
			if(value == _font)
				return;
		
			_font = value;
			
			generateText();
		}
		
		public function get textWidth():Number
		{
			//trace(_maxPosition.x + ", " + _minPosition.x);
			return _maxPosition.x - _minPosition.x;
		}
		public function get textHeight():Number
		{
			return _maxPosition.y - _minPosition.y;
		}
		
		public function get width():Number
		{
			return _width;
		}
		public function set width(value:Number):void
		{
			if(value == _width)
				return;
			
			_width = value;
			
			generateText();
		}
		
		/////////////////////////////////////////////////////////////////////////////////////
		//Private methods.
		/////////////////////////////////////////////////////////////////////////////////////
		
		private function generateText():void
		{
			resetText();
			
			for(var i:uint; i<_text.length; i++)
				addGlyf(text.charAt(i));
		}
		
		private function resetText():void
		{
			_penPosition = new Point();
			_lineCount = 0;
			_minPosition = new Point();
			_maxPosition = new Point();
			
			var shapeCount:uint = shapes.length;
			for(var i:uint; i<shapeCount; i++)
				removeChild(shapes[0]);
		}
		
		private function addGlyf(char:String, X:Number = 0, Y:Number = 0):void
		{
			if(char == " " && _penPosition.x == 0 && _lineCount != 0)
				return;
			
			var shp:Shape3D = new Shape3D();
			shp.name = char;
			
			var tX:Number = 0;
			var tY:Number = 0;
			var cX:Number = 0;
			var cY:Number = 0;
			
			if(_font.glyfs[char])
				var glyf:Array = _font.glyfs[char];
			else
				throw new Error("Used font does not contain the character '" + char + "'.");
			
			for(var i:uint; i<glyf.length; i++)
			{
				var instructionType:String = glyf[i][0];
				
				tX = glyf[i][1]*_textSize*_fontScaling + _penPosition.x;
				tY = glyf[i][2]*_textSize*_fontScaling + _penPosition.y;
				analyseDimensionsForPoint(tX, tY);
				
				switch(instructionType)
				{	
					case 'M':
						shp.graphicsMoveTo(tX, tY, 0);
						break;
					case 'L':
						shp.graphicsLineTo(tX, tY, 0);
						break;
					case 'C':
						cX = glyf[i][3]*_textSize*_fontScaling + _penPosition.x;
						cY = glyf[i][4]*_textSize*_fontScaling + _penPosition.y;
						analyseDimensionsForPoint(cX, cY);
						shp.graphicsCurveTo(cX, cY, 0, tX, tY, 0);  
						break;
				}
			}
			
			var penDeltaX:Number = _font.dims[char][0]*_textSize*_fontScaling + _letterSpacing;
			if(_penPosition.x + penDeltaX < _width)
				_penPosition.x += penDeltaX;
			else
			{
				_penPosition.x = 0;
				_penPosition.y -= _font.dims[" "][1]*_textSize*_fontScaling + _lineSpacing;
				_lineCount++;
			}
			
			addChild(shp);
		}
		
		private function analyseDimensionsForPoint(X:Number, Y:Number):void
		{
			if(X > _maxPosition.x)
				_maxPosition.x = X;
			if(Y > _maxPosition.y)
				_maxPosition.y = Y;
				
			if(X < _minPosition.x)
				_minPosition.x = X;
			if(Y < _minPosition.y)
				_minPosition.y = Y;
		}
	}
}