package away3d.core.draw
{
    import away3d.core.render.*;
    
    import flash.display.DisplayObject;
    import flash.geom.Rectangle;
	
	/**
	 * Displayobject container drawing primitive.
	 */
    public class DrawDisplayObject extends DrawPrimitive
    {
    	private var displayRect:Rectangle;
    	
    	/**
    	 * The screenvertex used to position the drawing primitive in the view.
    	 */
        public var screenvertex:ScreenVertex;
        
    	/**
    	 * A reference to the displayobject used by the drawing primitive.
    	 */
        public var displayobject:DisplayObject;
        
    	/**
    	 * A reference to the session used by the drawing primitive.
    	 */
        public var session:AbstractRenderSession;
        
		/**
		 * @inheritDoc
		 */
        public override function calc():void
        {
        	displayRect = displayobject.getBounds(displayobject);
            screenZ = screenvertex.z;
            minZ = screenZ;
            maxZ = screenZ;
            minX = screenvertex.x + displayRect.left;
            minY = screenvertex.y + displayRect.top;
            maxX = screenvertex.x + displayRect.right;
            maxY = screenvertex.y + displayRect.bottom;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function clear():void
        {
            displayobject = null;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function render():void
        {
            displayobject.x = screenvertex.x;// - displayobject.width/2;
            displayobject.y = screenvertex.y;// - displayobject.height/2;
            session.addDisplayObject(displayobject);
        }
		
		//TODO: correct function for contains in DrawDisplayObject
		/**
		 * @inheritDoc
		 */
        public override function contains(x:Number, y:Number):Boolean
        {   
            return true;
        }
    }
}
