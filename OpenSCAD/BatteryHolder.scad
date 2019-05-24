$fn = 200;
inch = 25.4;

include <RocketCouplers.scad>
bt70adj = 0.0;
couplingTube = 0.03*inch;

batteryWidth = 0.70*inch;
batteryHeight = 1.05*inch;

r4 = bt70id/2 - bt70adj;
//r4 = bt70id/2 - bt70adj - couplingTube;
wall = r4-5;
cutoutLength = bt70od;
cutoutWidth = batteryWidth;

h1 = 7;
h0 = 3;
flatLen = sqrt(4*r4*r4-batteryWidth*batteryWidth);
flatWidth = bt70id-20;

intersection()
{
    difference()
    {
        hollowCylinderAsBase(r4,wall,h1);
        translate([-cutoutLength/2,-cutoutWidth/2,h0])
        cube([cutoutLength,cutoutWidth,h1]);
    }
    cube([flatLen,flatWidth,2*h1],center=true);
}

postR = (flatWidth - batteryWidth)/4;
postH = batteryHeight;
dx = sqrt(4*r4*r4 - flatWidth*flatWidth)/2 - postR;
dy = flatWidth/2 - postR;

translate([0,0,h0])
for (i=[-1,1])
for (j=[-1,1])    
{
    translate([i*dx,j*dy,0])
    cylinder(r=postR,h=postH);
}
