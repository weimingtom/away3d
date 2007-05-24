package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import flash.display.*;
    import flash.utils.*;

    public class VolumeExtrusionFilter implements IPrimitiveVolumeBlockFilter
    {
        public var maxdelay:int;

        public var inner:Boolean;

        /*
            var start:int = getTimer();
                    check++;
                    if (check == 10)
                        if (getTimer() - start > maxdelay)
                            return;
                        else
                            check = 0;
        */
        public function VolumeExtrusionFilter(inner:Boolean = false, maxdelay:int = 60000)
        {
            this.inner = inner;
            this.maxdelay = maxdelay;
        }
    
        public function filter(blocklist:PrimitiveVolumeBlockList, scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping):void
        {
            var blocks:Array = blocklist.blocks();
            if (Debug.active) Debug.delimiter();
            if (Debug.active) Debug.trace("Block count: "+blocks.length);

            var orderer:Orderer = new Orderer();
            //var xpris:Array = [];
            //var xpri:DrawPrimitive;
            var pri:DrawPrimitive;
            //var dirty:Boolean;
            var focus:Number = camera.focus;
            var turn:int;

            if (inner)
            {
                for each (var block:PrimitiveVolumeBlock in blocks)
                {
                    var list:Array = block.list;
                    var leftover:Array = [];
                    
                    for each (pri in block.list)
                    {
                        if (pri.screenZ == Infinity)
                            continue;
                        orderer.init(pri, block, leftover);
                        orderer.conflict(block.list, focus);
                        if (orderer.ok())
                            continue;
                        if (orderer.fit())
                            continue;
                        orderer.defer();
                    }

                    turn = 0;
                    while (leftover.length > 0)
                    {
                        if (Debug.active) Debug.trace("");
                        if (Debug.active) Debug.trace("--turn-- "+turn);
                        list = leftover;
                        leftover = [];
                        for each (pri in list)
                        {
                            if (pri.screenZ == Infinity)
                                continue;
                            orderer.init(pri, block, leftover);
                            orderer.conflict(block.list, focus);
                            if (orderer.ok())
                                continue;
                            if (orderer.fit())
                                continue;
                            if ((turn % 2 == 0) || orderer.smallest())
                            {
                                orderer.defer();
                                continue;
                            }
                            orderer.quarter(focus);
                        }
                        turn++;                           
                        if (turn == 6)
                            break;
                    }
                }            
            }

            for each (var ablock:PrimitiveVolumeBlock in blocks)
            {
                for each (var bblock:PrimitiveVolumeBlock in blocks)
                {
                    if (ablock.maxZ < bblock.minZ)
                        continue;
                    if (ablock.minZ > bblock.maxZ)
                        continue;

                    // unordered pairs
                    if (ablock == bblock)
                        continue; 
                    if (ablock.minZ + ablock.maxZ > bblock.minZ + bblock.maxZ)
                        continue; 
                    // unordered pairs

                    if (ablock.maxX < bblock.minX)
                        continue;
                    if (ablock.minX > bblock.maxX)
                        continue;
                    if (ablock.maxY < bblock.minY)
                        continue;
                    if (ablock.minY > bblock.maxY)
                        continue;

                    var apri:DrawPrimitive;
                    var apris:Array = [];
                    var aminZ:Number = +Infinity;
                    var amaxZ:Number = -Infinity;
                    var aminX:Number = +Infinity;
                    var amaxX:Number = -Infinity;
                    var aminY:Number = +Infinity;
                    var amaxY:Number = -Infinity;
                    for each (apri in ablock.list)
                    {
                        if (apri.maxZ < bblock.minZ)
                            continue;
                        if (apri.minZ > bblock.maxZ)
                            continue;
                        if (apri.maxX < bblock.minX)
                            continue;
                        if (apri.minX > bblock.maxX)
                            continue;
                        if (apri.maxY < bblock.minY)
                            continue;
                        if (apri.minY > bblock.maxY)
                            continue;
                        if (aminZ > apri.minZ)
                            aminZ = apri.minZ;
                        if (amaxZ < apri.maxZ)
                            amaxZ = apri.maxZ;
                        if (aminX > apri.minX)
                            aminX = apri.minX;
                        if (amaxX < apri.maxX)
                            amaxX = apri.maxX;
                        if (aminY > apri.minY)
                            aminY = apri.minY;
                        if (amaxY < apri.maxY)
                            amaxY = apri.maxY;
                        apris.push(apri);
                    }
                    if (apris.length == 0)
                        continue;

                    var bpri:DrawPrimitive;
                    var bpris:Array = [];
                    var bminZ:Number = +Infinity;
                    var bmaxZ:Number = -Infinity;
                    var bminX:Number = +Infinity;
                    var bmaxX:Number = -Infinity;
                    var bminY:Number = +Infinity;
                    var bmaxY:Number = -Infinity;
                    for each (bpri in bblock.list)
                    {
                        if (bpri.maxZ < ablock.minZ)
                            continue;
                        if (bpri.minZ > ablock.maxZ)
                            continue;
                        if (bpri.maxX < ablock.minX)
                            continue;
                        if (bpri.minX > ablock.maxX)
                            continue;
                        if (bpri.maxY < ablock.minY)
                            continue;
                        if (bpri.minY > ablock.maxY)
                            continue;
                        if (bminZ > bpri.minZ)
                            bminZ = bpri.minZ;
                        if (bmaxZ < bpri.maxZ)
                            bmaxZ = bpri.maxZ;
                        if (bminX > bpri.minX)
                            bminX = bpri.minX;
                        if (bmaxX < bpri.maxX)
                            bmaxX = bpri.maxX;
                        if (bminY > bpri.minY)
                            bminY = bpri.minY;
                        if (bmaxY < bpri.maxY)
                            bmaxY = bpri.maxY;
                        bpris.push(bpri);
                    }
                    if (bpris.length == 0)
                        continue;

                    var aleft:Array = apris;
                    var bleft:Array = bpris;
                    var aori:Array = apris;
                    var bori:Array = bpris;
                    turn = 0;
                    while ((aleft.length > 0) || (bleft.length > 0))
                    {
                        apris = aleft;
                        bpris = bleft;
                        aleft = [];
                        bleft = [];
                        for each (apri in apris)
                        {
                            if (apri.screenZ == Infinity)
                                continue;
                            for each (bpri in bori)
                            {
                                if (bpri.minZ >= apri.maxZ)
                                    continue;
                                if (bpri.maxZ <= apri.minZ)
                                    continue;
                                if (!(bpri is DrawTriangle))
                                    continue;
                        
                                var brival:DrawTriangle = bpri as DrawTriangle;
                        
                                var asubst:Array = apri.riddle(brival, focus); 
                                if (asubst == null)
                                    continue;
                        
                                for each (var apart:DrawPrimitive in asubst)
                                {
                                    aleft.push(apart);
                                    ablock.push(apart);
                                }
                            
                                // hack to exclude primitive
                                //apri.minZ = Infinity; 
                                //apri.maxZ = Infinity;
                                ablock.remove(apri);
                                //apri.screenZ = Infinity;
                                break;
                            }
                        }
                        for each (bpri in bpris)
                        {
                            if (bpri.screenZ == Infinity)
                                continue;
                            for each (apri in aori)
                            {
                                if (apri.minZ >= bpri.maxZ)
                                    continue;
                                if (apri.maxZ <= bpri.minZ)
                                    continue;
                                if (!(apri is DrawTriangle))
                                    continue;
                        
                                var arival:DrawTriangle = apri as DrawTriangle;
                        
                                var bsubst:Array = bpri.riddle(arival, focus); 
                                if (bsubst == null)
                                    continue;
                        
                                for each (var bpart:DrawPrimitive in bsubst)
                                {
                                    bleft.push(bpart);
                                    bblock.push(bpart);
                                }
                            
                                // hack to exclude primitive
                                //bpri.minZ = Infinity; 
                                //bpri.maxZ = Infinity;
                                bblock.remove(bpri);
                                //bpri.screenZ = Infinity;
                                break;
                            }
                        }
                        if (turn == 5)
                            break;
                        turn++;
                    }

                    apris = [];
                    bpris = [];
                    for each (apri in ablock.list)
                    {
                        if (apri.maxZ < bblock.minZ)
                            continue;
                        if (apri.minZ > bblock.maxZ)
                            continue;
                        if (apri.maxX < bblock.minX)
                            continue;
                        if (apri.minX > bblock.maxX)
                            continue;
                        if (apri.maxY < bblock.minY)
                            continue;
                        if (apri.minY > bblock.maxY)
                            continue;
                        if (aminZ > apri.minZ)
                            aminZ = apri.minZ;
                        if (amaxZ < apri.maxZ)
                            amaxZ = apri.maxZ;
                        if (aminX > apri.minX)
                            aminX = apri.minX;
                        if (amaxX < apri.maxX)
                            amaxX = apri.maxX;
                        if (aminY > apri.minY)
                            aminY = apri.minY;
                        if (amaxY < apri.maxY)
                            amaxY = apri.maxY;
                        apris.push(apri);
                    }

                    for each (bpri in bblock.list)
                    {
                        if (bpri.maxZ < ablock.minZ)
                            continue;
                        if (bpri.minZ > ablock.maxZ)
                            continue;
                        if (bpri.maxX < ablock.minX)
                            continue;
                        if (bpri.minX > ablock.maxX)
                            continue;
                        if (bpri.maxY < ablock.minY)
                            continue;
                        if (bpri.minY > ablock.maxY)
                            continue;
                        if (bminZ > bpri.minZ)
                            bminZ = bpri.minZ;
                        if (bmaxZ < bpri.maxZ)
                            bmaxZ = bpri.maxZ;
                        if (bminX > bpri.minX)
                            bminX = bpri.minX;
                        if (bmaxX < bpri.maxX)
                            bmaxX = bpri.maxX;
                        if (bminY > bpri.minY)
                            bminY = bpri.minY;
                        if (bmaxY < bpri.maxY)
                            bmaxY = bpri.maxY;
                        bpris.push(bpri);
                    }

                    aleft = apris;
                    bleft = bpris;
                    turn = 0;
                    while ((aleft.length > 0) && (bleft.length > 0))
                    {
                        apris = aleft;
                        bpris = bleft;
                        aleft = [];
                        bleft = [];
                        for each (apri in apris)
                        {
                            orderer.init(apri, ablock, aleft);
                            orderer.conflict(bblock.list, focus);
                            if (orderer.ok())
                                continue;
                            orderer.reference(ablock.list);
                            if (orderer.fit())
                                continue;
                            if ((turn % 3 == 0) || orderer.smallest())
                            {
                                orderer.defer();
                                continue;
                            }
                            orderer.quarter(focus);
                        }
                        for each (bpri in bpris)
                        {
                            orderer.init(bpri, bblock, bleft);
                            orderer.conflict(ablock.list, focus);
                            if (orderer.ok())
                                continue;
                            orderer.reference(bblock.list);
                            if (orderer.fit())
                                continue;
                            if ((turn % 3 == 0) || orderer.smallest())
                            {
                                orderer.defer();
                                continue;
                            }
                            orderer.quarter(focus);
                        }
                        turn++;
                        if (turn == 9)
                            break;
                    }

                }
                
            }
        }
    
        public function toString():String
        {
            return "VolumeExtrusion" + (inner ? "Inner" : "") + ((maxdelay == 60000) ? "" : "("+maxdelay+"ms)");
        }
    }

}

