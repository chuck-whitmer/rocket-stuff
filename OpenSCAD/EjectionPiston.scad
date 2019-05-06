$fn = 200;
inch = 25.4;

include <RocketCouplers.scad>
bt80adj = 0.3;
bt70adj = 0.3;
bt60adj = 0.2; // Fits nicely with Prusa.
bt55adj = 0.2;
bt50adj = 0.2;

r1 = bt60id/2 - bt60adj; 
wall = 3;
h1 = 0.5*inch;
h2 = 0.5*inch;
h3 = 1.0*inch;

translate([0,0,h1+h2-1])
linear_extrude(h3)
for (angle=[0,90,180,270])
{
    rotate(angle)
    offset(1)
    intersection()
    {
        translate([r1-0.25*inch,-0.25*inch])
        square(0.6*inch);
        difference()
        {
            rr = r1 - 1.0;
            circle(rr);
            circle(rr-wall+2.0);
        }
    }
}

difference()
{
    hollowCylinderAsBase(r1,r1-1,h1);
    translate([r1/3,0,2])
    cylinder(r=1,h=h1);
}
translate([0,0,h1])
hollowCylinderWithDrop(r1,wall,h2);

