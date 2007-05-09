package
{
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    import flash.utils.*;

    import mx.core.BitmapAsset;
    
    import away3d.cameras.*;
    import away3d.objects.*;
    import away3d.loaders.*;
    import away3d.test.*;
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.render.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.draw.*;
    
    [SWF(backgroundColor="#222266", frameRate="60", width="800", height="600")]
    public class MappingTest extends BaseDemo
    {
        public function MappingTest()
        {
            super("Texture mapping demo");
            infogroup.visible = false;

            addSlide("Texture mapping", 
"", 
            new Scene3D(new MappingShow), 
            new BasicRenderer());

        }
    }
}

    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    import flash.utils.*;
    import flash.geom.*;

    import mx.core.BitmapAsset;
    
    import away3d.cameras.*;
    import away3d.objects.*;
    import away3d.loaders.*;
    import away3d.core.*;
    import away3d.core.render.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;

class Asset
{
    [Embed(source="images/workshop.jpg")]
    public static var WorkshopImage:Class;

    [Embed(source="images/workshopgood.dae",mimeType="application/octet-stream")]
    public static var WorkshopGoodModel:Class;

    public static function get wi():BitmapData
    {
        return (new WorkshopImage as BitmapAsset).bitmapData;
    }

    public static function get black1x1():BitmapData
    {
        return fill(0x000000, 1, 1);
    }

    public static function get white1x1():BitmapData
    {
        return fill(0xFFFFFF, 1, 1);
    }

    public static function color1x1(color:int):BitmapData
    {
        return fill(color, 1, 1);
    }

    public static function fill(color:int, width:int, height:int):BitmapData
    {
        var b:BitmapData = new BitmapData(width, height, false);
        for (var i:int = 0; i < width; i++)
            for (var j:int = 0; j < height; j++)
                b.setPixel(i, j, color);
        return b;
    }

    public static function get bwwb():BitmapData
    {
        var b:BitmapData = new BitmapData(2, 2, false);
        b.setPixel(0, 0, 0xFFFFFF);
        b.setPixel(1, 1, 0xFFFFFF);
        b.setPixel(0, 1, 0);
        b.setPixel(1, 0, 0);
        return b;
    }
}

class MappingShow extends ObjectContainer3D
{
    public var workshop:ObjectContainer3D;
    public var board:TextureMappingBoard;

    public function MappingShow()
    {
        var texture:IMaterial = new BitmapMaterial(Asset.wi);
        workshop = new Collada(new XML(new Asset.WorkshopGoodModel), new MaterialLibrary({main:texture}), 3);
        board = new TextureMappingBoard(Asset.wi);
        board.dx = 150;
        board.dy = 150;

        workshop.events.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

        super(workshop, board);
    }

    public function onMouseMove(e:MouseEvent3D):void
    {
        board.face = e.drawpri as DrawTriangle;
    }

}

class TextureMappingBoard extends Object3D implements IPrimitiveProvider
{
    public var bitmap:BitmapData;
    public var face:DrawTriangle;
    public var dx:Number;
    public var dy:Number;

    public function TextureMappingBoard(bitmap:BitmapData)
    {
        this.bitmap = bitmap;
    }

    public function primitives(projection:Projection, consumer:IPrimitiveConsumer):void
    {
        consumer.primitive(DrawBitmap.create(bitmap, dx, dy, 1));
        if (face != null)
        {
            consumer.primitive(DrawTriangle.create(this, new WireframeMaterial(0xFF0000), null,
                    new Vertex2D((face.uv0.u-0.5)*bitmap.width + dx, (0.5-face.uv0.v)*bitmap.height + dy, 0),
                    new Vertex2D((face.uv1.u-0.5)*bitmap.width + dx, (0.5-face.uv1.v)*bitmap.height + dy, 0),
                    new Vertex2D((face.uv2.u-0.5)*bitmap.width + dx, (0.5-face.uv2.v)*bitmap.height + dy, 0),
                    null, null, null
                ));

            var tri:DrawTriangle = DrawTriangle.create(this, new WireframeMaterial(0xFF0000), null,
                    face.v0, face.v1, face.v2,
                    null, null, null);

            tri.screenZ -= 10;
            consumer.primitive(tri);

        }

    }

}

