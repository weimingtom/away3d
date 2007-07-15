package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.geom.*;
    import flash.display.*;

    /** Quadrant tree for storing drawing primitives */
    public class PrimitiveQuadrantTree implements IPrimitiveConsumer
    {
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
            return root.get(-1000000, -1000000, 1000000, 1000000, null);
        }

        public function get(minX:Number, minY:Number, maxX:Number, maxY:Number, except:Object3D):Array
        {
            return root.get(minX, minY, maxX, maxY, except);
        }

        public function render(session:RenderSession):void
        {
            root.render(session, -Infinity);
        }

    }
}
