package away3d.primitives
{
	import away3d.core.base.Mesh;
	
	import wumedia.parsers.swf.DefineFont;
	import wumedia.vector.VectorText;

	public class TextField3D extends Mesh
	{
		private var _fontId:String;
		private var _fontDefinition:DefineFont;
		private var _size:Number;
		private var _leading:Number;
		private var _kerning:Number;
		private var _text:String;
		private var _xOffset:Number = 0;
		private var _yOffset:Number = 0;
		private var _textWidth:Number;
		private var _align:String;
		private var _alignToBaseLine:Boolean;
		private var _textColor:uint;
		private var _textAlpha:Number;
		
		private const emSize:Number = 1024;
		
		public function set textColor(value:uint):void
		{
			_textColor = value;
			buildText();
		}
		public function get textColor():uint
		{
			return _textColor;
		}
		
		public function set size(value:Number):void
		{
			_size = value;
			buildText();
		}
		public function get size():Number
		{
			return _size;
		}
		
		public function set leading(value:Number):void
		{
			_leading = value;
			buildText();
		}
		public function get leading():Number
		{
			return _leading;
		}
		
		public function set kerning(value:Number):void
		{
			_kerning = value;
			buildText();
		}
		public function get kerning():Number
		{
			return _kerning;
		}
		
		public function set text(value:String):void
		{
			_text = value;
			buildText();
		}
		public function get text():String
		{
			return _text;
		}
		
		public function set xOffset(value:Number):void
		{
			_xOffset = value;
			buildText();
		}
		public function get xOffset():Number
		{
			return _xOffset;
		}
		
		public function set yOffset(value:Number):void
		{
			_yOffset = value;
			buildText();
		}
		public function get yOffset():Number
		{
			return _yOffset;
		}
		
		public function set textWidth(value:Number):void
		{
			_textWidth = value;
			buildText();
		}
		public function get textWidth():Number
		{
			return _textWidth;
		}
		
		public function set align(value:String):void
		{
			_align = value;
			buildText();
		}
		public function get align():String
		{
			return _align;
		}
		
		public function set alignToBaseLine(value:Boolean):void
		{
			_alignToBaseLine = value;
			buildText();
		}
		public function get alignToBaseLine():Boolean
		{
			return _alignToBaseLine;
		}
		
		public function set textAlpha(value:Number):void
		{
			_textAlpha = value;
			buildText();
		}
		public function get textAlpha():Number
		{
			return _textAlpha;
		}
		
		public function TextField3D(fontId:String, init:Object = null)
		{
			super(init);
			
			_fontId = fontId;
			_fontDefinition = VectorText.getFontDefinition(_fontId);
			
			_size = ini.getNumber("size", 20);
			_leading = ini.getNumber("leading", 20);
			_kerning = ini.getNumber("kerning", 0);
			_text = ini.getString("text", "");
			_textWidth = ini.getNumber("textWidth", 500);
			_align = ini.getString("align", "TL");
			_alignToBaseLine = ini.getBoolean("alignToBase", false);
			_textColor = ini.getInt("textColor", 0, {min:0, max:0xFFFFFF});
			_textAlpha = ini.getNumber("textAlpha", 1, {min:0, max:1});
			
			buildText();
		}
		
		private function buildText():void
		{
			geometry.graphics.clear();
			geometry.graphics.lineStyle(1, 0, 0);
			geometry.graphics.beginFill(_textColor, _textAlpha);
			VectorText.write(geometry.graphics, _fontId, _size, _leading, _kerning, _text, 0, 0, _textWidth, _align, false);
			geometry.graphics.endFill();
		}
	}
}