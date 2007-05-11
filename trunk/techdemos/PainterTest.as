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
    public class PainterTest extends BaseDemo
    {
        public function PainterTest()
        {
            super("Painter demo");
            infogroup.visible = false;

            addSlide("Drawing", 
"", 
            new Scene3D(new Drawing), 
            new QuadrantRenderer(new AnotherRivalFilter));

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
    [Embed(source="images/grad.jpg")]
    public static var GradImage:Class;

    public static function get grad():BitmapData
    {
        return (new GradImage as BitmapAsset).bitmapData;
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

class Drawing extends ObjectContainer3D
{
    private var sphere1:Sphere;
    private var sphere2:Sphere;
    private var sphere3:Sphere;
    private var sphere4:Sphere;
    private var sphere5:Sphere;
    private var sphere6:Sphere;
    private var sphere7:Sphere;
    private var sphere8:Sphere;
    private var sizepickermat:WireColorMaterial;
    private var selectedsizemat:WireColorMaterial;
    private var sizepicker:ObjectContainer3D;
    private var colorpicker:Triangle;
    private var spraypicker:ObjectContainer3D;
    private var smoothswitch:Plane;
    private var clearbutton:Plane;

    private var spray0:Sphere;
    private var spray1:Sphere;
    private var spray2:Sphere;

    private var plane:Plane;
    private var canvas:BitmapData;
    private var pallete:BitmapData;
    private var drawing:Boolean;
    private var lastx:Number;
    private var lasty:Number;

    private var thickness:Number = 3;
    private var spray:Number = 0.5;
    private var color:Number = 0x808080;
    private var smooth:Boolean = true;
                       
    public function Drawing()
    {
        canvas = new BitmapData(400, 400);
        pallete = Asset.grad;
        plane = new Plane(new PreciseBitmapMaterial(canvas, {precision:8, smooth:true}), {width:1000, height:1000, segmentsW:10, segmentsH:10, y:-20});

        sizepickermat = new ColorMaterial(0x808080);
        selectedsizemat = new WireColorMaterial(0x808080);
        sphere1 = new Sphere(sizepickermat,   {radius: 10, segmentsW:5, segmentsH:4, x:-400, y:160, z:560, extra:1});
        sphere1 = new Sphere(sizepickermat,   {radius: 10, segmentsW:3, segmentsH:2, x:-400, y:160, z:560, extra:1});
        sphere2 = new Sphere(sizepickermat,   {radius: 15, segmentsW:3, segmentsH:2, x:-345, y:160, z:560, extra:1.5});
        sphere3 = new Sphere(sizepickermat,   {radius: 20, segmentsW:4, segmentsH:3, x:-280, y:160, z:560, extra:2});
        sphere4 = new Sphere(selectedsizemat, {radius: 30, segmentsW:4, segmentsH:3, x:-200, y:160, z:560, extra:3});
        sphere5 = new Sphere(sizepickermat,   {radius: 40, segmentsW:5, segmentsH:4, x:-100, y:160, z:560, extra:4});
        sphere6 = new Sphere(sizepickermat,   {radius: 50, segmentsW:5, segmentsH:4, x:  20, y:160, z:560, extra:5});
        sphere7 = new Sphere(sizepickermat,   {radius: 70, segmentsW:5, segmentsH:4, x: 170, y:160, z:560, extra:7});
        sphere8 = new Sphere(sizepickermat,   {radius:100, segmentsW:5, segmentsH:4, x: 370, y:160, z:560, extra:10});

        sizepicker = new ObjectContainer3D(null, sphere1, sphere2, sphere3, sphere4, sphere5, sphere6, sphere7, sphere8);

        spray0 = new Sphere(sizepickermat,   {radius: 50, segmentsW:5, segmentsH:4, x:-350, y:260, z:660, extra:0});
        spray1 = new Sphere(selectedsizemat, {radius: 50, segmentsW:5, segmentsH:4, x:-200, y:260, z:660, extra:0.5});
        spray2 = new Sphere(sizepickermat,   {radius: 50, segmentsW:5, segmentsH:4, x:- 50, y:260, z:660, extra:1});

        var v:Vertex3D;
        var k:Number;
        for each (v in spray1.vertices)
        {
            k = Math.random() * 0.6 + 0.7;
            v.x *= k;
            v.y *= k;
            v.z *= k;
        }
        for each (v in spray2.vertices)
        {
            k = Math.random() * 1.0 + 0.5;
            v.x *= k;
            v.y *= k;
            v.z *= k;
        }

        spraypicker = new ObjectContainer3D(null, spray0, spray1, spray2);

        colorpicker = new Triangle(new PreciseBitmapMaterial(pallete, {precision:8, smooth:false}), null, 550, {rotationY: 90, x:600, y:300, rotationZ:-35});

        smoothswitch = new Plane(new PreciseBitmapMaterial(Asset.bwwb, {precision:8, smooth:true}), {width:80, height:80, z:400, x:-600});
        clearbutton = new Plane(new ColorMaterial(0xFFFFFF), {width:80, height:80, z:300, x:-600});

        plane.events.addEventListener(MouseEvent.MOUSE_DOWN, onPlaneMouseDown);
        plane.events.addEventListener(MouseEvent.MOUSE_MOVE, onPlaneMouseMove);

        sizepicker.events.addEventListener(MouseEvent.MOUSE_DOWN, onSizepickerMouseDown);
        spraypicker.events.addEventListener(MouseEvent.MOUSE_DOWN, onSpraypickerMouseDown);
        colorpicker.events.addEventListener(MouseEvent.MOUSE_DOWN, onColorpickerMouseDown);
        smoothswitch.events.addEventListener(MouseEvent.MOUSE_DOWN, onSmoothswitchMouseDown);
        clearbutton.events.addEventListener(MouseEvent.MOUSE_DOWN, onClearbuttonMouseDown);

        super(null, plane, sizepicker, spraypicker, colorpicker, smoothswitch, clearbutton);
    }

    public function onPlaneMouseDown(e:MouseEvent3D):void
    {
        drawing = !drawing;
        if (drawing)
        {
            lastx = e.uv.u*canvas.width;
            lasty = (1-e.uv.v)*canvas.height;
        }
    }
    
    public function onSizepickerMouseDown(e:MouseEvent3D):void
    {
        drawing = false;
        if (e.object is Sphere)
        {
            var sphere:Sphere = e.object as Sphere;
            thickness = sphere.extra as Number;
            for each (var s:Sphere in sizepicker.children)
                s.material = sizepickermat;
            sphere.material = selectedsizemat;
        }
    }

    public function onSpraypickerMouseDown(e:MouseEvent3D):void
    {
        drawing = false;
        if (e.object is Sphere)
        {
            var sphere:Sphere = e.object as Sphere;
            spray = sphere.extra as Number;
            for each (var s:Sphere in spraypicker.children)
                s.material = sizepickermat;
            sphere.material = selectedsizemat;
        }
    }

    public function onSmoothswitchMouseDown(e:MouseEvent3D):void
    {
        drawing = false;
        smooth = !smooth;
        (smoothswitch.material as PreciseBitmapMaterial).smooth = smooth;
        (plane.material as PreciseBitmapMaterial).smooth = smooth;
    }

    public function onClearbuttonMouseDown(e:MouseEvent3D):void
    {
        drawing = false;
        for (var i:int = 0; i < canvas.width; i++)
            for (var j:int = 0; j < canvas.height; j++)
                canvas.setPixel(i, j, 0xFFFFFF);

        for each (var vertex:Vertex3D in plane.vertices)
            vertex.y = 0;
    }

    public function onColorpickerMouseDown(e:MouseEvent3D):void
    {
        drawing = false;
        if (e.uv == null)
            return;

        var x:Number = e.uv.u*pallete.width;
        var y:Number = (1-e.uv.v)*pallete.height;
        color = pallete.getPixel(int(Math.round(x)), int(Math.round(y)));
        sizepickermat.fillColor = color;
        selectedsizemat.fillColor = color;
    }

    public function onPlaneMouseMove(e:MouseEvent3D):void
    {
        if (drawing)
        {
            var x:Number = e.uv.u*canvas.width;
            var y:Number = (1-e.uv.v)*canvas.height;
            var n:Number = Math.sqrt((lastx-x)*(lastx-x) + (lasty-y)*(lasty-y)) * (thickness+1.2);
            for (var i:int = 0; i < n; i++)
            {
                var k:Number = Math.random();
                var dx:Number = (2*Math.random()-1)*(thickness*(0.2+spray));
                var dy:Number = (2*Math.random()-1)*(thickness*(0.2+spray));
                var bx:Number = k*x + (1-k)*lastx + dx;
                var by:Number = k*y + (1-k)*lasty + dy;

                canvas.setPixel(int(Math.round(bx)), int(Math.round(by)), color);

                if (i % 20 == 0)
                {
                    var px:Number = (bx / canvas.width * 2 - 1) * 500;
                    var py:Number = (1 - by / canvas.height * 2) * 500;

                    for each (var vertex:Vertex3D in plane.vertices)
                        vertex.y += 40 * thickness / ((vertex.x-px)*(vertex.x-px) + (vertex.z-py)*(vertex.z-py) + 5000);
                }

            }
            lastx = x;
            lasty = y;
        }
    }
}