import away3d.core.*;
import away3d.core.draw.*;
import away3d.core.render.*;

class Orderer
{
    public var pri:DrawPrimitive;
    public var block:PrimitiveVolumeBlock;
    public var deferred:Array;
    public var hiZ:Number;
    public var loZ:Number;
    public var hiD:Number;
    public var loD:Number;
    
    public function Orderer()
    {
    }

    public function init(pri:DrawPrimitive, block:PrimitiveVolumeBlock, deferred:Array):void
    {
        if (Debug.active) Debug.trace("");
        if (Debug.active) Debug.trace(pri);
        this.pri = pri;
        this.block = block;
        this.deferred = deferred;
        hiZ = Infinity;
        loZ = -Infinity;
        hiD = Infinity;
        loD = Infinity;
    }

    public function conflict(a:Array, focus:Number):void
    {
        if (hiZ < loZ)
            return;

        //Debug.trace("conflict");
        for each (var rival:DrawPrimitive in a)
        {
            if (rival == pri)
                continue;
            if (rival.screenZ == Infinity)
                continue;
            /*
            if (loZ > rival.screenZ)
                continue;
            if (hiZ < rival.screenZ)
                continue;
            */
            /*
            if (loZ == rival.screenZ)
                if (loD > rival.maxZ - rival.minZ)
                    continue;
            if (hiZ == rival.screenZ)
                if (hiD > rival.maxZ - rival.minZ)
                    continue;
            */
            switch (ZCompare.zconflict(pri, rival, focus))
            {
                case ZCompare.ZOrderIrrelevant:
                    if (Debug.active) Debug.trace("irrelevant "+rival);
                    break;
                case ZCompare.ZOrderDeeper:
                    if (Debug.active) Debug.trace("deeper "+rival);
                    if (loZ < rival.screenZ)
                    {
                        loZ = rival.screenZ;
                        loD = rival.maxZ - rival.minZ;
                    }
                    //if (hiZ < loZ)
                    //    return;
                    break;
                case ZCompare.ZOrderHigher:
                    if (Debug.active) Debug.trace("higher "+rival);
                    if (hiZ > rival.screenZ)
                    {
                        hiZ = rival.screenZ;
                        hiD = rival.maxZ - rival.minZ;
                    }
                    //if (hiZ < loZ)
                    //    return;
                    break;
            }
        }
    }

