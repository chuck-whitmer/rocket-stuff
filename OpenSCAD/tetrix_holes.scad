drillDepth = 15;

module holes(nholes)
{
    smallR = 4.2/2; // Nominal 3.7 mm.  4.2 works on TAZ.
    largeR = 8.8/2; // Nominal 8.0 mm.  8.8 works on TAZ.
    offset = 8;
    
    translate([0,0,-drillDepth/2])
    cylinder(r=largeR,h=drillDepth);
    
    if (nholes > 0)
    {
        angle = 360/nholes;
        for (i=[0:nholes-1])
        {
            translate([offset*sin(i*angle),offset*cos(i*angle),-drillDepth/2])
            cylinder(r=smallR,h=drillDepth);
        }
    }
}

module ChannelHolePattern(length)
{
    n = ceil(length/64);
    if (length==32 || length==96 || length==160 || length==288|| length==416)
    {
        for (i=[0:n-2])
        {
            translate([64*i,0,0])
            holePattern();
        }
        translate([(n-1)*64+16,0,0])
        holes(8);
    }
    else
    {
        for (i=[0:n-1])
        {
            translate([64*i,0,0])
            holePattern();
        }
    }
}

module holePattern()
{
    translate([16,0,0])
    {
        holes(8);
        translate([16,0,0])
        {
            holes(0);
            translate([16,0,0])
            {
                holes(4);
                translate([16,0,0])
                holes(0);
            }
        }
    }
}

module TetrixChannel(length)
{
    color("silver")
    difference()
    {
        union()
        {
            rotate([-90,0,0])
            translate([-length/2,-16,-16])
            {
                translate([0,0,30])
                cube([length,32,2]);
                translate([0,2,0])
                rotate([90,0,0])
                cube([length,32,2]);
                cube([length,32,2]);
            }
        }
        translate([-length/2,0,16])
        ChannelHolePattern(length);
        translate([-length/2,16,0])
        rotate([90,0,0])
        ChannelHolePattern(length);
        translate([-length/2,-16,0])
        rotate([90,0,0])
        ChannelHolePattern(length);
    }
}

module slots(nholes, angle)
{
    smallR = 4.2/2; // Nominal 3.7 mm.  4.2 works on TAZ.
    largeR = 8.8/2; // Nominal 8.0 mm.  8.8 works on TAZ.
    offset = 8;
    delta = 0.02;
    
    translate([0,0,-drillDepth/2])
    cylinder(r=largeR,h=drillDepth);

    
    if (nholes > 0)
    {
        theta = 360/nholes;
        for (i=[0:nholes-1])
        {
            translate([0,0,-drillDepth/2])
            rotate([0,0,i*theta])
            minkowski()
            {
                difference()
                {
                    cylinder(r=offset+delta, h=delta);
                    translate([0,0,-delta/2])
                    {
                        cylinder(r=offset-delta, h=2*delta);
                        rotate([0,0,-angle/2])
                        translate([0,-(offset+2*delta),0])
                        cube([offset+2*delta,2*(offset+2*delta),2*delta]);
                        rotate([0,0,angle/2-180])
                        translate([0,-(offset+2*delta),0])
                        cube([offset+2*delta,2*(offset+2*delta),2*delta]);
                    }
                }
                cylinder(r=smallR,h=drillDepth);
            }    
        }
    }
}

module littleHoles(nholes)
{
    smallR = 4.2/2; // Nominal 3.7 mm.  4.2 works on TAZ.
    offset = 8;
    
    angle = 360/nholes;
    for (i=[0:nholes-1])
    {
        translate([offset*sin(i*angle),offset*cos(i*angle),-drillDepth/2])
        cylinder(r=smallR,h=drillDepth);
    }
}

module littleHoles2(nholes, ntotal)
{
    smallR = 4.2/2; // Nominal 3.7 mm.  4.2 works on TAZ.
    offset = 8;
    
    angle = 360/nholes;
    for (i=[0:ntotal-1])
    {
        translate([offset*sin(i*angle),offset*cos(i*angle),-drillDepth/2])
        cylinder(r=smallR,h=drillDepth);
    }
}

