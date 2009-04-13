package away3d.core.draw;

import away3d.containers.View3D;


/**
 * Interface for containers capable of drawing primitives
 */
interface IPrimitiveConsumer  {
	
	function primitive(pri:DrawPrimitive):Bool;

	function list():Array<DrawPrimitive>;

	function clear(view:View3D):Void;

	function clone():IPrimitiveConsumer;

	

}

