package away3d.core.render;

import away3d.containers.View3D;


/**
 * Interface for renderers capable of rendering a scene to a view
 */
interface IRenderer  {
	
	function render(view:View3D):Void;

	function toString():String;

	

}

