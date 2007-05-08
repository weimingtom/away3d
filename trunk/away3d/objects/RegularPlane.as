package away3d.objects
{
	import away3d.shapes.*;
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    import flash.display.BitmapData;
    
    public class RegularPlane extends IrregularPlane
    {      
        public function RegularPlane(material:IMaterial = null, init:Object = null)
        {
        	if (init != null)
            {
                sides = init.sides || sides;
            }
        	var shape:RegularShape = new RegularShape(init);
            super(material, shape.vertices, init);
        }
    }
}
