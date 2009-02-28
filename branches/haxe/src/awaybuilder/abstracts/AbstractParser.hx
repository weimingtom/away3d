package awaybuilder.abstracts;

import awaybuilder.interfaces.IParser;
import flash.events.EventDispatcher;


class AbstractParser extends EventDispatcher, implements IParser {
	public var sections(getSections, null) : Array<Dynamic>;
	
	private var _sections:Array<Dynamic>;
	

	public function new() {
		this._sections = [];
		
		
		super();
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Public Methods
	//
	////////////////////////////////////////////////////////////////////////////////
	public function parse(data:Dynamic):Void {
		
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Getters and Setters
	//
	////////////////////////////////////////////////////////////////////////////////
	public function getSections():Array<Dynamic> {
		
		return this._sections;
	}

}

