// Bottle Parameters (in mm)
total_height = 80;
max_diameter = 60;
neck_opening_diameter = 25;
wall_thickness = 2;

// Advanced Design Parameters
base_diameter = 40;
widest_point_height = 25;
neck_height = 10;
$fn = 200;

module bottle() {
    r_max = max_diameter / 2;
    r_neck_inner = neck_opening_diameter / 2;
    r_neck_outer = r_neck_inner + wall_thickness;
    r_base_outer = base_diameter / 2;
    r_base_inner = r_base_outer - wall_thickness;
    r_max_inner = r_max - wall_thickness;

    rotate_extrude(angle=360) {
        polygon(points=[
            // Outer profile
            [0, 0],
            [r_base_outer, 0],
            [r_max, widest_point_height],
            [r_neck_outer, total_height - neck_height],
            [r_neck_outer, total_height],
            
            // Inner profile
            [r_neck_inner, total_height],
            [r_neck_inner, total_height - neck_height],
            [r_max_inner, widest_point_height],
            [r_base_inner, wall_thickness],
            [0, wall_thickness]
        ]);
    }
}

bottle();

module slotted_stick(
    height = 70,
    outer_diameter = 16,
    inner_diameter = 13.5,
    base_thickness = 2,
    top_thickness = 10,
    slit_width = 2,
    slit_start_height = 5
) {
    $fn = 60;
    r_outer = outer_diameter / 2;
    r_inner = inner_diameter / 2;
    slit_height = height - slit_start_height - top_thickness;
    
    difference() {
        cylinder(h=height, r=r_outer);
        
        translate([0, 0, base_thickness])
            cylinder(h=height, r=r_inner);
        
        translate([0, 0, slit_start_height + slit_height/2]) {
            cube([outer_diameter + 2, slit_width, slit_height], center=true);
            cube([slit_width, outer_diameter + 2, slit_height], center=true);
        }
    }
}

//slotted_stick();