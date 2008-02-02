package away3d.loaders
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.mesh.*;
    import away3d.core.scene.*;
    import away3d.core.utils.*;
    
    import flash.utils.*;

    /** Collada scene loader */
    public class Collada
    {
        private var container:ObjectContainer3D;
        private var collada:XML;
        private var library:Dictionary;
        private var material:ITriangleMaterial;
        private var scaling:Number;
        private var yUp:Boolean;
    
        public function Collada(xml:XML, init:Object = null)
        {
            collada = xml;

            init = Init.parse(init);

            scaling = init.getNumber("scaling", 1) * 100;
            material = init.getMaterial("material");
            var materials:Object = init.getObject("materials") || {};

            library = new Dictionary();
            for (var name:String in materials)
                library[name] = Cast.material(materials[name]);
    
            container = new ObjectContainer3D(init);

            buildCollada();
        }

        public static function parse(data:*, init:Object = null):ObjectContainer3D
        {
            return new Collada(Cast.xml(data), init).container;
        }

        public static function load(url:String, init:Object = null):Object3DLoader
        {
            return Object3DLoader.load(url, parse, false, init);
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
	    	var matrix:Matrix3D;
	    	var newnode:Object3D;
	    	var m:Matrix3D = new Matrix3D();
	    	
            if (String(node.instance_geometry) == "")
                newnode = new ObjectContainer3D();
            else                                                
                newnode = new Mesh(null);

            newnode.name = node.@name;
            matrix = newnode.transform;
            parent.addChild(newnode);
    
            var children:XMLList = node.children();
            var totalChildren:int = children.length();
    
            for (var i:int = 0; i < totalChildren; i++)
            {
                var child:XML = children[i];
    
                switch (child.name().localName)
                {
                    case "translate":
                        matrix.multiply(matrix, translateMatrix(getArray(child)));
                        break;
    
                    case "rotate":
                        matrix.multiply(matrix, rotateMatrix(getArray(child)));
                        break;
    
                    case "scale":
                        matrix.multiply(matrix, scaleMatrix(getArray(child)));
                        break;
    
                    // Baked transform matrix
                    case "matrix":
                    	m.array2matrix(getArray(child));
                        matrix.multiply(matrix, m);
                        break;
    
                    case "node":
                        if (newnode is ObjectContainer3D)
                            parseNode(child, newnode as ObjectContainer3D);
                        break;
    
                    case "instance_geometry":
                        for each (var geometry:XML in child)
                        {                       
                            if (String(geometry) == "")
                                continue;

                            var materials:Dictionary = new Dictionary();
                            for each (var instance_material:XML in child..instance_material)
                            {
                                var symbol:String = instance_material.@symbol;
                                materials[symbol] = instance_material.@target.split("#")[1];
                            }
                                 
                            var geo:XML = collada.library_geometries.geometry.(@id == getId(geometry.@url))[0];
                            parseGeometry(geo, newnode as Mesh, materials);
                        }
                        break;
                }
            }
        }
    
        private function parseGeometry(geometry:XML, instance:Mesh, materials:Dictionary):void
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
    
            buildObject(semantics, instance, materials);
        }
    
        private function buildObject(semantics:Object, mesh:Mesh, materials:Dictionary):void
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
    
                var uva:UV = null;
                var uvb:UV = null;
                var uvc:UV = null;
    
                if (uv && tex)
                {
                    uva = new UV(tex[uv[0]].S, tex[uv[0]].T);
                    uvb = new UV(tex[uv[1]].S, tex[uv[1]].T);
                    uvc = new UV(tex[uv[2]].S, tex[uv[2]].T);
                }

                var face:Face = new Face(a, b, c, getMaterial(semFaces[i].material, materials), uva, uvb, uvc);
                mesh.addFace(face);
            }
    
            mesh.material = new WireColorMaterial(0xFF00FF);
    
            mesh.visible = true;
            
            mesh.type = ".Collada";
        }
    
        private function getMaterial(name:String, materials:Dictionary):ITriangleMaterial
        {
            if (name == null)
                return material;

            if (library[name] != null)
                return library[name];

            name = materials[name];

            if (name == null)
                return material;

            if (library[name] != null)
                return library[name];

            var matxml:XML = collada.library_materials.material.(@id == name)[0];

            if (matxml == null)
                return material;

            var effectId:String = getId(matxml.instance_effect.@url);
            var effect:XML = collada.library_effects.effect.(@id == effectId)[0];

            if (effect..texture.length() == 0) 
                return material;

            var textureId:String = effect..texture[0].@texture;
            var sampler:XML =  effect..newparam.(@sid == textureId)[0];

            // Blender
            var imageId:String = textureId;

            // Not Blender
            if (sampler)
            {
                var sourceId:String = sampler..source[0];
                var source:XML =  effect..newparam.(@sid == sourceId)[0];

                imageId = source..init_from[0];
            }

            var image:XML = collada.library_images.image.(@id == imageId)[0];

            var filename:String = image.init_from;

            if (filename.indexOf("/") != -1)
                filename = filename.substring(filename.lastIndexOf("/")+1);

            filename = filename.replace(/\-/g, "");

            try
            {
                return Cast.material(filename);
            }
            catch (error:CastError)
            {
            }
            return material;
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
        
    	internal var rotationMatrix:Matrix3D = new Matrix3D();
    	
        private function rotateMatrix(vector:Array):Matrix3D
        {
            if (this.yUp)
                rotationMatrix.rotationMatrix(vector[0], vector[1], vector[2], -vector[3] * toRADIANS);
            else
                rotationMatrix.rotationMatrix(vector[0], vector[2], vector[1], -vector[3] * toRADIANS);
            
            return rotationMatrix;
        }
    
    	internal var translationMatrix:Matrix3D = new Matrix3D();
    	
        private function translateMatrix(vector:Array):Matrix3D
        {
            if (this.yUp)
                translationMatrix.translationMatrix(-vector[0] * this.scaling, vector[1] * this.scaling, vector[2] * this.scaling);
            else
                translationMatrix.translationMatrix( vector[0] * this.scaling, vector[2] * this.scaling, vector[1] * this.scaling);
            
            return translationMatrix;
        }
    
    	internal var scalingMatrix:Matrix3D = new Matrix3D();
    	
        private function scaleMatrix(vector:Array):Matrix3D
        {
            if (this.yUp)
                scalingMatrix.scaleMatrix(vector[0], vector[1], vector[2]);
            else
                scalingMatrix.scaleMatrix(vector[0], vector[2], vector[1]);
            
            return scalingMatrix;
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
