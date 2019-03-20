$fn = 200;
inch = 25.4;

include <RocketCouplers.scad>

r1 = bt70od/2 + 0.3; // 0.3 for 70 and 80. 0.2 for 50 and 55.
wall = 3;
height = 0.5*inch;

translate([0,0,height-1])
linear_extrude(1.0*inch)
for (angle=[0,120,240])
{
    rotate(angle)
    offset(1)
    intersection()
    {
        translate([r1-0.25*inch,-0.25*inch])
        square(0.5*inch);
        difference()
        {
            rr = r1 + 1.0;
            circle(rr+wall-2.0);
            circle(rr);
        }
    }
}

hollowCylinderAsBase(r1+wall,wall,height);
