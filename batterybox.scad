$fn = 60;

// --- Customization ---
render_mode = 2; // [0:Base Tray, 1:Snap Lid, 2:Both (Exploded)]

// --- Dimensions ---
pb_w = 155.0; // Powerbank Width (X)
pb_d = 73.0;  // Powerbank Depth (Y)
pb_h = 31.0;  // Powerbank Height (Z)

gap_w = 60.0; // Empty space for cable on the right side
wt = 2.0;     // Wall thickness
base_thickness = 2.0;
explode_dist = (render_mode == 2) ? 30 : 0;
fit_tolerance = 0.1;

// Hook variables
hook_w = 10.0;
hook_h = 4.0;
hook_protrusion = 1.0;
tab_x1 = (pb_w + 2*wt + gap_w) * 0.25 - 10; 
tab_x2 = (pb_w + 2*wt + gap_w) * 0.75 - 20; 

// =================== T‑PRONG PARAMETERS ===================
// General
prong_wall_extension_len = gap_w - 6.0;  
prong_jog_x_offset = 6.0;               
prong_neck_x_length = 4.0;              
prong_head_x_length = wt;               


// Front prong 
front_jog_height = 10.0;                
front_neck_y_start = 8.0;               
front_head_y_start = 4.5;               
front_neck_width = wt;                  
front_head_width = 9.0;                 

// Back prong 
back_jog_height = 10.0;                 
back_neck_y_start = 66.0;               
back_head_y_start = 62.5;               
back_neck_width = wt;
back_head_width = 9.0;
// ============================================================================

module base_tray() {
    end_x = pb_w + 2*wt + gap_w;
    
    prong_z_start = 2.75;
    prong_z_height = (pb_h + base_thickness) - prong_z_start - 8.0;
    
    union() {
        difference() {
            union() {
                // Main outer walls
                linear_extrude(pb_h + base_thickness) 
                difference() {
                    square([pb_w + 2*wt, pb_d + 2*wt]);
                    translate([wt, wt]) square([pb_w, pb_d]);
                }
                
                // Separating wall at the end of the powerbank
                translate([pb_w + wt, wt, base_thickness])
                cube([wt, pb_d, pb_h]);

                // --- FRONT WALL EXTENSION & T-PRONG ---
                translate([pb_w + 2*wt, 0, 0]) 
                    cube([prong_wall_extension_len + 3*wt, wt, pb_h + base_thickness]);
                translate([end_x - prong_jog_x_offset, 0, 0]) 
                    cube([wt, front_jog_height, pb_h + base_thickness]);
                translate([end_x - prong_neck_x_length, front_neck_y_start, prong_z_start]) 
                    cube([prong_neck_x_length, front_neck_width, prong_z_height]);
                translate([end_x - prong_head_x_length, front_head_y_start, prong_z_start]) 
                    cube([prong_head_x_length, front_head_width, prong_z_height]);

                // --- BACK WALL EXTENSION & T-PRONG ---
                translate([pb_w + 2*wt, pb_d + wt, 0]) 
                    cube([prong_wall_extension_len + 3*wt, wt, pb_h + base_thickness]);
                translate([end_x - prong_jog_x_offset, back_neck_y_start, 0]) 
                    cube([wt, back_jog_height, pb_h + base_thickness]);
                translate([end_x - prong_neck_x_length, back_neck_y_start, prong_z_start]) 
                    cube([prong_neck_x_length, back_neck_width, prong_z_height]);
                translate([end_x - prong_head_x_length, back_head_y_start, prong_z_start]) 
                    cube([prong_head_x_length, back_head_width, prong_z_height]);
                    
                // --- TOP CONTINUOUS WALL ---
                translate([end_x - 3*wt, 0, pb_h + base_thickness - 10.0])
                    cube([wt, pb_d + 2*wt, 10.0]);
            }
            
            // Wire slot pushed 5mm further into the middle of the wall
            translate([pb_w + wt - 1.0, pb_d + 2*wt - 22.0, base_thickness + pb_h - 25])
            cube([wt + 2.0, 15.0, 25.0]);

            // Snap fit pockets
            pocket_z = base_thickness + pb_h - 4;
            for(tx = [tab_x1, tab_x2]) {
                // Front wall inner pocket
                translate([tx, wt, pocket_z])
                hull() {
                    translate([-(hook_w+1)/2, 0, -0.2]) cube([hook_w+1, 0.01, hook_h + 0.4]);
                    translate([-(hook_w+1)/2, -hook_protrusion - 0.3, 0.8]) cube([hook_w+1, 0.01, hook_h - 1.6]);
                }
                translate([tx, wt, base_thickness + pb_h])
                hull() {
                    translate([-(hook_w+1)/2, 0, -0.1]) cube([hook_w+1, 0.01, 0.1]);
                    translate([-(hook_w+1)/2, -hook_protrusion - 0.3, -0.1]) cube([hook_w+1, 0.01, 0.1]);
                    translate([-(hook_w+1)/2, 0, hook_protrusion + 0.2]) cube([hook_w+1, 0.01, 0.1]);
                }
                
                // Back wall inner pocket
                translate([tx, pb_d + wt, pocket_z])
                hull() {
                    translate([-(hook_w+1)/2, 0, -0.2]) cube([hook_w+1, 0.01, hook_h + 0.4]);
                    translate([-(hook_w+1)/2, hook_protrusion + 0.3, 0.8]) cube([hook_w+1, 0.01, hook_h - 1.6]);
                }
                translate([tx, pb_d + wt, base_thickness + pb_h])
                hull() {
                    translate([-(hook_w+1)/2, 0, -0.1]) cube([hook_w+1, 0.01, 0.1]);
                    translate([-(hook_w+1)/2, hook_protrusion + 0.3, -0.1]) cube([hook_w+1, 0.01, 0.1]);
                    translate([-(hook_w+1)/2, 0, hook_protrusion + 0.2]) cube([hook_w+1, 0.01, 0.1]);
                }
            }
        }
        
