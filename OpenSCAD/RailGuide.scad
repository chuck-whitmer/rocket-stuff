$fn = 200;
inch = 25.4;

include <RocketCouplers.scad>

r1 = bt80od/2;
r2 = bt80od/2;
label = "80/80";

fontSize = 6;

x5 = 0.305*inch + r2 - r1;
x4 = x5-0.08*inch;
x1 = x5-0.31*inch; // Spacing between guide tracks.  Was 0.29
x2 = x1+0.075*inch;
x3 = (2*x2+x4)/3;  // Depth of gap
y1 = 0.13/2*inch;
y2 = 0.23/2*inch; // Width of rail guide. Was 0.245
y3 = 0.40/2*inch;
y3a = 0.45/2*inch; // Was also 0.40/2
y4 = 0.04*inch;
theta = 38;
shortHeight1 = 0.46*inch;
wall = 0.08*inch;
wallWidth = 0.5*inch;
drop = (x5-wall)*tan(theta);
cutHeight = max(drop+shortHeight1,0.75*inch);
shortHeight = cutHeight-drop;



dc = x5-x4;
hc = y3-y4;
translate([(x4+x5)/2,0,shortHeight+tan(theta)*(x5-x4)])
rotate([90])
{
    translate([0,0,y4])
    {
        cylinder(d=dc, h=hc);
        translate([-dc/2,-dc,0])
        cube([dc,dc,hc]);
    }
    translate([0,0,-y3])
    {
        cylinder(d=dc, h=hc);
        translate([-dc/2,-dc,0])
        cube([dc,dc,hc]);
    }
}

difference()
{
    linear_extrude(height=1*inch+x5)
    {
        intersection()
        {
            square(wallWidth,center=true);
            translate([-r1,0])
            difference()
            {
                circle(r=r1+wall);
                circle(r=r1);
            }
        }
        pts = [
            [0,y1],
            [x1,y1],
            [x1,y3a],
            [x2,y3a],
            [x2,y2],
            [x4,y2],
            [x4,y3],
            [x5,y3],
            [x5,y4],
            [x3,y4],
            [x3,-y4],
            [x5,-y4],
            [x5,-y3],
            [x4,-y3],
            [x4,-y2],
            [x2,-y2],
            [x2,-y3a],
            [x1,-y3a],
            [x1,-y1],
            [0,-y1]];
        polygon(pts);
    }

    translate([x5,0,shortHeight])
    rotate([0,theta,0])
    translate([-2*inch,-2*inch,0])
    cube(4*inch);

    echo(cutHeight);
    translate([0,0,cutHeight])
    translate([-2*inch,-2*inch,0])
    cube(4*inch);
    
    M = [
    [ 1, 0, 0, 0],
    [ 0, 1, 0, 0],
    [-1, 0, 1, 0],
    [ 0, 0, 0, 1]
    ];
    
    
    multmatrix(M)
    rotate([0,-90,0])
    translate([cutHeight/2,-fontSize/2,-wall/2])
    linear_extrude(wall)
    text(text=label,font="Times New Roman",size=fontSize,halign="center");
}

