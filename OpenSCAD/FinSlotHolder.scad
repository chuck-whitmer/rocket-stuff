$fn = 200;
inch = 25.4;

include <RocketCouplers.scad>

wall = 3;
baseHeight = 20;

bt60adj = 0.0; // Zero adjust works on Prusa. 0.15 layer height.  20% infill.
rOut = bt60od/2;
rIn = bt60id/2 - bt60adj;

width = 2*rOut/sqrt(3);
h = rOut*(1-sqrt(2/3)) + (rOut-rIn);

echo(width, rOut, h);

yBottom = sqrt(3)*width/2 - 2* rOut;

difference()
{
    union()
    {
        linear_extrude(baseHeight)
        {
            for (angle=[0,120,240])
            {
                rotate(angle)
                translate([-width/2,yBottom])
                square([width,h]);
            }
        }

        rotate_extrude()
        translate([rIn-wall,0])
        square([wall,2*baseHeight]);
    }   
    translate([0,0,baseHeight])
    linear_extrude(2*baseHeight)
    {
        for (angle=[0,120,240])
        {
            rotate(angle)
            translate([-0.125*inch,0])
            square([0.25*inch,2*rOut]);
        }
    }
}