    public function reference(a:Array):void
    {
        if (hiZ < loZ)
            return;

        for each (var ref:DrawPrimitive in a)
        {
            if (ref == pri)
                continue;
            if (ref.screenZ == Infinity)
                continue;
            if (loZ > ref.screenZ)
                continue;
            if (hiZ < ref.screenZ)
                continue;
            /*
            if (loZ == ref.screenZ)
                if (loD > ref.maxZ - ref.minZ)
                    continue;
            if (hiZ == ref.screenZ)
                if (hiD > ref.maxZ - ref.minZ)
                    continue;
            */
            if (ref.maxX < pri.minX)
                continue;
            if (ref.minX > pri.maxX)
                continue;
            if (ref.maxY < pri.minY)
                continue;
            if (ref.minY > pri.maxY)
                continue;
            if (ref.screenZ == pri.screenZ)
                continue;
            if (ZCompare.overlap(ref, pri))
            {
                if (ref.screenZ > pri.screenZ)
                {
                    loZ = ref.screenZ;
                    loD = ref.maxZ - ref.minZ;
                }
                else
                {
                    hiZ = ref.screenZ;
                    hiD = ref.maxZ - ref.minZ;
                }
                if (hiZ < loZ)
                    return;
            }
        }
    }

    public function ok():Boolean
    {
        if ((hiZ > pri.screenZ) && (pri.screenZ > loZ))
        {
            if (Debug.active) Debug.trace("ok");
        }
        else
        {
            if (Debug.active) Debug.trace("bad");
        }
        return (hiZ > pri.screenZ) && (pri.screenZ > loZ);
    }

