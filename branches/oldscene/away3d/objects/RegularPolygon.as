package away3d.objects
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    /** Regular polygon */
    public class RegularPolygon extends Mesh3D 
    {
        public function RegularPolygon(material:IMaterial, init:Object = null) 
        {
            super(material, init);
                 
            init = Init.parse(init);

            var radius:Number = init.getNumber("radius", 100, {min:0});
            var sections:int = init.getInt("sections", 8, {min:3});
            var mapping:String = init.getString("mapping", "rotate");

            var tp:Number = 2 * Math.PI;
            var i:int;

            for (i = 0; i < sections; i++)
                vertices.push(new Vertex3D(radius*Math.sin(i*tp/sections), 0, radius*Math.cos(i*tp/sections)));

            var center:Vertex3D = new Vertex3D(0,0,0);
            vertices.push(center);

            var uvs:Array = [];
            var centeruv:NumberUV;
            switch (mapping)
            {
                case "rotate":
                    for (i = 0; i <= sections; i++)
                        uvs.push(new NumberUV(i / sections, 1));
                    centeruv = new NumberUV(0.5, 0);
                    break;
                case "planar":
                    for (i = 0; i <= sections; i++)
                        uvs.push(new NumberUV(Math.sin(i*tp/sections)/2+0.5, Math.cos(i*tp/sections)/2+0.5));
                    centeruv = new NumberUV(0.5, 0.5);
                    break;
                default:
                    throw new Error("Unknown RegularPolygon mapping: "+mapping);
            }

            for (i = 0; i < sections; i++)
                faces.push(new Face3D(center, vertices[i], vertices[(i+1) % sections], null, centeruv, uvs[i], uvs[i+1]));
        }
    }
}