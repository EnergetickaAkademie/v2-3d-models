$fn = 60;

render_mode = 2; // [0:Bottom Plate, 1:Top Hood, 2:Both (Exploded)]

led1_pos = [48.27, 123.06];
led2_pos = [100.57, 123.06];
led3_pos = [48.28, 91.06];
led4_pos = [100.57, 91.06];
dsub1_pos = [26.16, 90.93];
dsub2_pos = [122.68, 90.93];
h1 = [36.07, 76.71];
h2 = [114.43, 137.92];
h3 = [27.56, 137.92];
h4 = [114.43, 76.71];

disp_w = 51.5; 
disp_h = 20.0; 

case_min_x = 16; 
case_max_x = 134; 
case_min_y = 70;
case_max_y = 143;

case_width = case_max_x - case_min_x;
case_length = case_max_y - case_min_y;

wall_thickness = 2; 

base_thickness = 2.0;
dsub_body_thickness = 12.5; 
dsub_clearance_to_floor = 1.0; 

standoff_h = dsub_body_thickness + dsub_clearance_to_floor - 0.5;
standoff_minus_h = 1.0;
pcb_thickness = 1.6;

dsub_center_offset = -(dsub_body_thickness / 2);
dsub_z = base_thickness + standoff_h + dsub_center_offset; 

display_height_above_pcb = 6.0; 
total_internal_height = base_thickness + standoff_h + pcb_thickness + display_height_above_pcb;
fit_tolerance = -0.2; 

dsub_bot_tol = 0.0;
dsub_wide_side_up = false; 

explode_dist = (render_mode == 2) ? 25 : 0;
dsub_bot_left_oversize = 1.0;
dsub_bot_right_oversize = 2.0; 

hook_w = 10.0;
hook_t = 1.6;
hook_h = 10.0;
hook_protrusion = 1.2; 

x1 = case_min_x + (case_width * 0.33);
x2 = case_min_x + (case_width * 0.67);

module dsub(sc,sz,dp){
    $fn=64;
    cs=(sz/2)-2.6;
    cs2=(sz/2)-4.095;
    scale([sc,sc,sc]) hull(){
        translate([0,-cs,0]) cylinder(r=2.6,h=10);
        translate([0,cs,0]) cylinder(r=2.6,h=10);
        translate([3.28,-cs2,0]) cylinder(r=2.6,h=10);
        translate([3.28,cs2,0]) cylinder(r=2.6,h=10);
    }
}

module centered_dsub() {
    translate([-1.66, 0, 0])
    dsub(sc=1.2, sz=17.04, dp=10);
}

module oriented_dsub(flip_orientation) {
    translate([0, 0, -5]) 
    rotate([0, 0, flip_orientation ? 180 : 0]) 
    centered_dsub();
}

module yz_detent_wedge(dir) {
    hull() {
        translate([-hook_w/2, 0, 0]) cube([hook_w, 0.01, 5]);
        translate([-hook_w/2, dir * hook_protrusion, 2]) cube([hook_w, 0.01, 0.01]);
    }
}

module vertical_detent_hook(is_front) {
    if (is_front) {
        translate([-hook_w/2, 0, 0]) cube([hook_w, hook_t, hook_h]);
        translate([0, 0, hook_h - 5]) yz_detent_wedge(-1);
    } else {
        translate([-hook_w/2, -hook_t, 0]) cube([hook_w, hook_t, hook_h]);
        translate([0, 0, hook_h - 5]) yz_detent_wedge(1);
    }
}

module hood_inlets_and_chamfers() {
    clearance = 0.2;
    for(tx = [x1, x2]) {
        translate([tx, case_min_y, base_thickness + hook_h - 5])
            hull() {
                translate([-(hook_w+1)/2, 0, -clearance]) cube([hook_w+1, 0.01, 5 + 2*clearance]);
                translate([-(hook_w+1)/2, -hook_protrusion - clearance, 2]) cube([hook_w+1, 0.01, 0.01]);
            }
        translate([tx, case_min_y, 0])
            hull() {
                translate([-(hook_w+1)/2, 0, -0.1]) cube([hook_w+1, 0.01, 0.1]);
                translate([-(hook_w+1)/2, -hook_protrusion - 0.2, -0.1]) cube([hook_w+1, 0.01, 0.1]);
                translate([-(hook_w+1)/2, 0, hook_protrusion + 0.2]) cube([hook_w+1, 0.01, 0.1]);
            }

        translate([tx, case_max_y, base_thickness + hook_h - 5])
            hull() {
                translate([-(hook_w+1)/2, 0, -clearance]) cube([hook_w+1, 0.01, 5 + 2*clearance]);
                translate([-(hook_w+1)/2, hook_protrusion + clearance, 2]) cube([hook_w+1, 0.01, 0.01]);
            }
        translate([tx, case_max_y, 0])
            hull() {
                translate([-(hook_w+1)/2, 0, -0.1]) cube([hook_w+1, 0.01, 0.1]);
                translate([-(hook_w+1)/2, hook_protrusion + 0.2, -0.1]) cube([hook_w+1, 0.01, 0.1]);
                translate([-(hook_w+1)/2, 0, hook_protrusion + 0.2]) cube([hook_w+1, 0.01, 0.1]);
            }
    }
}

