$fn = 60;

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

s1 = [65, 135];
s2 = [90, 135];

disp_w = 51.5; 
disp_h = 20; 
bar_w = 26.5;  
bar_h = 11.5;  
enc_hole_d = 7.5; 

case_min_x = 16; 
case_max_x = 132; 
case_min_y = 70;
case_max_y = 143;

case_width = case_max_x - case_min_x;
case_length = case_max_y - case_min_y;
wall_thickness = 2;

// --- Z-Axis Hardware Stack (Bottom Up) ---
dsub_body_thickness = 12.5; 
dsub_clearance_to_floor = 1.0; 

standoff_h = dsub_body_thickness + dsub_clearance_to_floor;
pcb_thickness = 1.6;

// Absolute Z-height of the physical D-Sub center
dsub_center_offset = -(dsub_body_thickness / 2); 
dsub_absolute_z = wall_thickness + standoff_h + dsub_center_offset; 

// --- Clamshell Split Line ---
// Positive value moves the seam higher up the connector
split_offset = 2.5; 
split_z = dsub_absolute_z + split_offset; 

display_height_above_pcb = 10.0; 
total_internal_height = standoff_h + pcb_thickness + display_height_above_pcb; 

// --- Lap Joint (Lip) Parameters ---
lip_height = 3.0; 
lip_thickness = 1.0; 
fit_tolerance = 0.05; 

dsub_wide_side_up = false; 

render_mode = 2; 
explode_dist = (render_mode == 2) ? 20 : 0; 


module dsub(sc,sz,dp){
    $fn=64;
    cs=(sz/2)-2.6;
    cs2=(sz/2)-4.095;
    ns=(sz/2)+4.04;
    translate([1.66,-ns,0]) cylinder(r=1.6,h=10);
    translate([1.66,ns,0]) cylinder(r=1.6,h=10);
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

module top_shell() {
    translate([0, 0, split_z + explode_dist])
    union() {
        difference() {
            translate([case_min_x - wall_thickness, case_min_y - wall_thickness, 0])
                cube([case_width + 2*wall_thickness, case_length + 2*wall_thickness, total_internal_height - split_z + wall_thickness]);
            
            translate([case_min_x, case_min_y, -0.1])
                cube([case_width, case_length, total_internal_height - split_z + 0.1]);

            // D-Sub Cutouts (Shifted down locally to account for raised split line)
            translate([case_min_x, dsub1_pos[1], -split_offset]) 
                rotate([0, -90, 0]) oriented_dsub(dsub_wide_side_up);
            
            translate([case_max_x, dsub2_pos[1], -split_offset]) 
                rotate([0, 90, 0]) oriented_dsub(!dsub_wide_side_up);

            roof_z = total_internal_height - split_z + wall_thickness / 2;
            translate([led1_pos[0], led1_pos[1], roof_z]) cube([disp_w, disp_h, wall_thickness * 3], center=true);
            translate([led2_pos[0], led2_pos[1], roof_z]) cube([disp_w, disp_h, wall_thickness * 3], center=true);
            translate([led3_pos[0], led3_pos[1], roof_z]) cube([bar_w, bar_h, wall_thickness * 3], center=true);
            translate([led4_pos[0], led4_pos[1], roof_z]) cube([bar_w, bar_h, wall_thickness * 3], center=true);
            translate([enc1_pos[0], enc1_pos[1], roof_z - wall_thickness]) cylinder(d=enc_hole_d, h=wall_thickness * 3);
            translate([enc2_pos[0], enc2_pos[1], roof_z - wall_thickness]) cylinder(d=enc_hole_d, h=wall_thickness * 3);
        }

        difference() {
            translate([case_min_x - lip_thickness + fit_tolerance, case_min_y - lip_thickness + fit_tolerance, -lip_height]) 
                cube([case_width + (2*lip_thickness) - (2*fit_tolerance), case_length + (2*lip_thickness) - (2*fit_tolerance), lip_height + 0.1]);
            
            translate([case_min_x, case_min_y, -(lip_height + 1)]) 
                cube([case_width, case_length, lip_height + 2]);

            // Ensure lip doesn't block the D-Subs at the new offset
            translate([case_min_x, dsub1_pos[1], -split_offset]) rotate([0, -90, 0]) oriented_dsub(dsub_wide_side_up);
            translate([case_max_x, dsub2_pos[1], -split_offset]) rotate([0, 90, 0]) oriented_dsub(!dsub_wide_side_up);
        }
    }
}

module bottom_shell() {
    difference() {
        translate([case_min_x - wall_thickness, case_min_y - wall_thickness, 0])
            cube([case_width + 2*wall_thickness, case_length + 2*wall_thickness, split_z]);
        
        translate([case_min_x, case_min_y, wall_thickness])
            cube([case_width, case_length, split_z]);
        
        // D-Sub Cutouts (Anchored to absolute physical Z, regardless of split)
        translate([case_min_x, dsub1_pos[1], dsub_absolute_z]) 
            rotate([0, -90, 0]) oriented_dsub(dsub_wide_side_up);
            
        translate([case_max_x, dsub2_pos[1], dsub_absolute_z]) 
            rotate([0, 90, 0]) oriented_dsub(!dsub_wide_side_up);

        translate([case_min_x - lip_thickness, case_min_y - lip_thickness, split_z - lip_height - 0.2])
            difference() {
                cube([case_width + (2*lip_thickness), case_length + (2*lip_thickness), lip_height + 0.5]); 
                translate([lip_thickness, lip_thickness, -1]) cube([case_width, case_length, lip_height + 2]); 
            }
    }
    
    standoff(h1);
    standoff(h2);
    standoff(h3);
    standoff(h4);
    
    standoff(s1);
    standoff(s2);
}

module standoff(pos) {
    translate([pos[0], pos[1], wall_thickness])
    difference() {
        cylinder(d=6, h=standoff_h); 
        translate([0,0,-1]) cylinder(d=2.2, h=standoff_h + 2);
    }
}

if (render_mode == 0 || render_mode == 2) {
    color("DarkSlateGray") bottom_shell();
}

if (render_mode == 1 || render_mode == 2) {
    color("LightGray") top_shell();
}