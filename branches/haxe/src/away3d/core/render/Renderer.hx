package away3d.core.render;

    import away3d.core.filter.*;

    /**
    * A static class for an easy access to the most useful renderers.
    */
    class Renderer
     {
        public var BASIC(getBASIC, null) : IRenderer
        ;
        public var CORRECT_Z_ORDER(getCORRECT_Z_ORDER, null) : IRenderer
        ;
        public var INTERSECTING_OBJECTS(getINTERSECTING_OBJECTS, null) : IRenderer
        ;
        /**
        * Fastest and simplest renderer, useful for many applications.
        * 
        * @see away3d.core.render.BasicRenderer
        */
        
        /**
        * Fastest and simplest renderer, useful for many applications.
        * 
        * @see away3d.core.render.BasicRenderer
        */
        public static function getBASIC():IRenderer
        {
            return new BasicRenderer();
        }
        
        /** Perform reordering of triangles after sorting to guarantee their correct rendering.
        * 
        * @see away3d.core.render.QuadrantRenderer
        * @see away3d.core.render.AnotherRivalFilter
        */
        public static function getCORRECT_Z_ORDER():IRenderer
        {
            return new QuadrantRenderer(new AnotherRivalFilter());
        }

        /**
        * Perform triangles splitting to correctly render scenes with intersecting objects.
        * 
        * @see away3d.core.render.QuadrantRenderer
        * @see away3d.core.render.QuadrantRiddleFilter
        * @see away3d.core.render.AnotherRivalFilter
        */
        public static function getINTERSECTING_OBJECTS():IRenderer
        {
            return new QuadrantRenderer(new QuadrantRiddleFilter(), new AnotherRivalFilter());
        }
    }

