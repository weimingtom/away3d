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
            Debug.warningsAsErrors = true;

            super("Away3D engine test", 85+40);

            DrawTriangle.test();
            DrawSegment.test();

            addSlide("Primitives", 
"Basic primitives to start playing with", 
            new Scene3D(new Primitives), 
            new QuadrantRenderer(new AnotherRivalFilter));

            addSlide("Transforms", 
"Affine transforms for object and groups",
            new Scene3D(new Transforms), 
            new QuadrantRenderer(new AnotherRivalFilter));

            addSlide("Texturing", 
"Bitmap texturing", 
            new Scene3D(new Texturing), 
            new QuadrantRenderer(new AnotherRivalFilter));

            addSlide("Smooth texturing", 
"Smooth bitmap texturing", 
            new Scene3D(new SmoothTexturing), 
            new QuadrantRenderer(new AnotherRivalFilter));

            addSlide("Movie texturing", 
"Any Sprite or MovieClip can be used as a material", 
            new Scene3D(new MovieTexturing), 
            new QuadrantRenderer(new AnotherRivalFilter));
                    
            addSlide("Occlusion culling", 
"Unnecessary triangles elimination",
            new Scene3D(new Blockers), 
            new BasicRenderer());

            addSlide("Wire primitives", 
"First class support for segments", 
            new Scene3D(new WirePrimitives), 
            new QuadrantRenderer(new AnotherRivalFilter));

            addSlide("Bezier extrusion", 
"Bezier extrusion of a plane", 
            new Scene3D(new BezierCurve), 
            new BasicRenderer());
            
            addSlide("Mouse events", 
"Click on the objects to change their color", 
            new Scene3D(new MouseEvents), 
            new QuadrantRenderer(new AnotherRivalFilter));

            addSlide("Drawing", 
"Click on the plane to start drawing", 
            new Scene3D(new Drawing), 
            new QuadrantRenderer(new AnotherRivalFilter));

/*
            addSlide("Meshes", 
"", 
            new Scene3D(new Meshes), 
            new QuadrantRenderer(new AnotherRivalFilter));
*/

            addSlide("Sprites", 
"Directional sprites support", 
            new Scene3D(new Sprites), 
            new QuadrantRenderer(new AnotherRivalFilter));

            addSlide("Level of details", 
"Reducing triangle count for distant objects", 
            new Scene3D(new LODs), 
            new BasicRenderer());

            addSlide("Perspective texturing", 
"Correct perspective transform for textures",
            new Scene3D(new PerspectiveTexturing), 
            new BasicRenderer());
