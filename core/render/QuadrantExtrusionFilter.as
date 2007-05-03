package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;

    import flash.display.*;
    import flash.utils.*;

    public class QuadrantExtrusionFilter implements IPrimitiveQuadrantFilter
    {
        public var maxdelay:int;
    
        public function QuadrantExtrusionFilter(maxdelay:int = 60000)
        {
            this.maxdelay = maxdelay;
        }
    
        public function filter(tree:PrimitiveQuadrantTree, scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping):void
        {
            var start:int = getTimer();
            var check:int = 0;
    
            var primitives:Array = tree.list();
            var turn:int = 0;
            while (primitives.length > 0)
            {
                var leftover:Array = new Array();
                for each (var pri:DrawPrimitive in primitives)
                {
                    var hiZ:Number = Infinity;
                    var loZ:Number = -Infinity;
                    var hiD:Number = Infinity;
                    var loD:Number = Infinity;
                    var source:Object3D = pri.source;
                    var rivals:Array = tree.get(pri.minX, pri.minY, pri.maxX, pri.maxY, null);
                    for each (var rival:DrawPrimitive in rivals)
                    {
                        if (rival == pri)
                            continue;
                        /*
                        if (source != null)
                            if (rival.source == source)
                            {
                                if (ZCompare.overlap(rival, pri))
                                {
                                    if (rival.screenZ > pri.screenZ)
                                    {
                                        loZ = rival.screenZ;
                                        loD = rival.maxZ - rival.minZ;
                                    }
                                    else
                                    {
                                        hiZ = rival.screenZ;
                                        hiD = rival.maxZ - rival.minZ;
                                    }
                                    //if (hiZ < loZ)
                                    //    break;
                                }
                                continue;
                            }
                        */
                        switch (ZCompare.zconflict(pri, rival, camera.focus))
                        {
                            case ZCompare.ZOrderIrrelevant:
                                break;
                            case ZCompare.ZOrderDeeper:
                                if (loZ < rival.screenZ)
                                {
                                    loZ = rival.screenZ;
                                    loD = rival.maxZ - rival.minZ;
                                }
                                break;
                            case ZCompare.ZOrderHigher:
                                if (hiZ > rival.screenZ)
                                {
                                    hiZ = rival.screenZ;
                                    hiD = rival.maxZ - rival.minZ;
                                }
                                break;
                        }
                        //if (hiZ < loZ)
                        //    break;
                    }
    
                    if ((hiZ >= pri.screenZ) && (pri.screenZ >= loZ))
                    {
                        // ok
                    }
                    else
                    if ((hiZ > loZ))
                    {
                        if (hiZ == Infinity)
                            pri.screenZ = loZ+0.01;
                        else
                        if (loZ == -Infinity)
                            pri.screenZ = hiZ-0.01;
                        else
                            pri.screenZ = (hiZ + loZ) / 2;
                    }
                    else
                    {
                        var dZ:Number = pri.maxZ - pri.minZ;
                        if (/*(dZ > loD) || (dZ > hiD) ||*/ (turn % 3 == 2))
                        {
                            var parts:Array = pri.quarter(camera.focus);
                            
                            if (parts != null)
                            {
                                tree.remove(pri);
                                for each (var part:DrawPrimitive in parts)
                                {
                                    //part.screenZ = pri.screenZ;
                                    leftover.push(part);
                                    tree.push(part);
                                }
                            }
                        }
                        else
                            leftover.push(pri);
                    }
                }
                primitives = leftover;
                turn += 1;
                if (turn == 20)
                    break;
            }
        }
    
        public function toString():String
        {
            return "QuadrantExtrusionFilter" + ((maxdelay == 60000) ? "" : "("+maxdelay+"ms)");
        }
    }
}   