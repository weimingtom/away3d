package away3d.test;

import away3d.containers.Scene3D;
import away3d.containers.ObjectContainer3D;
import flash.events.EventDispatcher;
import away3d.core.render.IRenderer;
import away3d.core.render.AbstractRenderSession;


/**
 * Represents a single slide of the demo
 */
class Slide  {
	
	public var scene:Scene3D;
	public var renderer:IRenderer;
	public var session:AbstractRenderSession;
	public var title:String;
	public var desc:String;
	

	public function new(title:String, desc:String, scene:Scene3D, renderer:IRenderer, session:AbstractRenderSession) {
		
		
		this.scene = scene;
		this.renderer = renderer;
		this.session = session;
		this.title = title;
		this.desc = desc;
	}

}

