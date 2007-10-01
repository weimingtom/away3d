package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;

    import flash.display.*;
    import flash.utils.*;

    /** Filter that splits all intersecting triangles and line segments. */
    public class QuadrantRiddleFilter implements IPrimitiveQuadrantFilter
    {       
        public var maxdelay:int;
    
        public function QuadrantRiddleFilter(maxdelay:int = 60000)
        {
            this.maxdelay = maxdelay;
        }
    
        public function filter(tritree:PrimitiveQuadrantTree, scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping):void
        {
            var start:int = getTimer();
            var check:int = 0;
    
            var triangles:Array = tritree.list();
            var turn:int = 0;
            while (triangles.length > 0)
            {
                var leftover:Array = new Array();
                for each (var tri:DrawPrimitive in triangles)
                {
                    /*
                    check++;
                    if (check == 10)
                        if (getTimer() - start > maxdelay)
                            return;
                        else
                            check = 0;
                    */
                    var rivals:Array = tritree.get(tri.minX, tri.minY, tri.maxX, tri.maxY, tri.source);
                    for each (var rivalp:DrawPrimitive in rivals)
                    {
                        if (rivalp == tri)
                            continue;
                        if (tri.source != null)
                            if (rivalp.source == tri.source)
                                continue;
                        if (rivalp.minZ >= tri.maxZ)
                            continue;
                        if (rivalp.maxZ <= tri.minZ)
                            continue;
                        if (!(rivalp is DrawTriangle))
                            continue;
    
                        var rival:DrawTriangle = rivalp as DrawTriangle;
    
                        //if (ZCompare.zconflict(tri, rival, camera.focus) == 0)
                        //    continue;
                            
                        var subst:Array = tri.riddle(rival, camera.focus); 
                        if (subst == null)
                            continue;
    
                        tritree.remove(tri);
                        for each (var p:DrawPrimitive in subst)
                        {
                            leftover.push(p);
                            tritree.push(p);
                        }
                        break;
                    }
                }
                triangles = leftover;
                turn += 1;
                if (turn == 40)
                    break;
            }
        }
    
        public function toString():String
        {
            return "QuadrantRiddleFilter" + ((maxdelay == 60000) ? "" : "("+maxdelay+"ms)");
        }
    }

}