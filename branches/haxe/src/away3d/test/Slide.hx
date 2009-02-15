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
		
		OPPOSITE_OR[X | X] = N;
		OPPOSITE_OR[XY | X] = Y;
		OPPOSITE_OR[XZ | X] = Z;
		OPPOSITE_OR[XYZ | X] = YZ;
		OPPOSITE_OR[Y | Y] = N;
		OPPOSITE_OR[XY | Y] = X;
		OPPOSITE_OR[XYZ | Y] = XZ;
		OPPOSITE_OR[YZ | Y] = Z;
		OPPOSITE_OR[Z | Z] = N;
		OPPOSITE_OR[XZ | Z] = X;
		OPPOSITE_OR[XYZ | Z] = XY;
		OPPOSITE_OR[YZ | Z] = Y;
		SCALINGS[1] = [1, 1, 1];
		SCALINGS[2] = [-1, 1, 1];
		SCALINGS[4] = [-1, 1, -1];
		SCALINGS[8] = [1, 1, -1];
		SCALINGS[16] = [1, -1, 1];
		SCALINGS[32] = [-1, -1, 1];
		SCALINGS[64] = [-1, -1, -1];
		SCALINGS[128] = [1, -1, -1];
		
		this.scene = scene;
		this.renderer = renderer;
		this.session = session;
		this.title = title;
		this.desc = desc;
	}

}

