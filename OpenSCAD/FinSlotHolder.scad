$fn = 200;
inch = 25.4;

include <RocketCouplers.scad>

wall = 3;
baseHeight = 20;

bt60adj = 0.0; // Zero adjust works on Prusa. 0.15 layer height.  20% infill.
bt80adj = 0.0;
rOut = bt80od/2;
rIn = bt80id/2 - bt80adj;

width = 20;  // By fiat. Works for BT-60 and larger.
hPrime = max(rOut-1.5, sqrt(3)/2*width); // -1.5 to butt against ruler.
h = 2*rOut - hPrime - sqrt(rIn*rIn - (width/2)*(width/2));

echo(width, rOut, h);

yBottom = hPrime - 2*rOut;

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

        x1 = rIn-wall;
        x2 = rIn;
        rotate_extrude()
        polygon([[x1,0],[x2,0],[x2,2*baseHeight-1],
        [x2-1,2*baseHeight],[x1,2*baseHeight]]);
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