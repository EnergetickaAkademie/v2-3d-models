$fn = 60;

// --- Customization ---
render_mode = 2; // [0:Base Tray, 1:Snap Lid, 2:Both (Exploded), 3:2D Paper Template]

enable_usb_out_1 = true;
enable_usb_out_2 = true;
enable_usb_out_3 = true;
enable_gpio_port = false;
enable_prog_port = false;
enable_status_led = true;

led_pos = [-40.0, 112.5];
ch224k_slot_depth = 1.0;

// --- Case Limits ---
case_min_x = -55.00; 
case_max_x = 99.84;
case_min_y = 75.84;
case_max_y = 148.84;

case_width = case_max_x - case_min_x;
case_length = case_max_y - case_min_y;

wall_thickness = 2.0;
base_thickness = 2.0;
total_internal_height = 22.6; 
fit_tolerance = -0.15;
explode_dist = (render_mode == 2) ? 30 : 0;
insert_hole_d = 2.5; 

// --- Top Wall Recess Parameters ---
recess_x = 7.0;
recess_w = 45.0; 
recess_y = 146.07; 
recess_wall_thickness = 1.0; 

// --- Heights ---
dsub_z = 6.75;
mb_standoff_h = 12.0;
db_standoff_h = 4.0;

mb_usb_z = base_thickness + mb_standoff_h + 3.2; 
ch_usb_z = base_thickness + db_standoff_h + 3.2; 

// --- Component Coordinates ---
h_mb = [
    [41.39, 80.39],
    [68.18, 94.62],
    [92.69, 138.94],
    [53.96, 139.07]
];

h_mb_supports = [
    [32.0, 110.0],
    [12.0, 125.0]
];

usb_out_x = [14.34, 29.34, 44.34];
prog_usb_x = 60.56;
dsub_y = 96.77; 

ch224k_pos = [-53, 119.34]; 
h_ch224k = [
    [ch224k_pos[0], ch224k_pos[1]],
    [ch224k_pos[0] + 24, ch224k_pos[1]],
    [ch224k_pos[0], ch224k_pos[1] - 14],
    [ch224k_pos[0] + 24, ch224k_pos[1] - 14]
];

xl1_pos = [-43, 145];
h_xl1 = [
    [xl1_pos[0], xl1_pos[1]],
    [xl1_pos[0] + 34, xl1_pos[1] - 20]
];

xl2_pos = [-43, 100]; 
h_xl2 = [
    [xl2_pos[0], xl2_pos[1]],
    [xl2_pos[0] + 34, xl2_pos[1] - 20]
];

hook_w = 10.0;
hook_h = 4.0;
hook_protrusion = 1.0;
tab_x1 = -20.0; 
tab_x2 = 75.0;  

// --- Connection Mechanisms ---
module battery_box_receiver_cutout() {
    cut_z = total_internal_height + base_thickness + 2.0; 
    tol = 0.3;
    base_x = case_min_x - wall_thickness;
    base_y = case_min_y - wall_thickness;
    
    // Front Receiver (Shifted Z to 2.0 to create the bottom endstop)
    translate([base_x - 4.1, base_y + 8.0 - tol - 0.25, 2.0]) 
    cube([2.1 + tol, 2.5 + 2*tol, cut_z - 2.0]); 
    
    translate([base_x - 2.0 - tol, base_y + 5.0 - tol - 0.5, 2.0]) 
    cube([2.1 + tol, 9.0 + 2*tol, cut_z - 2.0]); 

    // Back Receiver (Shifted Z to 2.0 to create the bottom endstop)
    translate([base_x - 4.1, base_y + 66.0 - tol - 0.25, 2.0]) 
    cube([2.1 + tol, 2.5 + 2*tol, cut_z - 2.0]); 
    
    translate([base_x - 2.0 - tol, base_y + 63.0 - tol - 0.5, 2.0]) 
    cube([2.1 + tol, 9.0 + 2*tol, cut_z - 2.0]); 
}

// --- 2D Case Profiles ---
module outer_profile() {
    difference() {
        union() {
            translate([case_min_x - wall_thickness, case_min_y - wall_thickness])
            square([case_width + 2*wall_thickness, case_length + 2*wall_thickness]);
            
            translate([case_min_x - wall_thickness - 4.0, case_min_y - wall_thickness + 3.0])
            square([4.0, 12.0]);
            
            translate([case_min_x - wall_thickness - 4.0, case_min_y - wall_thickness + 61.0])
            square([4.0, 12.0]);
        }
        
        translate([recess_x, recess_y - (wall_thickness - recess_wall_thickness)])
        square([recess_w, 50]);
    }
}

module lid_outer_profile() {
    difference() {
        translate([case_min_x - wall_thickness, case_min_y - wall_thickness])
        square([case_width + 2*wall_thickness, case_length + 2*wall_thickness]);
        
        translate([recess_x, recess_y - (wall_thickness - recess_wall_thickness)])
        square([recess_w, 50]);
    }
}

