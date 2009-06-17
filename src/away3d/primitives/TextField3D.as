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
		private var _textAlpha:uint;
		
		private const emSize:Number = 1024;
		
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
			
			this.bothsides = true;
			
			buildText();
		}
		
		private function buildText():void
		{
			geometry.graphics.clear();
			
			geometry.graphics.lineStyle(1, 0, 0);
			geometry.graphics.beginFill(_textColor, _textAlpha);
			VectorText.write(geometry.graphics, _fontId, _size, _leading, _kerning, _text, 0, 0, _textWidth, _align, false);
			geometry.graphics.endFill();
			
			geometry.graphics.apply();
		}
	}
}