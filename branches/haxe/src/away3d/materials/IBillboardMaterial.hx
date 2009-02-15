package away3d.materials;

import away3d.core.draw.DrawBillboard;


/**
 * Interface for materials that are capable of drawing billboards.
 */
interface IBillboardMaterial implements IMaterial  {
	
	function renderBillboard(bill:DrawBillboard):Void;

	

}

