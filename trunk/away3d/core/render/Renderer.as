package away3d.core.render
{
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import flash.geom.*;
    import flash.display.*;

    public class Renderer
    {
        public static function get BASIC():IRenderer
        {
            return new BasicRenderer();
        }

        public static function get CORRECT_Z_ORDER():IRenderer
        {
            return new QuadrantRenderer(new AnotherRivalFilter);
        }

        public static function get INTERSECTING_OBJECTS():IRenderer
        {
            return new QuadrantRenderer(new QuadrantRiddleFilter, new AnotherRivalFilter);
        }
    }
}
