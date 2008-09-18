package away3d.materials
{
    import away3d.containers.*;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    import away3d.events.*;
    
    import flash.events.*;
	
    /**
    * Material for solid color drawing
    */
    public class ColorMaterial extends EventDispatcher implements ITriangleMaterial, IFogMaterial
    {
    	private var _alpha:Number;
    	
        /**
        * Instance of the Init object used to hold and parse default property values
        * specified by the initialiser object in the 3d object constructor.
        */
		protected var ini:Init;
		
		/**
		 * 24 bit color value representing the material color
		 */
        public var color:uint;
        
		/**
		 * @inheritDoc
		 */
        public function set alpha(val:Number):void
        {
        	_alpha = val;
        }
        
        public function get alpha():Number
        {
        	return _alpha;
        }
        
		/**
		 * @inheritDoc
		 */
        public function get visible():Boolean
        {
            return (alpha > 0);
        }
    	
		/**
		 * Creates a new <code>ColorMaterial</code> object.
		 * 
		 * @param	color				A string, hex value or colorname representing the color of the material.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function ColorMaterial(color:* = null, init:Object = null)
        {
            if (color == null)
                color = "random";

            this.color = Cast.trycolor(color);

            ini = Init.parse(init);
            
            _alpha = ini.getNumber("alpha", 1, {min:0, max:1});
        }
        
		/**
		 * @inheritDoc
		 */
        public function updateMaterial(source:Object3D, view:View3D):void
        {
        	
        }
        
		/**
		 * @inheritDoc
		 */
        public function renderTriangle(tri:DrawTriangle):void
        {
            tri.source.session.renderTriangleColor(color, _alpha, tri.v0, tri.v1, tri.v2);
        }
        
		/**
		 * @inheritDoc
		 */
        public function renderFog(fog:DrawFog):void
        {
            fog.source.session.renderFogColor(fog.clip, color, _alpha);
        }
        
		/**
		 * @inheritDoc
		 */
        public function clone():IFogMaterial
        {
        	return new ColorMaterial(color, {alpha:alpha});
        }
        
		/**
		 * @inheritDoc
		 */
        public function addOnUpdate(listener:Function):void
        {
        	addEventListener(MaterialEvent.UPDATED, listener, false, 0, true);
        }
        
		/**
		 * @inheritDoc
		 */
        public function removeOnUpdate(listener:Function):void
        {
        	removeEventListener(MaterialEvent.UPDATED, listener, false);
        }
    }
}
