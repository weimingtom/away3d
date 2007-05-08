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
    public class EngineTest extends BaseDemo
    {
        public function EngineTest()
        {
            super("Away3d engine test");

            DrawTriangle.test();
            DrawSegment.test();

            addSlide("Primitives", 
"", 
            new Scene3D(new Primitives), 
            new QuadrantRenderer(new AnotherRivalFilter));

            addSlide("Transforms", 
"", 
            new Scene3D(new Transforms), 
            new QuadrantRenderer(new AnotherRivalFilter));

            addSlide("Texturing", 
"", 
            new Scene3D(new Texturing), 
            new QuadrantRenderer(new AnotherRivalFilter));

            addSlide("Smooth texturing", 
"", 
            new Scene3D(new SmoothTexturing), 
            new QuadrantRenderer(new AnotherRivalFilter));

            addSlide("Wire primitives", 
"", 
            new Scene3D(new WirePrimitives), 
            new QuadrantRenderer(new AnotherRivalFilter));

            addSlide("Mouse Events", 
"", 
            new Scene3D(new MouseEvents), 
            new QuadrantRenderer(new AnotherRivalFilter));

            addSlide("Drawing", 
"", 
            new Scene3D(new Drawing), 
            new QuadrantRenderer(new AnotherRivalFilter));

            addSlide("Meshes", 
"", 
            new Scene3D(new Meshes), 
            new QuadrantRenderer(new AnotherRivalFilter));

            addSlide("Perspective texturing", 
"",
            new Scene3D(new PerspectiveTexturing), 
            new BasicRenderer());

            addSlide("Skybox", 
"",
            new Scene3D(new SimpleSkybox), 
            new BasicRenderer());

            addSlide("Smooth skybox", 
"",
            new Scene3D(new SmoothSkybox), 
            new BasicRenderer());

            addSlide("Z ordering", 
"",
            new Scene3D(new ZOrdering), 
            new QuadrantRenderer(new AnotherRivalFilter));

            addSlide("Intersecting objects", 
"",
            new Scene3D(new IntersectingObjects, new IntersectingObjects2), 
            new QuadrantRenderer(new QuadrantRiddleFilter, new AnotherRivalFilter));

            addSlide("Color lighting", 
"",
            new Scene3D(new ColorLighting), 
            new BasicRenderer());

            addSlide("White lighting", 
"",
            new Scene3D(new WhiteLighting), 
            new BasicRenderer());

            addSlide("Morphing", 
"",
            new Scene3D(new Morphing), 
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
    [Embed(source="images/mandelbrot.jpg")]
    public static var ManderlbrotImage:Class;

    public static function get mandelbrot():BitmapData
    {
        return (new ManderlbrotImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/grad.jpg")]
    public static var GradImage:Class;

    public static function get grad():BitmapData
    {
        return (new GradImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/foil-dots.png")]
    public static var FoilDotsImage:Class;

    public static function get foilDots():BitmapData
    {
        return (new FoilDotsImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/foil-white.png")]
    public static var FoilWhiteImage:Class;

    public static function get foilWhite():BitmapData
    {
        return (new FoilWhiteImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/foil-color.png")]
    public static var FoilColorImage:Class;

    public static function get foilColor():BitmapData
    {
        return (new FoilColorImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/marble.jpg")]
    public static var MarbleImage:Class;

    public static function get marble():BitmapData
    {
        return (new MarbleImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/httt.jpg")]
    public static var HttTImage:Class;

    public static function get httt():BitmapData
    {
        return (new HttTImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/blue.jpg")]
    public static var BlueImage:Class;

    public static function get blue():BitmapData
    {
        return (new BlueImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/green.jpg")]
    public static var GreenImage:Class;

    public static function get green():BitmapData
    {
        return (new GreenImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/red.jpg")]
    public static var RedImage:Class;

    public static function get red():BitmapData
    {
        return (new RedImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/yellow.jpg")]
    public static var YellowImage:Class;

    public static function get yellow():BitmapData
    {
        return (new YellowImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/morning-back.jpg")]
    public static var MorningBackImage:Class;

    public static function get morningBack():BitmapData
    {
        return (new MorningBackImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/morning-down.jpg")]
    public static var MorningDownImage:Class;

    public static function get morningDown():BitmapData
    {
        return (new MorningDownImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/morning-front.jpg")]
    public static var MorningFrontImage:Class;

    public static function get morningFront():BitmapData
    {
        return (new MorningFrontImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/morning-left.jpg")]
    public static var MorningLeftImage:Class;

    public static function get morningLeft():BitmapData
    {
        return (new MorningLeftImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/morning-right.jpg")]
    public static var MorningRightImage:Class;

    public static function get morningRight():BitmapData
    {
        return (new MorningRightImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/morning-up.jpg")]
    public static var MorningUpImage:Class;

    public static function get morningUp():BitmapData
    {
        return (new MorningUpImage as BitmapAsset).bitmapData;
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
            {
                //b.setPixel(i, j, int(Math.max(i-j/2, 0))*0x10000 + int(i/2)*0x100 + int(Math.max(j-i/2, 0)));
                b.setPixel(i, j, color);
                //if (i % 20 == 1)
                //    b.setPixel(i, j, 0);
                //if (j % 20 == 1)
                //    b.setPixel(i, j, 0xEE7700);
            }
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

class Meshes extends ObjectContainer3D
{
    [Embed(source="images/Focus.dae",mimeType="application/octet-stream")]
    public static var FocusModel:Class;

    [Embed(source="images/body.jpg")]
    public static var bodyImage:Class;

    [Embed(source="images/wheel.jpg")]
    public static var wheelImage:Class;
    
                       
    public function Meshes()
    {
        var bodyTexture:IMaterial = PreciseBitmapMaterial.fromAsset(new bodyImage, {precision:2});
        var wheelTexture:IMaterial = PreciseBitmapMaterial.fromAsset(new wheelImage, {precision:2});
        var focus:ObjectContainer3D = new Collada(new XML(new FocusModel), new MaterialLibrary({materialBody:bodyTexture, materialWheel:wheelTexture}));
        focus.y = -40;

        super(focus);
    }
    
}

class Primitives extends ObjectContainer3D
{
    private var sphere:Sphere;
    private var plane:Plane;
    private var cube:Cube;
                       
    public function Primitives()
    {
        plane = new Plane(new WireColorMaterial(0xFFFF00), {y:-20 , width:1000, height:1000});
        sphere = new Sphere(new WireColorMaterial(0xFF0000), {x:300, y:160, z:300, radius:150, segmentsW:12, segmentsH:9});
        cube = new Cube(new WireColorMaterial(0x0000FF), {x:300, y:160, z:-80, width:200, height:200, depth:200});

        super(sphere, plane, cube);
    }
    
}

class Transforms extends ObjectContainer3D
{
    private var sphere:Sphere;
    private var plane:Plane;
    private var cube:Cube;
                       
    public function Transforms()
    {
        plane = new Plane(new WireColorMaterial(0xFFFF00), {y:-20 , width:1000, height:1000});
        sphere = new Sphere(new WireColorMaterial(0xFF0000), {x:300, y:160, z:300, radius:150, segmentsW:12, segmentsH:9});
        cube = new Cube(new WireColorMaterial(0x0000FF), {x:300, y:160, z:-80, width:200, height:200, depth:200});

        super(sphere, plane, cube);
    }
    
    public override function tick(time:int):void
    {
        cube.scaleX = 1 + 0.5 * Math.sin(time / 200);
        cube.scaleY = 1 - 0.5 * Math.sin(time / 200);
        sphere.rotationY = Math.tan(time / 3000)*90;
    }
}

class Texturing extends ObjectContainer3D
{
    private var sphere:Sphere;
    private var plane:Plane;
    private var cube:Cube;
                       
    public function Texturing()
    {
        plane = new Plane(new PreciseBitmapMaterial(Asset.yellow, {precision:1.5}), {y:-20 , width:1000, height:1000});
        sphere = new Sphere(new PreciseBitmapMaterial(Asset.red, {precision:1.5}), {x:300, y:160, z:300, radius:150, segmentsW:12, segmentsH:9});
        cube = new Cube(new PreciseBitmapMaterial(Asset.blue, {precision:1.5}), {x:300, y:160, z:-80, width:200, height:200, depth:200});

        super(sphere, plane, cube);
    }
    
}

class SmoothTexturing extends ObjectContainer3D
{
    private var sphere:Sphere;
    private var plane:Plane;
    private var cube:Cube;
                       
    public function SmoothTexturing()
    {
        plane = new Plane(new PreciseBitmapMaterial(Asset.yellow, {precision:1.2, smooth:true}), {y:-20 , width:1000, height:1000});
        sphere = new Sphere(new PreciseBitmapMaterial(Asset.red, {precision:1.2, smooth:true}), {x:300, y:160, z:300, radius:150, segmentsW:12, segmentsH:9});
        cube = new Cube(new PreciseBitmapMaterial(Asset.blue, {precision:1.2, smooth:true}), {x:300, y:160, z:-80, width:200, height:200, depth:200});

        super(sphere, plane, cube);
    }
    
}

class WirePrimitives extends ObjectContainer3D
{
    private var sphere:WireSphere;
    private var plane:WirePlane;
    private var gridplane:GridPlane;
    private var cube:WireCube;
                       
    public function WirePrimitives()
    {
        plane = new WirePlane(new WireframeMaterial(0xFFFF00), {y:-20, width:1000, height:1000, segmentsW:10});
        sphere = new WireSphere(new WireframeMaterial(0xFF0000, 1, 2), {x:300, y:160, z:300, radius:150, segmentsW:12, segmentsH:9});
        cube = new WireCube(new WireframeMaterial(0x0000FF, 1, 2), {x:300, y:160, z:-80, width:200, height:200, depth:200});
        gridplane = new GridPlane(new WireframeMaterial(0xFFFFFF), {y:-30, width:1000, height:1000, segmentsW:10});

        super(sphere, plane, cube, gridplane);
    }
    
}

class MouseEvents extends ObjectContainer3D
{
    private var sphere:Sphere;
    private var plane:Plane;
    private var cube:Cube;
                       
    public function MouseEvents()
    {
        plane = new Plane(new WireColorMaterial(0xFFFF00), {y:-20 , width:1000, height:1000});
        sphere = new Sphere(new WireColorMaterial(0xFF0000), {x:300, y:160, z:300, radius:150, segmentsW:12, segmentsH:9});
        cube = new Cube(new WireColorMaterial(0x0000FF), {x:300, y:160, z:-80, width:200, height:200, depth:200});

        events.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);

        super(sphere, plane, cube);
    }

    public function onMouseDown(e:MouseEvent3D):void
    {
        if (e.object is Mesh3D)
        {
            var mesh:Mesh3D = e.object as Mesh3D;
            mesh.material = new WireColorMaterial();
        }
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

class PerspectiveTexturing extends ObjectContainer3D
{
    public var cube:Cube;
                       
    public function PerspectiveTexturing()
    {
        cube = new Cube(new PreciseBitmapMaterial(Asset.httt, {precision:2.5}), {width:800, height:800, depth:800});
        
        super(cube);
    }
    
}

class SimpleSkybox extends ObjectContainer3D
{
    public var skybox:Skybox;
                       
    public function SimpleSkybox()
    {
        skybox = new Skybox(new BitmapMaterial(Asset.morningFront), 
                            new BitmapMaterial(Asset.morningLeft), 
                            new BitmapMaterial(Asset.morningBack), 
                            new BitmapMaterial(Asset.morningRight), 
                            new BitmapMaterial(Asset.morningUp), 
                            new BitmapMaterial(Asset.morningDown));

        skybox.quarterFaces();

        super(skybox);
    }
    
}

class SmoothSkybox extends ObjectContainer3D
{
    public var skybox:Skybox;
                       
    public function SmoothSkybox()
    {
        skybox = new Skybox(new PreciseBitmapMaterial(Asset.morningFront, {precision:5, smooth:true}), 
                            new PreciseBitmapMaterial(Asset.morningLeft, {precision:5, smooth:true}), 
                            new PreciseBitmapMaterial(Asset.morningBack, {precision:5, smooth:true}), 
                            new PreciseBitmapMaterial(Asset.morningRight, {precision:5, smooth:true}), 
                            new PreciseBitmapMaterial(Asset.morningUp, {precision:5, smooth:true}), 
                            new PreciseBitmapMaterial(Asset.morningDown, {precision:5, smooth:true}));

        super(skybox);
    }
    
}

class ZOrdering extends ObjectContainer3D
{
    private var cube:Cube;
                       
    public function ZOrdering()
    {
        var white:IMaterial = new WireColorMaterial(0xFFFFFF, 0xEEEEEE);// new ColorShadingBitmapMaterial(0xFFFFFF, 0xFFFFFF, 0);
        var grey:IMaterial = new WireColorMaterial(0x808080, 0x777777);// new ColorShadingBitmapMaterial(0x808080, 0x808080, 0);

        cube = new Cube(white, {width:600, height:600, depth:600});

        super(null, cube);

        addChild(new Cube(grey, {x: 340, y: 210, z: 210, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x: 340, y: 210, z:-210, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x: 340, y:-210, z: 210, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x: 340, y:-210, z:-210, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x:-340, y: 210, z: 210, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x:-340, y: 210, z:-210, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x:-340, y:-210, z: 210, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x:-340, y:-210, z:-210, width:60, height:60, depth:60}));

        addChild(new Cube(grey, {x: 210, y: 340, z: 210, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x: 210, y: 340, z:-210, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x: 210, y:-340, z: 210, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x: 210, y:-340, z:-210, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x:-210, y: 340, z: 210, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x:-210, y: 340, z:-210, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x:-210, y:-340, z: 210, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x:-210, y:-340, z:-210, width:60, height:60, depth:60}));

        addChild(new Cube(grey, {x: 210, y: 210, z: 340, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x: 210, y: 210, z:-340, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x: 210, y:-210, z: 340, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x: 210, y:-210, z:-340, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x:-210, y: 210, z: 340, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x:-210, y: 210, z:-340, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x:-210, y:-210, z: 340, width:60, height:60, depth:60}));
        addChild(new Cube(grey, {x:-210, y:-210, z:-340, width:60, height:60, depth:60}));
    }
    
}

class IntersectingObjects extends ObjectContainer3D
{
    private var cubeA:Cube;
    private var cubeB:Cube;
    private var cubeC:Cube;
                       
    public function IntersectingObjects()
    {
        cubeA = new Cube(new PreciseBitmapMaterial(Asset.red, {precision:2}), {width:40, height:120, depth:400});
        cubeB = new Cube(new PreciseBitmapMaterial(Asset.yellow, {precision:2}), {width:400, height:40, depth:120});
        cubeC = new Cube(new PreciseBitmapMaterial(Asset.blue, {precision:2}), {width:120, height:400, depth:40});

        super(cubeA, cubeB, cubeC);

        x = 250;
    }
    
}

class IntersectingObjects2 extends ObjectContainer3D
{
    private var a:Sphere;
    private var b:Sphere;

    public function IntersectingObjects2()
    {
        var k:int = 1;
        a = new Sphere(new WireColorMaterial(0xFFFFFF, 0x000000, 1, 0), {radius:280, segmentsW:3, segmentsH:2});
        b = new Sphere(new BitmapMaterial(Asset.foilColor), {radius:200, segments:8,segmentsH:6});

        a.rotationY = 360 / 6 / 2;
        super(a, b);

        x = -250;
    }
}

class ColorLighting extends ObjectContainer3D
{
    private var plane:Plane;
    private var sphere:Sphere;
    private var texture:ColorShadingBitmapMaterial;
    private var light1:Light3D;
    private var light2:Light3D;
    private var light3:Light3D;
    private var lights:ObjectContainer3D;

    public function ColorLighting()
    {
        texture = new ColorShadingBitmapMaterial(0xFFFFFF, 0xFFFFFF, 0xFFFFFF, {alpha:20});
        plane = new Plane(texture, {y:-100, width:1000, height:1000, segmentsW:16});
        sphere = new Sphere(texture, {y:800, radius:200, segmentsW:12, segmentsH:9});
        light1 = new Light3D(0xFF0000, 0.5, 0.5, 1);
        light2 = new Light3D(0x808000, 0.5, 0.5, 1);
        light3 = new Light3D(0x0000FF, 0.5, 0.5, 1);
        super(plane, light1, light2, light3);
    }
    
    public override function tick(time:int):void
    {
        for (var x:int = 0; x <= plane.segmentsW; x++)
            for (var y:int = 0; y <= plane.segmentsH; y++)
                plane.vertice(x, y).y = 50*Math.sin(dist(x-plane.segmentsW/2*Math.sin(time/5000), y-plane.segmentsH/2*Math.cos(time/7000))/2+time/500);

        light1.x = 600*Math.sin(time/5000) + 200*Math.sin(time/6000) + 200*Math.sin(time/7000);
        light1.z = 400*Math.cos(time/5000) + 500*Math.cos(time/6000) + 100*Math.cos(time/7000);
        light1.y = 400 + 100*Math.sin(time/10000);

        light2.x = 400*Math.sin(time/5500) + 400*Math.sin(time/4000) + 200*Math.sin(time/5000);
        light2.z = 400*Math.cos(time/5500) + 500*Math.cos(time/4000) + 100*Math.cos(time/5000);
        light2.y = 400 + 100*Math.sin(time/11000);

        light3.x = 300*Math.sin(time/3000) + 200*Math.sin(time/6500) + 300*Math.sin(time/4000);
        light3.z = 100*Math.cos(time/3000) + 300*Math.cos(time/6500) + 600*Math.cos(time/4000);
        light3.y = 400 + 100*Math.sin(time/12000);
    }

    private static function dist(dx:Number, dy:Number):Number
    {
        return Math.sqrt(dx*dx + dy*dy);
    }
}

class WhiteLighting extends ObjectContainer3D
{
    private var sphere:Sphere;
    private var light1:Light3D;
    private var light2:Light3D;
    private var texture:WhiteShadingBitmapMaterial;
    private var light1c:ObjectContainer3D;
    private var light2c:ObjectContainer3D;

    public function WhiteLighting()
    {
        texture = new WhiteShadingBitmapMaterial(Asset.mandelbrot, {alpha:10});
        texture.smooth = true;

        sphere = new Sphere(texture, {radius:200, segmentsW:4*8, segmentsH:3*8});

        light1 = new Light3D(0x555555, 1, 1, 1);
        light1.x = 350;
        light1.y = 350;
        light1.z = 350;
        light2 = new Light3D(0xAAAAAA, 1, 1, 1);
        light2.x = -300;
        light2.y = 300;
        light2.z = 300;
        light1c = new ObjectContainer3D(null, light1);
        light2c = new ObjectContainer3D(null, light1);

        super(sphere, light1c, light2c);
    }
    
    public override function tick(time:int):void
    {
        light1c.rotationY = time / 100;
        light2c.rotationY = time / 200;
        if (time % 19 == 1)
            texture.doubleStepTo(64);
    }
}

class Morphing extends ObjectContainer3D
{
    [Embed(source="images/circle.dae",mimeType="application/octet-stream")]
    public static var CircleModel:Class;

    [Embed(source="images/tri.dae",mimeType="application/octet-stream")]
    public static var TriModel:Class;

    [Embed(source="images/square.dae",mimeType="application/octet-stream")]
    public static var SquareModel:Class;

    private var circle:Mesh3D;
    private var tri:Mesh3D;
    private var square:Mesh3D;
    private var morph:Mesh3D;
    private var morpher:Morpher;
    private var texture:WireColorMaterial;

    public function Morphing()
    {
        texture = new WireColorMaterial();
        circle = new Collada(new XML(new CircleModel), new MaterialLibrary({face:texture})).children[0];
        tri    = new Collada(new XML(new TriModel), new MaterialLibrary({face:texture})).children[0];
        square = new Collada(new XML(new SquareModel), new MaterialLibrary({face:texture})).children[0];
        morph  = new Collada(new XML(new CircleModel), new MaterialLibrary({face:texture})).children[0];
        morpher = new Morpher(morph);

        super(morph);
    }

    public override function tick(time:int):void
    {
        var kt:Number = Math.min(Math.max(Math.sin(time/3000), 0), 1);
        var ks:Number = Math.min(Math.max(Math.sin(time/3000+2*Math.PI/3), 0), 1);
        morpher.start();
        morpher.mix(tri, kt);
        morpher.mix(square, ks);
        morpher.finish(circle);
        texture.fillColor = int(255*kt)*0x10000 + int(255*(1-kt-ks))*0x100 + int(255*ks);
    }
}

