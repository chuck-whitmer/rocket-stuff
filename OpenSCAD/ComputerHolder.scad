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

h1 = 7;

intersection()
{
    difference()
    {
        hollowCylinderAsBase(r4,wall,h1);
        translate([-cutoutLength/2,-cutoutWidth/2,2])
        cube([cutoutLength,cutoutWidth,h1]);
    }
    cube([cutoutLength+3.6,bt70id-20,2*h1],center=true);
}
