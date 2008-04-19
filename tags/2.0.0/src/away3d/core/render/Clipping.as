package away3d.core.render
{
    import away3d.core.draw.*;
    
    import flash.display.*;
    import flash.geom.*;

    /** Rendering clipping, base class for no clipping */
    public class Clipping
    {
    	public var minX:Number = -1000000;
        public var minY:Number = -1000000;
        public var maxX:Number = 1000000;
        public var maxY:Number = 1000000;
        
        public function Clipping()
        {
        }

        public function check(pri:DrawPrimitive):Boolean
        {
            return true;
        }

        public function rect(minX:Number, minY:Number, maxX:Number, maxY:Number):Boolean
        {
            return true;
        }

    	internal var rectangleClipping:RectangleClipping;
    	
        public function asRectangleClipping():RectangleClipping
        {
        	if (!rectangleClipping)
        		rectangleClipping = new RectangleClipping();
        	rectangleClipping.minX = -1000000;
        	rectangleClipping.minY = -1000000;
        	rectangleClipping.maxX = 1000000;
        	rectangleClipping.maxY = 1000000;
            return rectangleClipping;
        }
        
    	internal var zeroPoint:Point = new Point(0, 0);
		internal var globalPoint:Point;
		
        public function screen(container:Sprite):Clipping
        {
            if (container.stage.align == StageAlign.TOP_LEFT)
            {
            	if (!rectangleClipping)
        			rectangleClipping = new RectangleClipping();
        		
                globalPoint = container.globalToLocal(zeroPoint);
                
                rectangleClipping.maxX = (rectangleClipping.minX = globalPoint.x) + container.stage.stageWidth;
                rectangleClipping.maxY = (rectangleClipping.minY = globalPoint.y) + container.stage.stageHeight;
                
                return rectangleClipping;
            }
            else
                return this; // no clipping
        }
    }
}