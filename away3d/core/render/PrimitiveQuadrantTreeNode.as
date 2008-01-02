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
        private var children:Array;
        private var center:Array;
        private var lefttop:PrimitiveQuadrantTreeNode;
        private var leftbottom:PrimitiveQuadrantTreeNode;
        private var righttop:PrimitiveQuadrantTreeNode;
        private var rightbottom:PrimitiveQuadrantTreeNode;
        private var onlysource:Object3D;

        private static var dummysource:Object3D = new Object3D();

        private var split:Boolean;
        private var xdiv:Number;
        private var ydiv:Number;
        private var halfwidth:Number;
        private var halfheight:Number;
        private var level:Number;
		private var i:int;
		
        public function PrimitiveQuadrantTreeNode(xdiv:Number, ydiv:Number, width:Number, height:Number, level:Number)
        {
            this.level = level;
            this.xdiv = xdiv;
            this.ydiv = ydiv;
            halfwidth = width / 2;
            halfheight = height / 2;
            onlysource = dummysource;
        }

        public function push(pri:DrawPrimitive):void
        {
            if (onlysource == dummysource)
                onlysource = pri.source;
            else
                if (onlysource != pri.source)
                    onlysource == null;

            if ((pri.maxX > xdiv && pri.minX < xdiv) || (pri.maxY > ydiv && pri.minY < ydiv))
            {
                if (center == null)
                    center = new Array();
                center.push(pri);
                return;
            }

            if (!split)
            {       
                if (children == null)
                    children = new Array();

                children.push(pri);

                if (children.length > level * 2)
                {
                    split = true;
                    i = children.length;
	                while (i--)
	                	push(children[i]);
                    children = null;
                }

                return;
            }

            if (pri.maxX <= xdiv)
            {
                if (pri.maxY <= ydiv)
                {
                    if (lefttop == null)
                        lefttop = new PrimitiveQuadrantTreeNode(xdiv - halfwidth/2, ydiv - halfheight/2, halfwidth, halfheight, level+1);
                    lefttop.push(pri);
                }
                else
                {
                    if (leftbottom == null)
                        leftbottom = new PrimitiveQuadrantTreeNode(xdiv - halfwidth/2, ydiv + halfheight/2, halfwidth, halfheight, level+1);
                    leftbottom.push(pri);
                }
            }
            else
            if (pri.minX >= xdiv)
            {
                if (pri.maxY <= ydiv)
                {
                    if (righttop == null)
                        righttop = new PrimitiveQuadrantTreeNode(xdiv + halfwidth/2, ydiv - halfheight/2, halfwidth, halfheight, level+1);
                    righttop.push(pri);
                }
                else
                {
                    if (rightbottom == null)
                        rightbottom = new PrimitiveQuadrantTreeNode(xdiv + halfwidth/2, ydiv + halfheight/2, halfwidth, halfheight, level+1);
                    rightbottom.push(pri);
                }
            }
        }

        public function remove(pri:DrawPrimitive):void
        {
            var index:int;
            if (((pri.maxX > xdiv) && (pri.minX < xdiv)) || ((pri.maxY > ydiv) && (pri.minY < ydiv)))
            {
                if (center == null)
                    throw new Error("Can't remove");

                index = center.indexOf(pri);
                if (index == -1)
                    throw new Error("Can't remove");
                    
                center.splice(index, 1);
                
                return;
            }

            if (!split)
            {
                if (children == null)
                    throw new Error("Can't remove");

                index = children.indexOf(pri);
                if (index == -1)
                    throw new Error("Can't remove");

                children.splice(index, 1);

                return;
            }

            if (pri.maxX <= xdiv)
            {
                if (pri.maxY <= ydiv)
                {
                    if (lefttop == null)
                        throw new Error("Can't remove");
                    lefttop.remove(pri);
                }
                else
                {
                    if (leftbottom == null)
                        throw new Error("Can't remove");
                    leftbottom.remove(pri);
                }
            }
            else
            if (pri.minX >= xdiv)
            {
                if (pri.maxY <= ydiv)
                {
                    if (righttop == null)
                        throw new Error("Can't remove");
                    righttop.remove(pri);
                }
                else
                {
                    if (rightbottom == null)
                        throw new Error("Can't remove");
                    rightbottom.remove(pri);
                }
            }
        }
		
		internal var minX:Number;
		internal var minY:Number;
		internal var maxX:Number;
		internal var maxY:Number;

        public function get(minX:Number, minY:Number, maxX:Number, maxY:Number, except:Object3D):Array
        {
            var result:Array = [];
                    
			this.minX = minX;
			this.minY = minY;
			this.maxX = maxX;
			this.maxY = maxY;
			
            getList(except, result);
            return result;
        }
		
        public function getList(except:Object3D, result:Array):void
        {
            if (onlysource != null)
                if (except == onlysource)
                    return;
			
            var child:DrawPrimitive;
            if (center != null) {
                i = center.length;
                while (i--)
                {
                	child = center[i];
                    if (child.maxX < minX || child.minX > maxX || child.maxY < minY || child.minY > maxY)
                        continue;
                    if (except != null)
                        if (child.source == except)
                            continue;
                    result.push(child);
                }
            }

            if (!split)
            {
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

            if (minX < xdiv)
            {
                if (lefttop != null && minY < ydiv)
	                lefttop.getList(except, result);
	            
                if (leftbottom != null && maxY > ydiv)
                	leftbottom.getList(except, result);
            }
            
            if (maxX > xdiv)
            {
                if (righttop != null && minY < ydiv)
                	righttop.getList(except, result);
                
                if (rightbottom != null && maxY > ydiv)
                	rightbottom.getList(except, result);
                
            }
        }

        //private static var dummy_render_array:Array = [];
        //private var render_array:Array;
        private var render_center_length:int = -1;
        private var render_center_index:int = -1;
        private var render_children_length:int = -1;
        private var render_children_index:int = -1;

        //private static var dummyprimitive:DrawPrimitive = new DrawDummy();

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

                if (children != null)
                {
                    render_children_length = children.length;
                    if (render_children_length > 1)
                        children.sortOn("screenZ", Array.DESCENDING | Array.NUMERIC);
                }
                else
                    render_children_length = 0;
                render_children_index = 0;
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
            if (render_children_length > 0)
            {
                while (render_children_index < render_children_length)
                {
                    var pri:DrawPrimitive = children[render_children_index];

                    if (pri.screenZ < limit)
                        return;

                    pri.render();

                    render_children_index++;
                }
            }
            else
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
}
