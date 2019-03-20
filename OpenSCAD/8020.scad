$fn=100;
inch = 25.4;

module Extrusion_8020(length)
{
    color("silver")
    linear_extrude(length)
    difference()
    {
    translate([-0.5*inch,-0.5*inch])
    square(1.0 * inch);    
    notch = 0.256*inch;
        union()
        {
            for (a = [0,90,180,270])
            {
                rotate([0,0,a])
                {
                    translate([-notch/2.0,7])
                      square([notch,0.4*inch]);
                    translate([0,9])
                    scale([1.3,0.5])
                    circle(5);
                }
            }
            circle(3);
        }
    }
}

Extrusion_8020(150);