$fn = 200;
inch = 25.4;

include <RocketCouplers.scad>
bt80adj = 0.3;
bt70adj = 0.3;
bt60adj = 0.3;
bt55adj = 0.2;
bt50adj = 0.2;

r1 = bt60id/2 - bt60adj;
r2 = bt60od/2;
r3 = bt80od/2;
r4 = bt80id/2 - bt80adj;
wall = 2.0;

h1 = 0.75*inch;
h2 = 2*inch;
h3 = 0.75*inch;

hole = 3.0;

difference()
{
    union()
    {
        hollowCylinderAsBase(r4,wall,h1);
        translate([0,0,h1])
        hollowConeWithDrop(r3,r2,wall,h2);
        translate([0,0,h1+h2])
        hollowCylinderWithDrop(r1,wall,h3);
    }
    if (hole > 0)
    {
        translate([0,0,h2/2+h1])
        rotate([0,90,0])
        cylinder(d=hole,h=max(r1,r4));
    }
}

