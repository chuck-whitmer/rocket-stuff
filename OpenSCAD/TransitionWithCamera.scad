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
h2 = 2.0*inch;
wall2 = 2.0;
r3 = bt70id / 2 - bt70adj;
h3 = 0.75*inch;

module CameraU838()
{
    w1 = 0.94*inch;
    w2 = 1.05*inch;
    h1 = 0.40*inch;
    h2 = 0.50*inch;
    dx1 = (w1-h1)/2;
    dx2 = (w2-h2)/2;
    b1 = 0.11*inch;
    b2 = 0.29*inch; // Top push back
    r1 = 1.5*inch;
    
    intersection()
    {
        union()
        {
            {
                rotate([-90,0,-90])
                linear_extrude(3.0*inch)
                {
                    translate([dx1,0])
                    circle(h1/2);
                    translate([-dx1,0])
                    circle(h1/2);
                    square([2*dx1,h1],center=true);
                }
            }
            intersection()
            {
                {
                    rotate([-90,0,-90])
                    linear_extrude(3.0*inch)
                    {
                        translate([dx2,0])
                        circle(h2/2);
                        translate([-dx2,0])
                        circle(h2/2);
                        square([2*dx2,h2],center=true);
                    }
                }
                translate([r1+b1,0,0])
                cylinder(r=r1,h=2*inch);
            }
            intersection()
            {
                {
                    rotate([-90,0,-90])
                    linear_extrude(3.0*inch)
                    {
                        translate([dx2,0])
                        circle(h2/2);
                        translate([-dx2,0])
                        circle(h2/2);
                        square([2*dx2,h2],center=true);
                    }
                }
                translate([r1+b2,0,-2.0*inch])
                cylinder(r=r1,h=2*inch);
            }
        }
        translate([r1,0,-1.0*inch])
        cylinder(r=r1,h=2*inch);
    }
}


difference()
{
    union()
    {
        hollowCylinderAsBase(r1,wall1,h1);
        translate([0,0,h1])
        hollowConeWithDrop(r2a,r2b,wall2,h2);
        translate([0,0,h1+h2])
        hollowCylinderWithDrop(r3,wall2,h3);
    }

   
    translate([-0.9*inch,0,1.2*inch])
    rotate([0,-57,0])
    translate([0.05*inch,0,0])
    CameraU838();
   
}