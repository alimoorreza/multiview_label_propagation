srcDir                                = './'; % root directory

if ~exist([srcDir 'colors_all.mat'])
    %%%%%%%%%%%%%%%%%%            AVD         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    AVD_TOTAL_LABELS = 34;
    colors_avd  =  [ 
                      0.0 0.0 0.0;            % 1500) background (avd)
                      0.6 0.0 0.0;            % 1501) advil_liqui_gels (avd)
                      1.0 0.7 0.8;            % 1502) aunt_jemima_original_syrup (avd) ---> light pink
                      0.0 0.0 0.5;            % 1503) bumblebee_albacore (avd)
                      0.0 0.0 0.7;            % 1504) cholula_chipotle_hot_sauce (avd)
                      0.2 0.2 0.2;            % 1505) coca_cola_glass_bottle (avd)
                      0.0 0.0 0.0;            % 1506) crest_complete_minty_fresh (avd)
                      0.2 1.2 0.2;            % 1507) crystal_hot_sauce (avd)
                      0.0 0.0 0.0;            % 1508) expo_marker_red (avd)
                      0.0 0.0 0.0;            % 1509) hersheys_bar (avd)
                      0.4 0.4 0.4;            % 1510) honey_bunches_of_oats_honey_roasted (avd)
                      0.0 0.0 1.0;            % 1511) honey_bunches_of_oats_with_almonds (avd)
                      1.0 0.7 0.4;            % 1512) hunts_sauce (avd)
                      0.0 0.0 0.0;            % 1513) listerine_green (avd)
                      0.6 1.0 1.0;            % 1514) mahatma_rice (avd)
                      0.0 1.0 1.0;            % 1515) nature_valley_granola_thins_dark_chocolate (avd)
                      1.0 0.6 0.6;            % 1516) nutrigrain_harvest_blueberry_bliss (avd)
                      1.0 0.0 0.0;            % 1517) pepto_bismol (avd)
                      0.0 0.0 0.0;            % 1518) pringles_bbq (avd)
                      0.7 0.7 0.0;            % 1519) progresso_new_england_clam_chowder (avd)
                      1.0 0.4 0.7;            % 1520) quaker_chewy_low_fat_chocolate_chunk (avd)
                      0.0 0.0 0.0;            % 1521) red_bull (avd)
                      0.0 0.0 0.0;            % 1522) softsoap_clear (avd)
                      0.0 0.0 0.0;            % 1523) softsoap_gold (avd)
                      0.6 0.8 1.0;            % 1524) softsoap_white (avd)
                      1.0 0.6 0.7;            % 1525) spongebob_squarepants_fruit_snaks (avd)
                      0.0 0.0 0.0;            % 1526) tapatio_hot_sauce (avd)
                      0.0 0.0 0.0;            % 1527) vo5_tea_therapy_healthful_green_tea_smoothing_shampoo (avd)
                      0.9 0.0 0.0;            % 1528) nature_valley_sweet_and_salty_nut_almond (avd)
                      0.0 0.0 0.0;            % 1529) nature_valley_sweet_and_salty_nut_cashew (avd
                      0.0 0.0 0.0;            % 1530) nature_valley_sweet_and_salty_nut_peanut (avd)
                      0.0 0.0 0.0;            % 1531) nature_valley_sweet_and_salty_nut_roasted_mix_nut (avd)
                      0.0 0.6 0.0;            % 1532) paper_plate (avd)
                      0.0 0.9 0.3;            % 1533) red_cup (avd)
    ];
                     
        
    %%%%%%%%%%%%%%%%%%            ADE20K         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % first 50 colors are handpicked
    ADE20K_TOTAL_LABELS = 150;
    colors_ade20k = [             
                      0.949 0.9529 0.9608; % 1) wall (ade20k) --> off-white
                      0.0 0.0 0.0;            % 2) building (ade20k)
                      0.0 0.0 0.0;            % 3) sky (ade20k)
                      0.0 0.0 0.3;            % 4) floor (ade20k) ---> navy blue
                      0.0 0.0 0.0;            % 5) tree (ade20k)
                      0.0 0.7 0.0;            % 6) ceiling (ade20k) ---> light green
                      0.0 0.0 0.0;            % 7) road (ade20k)
                      1.0 0.3 0.3;            % 8) bed (ade20k)
                      0.7 0.0 0.0;            % 9) window (ade20k) ---> red
                      0.0 0.0 0.0;            % 10) grass (ade20k)
                      1.0 0.7 1.0;            % 11) cabinet (ade20k)
                      0.0 0.0 0.0;            % 12) sidewalk (ade20k)
                      0.5 0.5 0.0;            % 13) person (ade20k)
                      0.0 0.0 0.0;            % 14) earth (ade20k)
                      0.0 0.0 1.0;            % 15) door (ade20k) --> blue
                      0.7 0.7 0.7;            % 16) table (ade20k)
                      0.0 0.0 0.0;            % 17) mountain (ade20k)
                      0.0 0.3 0.0;            % 18) plant (ade20k) 
                      0.0 0.9 0.3;            % 19) curtain (ade20k)
                      0.6 0.4 0.2;            % 20) chair (ade20k) --> wooden (0.6 0.4 0.2) or 
                      0.0 0.0 0.0;            % 21) car (ade20k)
                      0.0 0.0 0.0;            % 22) water (ade20k)
                      0.9 0.0 0.9;            % 23) painting (ade20k) ---> magenta
                      1.0 1.0 0.7;            % 24) sofa, couch (ade20k)
                      0.9 0.0 0.9;            % 25) shelf (ade20k)
                      0.0 0.0 0.0;            % 26) house (ade20k)
                      0.0 0.0 0.0;            % 27) sea (ade20k)
                      0.7 0.0 0.0;            % 28) mirror (ade20k)
                      0.9 0.9 0.0;            % 29) rug, carpet (ade20k)
                      0.0 0.0 0.0;            % 30) field (ade20k)
                      0.9 1.0 1.0;            % 31) armchair (ade20k)
                      0.5 0.5 0.0;            % 32) seat (ade20k)
                      0.0 0.0 0.0;            % 33) fence (ade20k)
                      0.0 0.0 0.4;            % 34) desk (ade20k)
                      0.0 0.0 0.0;            % 35) rock (ade20k)
                      0.3 0.0 0.0;            % 36) wardrobe (ade20k)
                      0.0 0.3 0.0;            % 37) lamp (ade20k)
                      0.0 0.9 0.3;            % 38) bathtub (ade20k)
                      0.0 0.0 0.0;            % 39) railing (ade20k)
                      0.0 0.7 0.0;            % 40) cushion (ade20k)
                      0.0 0.0 0.0;            % 41) base, pedestal (ade20k)
                      0.0 0.7 0.7;            % 42) box (ade20k)
                      0.0 0.0 7.0;            % 43) column, pillar (ade20k)
                      0.0 0.0 0.0;            % 44) signboard (ade20k)
                      0.9 0.0 0.9;            % 45) dresser (ade20k)
                      0.0 0.5 1.0;            % 46) counter (ade20k)
                      0.0 0.0 0.0;            % 47) sand (ade20k)
                      0.7 0.0 0.0;            % 48) sink (ade20k)
                      0.0 0.0 0.0;            % 49) skyscraper (ade20k)
                      1.0 0.7 1.0;            % 50) fireplace (ade20k)
                      0.9 1.0 1.0;            % 51) refrigerator, icebox (ade20k)
                      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                      0.0 0.0 0.0;            % 52   grandstand (ade20k)
                      0.0 0.0 0.0;            % 53   path (ade20k) 
                      0.9 0.9 0.0;            % 54   stairs (ade20k) 
                      0.0 0.0 0.0;            % 55   runway (ade20k) 
                      0.0 0.0 0.0;            % 56   case (ade20k) 
                      0.0 0.0 0.0;            % 57   pool table (ade20k) 
                      1.0 0.3 0.3;            % 58   pillow (ade20k) 
                      0.0 0.0 0.0;            % 59   screen door (ade20k) 
                      1.0 1.0 0.7;            % 60   stairway (ade20k) 
                      0.0 0.0 0.0;            % 61   river (ade20k) 
                      0.0 0.0 0.0;            % 62   bridge (ade20k) 
                      0.5 1.0 0.5;            % 63   bookcase (ade20k) 
                      0.7 0.7 0.7;            % 64   blind (ade20k) ---> 
                      0.5 0.5 0.5;            % 65   coffee table (ade20k) 
                      1.0 0.7 1.0;            % 66   toilet, potty (ade20k) 
                      0.0 0.0 0.0;            % 67   flower (ade20k) 
                      1.0 0.3 0.3;            % 68   book (ade20k) 
                      0.0 0.0 0.0;            % 69   hill (ade20k) 
                      0.0 0.0 0.0;            % 70   bench (ade20k) 
                      0.0 0.7 0.7;            % 71   countertop (ade20k) 
                      0.3 0.0 0.0;            % 72   stove (ade20k) 
                      0.0 0.0 0.0;            % 73   palm (ade20k) 
                      0.5 0.5 0.5;            % 74   kitchen island (ade20k) 
                      0.9 0.9 0.0;            % 75   computer (ade20k) 
                      0.0 0.5 1.0;            % 76   swivel chair (ade20k) 
                      0.0 0.0 0.0;            % 77   boat (ade20k) 
                      0.0 0.0 0.0;            % 78   bar (ade20k) 
                      0.0 0.0 0.0;            % 79   arcade machine (ade20k) 
                      0.0 0.0 0.0;            % 80   hovel (ade20k) 
                      0.0 0.0 0.0;            % 81   bus (ade20k) 
                      0.0 0.7 0.7;            % 82   towel (ade20k) 
                      0.0 0.0 0.0;            % 83   light (ade20k) 
                      0.0 0.0 0.0;            % 84   truck (ade20k) 
                      0.0 0.0 0.0;            % 85   tower (ade20k) 
                      1.0 1.0 0.7;            % 86   chandelier (ade20k) 
                      0.0 0.0 0.0;            % 87   sunshade (ade20k) 
                      0.0 0.0 0.0;            % 88   street lamp (ade20k) 
                      0.0 0.0 0.0;            % 89   booth, cubicle (ade20k) 
                      0.0 0.0 0.0;            % 90   television (ade20k) 
                      0.0 0.0 0.0;            % 91   airplane (ade20k) 
                      0.0 0.0 0.0;            % 92   dirt track (ade20k) 
                      0.5 1.0 0.5;            % 93   clothes (ade20k) 
                      0.0 0.0 0.0;            % 94   pole (ade20k) 
                      0.0 0.0 0.0;            % 95   land, ground, soil (ade20k) 
                      0.0 0.0 0.0;            % 96   bannister (ade20k) 
                      0.0 0.0 0.0;            % 97   escalator (ade20k) 
                      0.0 0.0 0.0;            % 98   ottoman (ade20k) 
                      0.5 1.0 0.5;            % 99   bottle (ade20k) 
                      0.4 0.3 0.3;            % 100   counter, sideboard (ade20k) 
                      0.3 0.7 0.3;            % 101   poster (ade20k) 
                      0.0 0.0 0.0;            % 102   stage (ade20k) 
                      0.0 0.0 0.0;            % 103   van (ade20k) 
                      0.0 0.0 0.0;            % 104   ship (ade20k) 
                      0.0 0.0 0.0;            % 105   fountain (ade20k) 
                      0.0 0.0 0.0;            % 106   conveyer belt (ade20k) 
                      0.0 0.0 0.0;            % 107   canopy (ade20k) 
                      0.9 0.9 0.8;            % 108   washing machine (ade20k) 
                      0.2 0.9 0.4;            % 109   toy (ade20k) 
                      0.0 0.0 0.0;            % 110   swimming pool (ade20k) 
                      0.2 0.1 0.6;            % 111   stool (ade20k) 
                      0.0 0.0 0.0;            % 112   barrel (ade20k) 
                      0.6 0.1 0.2;            % 113   basket (ade20k) 
                      0.0 0.0 0.0;            % 114   waterfall, falls 
                      0.0 0.0 0.0;            % 115   tent (ade20k) 
                      0.0 0.5 1.0;            % 116   bag (ade20k) 
                      0.0 0.0 0.0;            % 117   motorbike (ade20k) 
                      0.0 0.0 0.0;            % 118   cradle (ade20k) 
                      0.7 0.0 0.9;            % 119   oven (ade20k) 
                      0.5 0.5 0.1;            % 120   ball (ade20k) 
                      0.3 0.7 0.3;            % 121   food (ade20k) 
                      0.2 0.4 0.7;            % 122   step, stair (ade20k) 
                      0.0 0.0 0.0;            % 123   tank, storage tank (ade20k) 
                      0.0 0.0 0.0;            % 124   brand name (ade20k) 
                      0.7 0.1 0.1;            % 125   microwave (ade20k) 
                      0.8 0.2 0.6;            % 126   pot, flowerpot (ade20k) 
                      0.0 0.0 0.0;            % 127   animal (ade20k) 
                      0.0 0.0 0.4;            % 128   bicycle (ade20k) 
                      0.0 0.0 0.0;            % 129   lake (ade20k) 
                      0.8 0.2 0.2;            % 130   dishwasher (ade20k) 
                      0.9 0.8 0.2;            % 131   screen, projection screen (ade20k) 
                      0.2 0.9 0.2;            % 132   blanket, cover (ade20k) 
                      0.0 0.0 0.0;            % 133   sculpture (ade20k) 
                      0.0 0.0 0.0;            % 134   exhaust hood (ade20k) 
                      0.0 0.0 0.0;            % 135   sconce (ade20k) 
                      0.0 0.4 0.8;            % 136   vase (ade20k) 
                      0.0 0.0 0.0;            % 137   traffic signal (ade20k) 
                      0.9 1.0 1.0;            % 138   tray (ade20k) 
                      0.5 0.3 0.1;            % 139   trash can, garbage can (ade20k) ---> brown
                      0.8 0.8 0.5;            % 140   fan (ade20k) 
                      0.0 0.0 0.0;            % 141   pier, wharf (ade20k) 
                      0.1 0.5 0.1;            % 142   crt screen (ade20k) 
                      1.0 0.0 1.0;            % 143   plate (ade20k) 
                      0.2 0.5 0.2;            % 144   monitor (ade20k) 
                      0.2 0.7 0.2;            % 145   bulletin board (ade20k) 
                      0.3 0.7 0.3;            % 146   shower (ade20k) 
                      0.0 0.0 0.5;            % 147   radiator (ade20k)
                      1.0 0.5 0.5;            % 148   glass (ade20k) 
                      0.0 0.0 0.0;            % 149   clock (ade20k) 
                      0.0 0.0 0.0;            % 150   flag (ade20k)
    ];
      
        
    %%%%%%%%%%%%%%%%%%            LVIS         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % colors_lvis     = rand(LVIS_TOTAL_LABELS, 3);
    % remaining 100 colors are generated randomly
    LVIS_TOTAL_LABELS = 1203;
    numColors               = LVIS_TOTAL_LABELS;
    colors_lvis                = zeros(numColors, 3);
    
    for i = 1:numColors
        while true
            newColor = randi([0, 255], 1, 3)/255;
            if ~ismember(newColor, colors_lvis, 'rows') && ~ismember(newColor, colors_ade20k, 'rows') && ~ismember(newColor, colors_avd, 'rows')
                colors_lvis(i, :) = newColor;
                break;
            end
        end
    end    
                               
    empty_colors = zeros(1500 - (length(colors_ade20k) + length(colors_lvis) + 1), 3);
    colors_all = [colors_ade20k;
                        colors_lvis;
                        empty_colors;
                        colors_avd];
    save([srcDir 'colors_all.mat'], 'colors_all', 'colors_ade20k', 'colors_lvis', 'empty_colors', 'colors_avd');

else

    load([srcDir 'colors_all.mat'], 'colors_all', 'colors_ade20k', 'colors_lvis', 'colors_avd');
    
end