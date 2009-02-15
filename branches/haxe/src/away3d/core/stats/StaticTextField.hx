package away3d.core.stats;

import flash.text.TextField;
import flash.text.TextFormat;


class StaticTextField extends TextField  {
	
	public var defaultText:String;
	

	public function new(?text:String=null, ?textFormat:TextFormat=null) {
		
		
		super();
		defaultTextFormat = (textFormat != null) ? textFormat : new TextFormat();
		selectable = false;
		mouseEnabled = false;
		mouseWheelEnabled = false;
		autoSize = "left";
		tabEnabled = false;
		if ((text != null)) {
			this.htmlText = text;
		}
	}

}