/*
            addSlide("Skybox", 
"",
            new Scene3D(new SimpleSkybox), 
            new BasicRenderer());
*/
            addSlide("Skybox",
"Multiple panorama options",
            new Scene3D(new SmoothSkybox), 
            new BasicRenderer());

            addSlide("Z ordering", 
"Correct z-ordering for triangles",
            new Scene3D(new ZOrdering), 
            new QuadrantRenderer(new AnotherRivalFilter));

            addSlide("Intersecting objects", 
"Ability to render intersecting objects",
            new Scene3D(new IntersectingObjects, new IntersectingObjects2), 
            new QuadrantRenderer(new QuadrantRiddleFilter, new AnotherRivalFilter));

            addSlide("Color lighting", 
"Phong model color lighting",
            new Scene3D(new ColorLighting), 
            new BasicRenderer());

            addSlide("White lighting", 
"White lighting for bitmap textures",
            new Scene3D(new WhiteLighting), 
            new BasicRenderer());

            addSlide("Mesh morphing", 
"Linear mesh morphing",
            new Scene3D(new Morphing), 
            new BasicRenderer());

            addSlide("Texture projection", 
"Projecting textures on objects", 
            new Scene3D(new FunnyCube), 
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
    import away3d.core.math.*;
    import away3d.shapes.*
    import away3d.extrusions.*
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

    [Embed(source="images/ls_front.png")]
    public static var LostSoulFrontImage:Class;
    [Embed(source="images/ls_leftfront.png")]
    public static var LostSoulLeftFrontImage:Class;
    [Embed(source="images/ls_left.png")]
    public static var LostSoulLeftImage:Class;
    [Embed(source="images/ls_leftback.png")]
    public static var LostSoulLeftBackImage:Class;
    [Embed(source="images/ls_back.png")]
    public static var LostSoulBackImage:Class;

    public static function getLostSoul(dir:String):BitmapData
    {
        var asset:BitmapAsset;
        switch (dir)
        {
            case "front":      asset = new LostSoulFrontImage; break;
            case "leftfront":  asset = new LostSoulLeftFrontImage; break;
            case "left":       asset = new LostSoulLeftImage; break;
            case "leftback":   asset = new LostSoulLeftBackImage; break;
            case "back":       asset = new LostSoulBackImage; break;
            default: throw new Error("Unknown direction");
        }
        return asset.bitmapData;
    }

    public static function flipX(source:BitmapData):BitmapData
    {
        var bitmap:BitmapData = new BitmapData(source.width, source.height);
        for (var i:int = 0; i < bitmap.width; i++)
            for (var j:int = 0; j < bitmap.height; j++)
                bitmap.setPixel32(i, j, source.getPixel32(source.width-i-1, j));
        return bitmap;
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

    //[Embed(source="images/marble.jpg")]
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

    [Embed(source="images/target.png")]
    public static var targetImage:Class;

    public static function get target():BitmapData
    {
        return (new targetImage as BitmapAsset).bitmapData;
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

    //[Embed(source="images/morning-back.jpg")]
    public static var MorningBackImage:Class;

    public static function get morningBack():BitmapData
    {
        return (new MorningBackImage as BitmapAsset).bitmapData;
    }

    //[Embed(source="images/morning-down.jpg")]
    public static var MorningDownImage:Class;

    public static function get morningDown():BitmapData
    {
        return (new MorningDownImage as BitmapAsset).bitmapData;
    }

    //[Embed(source="images/morning-front.jpg")]
    public static var MorningFrontImage:Class;

    public static function get morningFront():BitmapData
    {
        return (new MorningFrontImage as BitmapAsset).bitmapData;
    }

    //[Embed(source="images/morning-left.jpg")]
    public static var MorningLeftImage:Class;

    public static function get morningLeft():BitmapData
    {
        return (new MorningLeftImage as BitmapAsset).bitmapData;
    }

    //[Embed(source="images/morning-right.jpg")]
    public static var MorningRightImage:Class;

    public static function get morningRight():BitmapData
    {
        return (new MorningRightImage as BitmapAsset).bitmapData;
    }

    //[Embed(source="images/morning-up.jpg")]
    public static var MorningUpImage:Class;

    public static function get morningUp():BitmapData
    {
        return (new MorningUpImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/peterskybox2.jpg")]
    public static var DarkSkyImage:Class;

    public static function get darkSky():BitmapData
    {
        return (new DarkSkyImage as BitmapAsset).bitmapData;
    }

    //[Embed(source="images/temple.dae",mimeType="application/octet-stream")]
    public static var TempleModel:Class;

    [Embed(source="images/sand.jpg")]
    public static var SandImage:Class;

    public static function get sand():BitmapData
    {
        return (new SandImage as BitmapAsset).bitmapData;
    }
    
    [Embed(source="images/trackedge.jpg")]
    public static var TrackedgeImage:Class;

    public static function get trackedge():BitmapData
    {
        return (new TrackedgeImage as BitmapAsset).bitmapData;
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

/*
class Meshes extends ObjectContainer3D
{
    public function Meshes()
    {
        var templetex:IMaterial = new PreciseBitmapMaterial(Asset.httt, {precision:2});
        var temple:ObjectContainer3D = new Collada(new XML(new Asset.TempleModel), new MaterialLibrary({templeShader:templetex}));
        temple.y = -40;

        super(temple);
    }
    
}
*/

class LostSoul extends Sprite2DDir
{
    public var role:String;
    public var nextthink:int;
    public var lastmove:int;

    public function LostSoul(init:Object = null)
    {
        super(3, init);

        add( 0  , 0,-1  , Asset.getLostSoul("front"));
        add(-0.7, 0,-0.7, Asset.getLostSoul("leftfront"));
        add(-1  , 0, 0  , Asset.getLostSoul("left"));
        add(-0.7, 0, 0.7, Asset.getLostSoul("leftback"));
        add( 0  , 0, 1  , Asset.getLostSoul("back"));
        add( 0.7, 0, 0.7, Asset.flipX(Asset.getLostSoul("leftback")));
        add( 1  , 0, 0  , Asset.flipX(Asset.getLostSoul("left")));
        add( 0.7, 0,-0.7, Asset.flipX(Asset.getLostSoul("leftfront")));
    }       
            
    public override function tick(time:int):void
    {
        if ((role == null) || (nextthink < time))
        {
            role = (["stop", "right", "left", "forward"])[int(Math.random()*4)];
            if ((Math.abs(x) > 300) || (Math.abs(z) > 300))
                role = "right";
                //role = (["right", "left"])[int(Math.random()*2)];
            nextthink = time + Math.random()*3000;
        }

        var delta:Number = (lastmove - time)/1000;
        switch (role)
        {
            case "stop":    rotationY += delta*(Math.random()*20-10); break;
            case "right":   rotationY += delta*Math.random()*10; moveForward(delta*20); break;
            case "left":    rotationY -= delta*Math.random()*10; moveForward(delta*20); break;
            case "forward": moveForward(delta*60) break;
        }
        lastmove = time;

        if (x > 500)
            x = 500;
        if (x < -500)
            x = -500;
        if (z > 500)
            z = 500;
        if (z < -500)
            z = -500;
    }
}

class Sprites extends ObjectContainer3D
{
    private var plane:Plane;

    public function Sprites()
    {
        plane = new Plane(new PreciseBitmapMaterial(Asset.yellow, {precision:1.5}), {y:-100 , width:1000, height:1000});

        super(plane);

        addChild(new LostSoul({x:-300, z:-300, rotationY:240}));
        addChild(new LostSoul({x:   0, z:-300, rotationY:120}));
        addChild(new LostSoul({x: 300, z:-300, rotationY:0}));
        addChild(new LostSoul({x:-300, z:   0, rotationY:280}));
        addChild(new LostSoul({x:   0, z:   0, rotationY:80}));
        addChild(new LostSoul({x: 300, z:   0, rotationY:200}));
        addChild(new LostSoul({x:-300, z: 300, rotationY:320}));
        addChild(new LostSoul({x:   0, z: 300, rotationY:160}));
        addChild(new LostSoul({x: 300, z: 300, rotationY:40}));
    }
}

class AutoLODSphere extends ObjectContainer3D
{
    public function AutoLODSphere(color:int, init:Object = null)
    {
        var sphere0:Sphere = new Sphere(new WireColorMaterial(color), {radius:150, segmentsW: 4, segmentsH:3 });
        var sphere1:Sphere = new Sphere(new WireColorMaterial(color), {radius:150, segmentsW: 6, segmentsH:4 });
        var sphere2:Sphere = new Sphere(new WireColorMaterial(color), {radius:150, segmentsW: 8, segmentsH:6 });
        var sphere3:Sphere = new Sphere(new WireColorMaterial(color), {radius:150, segmentsW:10, segmentsH:8 });
        var sphere4:Sphere = new Sphere(new WireColorMaterial(color), {radius:150, segmentsW:12, segmentsH:9 });
        var sphere5:Sphere = new Sphere(new WireColorMaterial(color), {radius:150, segmentsW:14, segmentsH:10});
        var sphere6:Sphere = new Sphere(new WireColorMaterial(color), {radius:150, segmentsW:16, segmentsH:12});
                                                                                   
        super(init,                                                                
            new LODObject(0, 0.1, sphere0), 
            new LODObject(0.1, 0.3, sphere1), 
            new LODObject(0.3, 0.5, sphere2), 
            new LODObject(0.5, 1, sphere3), 
            new LODObject(1, 2, sphere4), 
            new LODObject(2, 3, sphere5), 
            new LODObject(3, 10, sphere6));
    }
}

class LODs extends ObjectContainer3D
{
    private var plane:Plane;

    public function LODs()
    {
        plane = new Plane(new PreciseBitmapMaterial(Asset.green, {precision:1.5}), {y:-200 , width:1000, height:1000});

        super(plane, 
            new AutoLODSphere(0xFF0000, {x: 350, y:160, z: 350}), 
            new AutoLODSphere(0xFFFF00, {x: 350, y:160, z:-350}), 
            new AutoLODSphere(0x00FF00, {x:-350, y:160, z:-350}), 
            new AutoLODSphere(0x0000FF, {x:-350, y:160, z: 350}));
    }
}

class Primitives extends ObjectContainer3D
{
    protected var sphere:Sphere;
    protected var plane:Plane;
    protected var cube:Cube;
    protected var torus:Torus;
                       
    public function Primitives()
    {
        plane = new Plane(new WireColorMaterial(0xFFFF00),   {y:-20, width:1000, height:1000});
        sphere = new Sphere(new WireColorMaterial(0xFF0000), {x: 300, y:160, z: 300, radius:150, segmentsW:12, segmentsH:9});
        cube = new Cube(new WireColorMaterial(0x0000FF),     {x: 300, y:160, z: -80, width:200, height:200, depth:200});
        torus = new Torus(new WireColorMaterial(0x00FF00),   {x:-250, y:160, z:-250, radius:150, tube:60, segmentsR:8, segmentsT:6});

        super(sphere, plane, cube, torus);
    }
    
}

class Transforms extends Primitives
{
    public override function tick(time:int):void
    {
        cube.scaleX = 1 + 0.5 * Math.sin(time / 200);
        cube.scaleY = 1 - 0.5 * Math.sin(time / 200);
        sphere.rotationY = Math.tan(time / 3000)*90;
        torus.rotationX = time / 20;
        torus.rotationY = time / 30;
        torus.rotationZ = time / 40;
    }
}

class Texturing extends Primitives
{
    public function Texturing()
    {
        plane.material = new PreciseBitmapMaterial(Asset.yellow, {precision:1.6});
        sphere.material = new PreciseBitmapMaterial(Asset.red, {precision:1.6});
        cube.material = new PreciseBitmapMaterial(Asset.blue, {precision:1.6});
        torus.material = new PreciseBitmapMaterial(Asset.green, {precision:1.6});
    }
    
}

class SmoothTexturing extends Primitives
{
    public function SmoothTexturing()
    {
        plane.material = new PreciseBitmapMaterial(Asset.yellow, {precision:1.5, smooth:true});
        sphere.material = new PreciseBitmapMaterial(Asset.red, {precision:1.5, smooth:true});
        cube.material = new PreciseBitmapMaterial(Asset.blue, {precision:1.5, smooth:true});
        torus.material = new PreciseBitmapMaterial(Asset.green, {precision:1.5, smooth:true});
    }
}

class MovieTexturing extends Primitives
{
    public var movie:MovieClip;
    public function MovieTexturing()
    {
        movie = new MovieClip();
        var graphics:Graphics = movie.graphics;
        graphics.beginFill(0xFFCC00);
        graphics.drawCircle(40, 40, 40);

        cube.material = new MovieMaterial(movie, {transparent:true});
    }
    
    public override function tick(time:int):void
    {
        var graphics:Graphics = movie.graphics;
        graphics.beginFill(0xFFFFFF*Math.random());
        graphics.drawCircle(20+40*Math.random(), 20+40*Math.random(), 20);
    }
}

class WirePrimitives extends ObjectContainer3D
{
    private var sphere:WireSphere;
    private var plane:WirePlane;
    private var gridplane:GridPlane;
    private var cube:WireCube;
    private var torus:WireTorus;
                       
    public function WirePrimitives()
    {
        plane = new WirePlane(new WireframeMaterial(0xFFFF00, 1, 0), {y:-70, width:1000, height:1000, segments:10});
        sphere = new WireSphere(new WireframeMaterial(0xFF0000, 1, 2), {x:300, y:160, z:300, radius:150, segmentsW:12, segmentsH:9});
        cube = new WireCube(new WireframeMaterial(0x0000FF, 1, 2), {x:300, y:160, z:-80, width:200, height:200, depth:200});
        gridplane = new GridPlane(new WireframeMaterial(0xFFFFFF), {y:-170, width:1000, height:1000, segmentsW:10});
        torus = new WireTorus(new WireframeMaterial(0x00FF00), {x:-250, y:160, z:-250, radius:150, tube:60, segmentsR:8, segmentsT:6});

        for each (var v:Vertex3D in plane.vertices)
            v.y += Math.random() * 50;

        super(sphere, plane, cube, gridplane, torus);
    }
    
}

class Blockers extends ObjectContainer3D
{
    protected var sphere:Sphere;
    protected var plane:Plane;
    protected var cube:Cube;
    protected var torus:Torus;
                       
    protected var sphereblock:ConvexBlock;
    protected var planeblock:ConvexBlock;

    public function Blockers()
    {
        plane = new Plane(new WireColorMaterial(0xFFFF00),   {y:-20, width:1000, height:1000, pushback:true});
        cube = new Cube(new WireColorMaterial(0x0000FF),     {x: 300, y:160, z: -80, width:200, height:200, depth:200});
        torus = new Torus(new WireColorMaterial(0x00FF00),   {x:-250, y:160, z:-250, radius:150, tube:60, segmentsR:8, segmentsT:6});
        sphere = new Sphere(new WireColorMaterial(0xFF0000), {x:300, y:160, z: 300, radius:150, segmentsW:12, segmentsH:9});

        sphereblock = new ConvexBlock(new Sphere(null, {radius:150, segmentsW:8, segmentsH:6}).vertices, {x:-300, y:160, z: 300, debug:true});
        planeblock = new ConvexBlock(new Plane(null, {width:400, height:1000}).vertices, {x:650, y:200, z:0, rotationZ:90, debug:true});

        super(sphere, plane, cube, torus, sphereblock, planeblock);
    }
    
}

class BezierCurve extends ObjectContainer3D
{
    public function BezierCurve()
    {
        var texture1:IMaterial = new TransformBitmapMaterial(Asset.sand, {smooth:false, repeat:true, /*precision:3,*/ debug:false, scalex:0.5, scaley:0.5, normal:new Number3D(1,1,1)});
        var texture2:IMaterial = new TransformBitmapMaterial(Asset.trackedge, {smooth:false, repeat:true, /*precision:3,*/ debug:false, scalex:0, scaley:0.5});
        var vertices:Array = new Array();

        for(var i:int = -1000; i < 1000; i += 500) 
            vertices.push(new Number3D(0,i+0,0), new Number3D(250,i+50,0), new Number3D(500,i+100,500), new Number3D(500,i+150,750), new Number3D(0,i+200,1000), new Number3D(-250,i+250,1000), new Number3D(-500,i+300,500), new Number3D(-500,i+350,250));

        var plane:BezierExtrude = new BezierExtrude(null, new IrregularShape([new Vertex3D(-130,0,0), new Vertex3D(-100,0,0), new Vertex3D(100,0,0), new Vertex3D(130,0,0)], {wrap:false}), vertices, {bothsides:true, segmentsH:10, axisMaterials:[texture1, texture2, texture1, texture2]});
        addChild(plane);
    }
}

class MouseEvents extends Primitives
{
    public function MouseEvents()
    {
        events.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
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
    private var plane:Plane;
    private var canvas:BitmapData;
    private var pallete:BitmapData;
    private var drawing:Boolean;
    private var lastx:Number;
    private var lasty:Number;

    private var thickness:Number = 8;
    private var spray:Number = 1;
    private var color:Number = 0x808080;
    private var smooth:Boolean = true;
    private var wireplane:WirePlane;

    public function Drawing()
    {
        canvas = new BitmapData(400, 400);
        plane = new Plane(new PreciseBitmapMaterial(canvas, {precision:8, smooth:true}), {width:1000, height:1000, segmentsW:10, segmentsH:10, y:-20});
        wireplane = new WirePlane(new WireframeMaterial(0x000000, 1, 2), {width:1002, height:1002, y:-20});

        plane.events.addEventListener(MouseEvent.MOUSE_DOWN, onPlaneMouseDown);
        plane.events.addEventListener(MouseEvent.MOUSE_MOVE, onPlaneMouseMove);

        super(plane, wireplane);
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
    
    public function onPlaneMouseMove(e:MouseEvent3D):void
    {
        if (drawing)
        {
            color = Color.fromHSV((getTimer()/100) % 360, 1, 1);

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

                var rx:int = int(Math.round(bx));
                var ry:int = int(Math.round(by));
                canvas.setPixel(rx, ry, color);

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

class FunnyCube extends ObjectContainer3D
{
    public var cube:Cube;
    public var material:TransformBitmapMaterial;
                       
    public override function tick(time:int):void
    {
        if (cube != null)
            removeChild(cube);

        var m:Matrix = new Matrix();
        m.translate(-250,-250);
        m.scale(2*(Math.abs(Math.sin(time/2000))+0.2), 2*(Math.abs(Math.cos(time/2000))+0.2));
        material = new TransformBitmapMaterial(Asset.target, {precision:2.5, transform:m, repeat:false, normal:new Number3D(1, 1, 1)});
        cube = new Cube(material, {width:500, height:500, depth:500, bothsides:true});

        addChild(cube);
    }
    
}

class SimpleSkybox extends ObjectContainer3D
{
    public var skybox:Skybox;
                       
    public function SimpleSkybox()
    {
        skybox = new Skybox(new BitmapMaterial(Asset.morningFront, {smooth:true}), 
                            new BitmapMaterial(Asset.morningLeft, {smooth:true}), 
                            new BitmapMaterial(Asset.morningBack, {smooth:true}), 
                            new BitmapMaterial(Asset.morningRight, {smooth:true}), 
                            new BitmapMaterial(Asset.morningUp, {smooth:true}), 
                            new BitmapMaterial(Asset.morningDown, {smooth:true}));

        skybox.quarterFaces();

        super(skybox);
    }
    
}

class SmoothSkybox extends ObjectContainer3D
{
    public var skybox:Skybox6;
                       
    public function SmoothSkybox()
    {
        skybox = new Skybox6(new PreciseBitmapMaterial(Asset.darkSky, {precision:5}));                   

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
        b = new Sphere(new BitmapMaterial(Asset.foilColor), {radius:200, segmentsW:8, segmentsH:6});

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
        plane = new Plane(texture, {y:-100, width:1000, height:1000, segments:16});
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

        sphere = new Sphere(texture, {radius:200, segmentsW:4*7, segmentsH:3*7});
        sphere.scaleY = 1.2;

        for each (var v:Vertex3D in sphere.vertices)
        {
            var y:Number = v.y / sphere.radius;
            y = y + (y*y - 1)*0.2;
            v.y = y * sphere.radius * 1.1;

            v.x += Math.random()*4-2;
            v.z += Math.random()*4-2;
            v.y += Math.random()*2-1;
        }

        light1 = new Light3D(0x555555, 1, 1, 1);
        light1.x = 3500/2;
        light1.y = 3500/2;
        light1.z = 3500/2;
        light2 = new Light3D(0xAAAAAA, 1, 1, 1);
        light2.x = -3000/2;
        light2.y = 3000/2;
        light2.z = 3000/2;
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

        if (light1.x*light1.x + light1.y*light1.y + light1.z*light1.z > 350*350)
        {
            light1.x *= 0.996;
            light1.y *= 0.996;
            light1.z *= 0.996;
        }
            
        if (light2.x*light2.x + light2.y*light2.y + light2.z*light2.z > 300*300)
        {
            light2.x *= 0.997;
            light2.y *= 0.997;
            light2.z *= 0.997;
        }
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

