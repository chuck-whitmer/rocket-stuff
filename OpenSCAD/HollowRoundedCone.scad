$fn = 200;
inch = 25.4;

include <RocketCouplers.scad>
bt60adj = 0.0;

rOut = bt60od/2;
rIn = bt60id/2 - bt60adj;
rTip = 7;
wall = 2.0;

slipIn = 0.75*inch;
height=4*inch; 

dr = rOut-rIn;

module theHull()
{
    hull()
    {
        translate([0,slipIn+height-rTip])
        circle(rTip);    
        polygon([
            [rIn,slipIn-dr],
            [rOut,slipIn],
            [-rOut,slipIn],
            [-rIn,slipIn-dr]
        ]);
    }
}

rotate_extrude()
intersection()
{
    union()
    {
        difference()
        {
            theHull();
            translate([-wall,-0.1])
            theHull();
        }

        intersection()
        {
            theHull();
            translate([0,slipIn+height-wall])
            rotate(-50)
            translate([-2*rOut,0])
            square(4*rOut);
        }

        polygon([
            [rIn-wall,0],
            [rIn-wall,slipIn],
            [rIn,slipIn],
            [rIn,0.5],
            [rIn-0.5,0]
            ]);
    }
    square([2*rOut,2*height]);
}
