package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.scene.*;
    
    import flash.display.*;
    import flash.geom.*;

    /** Quadrant tree node */
    public final class PrimitiveQuadrantTreeNode
    {
        public var center:Array;
        public var lefttop:PrimitiveQuadrantTreeNode;
        public var leftbottom:PrimitiveQuadrantTreeNode;
        public var righttop:PrimitiveQuadrantTreeNode;
        public var rightbottom:PrimitiveQuadrantTreeNode;
        public var onlysource:Object3D;
		
		public var onlysourceFlag:Boolean = true;
        
        public var xdiv:Number;
        public var ydiv:Number;
        public var halfwidth:Number;
        public var halfheight:Number;
        public var level:Number;
		private var i:int;
		
		public var create:Function;
		
        public function PrimitiveQuadrantTreeNode(xdiv:Number, ydiv:Number, width:Number, height:Number, level:Number)
        {
            this.level = level;
            this.xdiv = xdiv;
            this.ydiv = ydiv;
            halfwidth = width / 2;
            halfheight = height / 2;
        }

        public function push(pri:DrawPrimitive):void
        {
            if (onlysource != null && onlysource != pri.source)
            	onlysourceFlag = false;
            if (onlysourceFlag)
                onlysource = pri.source;
			
			if (level < 5) {
	            if (pri.maxX <= xdiv)
	            {
	                if (pri.maxY <= ydiv)
	                {
	                    if (lefttop == null)
	                        lefttop = create(xdiv - halfwidth/2, ydiv - halfheight/2, halfwidth, halfheight, level+1);
	                    lefttop.push(pri);
	                    return;
	                }
	                else if (pri.minY >= ydiv)
	                {
	                    if (leftbottom == null)
	                        leftbottom = create(xdiv - halfwidth/2, ydiv + halfheight/2, halfwidth, halfheight, level+1);
	                    leftbottom.push(pri);
	                    return;
	                }
	            }
	            else if (pri.minX >= xdiv)
	            {
	                if (pri.maxY <= ydiv)
	                {
	                    if (righttop == null)
	                        righttop = create(xdiv + halfwidth/2, ydiv - halfheight/2, halfwidth, halfheight, level+1);
	                    righttop.push(pri);
	                    return;
	                }
	                else if (pri.minY >= ydiv)
	                {
	                    if (rightbottom == null)
	                        rightbottom = create(xdiv + halfwidth/2, ydiv + halfheight/2, halfwidth, halfheight, level+1);
	                    rightbottom.push(pri);
	                    return;
	                }
	            }
			}
			
			//no quadrant, store in center array
            if (center == null)
                center = new Array();
            center.push(pri);
        }
		
		internal var index:int;
		
        public function remove(pri:DrawPrimitive):void
        {
        	if (level < 5) {
	            if (pri.maxX <= xdiv)
	            {
	                if (pri.maxY <= ydiv)
	                {
	                    if (lefttop == null)
	                        throw new Error("Can't remove");
	                    lefttop.remove(pri);
	                    return;
	                }
	                else if (pri.minY >= ydiv)
	                {
	                    if (leftbottom == null)
	                        throw new Error("Can't remove");
	                    leftbottom.remove(pri);
	                    return;
	                }
	            }
	            else if (pri.minX >= xdiv)
	            {
	                if (pri.maxY <= ydiv)
	                {
	                    if (righttop == null)
	                        throw new Error("Can't remove");
	                    righttop.remove(pri);
	                    return;
	                }
	                else if (pri.minY >= ydiv)
	                {
	                    if (rightbottom == null)
	                        throw new Error("Can't remove");
	                    rightbottom.remove(pri);
	                    return;
	                }
	            }
	        }
            
            //no quadrant, remove from center array
            if (center == null)
                throw new Error("Can't remove");

            index = center.indexOf(pri);
            if (index == -1)
                throw new Error("Can't remove");
                
            center.splice(index, 1);
        }
		
        public var render_center_length:int = -1;
        public var render_center_index:int = -1;
        
        public function render(limit:Number):void
        {
            if (render_center_length == -1)
            {
                if (center != null)
                {
                    render_center_length = center.length;
                    if (render_center_length > 1)
                        center.sortOn("screenZ", Array.DESCENDING | Array.NUMERIC);
                }
                else
                    render_center_length = 0;
                render_center_index = 0;
            }

            while (render_center_index < render_center_length)
            {
                var pri:DrawPrimitive = center[render_center_index];

                if (pri.screenZ < limit)
                    break;

                render_other(pri.screenZ);

                pri.render();

                render_center_index++;
            }

            render_other(limit);
        }

        private function render_other(limit:Number):void
        {
        	if (lefttop != null)
                lefttop.render(limit);
            if (leftbottom != null)
                leftbottom.render(limit);
            if (righttop != null)
                righttop.render(limit);
            if (rightbottom != null)
                rightbottom.render(limit);
        }
    }
}