        // Floor generation
        linear_extrude(base_thickness)
        square([pb_w + 2*wt, pb_d + 2*wt]);
    }
}

module snap_lid() {
    total_len = pb_w + 2*wt + gap_w;
    lid_len = total_len; 
    
    translate([0, 0, base_thickness + pb_h + explode_dist])
    difference() {
        union() {
            linear_extrude(wt) 
            square([lid_len, pb_d + 2*wt]);

            // Downward lip adjusted to fit between the outer side walls
            translate([total_len - 4.0, wt, -8.0])
            cube([4.0, pb_d, 8.0]);

            translate([0, 0, -5])
            linear_extrude(5)
            union() {
                difference() {
                    // Outer perimeter of the lip
                    translate([wt + fit_tolerance, wt + fit_tolerance])
                    square([pb_w - 2*fit_tolerance, pb_d - 2*fit_tolerance]);
                    
                    // Inner perimeter (cutout) using a custom lip thickness
                    lip_t = 0.8; 
                    translate([wt + fit_tolerance + lip_t, wt + fit_tolerance + lip_t])
                    square([pb_w - 2*fit_tolerance - 2*lip_t, pb_d - 2*fit_tolerance - 2*lip_t]);
                }
                
                translate([pb_w + 2*wt + fit_tolerance, wt + fit_tolerance])
                square([gap_w - 7.0, wt]);
                
                translate([pb_w + 2*wt + fit_tolerance, pb_d - fit_tolerance])
                square([gap_w - 7.0, wt]);
            }
            
            lip_t = 0.8; // Match the thickness of your thinned inner lip

            for(tx = [tab_x1, tab_x2]) {
                // Front hooks
                translate([tx, wt + fit_tolerance, -4])
                hull() {
                    // Changed 'wt' to 'lip_t' so the stem doesn't stick out
                    translate([-hook_w/2, 0, 0]) cube([hook_w, lip_t, hook_h]);
                    translate([-hook_w/2, -hook_protrusion, 1]) cube([hook_w, 0.01, hook_h-2]);
                }
                
                // Back hooks
                translate([tx, pb_d + wt - fit_tolerance, -4])
                hull() {
                    // Changed '-wt' to '-lip_t' and 'wt' to 'lip_t'
                    translate([-hook_w/2, -lip_t, 0]) cube([hook_w, lip_t, hook_h]);
                    translate([-hook_w/2, hook_protrusion, 1]) cube([hook_w, 0.01, hook_h-2]);
                }
            }
        }
        
        translate([(pb_w + wt) - 23.0 - 12.5, (pb_d + 2*wt)/2 - 7.5, -1])
        cube([15.0, 15.0, wt + 0.7]);
    }
}

if (render_mode == 0 || render_mode == 2) {
    color("DarkSlateGray") base_tray();
}
if (render_mode == 1 || render_mode == 2) {
    color("LightGray") snap_lid();
}