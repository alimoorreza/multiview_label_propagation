function visualize_and_save_prediction(labelOld, labelSmoothed, srcDir, videoName, curFrame, rgbExtension, rgbFileType, predPath)
    %========================================================
    %--- initialize the information to save the predicted image/label
    %----------------------------------------------------------------------------
    %----------------------------------------------------------------------------    
    rgbPath         = [srcDir '/' videoName '/jpg_rgb/'];    
    
    % figure_path   = ['figure_windowLen_' num2str(windowLength)];
    figure_path   = ['figure'];
    if (~exist([predPath figure_path], 'dir'))
        mkdir([predPath figure_path]);
    end
    
    
    outnamePropLabels   = '_prop_labels.png';
    outnamePropSseg      = '_prop_sseg.png';
    outnameOrigSseg      = '_orig_sseg.png';
    
    
    labelMap             = containers.Map;
    % load ade20k
    labelMap            = decode_dictionary_from_json('combined_labels/json_files/ade20k_categories_clean.json', labelMap);
    
    % load lvis
    labelMap            = decode_dictionary_from_json('combined_labels/json_files/lvis_categories_clean.json', labelMap);
    
    % load avd    
    labelMap            = decode_dictionary_from_json('combined_labels/json_files/avd_categories_clean.json', labelMap);

    % load or create color codes for all 1387 labels
    color_codes; % it will load matrix 'colors_all' of size 1387x3    
    
    %========================================================
    % ---- visualize
    %========================================================
    
    rgbImg         = imread([rgbPath '/' curFrame rgbExtension rgbFileType]);
    %grayim          = double(repmat(rgb2gray(rgbImg), [1 1 3]));            
    
    labeledNewImg = create_colored_label_img(labelSmoothed, colors_all, rgbImg, labelMap);
    labeledOldImg = create_colored_label_img(labelOld, colors_all, rgbImg, labelMap);
           
    imwrite(labeledNewImg, fullfile(predPath, figure_path, [curFrame outnamePropSseg]));            
    imwrite(labeledOldImg, fullfile(predPath, figure_path, [curFrame outnameOrigSseg]));            
    imwrite(uint16(labelSmoothed), fullfile(predPath, figure_path, [curFrame outnamePropLabels]));            
    %keyboard;

    

end

function labeledImg = create_colored_label_img(label, colors_all, rgbImg, labelMap)

    labelim         = uint8(zeros(size(label,1)*size(label,2), 3));
    labelIds        = unique(label(:));


    for ilabelIds=1:length(labelIds)
        idx = find(label == labelIds(ilabelIds));

        if labelIds(ilabelIds) == 0
            continue;
        end
        uint8(255*colors_all(labelIds(ilabelIds),:));
        labelim(idx,:) = repmat( uint8(255*colors_all(labelIds(ilabelIds),:)), length(idx),1);
    end
    labelim = reshape(labelim, [size(label,1) size(label,2) 3]);


    % put the labels overlaid on top of the rgb image
    imagesc(rgbImg); hold on; % display the image          
    overlayTransparency = 0.5; % 0: fully transparent, 1: fully opaque            
    h = imagesc(labelim); % display the overlay with transparency        
    set(h, 'AlphaData', overlayTransparency); axis off; hold off;
    
    labeledImg = h.CData;
    
    % show the label names on top of the image        
    for ll=1:length(labelIds)
                        
        curLabel                      = labelIds(ll);
        if (curLabel == 0) % void region
            continue;
        end
        idx                              = find( label == curLabel);
        curLabelName             = labelMap(num2str(curLabel));
        boxColor                     = {"white"};

        [rows, cols]                  = ind2sub(size(label), idx);
        random_index             = randperm(length(idx));
        position                       = [cols(random_index(1)) rows(random_index(1))];
        
        labeledImg                  = insertText(labeledImg, position, curLabelName, ...
                                                               FontSize=18, BoxColor=boxColor, BoxOpacity=0.4, TextColor="black");


    end

end


function labelMap = decode_dictionary_from_json(file_name, labelMap)

    jsonString          = fileread(file_name);
    jsonData            = jsondecode(jsonString);
    fields                 = fieldnames(jsonData);
    
    for i = 1:numel(fields)
        key                           = fields{i};
        value                        = jsonData.(key);
        labelMap(key(2:end)) = value;
    end


end