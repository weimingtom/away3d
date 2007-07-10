package away3d.shapes
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.material.*;
    import away3d.trash.*;
    
    /** Irregular shape */
    public class IrregularShape extends Vertices3D
    {
        public var sides:Number;
        
        public function IrregularShape(vertices:Array, init:Object = null)
        {
            super(init);

            init = Init.parse(init);

            wrap = init.getBoolean("wrap", true);

            this.vertices = vertices;

            buildShape();
        }
    
        private function buildShape():void
        {
            sides = vertices.length;
            length = 0;
            var i:Number, vx:Number, vy:Number, oldV:Vertex3D, v:Vertex3D;
            for (i=0;i<sides;i++) {
                oldV = v;
                v = vertices[i];
                vx = v.x;
                vy = v.y;
                if (i) length += Math.sqrt(Math.pow(vx - oldV.x,2) + Math.pow(vy - oldV.y,2));
                if (xMin > vx)
                    xMin = vx;
                if (xMax < vx)
                    xMax = vx;
                if (yMin > vy)
                    yMin = vy;
                if (yMax < vy)
                    yMax = vy;
            }
            if (sides > 2 && wrap) length += Math.sqrt(Math.pow(vx - vertices[0].x,2) + Math.pow(vy - vertices[0].y,2));
            width = xMax - xMin;
            height = yMax - yMin;
        }
    }
}
