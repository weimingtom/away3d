package away3d.primitives
{
	import away3d.core.base.Shape3D;
	import away3d.core.base.Vertex;
	import away3d.loaders.data.FontData;
	
	import flash.events.Event;
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
		private var _paragraphWidth:Number;
		private var _useWordWrapping:Boolean;
		private var _penPosition:Point;
		private var _lineCount:uint;
		private var _words:Array;
		private var _currentWord:Array;
		private var _lastWordStartPenPositionX:Number;
		
		private var _fontScaling:Number = 0.02;
		
		/////////////////////////////////////////////////////////////////////////////////////
		//Constructor.
		/////////////////////////////////////////////////////////////////////////////////////
		
		public function TextField3D(text:String, font:FontData, init:Object = null)
		{
			super(init);
			
			_textSize = ini.getNumber("textSize", 20, {min:1});
			_letterSpacing = ini.getNumber("letterSpacing", 0);
			_lineSpacing = ini.getNumber("lineSpacing", 0);
			_paragraphWidth = ini.getNumber("paragraphWidth", 1000);
			_useWordWrapping = ini.getBoolean("useWordWrapping", true);
			
			_text = text;
			this.font = font;
			
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
			_font.addEventListener(Event.CHANGE, refreshFont);
			
			generateText();
		}
		
		public function get paragraphWidth():Number
		{
			return _paragraphWidth;
		}
		public function set paragraphWidth(value:Number):void
		{
			if(value == _paragraphWidth)
				return;
			
			_paragraphWidth = value;
			
			generateText();
		}
		
		public function get words():Array
		{
			return _words;
		}
		
		/////////////////////////////////////////////////////////////////////////////////////
		//Event handlers.
		/////////////////////////////////////////////////////////////////////////////////////
		
		private function refreshFont(evt:Event):void
		{
			generateText();
		}
		
		/////////////////////////////////////////////////////////////////////////////////////
		//Private methods.
		/////////////////////////////////////////////////////////////////////////////////////
		
		private function generateText(evt:Event = null):void
		{
			resetText();
			
			for(var i:uint; i<_text.length; i++)
				addGlyf(text.charAt(i));
		}
		
		private function resetText():void
		{
			_penPosition = new Point();
			_words = [];
			_currentWord = [];
			_lineCount = 0;
			_lastWordStartPenPositionX = 0;
			
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
			
			var glyf:Array;
			var dim:Array;
			if(_font.glyfs[char])
			{
				glyf = _font.glyfs[char];
				dim = _font.dims[char];
			}
			else
			{
				glyf = _font.glyfs['nochar'];
				dim = _font.dims['nochar'];
			}
			
			var spaceDim:Array;
			if(_font.dims[' '])
				spaceDim = _font.dims[' '];
			else
				spaceDim = _font.dims['nochar'];
			
			var i:uint;
			for(i = 0; i<glyf.length; i++)
			{
				var instructionType:String = glyf[i][0];
				
				tX = glyf[i][1]*_textSize*_fontScaling + _penPosition.x;
				tY = glyf[i][2]*_textSize*_fontScaling + _penPosition.y;
				
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
						shp.graphicsCurveTo(cX, cY, 0, tX, tY, 0);  
						break;
				}
			}
			
			shp.calculateOrientationXY();
			
			if(_currentWord.length == 0)
				_lastWordStartPenPositionX = _penPosition.x;
			
			_currentWord.push(shp);
			
			var penDeltaX:Number = dim[0]*_textSize*_fontScaling + _letterSpacing;
			if(_penPosition.x + penDeltaX < _paragraphWidth)
				_penPosition.x += penDeltaX;
			else
			{
				var deltaX:Number = _penPosition.x - _lastWordStartPenPositionX;
				var deltaY:Number = spaceDim[1]*_textSize*_fontScaling + _lineSpacing
				
				if(_useWordWrapping)
				{
					for(i = 0; i<_currentWord.length; i++)
					{
						var wordShape:Shape3D = _currentWord[i];
						for each(var vertex:Vertex in wordShape.vertices)
						{
							vertex.x -= _lastWordStartPenPositionX;
							vertex.y -= deltaY;
						}
					}
					
					_penPosition.x = deltaX + penDeltaX;
				}
				else
					_penPosition.x = 0;
				
				_penPosition.y -= deltaY;
				_lineCount++;
			}
			
			if(char == " ")
			{
				_words.push(_currentWord);
				_currentWord = [];
			}
			
			addChild(shp);
		}
	}
}