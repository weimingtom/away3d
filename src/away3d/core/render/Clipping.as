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
        	if (!rectangleClipping)
    			rectangleClipping = new RectangleClipping();
        	
        	switch(container.stage.align)
        	{
        		case StageAlign.TOP_LEFT:
	            	zeroPoint.x = 0;
	            	zeroPoint.y = 0;
	                globalPoint = container.globalToLocal(zeroPoint);
	                
	                rectangleClipping.maxX = (rectangleClipping.minX = globalPoint.x) + container.stage.stageWidth;
	                rectangleClipping.maxY = (rectangleClipping.minY = globalPoint.y) + container.stage.stageHeight;
	                break;
	            case StageAlign.TOP_RIGHT:
	            	zeroPoint.x = container.stage.stageWidth;
	            	zeroPoint.y = 0;
	                globalPoint = container.globalToLocal(zeroPoint);
	                
	                rectangleClipping.minX = (rectangleClipping.maxX = globalPoint.x) - container.stage.stageWidth;
	                rectangleClipping.maxY = (rectangleClipping.minY = globalPoint.y) + container.stage.stageHeight;
	                break;
	            case StageAlign.BOTTOM_LEFT:
	            	zeroPoint.x = 0;
	            	zeroPoint.y = container.stage.stageHeight;
	                globalPoint = container.globalToLocal(zeroPoint);
	                
	                rectangleClipping.maxX = (rectangleClipping.minX = globalPoint.x) + container.stage.stageWidth;
	                rectangleClipping.minY = (rectangleClipping.maxY = globalPoint.y) - container.stage.stageHeight;
	                break;
	            case StageAlign.BOTTOM_RIGHT:
	            	zeroPoint.x = container.stage.stageWidth;
	            	zeroPoint.y = container.stage.stageHeight;
	                globalPoint = container.globalToLocal(zeroPoint);
	                
	                rectangleClipping.minX = (rectangleClipping.maxX = globalPoint.x) - container.stage.stageWidth;
	                rectangleClipping.minY = (rectangleClipping.maxY = globalPoint.y) - container.stage.stageHeight;
	                break;
	            case StageAlign.TOP:
	            	zeroPoint.x = container.stage.stageWidth/2;
	            	zeroPoint.y = 0;
	                globalPoint = container.globalToLocal(zeroPoint);
	                
	                rectangleClipping.minX = globalPoint.x - container.stage.stageWidth/2;
	                rectangleClipping.maxX = globalPoint.x + container.stage.stageWidth/2;
	                rectangleClipping.maxY = (rectangleClipping.minY = globalPoint.y) + container.stage.stageHeight;
	                break;
	            case StageAlign.BOTTOM:
	            	zeroPoint.x = container.stage.stageWidth/2;
	            	zeroPoint.y = container.stage.stageHeight;
	                globalPoint = container.globalToLocal(zeroPoint);
	                
	                rectangleClipping.minX = globalPoint.x - container.stage.stageWidth/2;
	                rectangleClipping.maxX = globalPoint.x + container.stage.stageWidth/2;
	                rectangleClipping.minY = (rectangleClipping.maxY = globalPoint.y) - container.stage.stageHeight;
	                break;
	            case StageAlign.LEFT:
	            	zeroPoint.x = 0;
	            	zeroPoint.y = container.stage.stageHeight/2;
	                globalPoint = container.globalToLocal(zeroPoint);
	                
	                rectangleClipping.maxX = (rectangleClipping.minX = globalPoint.x) + container.stage.stageWidth;
	                rectangleClipping.minY = globalPoint.y - container.stage.stageHeight/2;
	                rectangleClipping.maxY = globalPoint.y + container.stage.stageHeight/2;
	                break;
	            case StageAlign.RIGHT:
	            	zeroPoint.x = container.stage.stageWidth;
	            	zeroPoint.y = container.stage.stageHeight/2;
	                globalPoint = container.globalToLocal(zeroPoint);
	                
	                rectangleClipping.minX = (rectangleClipping.maxX = globalPoint.x) - container.stage.stageWidth;
	                rectangleClipping.minY = globalPoint.y - container.stage.stageHeight/2;
	                rectangleClipping.maxY = globalPoint.y + container.stage.stageHeight/2;
	                break;
	            default:
	            	zeroPoint.x = container.stage.stageWidth/2;
	            	zeroPoint.y = container.stage.stageHeight/2;
	                globalPoint = container.globalToLocal(zeroPoint);
	            	
	                rectangleClipping.minX = globalPoint.x - container.stage.stageWidth/2;
	                rectangleClipping.maxX = globalPoint.x + container.stage.stageWidth/2;
	                rectangleClipping.minY = globalPoint.y - container.stage.stageHeight/2;
	                rectangleClipping.maxY = globalPoint.y + container.stage.stageHeight/2;
        	}
            
            return rectangleClipping;
        }
    }
}