module top_spacer(pos) {
    spacer_len = display_height_above_pcb + standoff_minus_h;
    translate([pos[0], pos[1], total_internal_height - spacer_len])
    cylinder(d=6, h=spacer_len);
}

module top_hood() {
    translate([0, 0, explode_dist])
    union() {
        difference() {
            translate([case_min_x - wall_thickness, case_min_y - wall_thickness, 0])
                cube([case_width + 2*wall_thickness, case_length + 2*wall_thickness, total_internal_height + wall_thickness]);

            translate([case_min_x, case_min_y, -0.1])
                cube([case_width, case_length, total_internal_height + 0.1]);

            hood_inlets_and_chamfers();

            translate([case_min_x, dsub1_pos[1], dsub_z]) 
                rotate([0, -90, 0]) oriented_dsub(dsub_wide_side_up);
            translate([case_max_x, dsub2_pos[1], dsub_z]) 
                rotate([0, 90, 0]) oriented_dsub(!dsub_wide_side_up);

            translate([case_min_x - wall_thickness - 0.1, dsub1_pos[1] - 17, -0.1]) 
                cube([wall_thickness + 0.2, 34, dsub_z + 0.1]);
            translate([case_max_x - 0.1, dsub2_pos[1] - 17, -0.1]) 
                cube([wall_thickness + 0.2, 34, dsub_z + 0.1]);

            roof_z = total_internal_height;
            
            translate([led1_pos[0], led1_pos[1], roof_z + wall_thickness/2]) cube([disp_w, disp_h, wall_thickness * 3], center=true);
            translate([led2_pos[0], led2_pos[1], roof_z + wall_thickness/2]) cube([disp_w, disp_h, wall_thickness * 3], center=true);
            translate([led3_pos[0], led3_pos[1], roof_z + wall_thickness/2]) cube([disp_w, disp_h, wall_thickness * 3], center=true);
            translate([led4_pos[0], led4_pos[1], roof_z + wall_thickness/2]) cube([disp_w, disp_h, wall_thickness * 3], center=true);

            translate([case_min_x + case_width/2 - 7.5, case_max_y - 0.1, -0.1]) 
                cube([15, wall_thickness + 0.2, 1.5]);
        }
        
        top_spacer(h1);
        top_spacer(h2);
        top_spacer(h3);
        top_spacer(h4);
    }
}

module bottom_plate() {
    union() {
        translate([case_min_x + fit_tolerance, case_min_y + fit_tolerance, 0])
            cube([case_width - 2*fit_tolerance, case_length - 2*fit_tolerance, base_thickness]);

        difference() {
            union() {
                translate([case_min_x - wall_thickness, dsub1_pos[1] - 17 + fit_tolerance, 0])
                    cube([wall_thickness + fit_tolerance + 0.1 + dsub_bot_left_oversize, 34 - 2*fit_tolerance, dsub_z + dsub_bot_tol]);
                translate([case_max_x - fit_tolerance - 0.1 - dsub_bot_right_oversize, dsub2_pos[1] - 17 + fit_tolerance, 0])
                    cube([wall_thickness + fit_tolerance + 0.1 + dsub_bot_right_oversize, 34 - 2*fit_tolerance, dsub_z + dsub_bot_tol]);
            }
            translate([case_min_x, dsub1_pos[1], dsub_z]) rotate([0, -90, 0]) oriented_dsub(dsub_wide_side_up);
            translate([case_max_x, dsub2_pos[1], dsub_z]) rotate([0, 90, 0]) oriented_dsub(!dsub_wide_side_up);
        }
        
        for (tx = [x1, x2]) {
            translate([tx, case_min_y + fit_tolerance, base_thickness])
                vertical_detent_hook(true);
                
            translate([tx, case_max_y - fit_tolerance, base_thickness])
                vertical_detent_hook(false);
        }
        
        standoff(h1);
        standoff(h2);
        standoff(h3);
        standoff(h4);
    }
}

module standoff(pos) {
    translate([pos[0], pos[1], base_thickness])
    difference() {
        cylinder(d=6, h=standoff_h-standoff_minus_h);
        translate([0,0,1]) cylinder(d=2.2, h=standoff_h); 
    }
}

if (render_mode == 0 || render_mode == 2) {
    color("DarkSlateGray") bottom_plate();
}

if (render_mode == 1 || render_mode == 2) {
    color("LightGray") top_hood();
}