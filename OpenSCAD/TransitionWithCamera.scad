$fn = 100;
inch = 25.4;

include <RocketCouplers.scad>

bt60adj = 0.0;
bt70adj = 0.0;

r1 = bt60id / 2 - bt60adj;
h1 = 1.0*inch;
wall1 = 3.0;
r2a = bt60od/2;
r2b = bt70od/2;
h2 = 1.5*inch;
wall2 = 2.0;
r3 = bt70id / 2 - bt70adj;

module CameraU838()
{
    w1 = 0.94*inch;
    w2 = 1.05*inch;
    h1 = 0.40*inch;
    h2 = 0.50*inch;
    dx = (w1-h1)/2;
    r1 = 1.5*inch;
    
    intersection()
    {
        {
            rotate([-90,0,-90])
            linear_extrude(3.0*inch)
            {
                translate([dx,0])
                circle(h1/2);
                translate([-dx,0])
                circle(h1/2);
                square([2*dx,h1],center=true);
            }
        }
        translate([r1,0,-1.0*inch])
        cylinder(r=r1,h=2*inch);
    }
}


CameraU838();
/*
hollowCylinderAsBase(r1,wall1,h1);
translate([0,0,h1])
hollowConeWithDrop(r2a,r2b,wall2,h2);
*/
