package away3d.materials;

import flash.geom.Rectangle;
import away3d.core.utils.FaceMaterialVO;
import flash.display.Sprite;
import away3d.core.draw.DrawTriangle;


/**
 * Interface for materials that can be layered using <code>CompositeMaterial</code> or <code>BitmapMaterialContainer</code>.
 * 
 * @see away3d.materials.CompositeMaterial
 * @see away3d.materials.BitmapMaterialContainer
 */
interface ILayerMaterial implements IMaterial  {
	
	function renderBitmapLayer(tri:DrawTriangle, containerRect:Rectangle, parentFaceMaterialVO:FaceMaterialVO):FaceMaterialVO;

	function renderLayer(tri:DrawTriangle, layer:Sprite, level:Int):Void;

	

}

