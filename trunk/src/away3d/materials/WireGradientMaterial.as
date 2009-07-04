package away3d.materials
{
    import away3d.containers.*;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    import away3d.events.*;
    
    import flash.display.*;
    import flash.events.*;
    import flash.geom.Rectangle;

    /**
    * Wire material for gradient color drawing with optional face border outlining
    */
    public class WireGradientMaterial extends EventDispatcher implements ITriangleMaterial
    {
        /**
        * Instance of the Init object used to hold and parse default property values
        * specified by the initialiser object in the 3d object constructor.
        */
		protected var ini:Init;
		
		/**
		 * Determines the color value of the material
		 */
        public var color1:int;
        public var color2:int;
        
    	/**
    	 * Determines the alpha value of the material
    	 */
        public var alpha1:Number;
        public var alpha2:Number;
        
        public var ratio1:Number;
        public var ratio2:Number;
        
        public var gradientType:String;
        public var spreadMethod:String;
        public var interpolationMethod:String;
        
        public var rotation:Number;
        
    	/**
    	 * Determines the wire width
    	 */
        public var width:Number;
        
    	/**
    	 * Determines the color value of the border wire
    	 */
        public var wirecolor:int;
        
    	/**
    	 * Determines the alpha value of the border wire
    	 */
        public var wirealpha:Number;
    	
		/**
		 * Creates a new <code>WireGradientMaterial</code> object.
		 * 
		 * @param	color1				A string, hex value or colorname representing the color1 of the material.
		 * @param	color2				A string, hex value or colorname representing the color2 of the material.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function WireGradientMaterial(color1:* = null, color2:* = null, init:Object = null)
        {
            if(color1 == null)
            	color1 = "random";
            	
            if(color2 == null)
            	color2 = "random";

            this.color1 = Cast.trycolor(color1);
            this.color2 = Cast.trycolor(color2);

            ini = Init.parse(init);
            
            alpha1 = ini.getNumber("alpha1", 1, {min:0, max:1});
            alpha2 = ini.getNumber("alpha2", 1, {min:0, max:1});
            ratio1 = ini.getNumber("ratio1", 0, {min:0, max:255});
            ratio2 = ini.getNumber("ratio2", 255, {min:0, max:255});
            gradientType = ini.getString("gradientType", GradientType.LINEAR);
        	spreadMethod = ini.getString("spreadMethod", SpreadMethod.PAD);
        	interpolationMethod = ini.getString("interpolationMethod", InterpolationMethod.RGB);
            rotation = ini.getNumber("rotation", 0);
            wirecolor = ini.getColor("wirecolor", 0x000000);
            width = ini.getNumber("width", 1, {min:0});
            wirealpha = ini.getNumber("wirealpha", 1, {min:0, max:1});
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
        	if(alpha1 <= 0 && alpha2 <= 0 && wirealpha <= 0)
            	return;
        	
        	var gradientObj:Object = {
        								gradientType:gradientType,
        								rotation:rotation,
        								colors:[color1, color2],
        								alphas:[alpha1, alpha2],
        								ratios:[ratio1, ratio2],
        								width:tri.maxX - tri.minX,
        								height:tri.maxY - tri.minY,
        								x:tri.minX,
        								y:tri.minY,
        								spreadMethod:spreadMethod,
        								interpolationMethod:interpolationMethod
        							 };
			
			tri.source.session.renderTriangleLineGradientFill(width, wirecolor, wirealpha, gradientObj, tri.screenVertices, tri.commands, tri.screenIndices, tri.startIndex, tri.endIndex);
        }
        
		/**
		 * @inheritDoc
		 */
        public function get visible():Boolean
        {
            return (alpha1 > 0) || (alpha2 > 0) || (wirealpha > 0);
        }
        
		/**
		 * @inheritDoc
		 */
        public function addOnMaterialUpdate(listener:Function):void
        {
        	addEventListener(MaterialEvent.MATERIAL_UPDATED, listener, false, 0, true);
        }
        
		/**
		 * @inheritDoc
		 */
        public function removeOnMaterialUpdate(listener:Function):void
        {
        	removeEventListener(MaterialEvent.MATERIAL_UPDATED, listener, false);
        }
    }
}
