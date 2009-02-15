package away3d.materials;

import away3d.core.draw.DrawSegment;


/**
 * Interface for materials that are capable of drawing line segments.
 */
interface ISegmentMaterial implements IMaterial  {
	
	function renderSegment(seg:DrawSegment):Void;

	

}

