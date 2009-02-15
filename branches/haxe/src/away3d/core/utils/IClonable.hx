package away3d.core.utils;

import away3d.core.base.Object3D;


/** Interface for object that can be cloned */
interface IClonable  {
	
	function clone(?object:Object3D=null):Object3D;

	

}

