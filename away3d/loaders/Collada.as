package away3d.loaders
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    import away3d.core.mesh.*;

    /** Collada scene loader */
    public class Collada
    {
        private var container:ObjectContainer3D;
        private var collada:XML;
        private var library:MaterialLibrary;
        private var scaling:Number;
        private var yUp:Boolean;
    
        public function Collada(xml:XML, init:Object = null)
        {
            collada = xml;

            init = Init.parse(init);

            scaling = init.getNumber("scaling", 1) * 100;
            library = Cast.library(init.getObject("materials"));
            library.def = init.getMaterial("material");
    
            container = new ObjectContainer3D(init);

            buildCollada();
        }

        public static function parse(data:*, init:Object = null):ObjectContainer3D
        {
            return new Collada(Cast.xml(data), init).container;
        }

        public static function load(url:String, init:Object = null, title:String = null, loader:Class = null):Object3D
        {
            return new (loader || CubeLoader)(url, parse, init, title);
        }

        protected function buildCollada():void
        {
            default xml namespace = collada.namespace();
    
            // Get up axis
            yUp = (collada.asset.up_axis == "Y_UP");
    
            // Parse first scene
            var sceneId:String = getId(collada.scene.instance_visual_scene.@url);
    
            var scene:XML = collada.library_visual_scenes.visual_scene.(@id == sceneId)[0];
    
            parseScene(scene);
        }
    
        private function parseScene(scene:XML):void
        {
            for each (var node:XML in scene.node)
                parseNode(node, container);
        }
    
        private function parseNode(node:XML, parent:ObjectContainer3D):void
        {
            var matrix:Matrix3D = Matrix3D.IDENTITY;
    
            var newnode:Object3D;
    
            if (String(node.instance_geometry) == "")
                newnode = new ObjectContainer3D();
            else                                                
                newnode = new Mesh(null);

            newnode.name = node.@name;
            parent.addChild(newnode);
    
            var children:XMLList = node.children();
            var totalChildren:int = children.length();
    
            for (var i:int = 0; i < totalChildren; i++)
            {
                var child:XML = children[i];
    
                switch (child.name().localName)
                {
                    case "translate":
                        matrix = Matrix3D.multiply(matrix, translateMatrix(getArray(child)));
                        break;
    
                    case "rotate":
                        matrix = Matrix3D.multiply(matrix, rotateMatrix(getArray(child)));
                        break;
    
                    case "scale":
                        matrix = Matrix3D.multiply(matrix, scaleMatrix(getArray(child)));
                        break;
    
                    // Baked transform matrix
                    case "matrix":
                        matrix = Matrix3D.multiply(matrix, Matrix3D.fromArray(getArray(child)));
                        break;
    
                    case "node":
                        if (newnode is ObjectContainer3D)
                            parseNode(child, newnode as ObjectContainer3D);
                        break;
    
                    case "instance_geometry":
                        for each(var geometry:XML in child)
                        {                       
                            if (String(geometry) == "")
                                continue;

                            var geoId:String = getId(geometry.@url);
                            var geo:XML = collada.library_geometries.geometry.(@id == geoId)[0];
                            parseGeometry(geo, newnode as Mesh);
                        }
                        break;
                }
            }
    
            newnode.setTransform(matrix); 
        }
    
        private function parseGeometry(geometry:XML, instance:Mesh):void
        {
            // Semantics
            var semantics:Object = new Object();
            semantics.name = geometry.@id;
    
            var faces:Array = semantics.triangles = new Array();
    
            // Triangles
            for each (var triangles:XML in geometry.mesh.triangles)
            {
                // Input
                var field:Array = new Array();
    
                for each(var input:XML in triangles.input)
                {
                    semantics[input.@semantic] = deserialize(input, geometry);
                    field.push(input.@semantic);
                }
    
                var data     :Array  = triangles.p.split(' ');
                var len      :Number = triangles.@count;
                var material :String = triangles.@material;
    
                for (var j:Number = 0; j < len; j++)
                {
                    var t:Object = new Object();
    
                    for (var v:Number = 0; v < 3; v++)
                    {
                        var fld:String;
                        for (var k:Number = 0; fld = field[k]; k++)
                        {
                            if (!t[fld]) 
                                t[fld] = new Array();
    
                            t[fld].push(Number(data.shift()));
                        }
    
                        t["material"] = material;
                    }
                    faces.push(t);
                }
            }
    
            buildObject(semantics, instance);
        }
    
        private function buildObject(semantics:Object, mesh:Mesh):void
        {
            // Vertices
            var vertices:Array = [];
    
            var semVertices:Array = semantics.VERTEX;
            var len:Number = semVertices.length;
    
            var i:int;
            for (i = 0; i < len; i++)
            {
                // Swap z & y for Max (to make Y up and Z depth)
                var vert:Object = semVertices[i];
                var x:Number = Number(vert.X) * scaling;
                var y:Number = Number(vert.Y) * scaling;
                var z:Number = Number(vert.Z) * scaling;
    
                if (this.yUp)
                    vertices.push(new Vertex(-x, y, z));
                else
                    vertices.push(new Vertex( x, z, y));
            }
    
            // Faces
            //var faces:Array = mesh.faces;
            var semFaces:Array = semantics.triangles;
            len = semFaces.length;
    
            for (i = 0; i < len; i++)
            {
                // Triangle
                var tri:Array = semFaces[i].VERTEX;
                var a:Vertex = vertices[tri[0]];
                var b:Vertex = vertices[tri[1]];
                var c:Vertex = vertices[tri[2]];
    
                var tex:Array = semantics.TEXCOORD;
                var uv:Array = semFaces[i].TEXCOORD;
    
                var uvA:UV = null;
                var uvB:UV = null;
                var uvC:UV = null;
    
                if (uv && tex)
                {
                    uvA = new UV(tex[uv[0]].S, tex[uv[0]].T);
                    uvB = new UV(tex[uv[1]].S, tex[uv[1]].T);
                    uvC = new UV(tex[uv[2]].S, tex[uv[2]].T);
                }

                var materialName:String = semFaces[i].material || null;
    
                var face:Face = new Face(a, b, c, library.getTriangleMaterial(materialName), uvA, uvB, uvC);
                mesh.addFace(face);
            }
    
            mesh.material = new WireColorMaterial(0xFF0000, 0.25, 0, 0.25);
    
            mesh.visible = true;
        }
    
    
        private function getArray(spaced:String):Array
        {
            var strings:Array = spaced.split(" ");
            var numbers:Array = new Array();
    
            var totalStrings:Number = strings.length;
    
            for (var i:Number = 0; i < totalStrings; i++)
                numbers[i] = Number(strings[i]);
    
            return numbers;
        }
    
        private function rotateMatrix(vector:Array):Matrix3D
        {
            if (this.yUp)
                return Matrix3D.rotationMatrix(vector[0], vector[1], vector[2], -vector[3] * toRADIANS);
            else
                return Matrix3D.rotationMatrix(vector[0], vector[2], vector[1], -vector[3] * toRADIANS);
        }
    
    
        private function translateMatrix(vector:Array):Matrix3D
        {
            if (this.yUp)
                return Matrix3D.translationMatrix(-vector[0] * this.scaling, vector[1] * this.scaling, vector[2] * this.scaling);
            else
                return Matrix3D.translationMatrix( vector[0] * this.scaling, vector[2] * this.scaling, vector[1] * this.scaling);
        }
    
    
        private function scaleMatrix(vector:Array):Matrix3D
        {
            if (this.yUp)
                return Matrix3D.scaleMatrix(vector[0], vector[1], vector[2]);
            else
                return Matrix3D.scaleMatrix(vector[0], vector[2], vector[1]);
        }
    
        private function deserialize(input:XML, geo:XML):Array
        {
            var output:Array = new Array();
            var id:String = input.@source.split("#")[1];
    
            // Source?
            var acc:XMLList = geo..source.(@id == id).technique_common.accessor;
    
            if (acc != new XMLList())
            {
                // Build source floats array
                var floId:String  = acc.@source.split("#")[1];
                var floXML:XMLList = collada..float_array.(@id == floId);
                var floStr:String  = floXML.toString();
                var floats:Array   = floStr.split(" ");
    
                // Build params array
                var params:Array = new Array();
    
                for each (var par:XML in acc.param)
                    params.push(par.@name);
    
                // Build output array
                var count:int = acc.@count;
                var stride:int = acc.@stride;
    
                for (var i:int = 0; i < count; i++)
                {
                    var element:Object = new Object();
    
                    for (var j:int = 0; j < stride; j++)
                        element[params[j]] = floats.shift();
    
                    output.push(element);
                }
            }
            else
            {
                // Store indexes if no source
                var recursive :XMLList = geo..vertices.(@id == id)["input"];
    
                output = deserialize(recursive[0], geo);
            }
    
            return output;
        }
    
    
        private function getId(url:String):String
        {
            return url.split("#")[1];
        }

        private static var toDEGREES:Number = 180 / Math.PI;
        private static var toRADIANS:Number = Math.PI / 180;
    }
}
