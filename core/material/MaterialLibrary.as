package away3d.core.material
{
    import away3d.core.proto.*;
    
    import flash.utils.Dictionary;
    
    public class MaterialLibrary
    {
        private var materials:Dictionary = new Dictionary();
    
        public function MaterialLibrary(init:Object = null):void
        {
            if (init != null)
                for (var name:String in init)
                    add(init[name], name);
        }
    
        public function add(material:IMaterial, name:String):IMaterial
        {
            this.materials[name] = material;

            return material;
        }
    
        public function getMaterialByName(name:String):IMaterial
        {
            return this.materials[name];
        }
    
        public function getTriangleMaterial(name:String):ITriangleMaterial
        {
            return this.materials[name] as ITriangleMaterial;
        }
    
    
    }
}
