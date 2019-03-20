$fn = 200;
inch = 25.4;

include <RocketCouplers.scad>
bt60adj = 0.2;

rOut = bt60od/2;
rIn = bt60id/2 - bt60adj;
rTip = 7;
rScrew = 1;

slipIn = 0.75*inch;
height=4*inch; 

dr = rOut-rIn;

rotate_extrude()
union()
{
    polygon([
        [rScrew,0],
        [rIn-1,0],
        [rIn,1],
        [rIn,slipIn-dr],
        [rScrew,slipIn-dr]
        ]);
hull()
{
    polygon([
        [rIn,slipIn-dr],
        [rOut,slipIn],
        [0,slipIn],
        [0,slipIn-dr],
        ]);

    intersection()
    {
    translate([0,slipIn+height-rTip])
    circle(rTip);    
    square(height+slipIn+10);    
    }
}
}
