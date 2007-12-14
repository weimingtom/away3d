package away3d.core.block
{
    import away3d.core.*;
    import away3d.core.render.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;

    import flash.display.Graphics;
    import flash.utils.*;

    /** Convex hull that blocks all them primitives containing completely inside */
    public class ConvexBlocker extends Blocker
    {
        public var boundlines:Array = [];

        public function ConvexBlocker(vertices:Array)
        {
            screenZ = 0;
            maxX = -Infinity;
            maxY = -Infinity;
            minX = Infinity;
            minY = Infinity;
            for (var i:int = 0; i < vertices.length; i++)
            {
                var v:ScreenVertex = vertices[i];
                boundlines.push(Line2D.from2points(v, vertices[(i+1) % vertices.length]));
                if (screenZ < v.z)
                    screenZ = v.z;
                if (minX > v.x)
                    minX = v.x;
                if (maxX < v.x)
                    maxX = v.x;
                if (minY > v.y)
                    minY = v.y;
                if (maxY < v.y)
                    maxY = v.y;
            }
            maxZ = screenZ;
            minZ = screenZ;
        }

        public override function contains(x:Number, y:Number):Boolean
        {   
            for each (var boundline:Line2D in boundlines)
                if (boundline.side(x, y) < 0)
                    return false;
            return true;
        }

        public override function block(pri:DrawPrimitive):Boolean
        {
            if (pri is DrawTriangle)
            {
                var tri:DrawTriangle = pri as DrawTriangle;
                return contains(tri.v0.x, tri.v0.y) && contains(tri.v1.x, tri.v1.y) && contains(tri.v2.x, tri.v2.y);
            }
            return contains(pri.minX, pri.minY) && contains(pri.minX, pri.maxY) && contains(pri.maxX, pri.maxY) && contains(pri.maxX, pri.minY);
        }

        public override function render():void
        {
            var graphics:Graphics = source.session.graphics;
            graphics.lineStyle(2, Color.fromHSV(0, 0, (Math.sin(getTimer()/1000)+1)/2));
            for (var i:int = 0; i < boundlines.length; i++)
            {
                var line:Line2D = boundlines[i];
                var prev:Line2D = boundlines[(i-1+boundlines.length) % boundlines.length];
                var next:Line2D = boundlines[(i+1+boundlines.length) % boundlines.length];

                var a:ScreenVertex = Line2D.cross(prev, line);
                var b:ScreenVertex = Line2D.cross(line, next);

                graphics.moveTo(a.x, a.y);
                graphics.lineTo(b.x, b.y);
                graphics.moveTo(a.x, a.y);
            }

            var count:int = (maxX - minX) * (maxY - minY) / 2000;
            if (count > 50)
                count = 50;
            for (var k:int = 0; k < count; k++)
            {
                var x:Number = minX + (maxX - minX)*Math.random();
                var y:Number = minY + (maxY - minY)*Math.random();
                if (contains(x, y))
                {
                    graphics.lineStyle(1, Color.fromHSV(0, 0, Math.random()));
                    graphics.drawCircle(x, y, 3);
                }
            }
        }
    }
}
