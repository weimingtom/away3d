package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.scene.*;
    
    import flash.display.*;
    import flash.geom.*;

    /** Quadrant tree for storing drawing primitives */
    public final class PrimitiveQuadrantTree implements IPrimitiveConsumer
    {
    	private var containers:Array = [];
        private var root:PrimitiveQuadrantTreeNode;

        private var clip:Clipping;

        public function PrimitiveQuadrantTree(clip:Clipping)
        {
            this.clip = clip;
            var rect:RectangleClipping = clip.asRectangleClipping();
            root = new PrimitiveQuadrantTreeNode((rect.minX + rect.maxX)/2, (rect.minY + rect.maxY)/2, (rect.maxX - rect.minX)/2, (rect.maxY - rect.minY)/2, 0);
        }

        public function primitive(pri:DrawPrimitive):void
        {
            if (clip.check(pri))
            {
                root.push(pri);
            }
        }
		
        public function push(object:DrawPrimitive):void
        {
            root.push(object);
        }

        public function add(objects:Array):void
        {
            for each (var object:DrawPrimitive in objects)
                root.push(object);
        }

        public function remove(tri:DrawPrimitive):void
        {
            root.remove(tri);
        }

        public function list():Array
        {
            return get(-1000000, -1000000, 1000000, 1000000, null);
        }
		
		internal var result:Array;
		internal var except:Object3D;
		internal var minX:Number;
		internal var minY:Number;
		internal var maxX:Number;
		internal var maxY:Number;
		
        public function get(minX:Number, minY:Number, maxX:Number, maxY:Number, except:Object3D):Array
        {
        	result = [];
                    
			this.minX = minX;
			this.minY = minY;
			this.maxX = maxX;
			this.maxY = maxY;
			this.except = except;
			
            getList(root);
            
            return result;
        }
		
		internal var child:DrawPrimitive;
		internal var children:Array;
		internal var i:int;
		public function getList(node:PrimitiveQuadrantTreeNode):void
        {
            if (node.onlysource != null)
                if (except == node.onlysource)
                    return;

            children = node.center;
            if (children != null) {
                i = children.length;
                while (i--)
                {
                	child = children[i];
                    if (child.maxX < minX || child.minX > maxX || child.maxY < minY || child.minY > maxY)
                        continue;
                    if (except != null)
                        if (child.source == except)
                            continue;
                    result.push(child);
                }
            }
            
            if (!node.split)
            {
            	children = node.children;
                if (children != null) {
                	i = children.length;
                    while (i--)
                    {
                    	child = children[i];
                        if (child.maxX < minX || child.minX > maxX || child.maxY < minY || child.minY > maxY)
                            continue;
                        if (except != null)
                            if (child.source == except)
                                continue;
                        result.push(child);
                    }
                }
                return;
            }
            
            if (minX < node.xdiv)
            {
                if (node.lefttop != null && minY < node.ydiv)
	                getList(node.lefttop);
	            
                if (node.leftbottom != null && maxY > node.ydiv)
                	getList(node.leftbottom);
            }
            
            if (maxX > node.xdiv)
            {
                if (node.righttop != null && minY < node.ydiv)
                	getList(node.righttop);
                
                if (node.rightbottom != null && maxY > node.ydiv)
                	getList(node.rightbottom);
                
            }
        }
        
        public function render():void
        {
            root.render(-Infinity);
        }

    }
}
