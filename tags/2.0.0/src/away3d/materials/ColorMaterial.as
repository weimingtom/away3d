package away3d.materials
{
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    
    import flash.display.*;

    /** Material for solid color drawing with face's border outlining */
    public class ColorMaterial implements ITriangleMaterial, IFogMaterial
    {
    	private var _alpha:Number;
    	
        public var color:uint;
        
        public function set alpha(val:Number):void
        {
        	_alpha = val;
        }
        
        public function get alpha():Number
        {
        	return _alpha;
        }

        public function ColorMaterial(color:* = null, init:Object = null)
        {
            if (color == null)
                color = "random";

            this.color = Cast.trycolor(color);

            init = Init.parse(init);
            _alpha = init.getNumber("alpha", 1, {min:0, max:1});
        }
		
        public function renderTriangle(tri:DrawTriangle):void
        {
            tri.source.session.renderTriangleColor(color, _alpha, tri.v0, tri.v1, tri.v2);
        }
        
        public function renderFog(fog:DrawFog):void
        {
            fog.source.session.renderFogColor(color, _alpha);
        }
        
        public function get visible():Boolean
        {
            return (alpha > 0);
        }
        
        public function fogLayer():IFogMaterial
        {
        	return new ColorMaterial(color, {alpha:alpha});
        }
    }
}
