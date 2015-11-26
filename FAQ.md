# Frequently Asked Questions #

1. How do I create a group of objects?
  * Use ObjectContainer3D
```
var group:ObjectContainer3D = new ObjectContainer3D(sphere, cube, mesh);
```

2. How do I remove object from a group?
  * Use ObjectContainer3D.removeChild() method
```
var group:ObjectContainer3D = new ObjectContainer3D(sphere, cube, mesh);
group.removeChild(cube);
```