    public function fit():Boolean
    {
        if (hiZ < loZ)
        {
            if (Debug.active) Debug.trace("dont-fit");
            return false;
        }
        if (Debug.active) Debug.trace("fit");

        if (hiZ == Infinity)
            pri.screenZ = loZ+0.01;
        else
        if (loZ == -Infinity)
            pri.screenZ = hiZ-0.01;
        else
            pri.screenZ = (hiZ + loZ) / 2;
            
        return true;
    }

    public function smallest():Boolean
    {
        var dZ:Number = pri.maxZ - pri.minZ;
        if (Debug.active) Debug.trace(((dZ < loD) && (dZ < hiD)) ? "smallest" : "not-smallest");
        return (dZ < loD) && (dZ < hiD);
    }

    public function defer():void
    {
        if (Debug.active) Debug.trace("defer");
        deferred.push(pri);
    }

    public function quarter(focus:Number):void
    {
        if (Debug.active) Debug.trace("quarter");
        var parts:Array = pri.quarter(focus);
        if (parts == null)
            return;
        
        // TODO block.remove()

        for each (var part:DrawPrimitive in parts)
        {
            part.screenZ = pri.screenZ;
            deferred.push(part);
            block.push(part);
        }

        // hack to exclude primitive
        pri.minZ = Infinity; 
        pri.maxZ = Infinity;
        pri.screenZ = Infinity;
        /*
        */
    }

}
