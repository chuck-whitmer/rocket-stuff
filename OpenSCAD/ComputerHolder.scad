$fn = 200;
inch = 25.4;

include <RocketCouplers.scad>
bt70adj = 0.0;

couplingTube = 0.03*inch;

r4 = bt70id/2 - bt70adj;
//r4 = bt70id/2 - bt70adj - couplingTube;
wall = r4-5;
cutoutLength = 50.0 + 0.2; // Firm fit on Prusa
cutoutWidth = (0.56)*inch; // Firm fit on Prusa

m4TapDiameter = 3.3;
tapDepth = 8;

h1 = 7;

boundBox = [cutoutLength+3.6,bt70id-20,2*h1];
angle1 = acos(boundBox[0]/2/r4);
angle2 = asin(boundBox[1]/2/r4);
drillAngle = (angle1+angle2)/2;
echo(angle1,angle2);

intersection()
{
    difference()
    {
        hollowCylinderAsBase(r4,wall,h1);
        translate([-cutoutLength/2,-cutoutWidth/2,2])
        cube([cutoutLength,cutoutWidth,h1]);
        // M4(0.7) drill holes
        rotate([0,0,-drillAngle])
        translate([-r4-0.1,0,h1/2])
        rotate([0,90,0])
        cylinder(r=m4TapDiameter/2,h=tapDepth);
        rotate([0,0,-drillAngle])
        translate([r4+0.1,0,h1/2])
        rotate([0,-90,0])
        cylinder(r=m4TapDiameter/2,h=tapDepth);
    }
    cube(boundBox,center=true);
}
