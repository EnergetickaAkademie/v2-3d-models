$fn = 60;

render_mode = 2; // [0:Bottom Plate, 1:Top Hood, 2:Both (Exploded)]

led1_pos = [45.85, 131.06];
led2_pos = [103.00, 131.06];
led3_pos = [45.85, 114.05];
led4_pos = [103.00, 114.05];
enc1_pos = [43.31, 82.30];
enc2_pos = [101.98, 82.30];
dsub1_pos = [26.16, 90.93];
dsub2_pos = [122.68, 90.93];
h1 = [33.15, 77.98];
h2 = [79.25, 90.93];
h3 = [67.69, 117.60];
h4 = [113.67, 77.85];

s1 = [35.15, 132];
s2 = [110, 132];

disp_w = 51.5;
disp_h = 20;
bar_w = 26.5;
bar_h = 11.5;
enc_hole_d = 7.5;

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

fit_tolerance = -0.2; //negative for oversize

dsub_bot_tol = 0.0;

dsub_wide_side_up = false;

explode_dist = (render_mode == 2) ? 25 : 0;

dsub_bot_left_oversize = 1.0;
dsub_bot_right_oversize = 2.0;


module dsub(sc,sz,dp){
    $fn=64;
    cs=(sz/2)-2.6;
    cs2=(sz/2)-4.095;
    //ns=(sz/2)+4.04;
    //translate([1.66,-ns,0]) cylinder(r=1.6,h=10);
    //translate([1.66,ns,0]) cylinder(r=1.6,h=10);
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

module top_hood() {
    translate([0, 0, explode_dist])
    difference() {
        translate([case_min_x - wall_thickness, case_min_y - wall_thickness, 0])
        cube([case_width + 2*wall_thickness, case_length + 2*wall_thickness, total_internal_height + wall_thickness]);

        translate([case_min_x, case_min_y, -0.1])
        cube([case_width, case_length, total_internal_height + 0.1]);

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
        translate([led3_pos[0], led3_pos[1], roof_z + wall_thickness/2]) cube([bar_w, bar_h, wall_thickness * 3], center=true);
        translate([led4_pos[0], led4_pos[1], roof_z + wall_thickness/2]) cube([bar_w, bar_h, wall_thickness * 3], center=true);
        translate([enc1_pos[0], enc1_pos[1], roof_z]) cylinder(d=enc_hole_d, h=wall_thickness * 3);
        translate([enc2_pos[0], enc2_pos[1], roof_z]) cylinder(d=enc_hole_d, h=wall_thickness * 3);

        translate([case_min_x + case_width/2 - 5, case_max_y - 0.1, -0.1])
        cube([10, wall_thickness + 0.2, base_thickness]);
    }
}

module bottom_plate() {
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

    standoff(h1);
    standoff(h2);
    standoff(h3);
    standoff(h4);

    standoff(s1);
    standoff(s2);
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
