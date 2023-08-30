function propagate_via_3d_projection_v4()
% This script is for ... cloud from a window of N annotated frames around the frame under consideration
% selection of candidate N frames are hand picked eg, N=40 frames

% Md Alimoor Reza: 08/2023
% md.reza@drake.edu
% Assistant Professor, CS Dept. Drake University
close all;
%**************************************************************************
if (~exist('video_name', 'var'))
    video_name        = 'Home_001_1';
    %video_name        = 'Home_002_1';

end

%**************************************************************************
%------------            root directory and other directory names for                     ------------             
%src_dir               = '/Volumes/reza_drive_iu/gmu_research/label_props/'; % CHANGE THIS ROOT DIR FIRST
src_dir               = '/Users/reza/Desktop/';
img_dir              = [src_dir video_name '/jpg_rgb/'];                                  % rgb image directory
label_dir             = [src_dir video_name '/' video_name '_sseg/'];               % per-frame semantic segmentation predicted image directory
depth_dir           = [src_dir video_name '/high_res_depth/'];                      % depth file directory used for depth-limit test inside projection
hand_picked_dir = [src_dir video_name '/' video_name '_sseg/hand_picked_prediction/'];


if (~exist('predDirName', 'var'))
    predDirName = [video_name '_sseg_smoothed'];
end

predPath       = [src_dir '/' video_name '/' predDirName '/']; 

%**************************************************************************

rgbExtension              = '01';
depthExtension          = '03';
worldpclExtension      = '01';
labelExtension            = '01';

rgbFileType                 = '.jpg';
depthFileType             = '.png';
worldpclFileType         = '.mat';
labelFileType               = '.png'; % semantic segmentation labels saved by Yimeng


% cropping parameters, crop images to ramove the boarder (active vision dataset)
% can't crop right now because 'worldpc' are saved without the crop hence
% there would index mismatch (REZA: 01/25/2018)
x1 = 1; x2 = 1920;
y1 = 1; y2 = 1080;
TOTAL_SEMANTIC_CLASSES          = 1387;
windowLength                              = 35;
WINDOW_SELECTION_METHOD     = 5; % 1) take the (first 'windowLength')-frames temporally nearby in the video sequence (DEFAULT CHOICE)
                                                            % 2) take the (first 'windowLength')-frames that overlaps most (in terms of projected points counts) 
                                                            %                   with the current frame temporally nearby in the video sequence
                                                            % 3) controlled sample from various subwindow, see the sampling function for details
                                                            % 4) controlled sample from various subwindow, see the second sampling function for details function 
                                                            % 5) hand picked samples

WINDOW_TYPE_UNDEFINED          = -1;
WINDOW_TYPE_CENTER                =  1;
WINDOW_TYPE_LEFT                     =  2;
WINDOW_TYPE_RIGHT                  =  3;


% len(ade20k_dict) + len(lvis_dict) + len(avd_dict) = 150 + 1203 + 33 (+1 background from avd) = 1387


%**************************************************************************
%------------      loading camera intrinsic and extrinsic parameters -----
load(fullfile(src_dir, video_name, 'intrinsic.mat'), 'K'); % load the intrinsic camera matrix 'K'
load(fullfile(src_dir, video_name, 'allframes-extrinsics.mat'), 'allframes', 'extrinsicsC2W', 'noRt'); % extrinsics from camera 2 world coordinates
worldpc_dir             = fullfile(src_dir, video_name, 'worldpc');
totalFramesInVideo = length(allframes);


%**************************************************************************
%%% some frames don't possess (R,t) (missed out on reconstruction by Phil@UNC)

framesWithRt             = {};
idx = find(noRt == 0);
for iF=1:length(idx)
    framesWithRt = cat(2, framesWithRt, allframes{idx(iF)});
end


framesWithoutRt        = {};
idx = find(noRt == 1);
for iF=1:length(idx)
    framesWithoutRt = cat(2, framesWithoutRt, allframes{idx(iF)});
end
       
