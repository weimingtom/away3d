package away3d.materials
{
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.core.draw.DrawShape;
	import away3d.core.draw.DrawTriangle;
	import away3d.core.utils.Cast;
	import away3d.core.utils.Init;
	import away3d.events.MaterialEvent;
	import away3d.core.arcane;
	
	import flash.display.Graphics;
	import flash.events.EventDispatcher;
	
	/* Li */
	/**
    * Shape material for drawing vector shapes.
    */
	public class ShapeMaterial extends EventDispatcher implements IShapeMaterial
	{
		use namespace arcane;
		
		/**
        * Instance of the Init object used to hold and parse default property values
        * specified by the initialiser object in the 3d object constructor.
        */
		protected var ini:Init;
		
		/**
		 * Determines the color value of the fill
		 */
        public var fillColor:int;
        
        /**
		 * Determines the alpha value of the fill
		 */
        public var fillAlpha:Number;
        
        /**
		 * Determines the color value of the lineStyle
		 */
        public var lineColor:int;
        
        /**
		 * Determines the alpha value of the lineStyle
		 */
        public var lineAlpha:Number;
        
        /**
		 * Determines the thickness value of the lineStyle
		 */
        public var lineThickness:Number;
        
        /* private */
        arcane var _graphics:Graphics;
		
		/**
		 * Creates a new <code>ShapeMaterial</code> object.
		 * 
		 * @param	fillColor				A string, hex value or colorname representing the color of the fill.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function ShapeMaterial(fillColor:* = null, init:Object = null)
		{
			if(fillColor == null)
            	fillColor = "random";

            this.fillColor = Cast.trycolor(fillColor);

            ini = Init.parse(init);
            
            fillAlpha = ini.getNumber("fillAlpha", 1, {min:0, max:1});
            lineColor = ini.getInt("lineColor", 0, {min:0, max:0xFFFFFF});
            lineAlpha = ini.getNumber("lineAlpha", 1, {min:0, max:1});
            lineThickness = ini.getNumber("lineThickness", 1, {min:0.75});
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
        public function renderShape(shp:DrawShape):void
        {
            if(fillAlpha <= 0 && lineAlpha <= 0)
            	return;
			
			shp.source.session.renderShape(lineColor, lineAlpha, lineThickness, fillColor, fillAlpha, shp);
        }
		
		public function renderTriangle(tri:DrawTriangle):void
		{
			throw new Error("Not implemented.");
		}
		
		/**
		 * @inheritDoc
		 */
        public function get visible():Boolean
        {
        	return (fillAlpha > 0 || lineAlpha > 0);
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