module inner_profile(tol=0) {
    difference() {
        translate([case_min_x - tol, case_min_y - tol])
        square([case_width + 2*tol, case_length + 2*tol]);
        
        translate([recess_x - wall_thickness + tol, recess_y - wall_thickness + tol])
        square([recess_w + 2*wall_thickness - 2*tol, 50]);
    }
}

// --- Modules ---
module pill(w, h, depth) {
    r = h/2;
    hull() {
        translate([-(w/2 - r), 0, 0]) cylinder(r=r, h=depth, center=true);
        translate([ (w/2 - r), 0, 0]) cylinder(r=r, h=depth, center=true);
    }
}

module dsub_cutout() {
    $fn = 64;
    sz = 17.04;
    cs = (sz/2) - 2.6;
    cs2 = (sz/2) - 4.095;
    scale([1.2, 1.2, 1.2]) hull(){
        translate([0,-cs,0]) cylinder(r=2.6, h=10, center=true);
        translate([0,cs,0]) cylinder(r=2.6, h=10, center=true);
        translate([3.28,-cs2,0]) cylinder(r=2.6, h=10, center=true);
        translate([3.28,cs2,0]) cylinder(r=2.6, h=10, center=true);
    }
}

module insert_standoff(pos, h) {
    translate([pos[0], pos[1], base_thickness])
    difference() {
        cylinder(d=5.5, h=h); 
        translate([0, 0, h - 4.5]) 
        cylinder(d=insert_hole_d, h=4.6); 
    }
}

module base_tray() {
    union() {
        difference() {
            linear_extrude(total_internal_height + base_thickness) outer_profile();
            
            translate([0, 0, base_thickness])
            linear_extrude(total_internal_height + 1) inner_profile();

            battery_box_receiver_cutout();

            if (enable_usb_out_1) translate([usb_out_x[0], recess_y - 1, mb_usb_z]) rotate([-90, 0, 0]) pill(9.5, 3.5, 20);
            if (enable_usb_out_2) translate([usb_out_x[1], recess_y - 1, mb_usb_z]) rotate([-90, 0, 0]) pill(9.5, 3.5, 20);
            if (enable_usb_out_3) translate([usb_out_x[2], recess_y - 1, mb_usb_z]) rotate([-90, 0, 0]) pill(9.5, 3.5, 20);

            if (enable_gpio_port) {
                translate([77.0, case_max_y, base_thickness + mb_standoff_h + 3.0]) 
                cube([30, 10, 8], center=true);
            }

            if (enable_prog_port) {
                translate([prog_usb_x, case_min_y + 1, mb_usb_z]) 
                rotate([90, 0, 0]) pill(9.5, 3.5, 20);
            }

            ch_usb_y = ch224k_pos[1] - 7;
            translate([case_min_x, ch_usb_y, ch_usb_z]) 
            rotate([90, 0, 90]) pill(9.5, 3.5, 15);

            translate([case_min_x - (ch224k_slot_depth / 2), ch_usb_y, base_thickness + db_standoff_h + 1.0]) 
            cube([ch224k_slot_depth, 20, 4.0], center=true);

            translate([case_max_x, dsub_y, dsub_z]) 
            rotate([0, -90, 0]) dsub_cutout();

            pocket_z = base_thickness + total_internal_height - 4;
            for(tx = [tab_x1, tab_x2]) {
                translate([tx, case_min_y, pocket_z])
                hull() {
                    translate([-(hook_w+1)/2, 0, -0.2]) cube([hook_w+1, 0.01, hook_h + 0.4]);
                    translate([-(hook_w+1)/2, -hook_protrusion - 0.3, 0.8]) cube([hook_w+1, 0.01, hook_h - 1.6]);
                }
                translate([tx, case_min_y, base_thickness + total_internal_height])
                hull() {
                    translate([-(hook_w+1)/2, 0, -0.1]) cube([hook_w+1, 0.01, 0.1]);
                    translate([-(hook_w+1)/2, -hook_protrusion - 0.3, -0.1]) cube([hook_w+1, 0.01, 0.1]);
                    translate([-(hook_w+1)/2, 0, hook_protrusion + 0.2]) cube([hook_w+1, 0.01, 0.1]);
                }
                
                translate([tx, case_max_y, pocket_z])
                hull() {
                    translate([-(hook_w+1)/2, 0, -0.2]) cube([hook_w+1, 0.01, hook_h + 0.4]);
                    translate([-(hook_w+1)/2, hook_protrusion + 0.3, 0.8]) cube([hook_w+1, 0.01, hook_h - 1.6]);
                }
                translate([tx, case_max_y, base_thickness + total_internal_height])
                hull() {
                    translate([-(hook_w+1)/2, 0, -0.1]) cube([hook_w+1, 0.01, 0.1]);
                    translate([-(hook_w+1)/2, hook_protrusion + 0.3, -0.1]) cube([hook_w+1, 0.01, 0.1]);
                    translate([-(hook_w+1)/2, 0, hook_protrusion + 0.2]) cube([hook_w+1, 0.01, 0.1]);
                }
            }
        }