% -- load the names of the frames whose projection intersects with the current frame
% -- these frame names are identified prior to running this script
% -- framesInsideWindow is 'struct' which contains 3 fields:
%                                                           i)   curFrameName
%                                                           ii)  frameNamesInsideWindow
%                                                           iii) windowLength
if WINDOW_SELECTION_METHOD ~= 5
    load(fullfile(src_dir, video_name, [video_name '_framesInsideWindow.mat']), 'framesInsideWindow');
end


start    = 1;
finish   = 50;
sampledFramesAll = [];

for ii = start:finish% totalFramesInVideo

    disp(['processing ' num2str(ii) '/' num2str(finish)]);            
    fileNameC     = allframes{ii};
    
    isEmptyRt = isempty( find(strcmp(framesWithoutRt, fileNameC) == 1) );
    if isEmptyRt
        fprintf([num2str(ii) ') processing ' fileNameC '\n']);
    else
        fprintf([num2str(ii) ') discarding processing (no Rot, Trans) for ' fileNameC '\n']);
        continue;
    end      
         
    %load the rgb image
    rgbC                     = imread(fullfile(img_dir, [fileNameC, rgbExtension, rgbFileType]));        
    rgbC                     = rgbC(y1:y2,x1:x2,:); % % FIND THE VALID CROPPED INDICES
    
    nCols                    = (x2-x1)+1; %number of columns
    nRows                   = (y2-y1)+1; %number of rows
     
    %**************************************************************************
    %--- 3D point-cloud in world-coordinate-space (wc) needs to converted into current frame's camera-coordinate-space (cc)
    %--- pre-processing for 3D point cloud's based energy term        
    extrinsicIndex                            = find(strcmp(allframes, fileNameC) == 1); % TO DO: Change the 'allframes' with adding the extension of rgb(01)
    Rc2w                                          = extrinsicsC2W(1:3,1:3, extrinsicIndex);
    Tc2w                                          = extrinsicsC2W(1:3,4, extrinsicIndex);
        
    if WINDOW_SELECTION_METHOD ~= 5
        frameNamesInsideWindow          = framesInsideWindow(ii).frameNamesInsideWindow;
    end

    %***************************************************************************
    %---        choices for winodw selection ---
    %--------------------------------------------------------------

    if WINDOW_SELECTION_METHOD == 1

        windowLength                            = min(framesInsideWindow(ii).windowLength, windowLength);

    elseif WINDOW_SELECTION_METHOD == 2

        overlapSizes                               = framesInsideWindow(ii).overlapSizes;
        [overlapSizesSorted, sortedIdx]   = sort(overlapSizes, "descend");    
        frameNamesInsideWindowSorted = frameNamesInsideWindow(sortedIdx);
        frameNamesInsideWindow          = frameNamesInsideWindowSorted;
        windowLength                            = min(framesInsideWindow(ii).windowLength, windowLength);

    elseif WINDOW_SELECTION_METHOD == 3

        overlapSizes                                                       = framesInsideWindow(ii).overlapSizes/(nRows*nCols);
        [ frameNamesInsideWindow, frameSamples ]      = sample_frames_from_overlap_ratio(frameNamesInsideWindow, overlapSizes);  
        windowLength                                                    = min(length(frameNamesInsideWindow), windowLength);
        sampledFramesAll(ii).frameName                        = fileNameC;
        sampledFramesAll(ii).frameNamesInsideWindow = frameNamesInsideWindow;
        sampledFramesAll(ii).frameSamples                    = frameSamples;

    elseif WINDOW_SELECTION_METHOD == 4

        overlapSizesLeft                                                  = framesInsideWindow(ii).overlapSizesLeft/(nRows*nCols);
        overlapSizesCenter                                              = framesInsideWindow(ii).overlapSizesCenter/(nRows*nCols);
        overlapSizesRight                                                = framesInsideWindow(ii).overlapSizesRight/(nRows*nCols);
        [ frameNamesInsideWindow, frameSamples , frameTypesInsideWindow ]  ...     
                                                                                   = sample_frames_from_overlap_ratio_lcr(frameNamesInsideWindow, ...
                                                                                                            overlapSizesLeft, overlapSizesCenter, overlapSizesRight);  
        windowLength                                                     = min(length(frameNamesInsideWindow), windowLength);
        sampledFramesAll(ii).frameName                         = fileNameC;
        sampledFramesAll(ii).frameNamesInsideWindow  = frameNamesInsideWindow;
        sampledFramesAll(ii).frameSamples                     = frameSamples;

    elseif WINDOW_SELECTION_METHOD == 5

        hand_picked_files = dir([hand_picked_dir '*.jpg']);
        frameNamesInsideWindow = {};
        frameTypesInsideWindow  = [];
        for ii=1:length(hand_picked_files)
            sample_file_name = hand_picked_files(ii).name(1:end-11);
            if isempty( find(strcmp(fileNameC, sample_file_name) == 1) )
                frameNamesInsideWindow = vertcat(frameNamesInsideWindow, sample_file_name);
                frameTypesInsideWindow  = cat( 2, WINDOW_TYPE_UNDEFINED, frameTypesInsideWindow);
            end
        end
        windowLength                                                     = length(frameNamesInsideWindow);
        sampledFramesAll(ii).frameName                         = fileNameC;
        sampledFramesAll(ii).frameNamesInsideWindow  = frameNamesInsideWindow;

    else
        error('Window selection method for choice > 4 has not been defined ...');
    end


    % append the current frame at the beginning (it will project to itself trivially 
    % but will be useful for projection based score calculation later)    
    frameNamesInsideWindow          = vertcat(fileNameC, frameNamesInsideWindow);

    if WINDOW_SELECTION_METHOD == 4
        frameTypesInsideWindow           = cat( 2, WINDOW_TYPE_CENTER, frameTypesInsideWindow);
    elseif WINDOW_SELECTION_METHOD == 5
        frameTypesInsideWindow           = cat( 2, WINDOW_TYPE_UNDEFINED, frameTypesInsideWindow);
    else
        error('WINDOW_TYPE for currrent frame is not set ...');
    end
    
    disp(['Current frame:                                                     ' fileNameC]);
    disp(['Total frames within the window (including itself): ' num2str(windowLength+1)]);
    
    % single data-structure to save relevant information per frame
    XYZcameraAll(windowLength+1)     = struct('projX', [], 'projY', [], 'label', [], 'frameNum', [], 'frameSize',-1);
    uniqueLabelsAmongAllFrames    = [];

    
    for jj=1:windowLength+1
        
        % disp([num2str(jj) '/' num2str(windowLength) ' processing ...']);        
        %if (ii == jj)
        %    disp('Trivial intersection between current frame with itself, so skip ...');
        %    continue;
        %end
        
        propagatedFrameName                         = frameNamesInsideWindow{jj};
        curFrameTypeInsideWindow                  = frameTypesInsideWindow(jj);

        fprintf([num2str(jj) '/' num2str(windowLength+1) ': calculating projection of ' propagatedFrameName ' into ' fileNameC ' \n']);        
        isEmptyRt = isempty( find(strcmp(framesWithoutRt, propagatedFrameName) == 1) );
        if ~isEmptyRt           
            fprintf([num2str(jj) '/' num2str(windowLength+1) ': discarding processing (no Rot, Trans) for ' propagatedFrameName '\n']);
            error([propagatedFrameName ' frame name was saved after calculating projection; hence it should have Rotation and Translation \n']);
        end      
        

        tmpFileName = fullfile(worldpc_dir, [propagatedFrameName, worldpclExtension, worldpclFileType]);        
        load(tmpFileName, 'XYZworld', 'valid');  % valid index is used to pick only those label-pixels that have valid XYZworld coordinate          
        
        %**********************************************************************
        labelPpath = fullfile(label_dir, [propagatedFrameName , labelExtension, '_labels', labelFileType]); %label of the key frame  
        tmpLabelP = imread(labelPpath);
        tmpLabelP = tmpLabelP(y1:y2,x1:x2,:);
        tmpLabelP = tmpLabelP(valid);            % valid index is used to pick only those label-pixels that have valid XYZworld coordinate
        if (length(XYZworld) ~= length(tmpLabelP))
            error(['''XYZworld'' should have same number of 3D points as there are pixels in the ''mapLabel'' : ' num2str(length(XYZworld)) '~=' num2str(length(tempLabelP))]);
        end
        
        
        %**********************************************************************
        %*** Reza: 02/2018        
        XYZcamera         = bsxfun(@minus, Rc2w'*Tc2w, Rc2w'*XYZworld); % x=(Rc2w')*X-(Rc2w')*(Tc2w)
        XYZcamera         = XYZcamera';    
        
        %******************************************************************
        %*** Reza: 02/2018
        % occlusion reasoning:
        % consider only those 3D points that are
        % closer to the camera along the ray casted from the camera towards
        % the pixel where it intersects in the image plane
        
        %***********************************************************************
        %------ pack all the parameters in 'params' structure for compactness
        params.curFrameName              = fileNameC;        
        params.XYZcamera                    = XYZcamera;
        params.K                                   = K;
        params.tmpLabelP                     = tmpLabelP;
        params.x1                                 = x1; 
        params.x2                                 = x2;
        params.y1                                 = y1; 
        params.y2                                 = y2;        
        params.nRows                           = nRows;
        params.nCols                            = nCols;        
        % parameters for depth limits
        params.depth_dir                       = depth_dir;
        params.depthExtension              = depthExtension;
        params.depthFileType                = depthFileType;
        % extra-parameters for debug the projection step
        params.propagatedFrameName  = propagatedFrameName;
        params.img_dir                          = img_dir;
        params.rgbExtension                  = rgbExtension;
        params.rgbFileType                    = rgbFileType;
        % params.LEFT_CENTER_RIGHT_SIDE_PROJECTIONS_ENABLED = 1;
        params.LEFT_CENTER_RIGHT_SIDE_PROJECTIONS_ENABLED = 0;

        [projections]                               = compute_projection_with_occlusion_visibility(params);        

        % the projected frame
        if curFrameTypeInsideWindow == WINDOW_TYPE_CENTER
            
            projX           = projections.projXCenter;
            projY           = projections.projYCenter;
            tmpLabelP   = projections.tmpLabelPCenter;
            disp(['considering only center portion for ' propagatedFrameName]);

        elseif curFrameTypeInsideWindow == WINDOW_TYPE_LEFT

            projX           = projections.projXLeft;
            projY           = projections.projYLeft;
            tmpLabelP   = projections.tmpLabelPLeft;
            disp(['considering only left portion for ' propagatedFrameName]);


        elseif curFrameTypeInsideWindow == WINDOW_TYPE_RIGHT

            projX           = projections.projXRight;
            projY           = projections.projYRight;
            tmpLabelP   = projections.tmpLabelPRight;    
            disp(['considering only right portion for ' propagatedFrameName]);

        elseif curFrameTypeInsideWindow == WINDOW_TYPE_UNDEFINED

            projX           = projections.projX;
            projY           = projections.projY;
            tmpLabelP   = projections.tmpLabelP;
            disp(['considering all portion for ' propagatedFrameName]);

        else

            error('frameTypeInsideWindow is undefined ...');

        end




        XYZcameraAll(jj).projX              = projX;
        XYZcameraAll(jj).projY              = projY;
        
        % transfer the label from the the image space
        XYZcameraAll(jj).label               = tmpLabelP;
        
        % find unique semantic labels
        XYZcameraAll(jj).uniqueLabels  = unique(tmpLabelP);
        
        % frame no
        XYZcameraAll(jj).frameNum      = propagatedFrameName; 
        
        % total no of valid 3D points from this frame
        XYZcameraAll(jj).frameSize       = length(projX);
        
        % disp([num2str(jj) '/' num2str(windowLength) ' projected frames within window processed ...']);  
        
        % finding unique labels among the nearby frames
        uniqueLabelsAmongAllFrames = union(uniqueLabelsAmongAllFrames, XYZcameraAll(jj).uniqueLabels);    
        
        clear XYZworld valid XYZcamera tmpLabelP projX projY;
        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
    %**********************************************************************************************
    % -- we do not need to consider 1387 labels since most of them won't be present in a frame
    % -- aggregate unique labels from all the frames within the window --
    % -- we will be map the union of all unique labels (that are present across all the evidence frames)
    % -- crf inference will be run on the mapped labels (that are present across all the evidence frames)

    % -- for example
    %      in frame-1   (Home_001_1): there will be 227 unique labels if 256 nearby frames within window are considered
    %      in frame-10 (Home_001_1): there will be 137 unique labels if 397 nearby frames within window are considered

    mapSemanticLabels2NewLabel   = containers.Map; 
    mapNewLabel2SemanticLabel     = containers.Map;    
    for kk=1:length(uniqueLabelsAmongAllFrames)
        semanticLabel                                                                  = uniqueLabelsAmongAllFrames(kk);
        mapNewLabel2SemanticLabel(num2str(kk))                      = semanticLabel;
        mapSemanticLabels2NewLabel(num2str(semanticLabel))  = kk;
    end

    nLabel = length(uniqueLabelsAmongAllFrames);
    %keyboard;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
    %**********************************************************************************************
    % --- generate superpixel from the semantic-segmentation assuming each label is a segment
    % --- this is the destination frame (fileNameC) where we are going to project the evidences 
    % --- onto  (from other frames within the window)
    labelPpath       = fullfile(label_dir, [ fileNameC, labelExtension, '_labels', labelFileType]); %label of the key frame  
    destLabelP      = imread(labelPpath);
    destLabelP      = destLabelP(y1:y2,x1:x2,:);
    
    uniqueLabels  = unique(destLabelP);
    newSpxlImg    = uint32((zeros(size(destLabelP))));
    for kk=1:length(uniqueLabels)        
        segIndex     = find(destLabelP == uniqueLabels(kk));
        newSpxlImg(segIndex) = kk;   
    end
    spixelNumCur       = max(newSpxlImg(:));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % pixel-wise unary data term based on 3D geometric projection
    % pwDataTermG = zeros(nRows, nCols, nLabel+1); % default zero to give precedence over flow-based score on the regions where we have no projection
    pwDataTermG = zeros(nRows, nCols, nLabel); % default IS UNKNOWN on the regions where we have no projection
    
    for kk= 1:spixelNumCur
        
        %find the superpixel of index kk
        seg                 = newSpxlImg==kk;
        
        %xSeg2d = xc(seg); ySeg2d = yc(seg); %x-coordinate %y-coordinate            
        segIndex        = find(newSpxlImg == kk);
        
        %{
        geomScores   = zeros(nLabel+1, windowLength+1);
        isProjected     = zeros(nLabel+1, windowLength+1); % Boolean flag to determine whether a label appears within a current projection
        %}
        geomScores   = zeros(nLabel, windowLength+1);
        isProjected     = zeros(nLabel, windowLength+1); % Boolean flag to determine whether a label appears within a current projection
        
        
        for jFrame=1:windowLength+1
        
            %-- can't assume all frames has same 3D points since Phil's reconstruction gives sparse point cloud            
            curProjX                            = XYZcameraAll(jFrame).projX; % vector of size 1xNUMBER_OF_PROJECTED_POINTS
            curProjY                            = XYZcameraAll(jFrame).projY; % vector of size 1xNUMBER_OF_PROJECTED_POINTS

            %keyboard;
            %%% Reza (08/2023): change the mapping of semanticLabel ---> newLabel
            curProjL                            = XYZcameraAll(jFrame).label; % vector of size 1xNUMBER_OF_PROJECTED_POINTS
            curProjLMapped                = uint16(zeros(1, length(curProjL)));

            for ll=1:length(XYZcameraAll(jFrame).uniqueLabels)
                                
                semLabel                      = XYZcameraAll(jFrame).uniqueLabels(ll);
                newLabel                      = mapSemanticLabels2NewLabel(num2str(semLabel));
                idx                                = find(curProjL == semLabel);
                curProjLMapped(idx)     = newLabel;

            end

            
                       
    
            % find the intersected projected pixels and current pixels within the superpixels
            projIndex                                   = sub2ind([nRows, nCols], curProjY, curProjX);            
            [cIndex, iSegIndex, IprojIndex]   = intersect(segIndex, projIndex);        
            labels                                         = curProjLMapped(IprojIndex);
            % labels                                         = curProjL(IprojIndex);
            


            vis = 0;
            if (vis)                
                xCoords     = curProjX(IprojIndex);
                yCoords     = curProjY(IprojIndex);                
                f3 = figure; imagesc(rgbC);
                %position3 = get(f3, 'OuterPosition');
                %set(f3, 'OuterPosition', [position1(3)+230 position3(2:4)]);
                hold on; plot(xCoords, yCoords, '+g');         
                % [spxl_r, spxl_c] = ind2sub([r, c], segIndex); % superpixel visualizaton
                % hold on; plot(spxl_c, spxl_r, '+r');
                pause; close(f3);  
                
            end

            %for nn=0:nLabel
            for nn=1:nLabel
                % fraction of pixel inside the superpixel that can be explained by the label (nn+1). used as geometric unary scores per pixel
                if (~isempty(find(labels == nn)))

                    sizeWithLabelnn = length(find(labels == nn));
                    curGeomScore = sizeWithLabelnn/length(labels);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % some view projects into the superpxl more than others
                    % this weight balances this factor
                    projWeight = length(labels)/length(segIndex);                    
                    
                    
                    % geomScores(nn+1, jFrame) = projWeight*curGeomScore;
                    geomScores(nn, jFrame) = projWeight*curGeomScore;

                    % more than 5 percent pixels are explained by a label is considered, others are considered as noise (since we are doing mean over multiple frames)
                    if (curGeomScore > 0.05) 
                        %isProjected(nn+1, jFrame) = 1; % this label is present within the superpixel when projected from j-th frame
                        isProjected(nn, jFrame) = 1; % this label is present within the superpixel when projected from j-th frame
                    end
                    
                end

            end
            

        end
        
        %keyboard;

        for nn=1:nLabel
            curPwDataTermG          = pwDataTermG(:,:,nn);
            % average of the scores from frames where a projection was found

            idxFrames = find(isProjected(nn,:));
            if (~isempty(idxFrames))
                curScore                           = mean( geomScores(nn, idxFrames) );            
                curPwDataTermG(seg)      = curScore;                     
                pwDataTermG(:,:,nn)     = curPwDataTermG;

            end

        end           
        
        fprintf('Finished processing %d/%d superpixels\n', kk, spixelNumCur);
        
    end    
    
    clear labels seg segIndex curPwDataTermG geomScores isProjected;
    clear XYZcameraAll; 
    
    vis = 0;
    if (vis)        
        figure; imagesc(pwDataTermG(:,:,1))
        figure; imagesc(pwDataTermG(:,:,2))
        figure; imagesc(pwDataTermG(:,:,3))
        figure; imagesc(pwDataTermG(:,:,4))
        figure; imagesc(pwDataTermG(:,:,5))
        
    end
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    %%%%%    finding argmax for final label the prediction
    %-----------------------------------------------------------------------------
    
    
    % Initialize arrays to store the results
    [s1, s2, ~]                     = size(pwDataTermG);    
    max_values_depth        = zeros(s1, s2);
    max_indices_depth       = zeros(s1, s2);
    
    % iterate over each row and column position find the max along the depth dimension    
    for row = 1:s1
        for col = 1:s2
    
            % find the maximum value and its index along the third dimension (depth)
            [max_value_depth, max_index_depth]  = max(pwDataTermG(row, col, :));
            
            % store the results for (value, index along the third dimension ie, depth)
            max_values_depth(row, col)                  = max_value_depth;
            max_indices_depth(row, col)                 = max_index_depth;
    
        end
    end
    
    %keyboard;
    %%% Reza (08/2023): revert back to original mapping of newLabel ---> semanticLabel 
    L                   = zeros(size(max_indices_depth));    
    uniqueLabels = unique(max_indices_depth);

    for ll=1:length(uniqueLabels)
                        
        newLabel                      = uniqueLabels(ll);
        semLabel                      = mapNewLabel2SemanticLabel(num2str(newLabel));
        idx                                = find( max_indices_depth == newLabel);
        L(idx)                            = semLabel;
    
    end    
    
    visualize_and_save_prediction(destLabelP, L, src_dir, video_name, fileNameC, rgbExtension, rgbFileType, predPath);
        
    
end

  
   

end



