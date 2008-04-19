package away3d.core.draw
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.base.*
    
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
        
        public var lefttopFlag:Boolean;
        public var leftbottomFlag:Boolean;
        public var righttopFlag:Boolean;
        public var rightbottomFlag:Boolean;
        
        public var onlysource:Object3D;
		public var onlysourceFlag:Boolean = true;
        
        public var xdiv:Number;
        public var ydiv:Number;
        public var halfwidth:Number;
        public var halfheight:Number;
        public var level:int;
        public var parent:PrimitiveQuadrantTreeNode;
        public var maxlevel:int = 4;
		private var i:int;
		
		public var create:Function;
		
        public function PrimitiveQuadrantTreeNode(xdiv:Number, ydiv:Number, width:Number, height:Number, level:int, parent:PrimitiveQuadrantTreeNode = null)
        {
            this.level = level;
            this.xdiv = xdiv;
            this.ydiv = ydiv;
            halfwidth = width / 2;
            halfheight = height / 2;
            this.parent = parent;
        }

        public function push(pri:DrawPrimitive):void
        {
            if (onlysourceFlag) {
	            if (onlysource != null && onlysource != pri.source)
	            	onlysourceFlag = false;
                onlysource = pri.source;
            }
			
			if (level < maxlevel) {
	            if (pri.maxX <= xdiv)
	            {
	                if (pri.maxY <= ydiv)
	                {
	                    if (lefttop == null) {
	                    	lefttopFlag = true;
	                        lefttop = new PrimitiveQuadrantTreeNode(xdiv - halfwidth/2, ydiv - halfheight/2, halfwidth, halfheight, level+1, this);
	                    } else if (!lefttopFlag) {
	                    	lefttopFlag = true;
	                    	lefttop.reset(xdiv - halfwidth/2, ydiv - halfheight/2, halfwidth, halfheight);
	                    }
	                    lefttop.push(pri);
	                    return;
	                }
	                else if (pri.minY >= ydiv)
	                {
	                	if (leftbottom == null) {
	                    	leftbottomFlag = true;
	                        leftbottom = new PrimitiveQuadrantTreeNode(xdiv - halfwidth/2, ydiv - halfheight/2, halfwidth, halfheight, level+1, this);
	                    } else if (!leftbottomFlag) {
	                    	leftbottomFlag = true;
	                    	leftbottom.reset(xdiv - halfwidth/2, ydiv - halfheight/2, halfwidth, halfheight);
	                    }
	                    leftbottom.push(pri);
	                    return;
	                }
	            }
	            else if (pri.minX >= xdiv)
	            {
	                if (pri.maxY <= ydiv)
	                {
	                	if (righttop == null) {
	                    	righttopFlag = true;
	                        righttop = new PrimitiveQuadrantTreeNode(xdiv - halfwidth/2, ydiv - halfheight/2, halfwidth, halfheight, level+1, this);
	                    } else if (!righttopFlag) {
	                    	righttopFlag = true;
	                    	righttop.reset(xdiv - halfwidth/2, ydiv - halfheight/2, halfwidth, halfheight);
	                    }
	                    righttop.push(pri);
	                    return;
	                }
	                else if (pri.minY >= ydiv)
	                {
	                	if (rightbottom == null) {
	                    	rightbottomFlag = true;
	                        rightbottom = new PrimitiveQuadrantTreeNode(xdiv - halfwidth/2, ydiv - halfheight/2, halfwidth, halfheight, level+1, this);
	                    } else if (!rightbottomFlag) {
	                    	rightbottomFlag = true;
	                    	rightbottom.reset(xdiv - halfwidth/2, ydiv - halfheight/2, halfwidth, halfheight);
	                    }
	                    rightbottom.push(pri);
	                    return;
	                }
	            }
			}
			
			//no quadrant, store in center array
            if (center == null)
                center = new Array();
            center.push(pri);
            pri.quadrant = this;
        }
        
		public function reset(xdiv:Number, ydiv:Number, width:Number, height:Number):void
		{
			this.xdiv = xdiv;
			this.ydiv = ydiv;
			halfwidth = width / 2;
            halfheight = height / 2;
			
            lefttopFlag = false;
            leftbottomFlag = false;
            righttopFlag = false;
            rightbottomFlag = false;
            
            onlysourceFlag = true;
            onlysource = null;
            
            render_center_length = -1;
            render_center_index = -1;
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
            
            if (render_center_index == render_center_length)
				center = null;
			
            render_other(limit);
        }

        private function render_other(limit:Number):void
        {
        	if (lefttopFlag)
                lefttop.render(limit);
            if (leftbottomFlag)
                leftbottom.render(limit);
            if (righttopFlag)
                righttop.render(limit);
            if (rightbottomFlag)
                rightbottom.render(limit);
        }
    }
}