        for (p = h_mb) insert_standoff(p, mb_standoff_h);
        for (p = h_ch224k) insert_standoff(p, db_standoff_h);
        for (p = h_xl1) insert_standoff(p, db_standoff_h);
        for (p = h_xl2) insert_standoff(p, db_standoff_h);
        
        for (p = h_mb_supports) {
            translate([p[0], p[1], base_thickness])
            cylinder(d=5.5, h=mb_standoff_h);
        }
    }
}

module snap_lid() {
    translate([0, 0, base_thickness + total_internal_height + explode_dist])
    difference() {
        union() {
            linear_extrude(wall_thickness) lid_outer_profile();

            translate([0, 0, -5])
            linear_extrude(5)
            difference() {
                inner_profile(fit_tolerance);
                inner_profile(fit_tolerance - wall_thickness);
            }

            for(tx = [tab_x1, tab_x2]) {
                translate([tx, case_min_y + fit_tolerance, -4])
                hull() {
                    translate([-hook_w/2, 0, 0]) cube([hook_w, wall_thickness, hook_h]);
                    translate([-hook_w/2, -hook_protrusion, 1]) cube([hook_w, 0.01, hook_h-2]);
                }
                translate([tx, case_max_y - fit_tolerance, -4])
                hull() {
                    translate([-hook_w/2, -wall_thickness, 0]) cube([hook_w, wall_thickness, hook_h]);
                    translate([-hook_w/2, hook_protrusion, 1]) cube([hook_w, 0.01, hook_h-2]);
                }
            }

            u_slot_w = 12.0;
            mb_tab_drop = total_internal_height + base_thickness - mb_usb_z;
            clamp_depth = 4.0;
            
            if (enable_usb_out_1) {
                translate([usb_out_x[0] - u_slot_w/2, recess_y - wall_thickness - clamp_depth, -mb_tab_drop])
                cube([u_slot_w, clamp_depth, mb_tab_drop]);
            }
            if (enable_usb_out_2) {
                translate([usb_out_x[1] - u_slot_w/2, recess_y - wall_thickness - clamp_depth, -mb_tab_drop])
                cube([u_slot_w, clamp_depth, mb_tab_drop]);
            }
            if (enable_usb_out_3) {
                translate([usb_out_x[2] - u_slot_w/2, recess_y - wall_thickness - clamp_depth, -mb_tab_drop])
                cube([u_slot_w, clamp_depth, mb_tab_drop]);
            }

            if (enable_prog_port) {
                translate([prog_usb_x - u_slot_w/2, case_min_y, -mb_tab_drop])
                cube([u_slot_w, clamp_depth, mb_tab_drop]);
            }
            
            ch_tab_drop = total_internal_height + base_thickness - ch_usb_z;
            ch_usb_y = ch224k_pos[1] - 7;
            translate([case_min_x, ch_usb_y - u_slot_w/2, -ch_tab_drop])
            cube([clamp_depth, u_slot_w, ch_tab_drop]);
        }

        mb_tab_z_local = -(total_internal_height + base_thickness - mb_usb_z);
        if (enable_usb_out_1) translate([usb_out_x[0], recess_y, mb_tab_z_local]) rotate([-90, 0, 0]) pill(9.5, 3.5, 20);
        if (enable_usb_out_2) translate([usb_out_x[1], recess_y, mb_tab_z_local]) rotate([-90, 0, 0]) pill(9.5, 3.5, 20);
        if (enable_usb_out_3) translate([usb_out_x[2], recess_y, mb_tab_z_local]) rotate([-90, 0, 0]) pill(9.5, 3.5, 20);

        if (enable_prog_port) {
            translate([prog_usb_x, case_min_y, mb_tab_z_local]) 
            rotate([90, 0, 0]) pill(9.5, 3.5, 20);
        }
        
        ch_tab_z_local = -(total_internal_height + base_thickness - ch_usb_z);
        ch_usb_y = ch224k_pos[1] - 7;
        translate([case_min_x, ch_usb_y, ch_tab_z_local]) 
        rotate([90, 0, 90]) pill(9.5, 3.5, 20);

        if (enable_status_led) {
            translate([led_pos[0], led_pos[1], 0])
			union(){
				cube([6.0, 6.0, 3.2], center=true);
				cylinder(h=2, d=10, center=true);
			}
        }
    }
}

module paper_template() {
    difference() {
        inner_profile();
        
        for (p = h_mb) translate([p[0], p[1]]) circle(d=insert_hole_d);
        for (p = h_ch224k) translate([p[0], p[1]]) circle(d=insert_hole_d);
        for (p = h_xl1) translate([p[0], p[1]]) circle(d=insert_hole_d);
        for (p = h_xl2) translate([p[0], p[1]]) circle(d=insert_hole_d);
    }
}

if (render_mode == 0 || render_mode == 2) {
    color("DarkSlateGray") base_tray();
}
if (render_mode == 1 || render_mode == 2) {
    color("LightGray") snap_lid();
}
if (render_mode == 3) {
    color("black") paper_template();
}