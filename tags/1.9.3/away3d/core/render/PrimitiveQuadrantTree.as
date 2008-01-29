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
        public var root:PrimitiveQuadrantTreeNode;
		public var quadrantStore:Array;
		public var quadrantActive:Array;
		
        private var _clip:Clipping;
		private var _rect:RectangleClipping;
		
		public function set clip(val:Clipping):void
		{
			_clip = val;
			_rect = _clip.asRectangleClipping();
			if (!root)
				root = new PrimitiveQuadrantTreeNode((_rect.minX + _rect.maxX)/2, (_rect.minY + _rect.maxY)/2, (_rect.maxX - _rect.minX)/2, (_rect.maxY - _rect.minY)/2, 0);
			else
				root.reset((_rect.minX + _rect.maxX)/2, (_rect.minY + _rect.maxY)/2, (_rect.maxX - _rect.minX)/2, (_rect.maxY - _rect.minY)/2);
			
		}
		
        public function PrimitiveQuadrantTree()
        {
        }

        public function primitive(pri:DrawPrimitive):void
        {
            if (_clip.check(pri))
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
		
		internal var center:Array;
		
        public function remove(tri:DrawPrimitive):void
        {
        	center = tri.quadrant.center;
        	center.splice(center.indexOf(tri), 1);
        }

        public function list():Array
        {
            result = [];
                    
			minX = -1000000;
			minY = -1000000;
			maxX = 1000000;
			maxY = 1000000;
			except = null;
			
            getList(root);
            
            return result;
        }
		
		internal var result:Array;
		internal var except:Object3D;
		internal var minX:Number;
		internal var minY:Number;
		internal var maxX:Number;
		internal var maxY:Number;
		
        public function get(pri:DrawPrimitive, ex:Object3D = null):Array
        {
        	result = [];
                    
			minX = pri.minX;
			minY = pri.minY;
			maxX = pri.maxX;
			maxY = pri.maxY;
			except = ex;
			
            getList(pri.quadrant);
            getParent(pri.quadrant);
            return result;
        }
		
		internal var child:DrawPrimitive;
		internal var children:Array;
		internal var i:int;
		public function getList(node:PrimitiveQuadrantTreeNode):void
        {
            if (node.onlysourceFlag && except == node.onlysource)
                return;

            if (minX < node.xdiv)
            {
                if (node.lefttopFlag && minY < node.ydiv)
	                getList(node.lefttop);
	            
                if (node.leftbottomFlag && maxY > node.ydiv)
                	getList(node.leftbottom);
            }
            
            if (maxX > node.xdiv)
            {
                if (node.righttopFlag && minY < node.ydiv)
                	getList(node.righttop);
                
                if (node.rightbottomFlag && maxY > node.ydiv)
                	getList(node.rightbottom);
                
            }
            
            children = node.center;
            if (children != null) {
                i = children.length;
                while (i--)
                {
                	child = children[i];
                    if ((except == null || child.source != except) && child.maxX > minX && child.minX < maxX && child.maxY > minY && child.minY < maxY)
                        result.push(child);
                }
            }           
        }
        
        public function getParent(node:PrimitiveQuadrantTreeNode = null):void
        {
        	node = node.parent;
        	
            if (node == null || (node.onlysourceFlag && except == node.onlysource))
                return;

            children = node.center;
            if (children != null) {
                i = children.length;
                while (i--)
                {
                	child = children[i];
                    if ((except == null || child.source != except) && child.maxX > minX && child.minX < maxX && child.maxY > minY && child.minY < maxY)
                        result.push(child);
                }
            }
            getParent(node);
        }
        
        public function render():void
        {
            root.render(-Infinity);
        }
    }
}
