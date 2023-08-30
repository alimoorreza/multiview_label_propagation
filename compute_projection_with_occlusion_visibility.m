function [projections] = compute_projection_with_occlusion_visibility(params)    

    % This function is for ...
    
    % Md Alimoor Reza: 08/2023
    % md.reza@drake.edu
    % Assistant Professor, CS Dept. Drake University
    
    
    % whole 3D pcl of a frame projected into other
    curFrameName              = params.curFrameName;
    tmpLabelP                     = params.tmpLabelP;
    propagatedFrameName = params.propagatedFrameName;
    nRows                           = params.nRows;
    nCols                            = params.nCols;
    x1                                 = params.x1;
    x2                                 = params.x2;
    y1                                 = params.y1;
    y2                                 = params.y2;

    img_dir                         = params.img_dir;
    rgbExtension                 = params.rgbExtension;
    rgbFileType                   = params.rgbFileType;

    depth_dir                      = params.depth_dir;                  
    depthExtension             = params.depthExtension;
    depthFileType               = params.depthFileType;


    pts                                = params.XYZcamera;
    focal_length_x              = params.K(1,1);
    focal_length_y               = params.K(2,2);
    center                           = [params.K(1,3) params.K(2,3)];
    projX                             = [];
    projY                             = [];   
    projIndices                    = [];
        

    %%%
    isClippingBehindCamera = 1;
    if (isClippingBehindCamera)
        frontOfCameraIndex  = find(pts(:,3) < 0); % positive z-value corresponds to points behind the camera
        pts                 = pts(frontOfCameraIndex,:);
        tmpLabelP      = tmpLabelP(frontOfCameraIndex);                    
    end
    
    %%%
    % clipping on the image coordinate space
    clippedIndex = zeros(1, size(pts,1));
    for jj=1:size(pts,1)
        projX(jj)=round((pts(jj,1)*focal_length_x)/pts(jj,3) + center(1)) - (x1-1);
        projY(jj)=round((pts(jj,2)*focal_length_y)/pts(jj,3) + center(2)) - (y1-1);   

        if (projX(jj) > 0 & projX(jj) <= x2) & (projY(jj) > 0 & projY(jj) <= y2)
            clippedIndex(jj) = 1;
        end

        % if projX(jj) == 826 & projY(jj)  == 538
        % 
        %     keyboard;
        % 
        % end
        
    end

    clippedIndex = find(clippedIndex == 1);
    % prune out elements that are not visible    
    pts              = pts(clippedIndex,:);    
    tmpLabelP   = tmpLabelP(clippedIndex);
    projX           = projX(clippedIndex);
    projY           = projY(clippedIndex);
    
    
    %{

    tmpIndex = find((projX > 0 & projX <= x2) & (projY > 0 & projY <= y2)); % CHANGE THE size(labelP,*) later on with parameter value
    % prune out elements that are not visible    
    pts              = pts(tmpIndex,:);    
    tmpLabelP   = tmpLabelP(tmpIndex);
    projX           = projX(tmpIndex);
    projY           = projY(tmpIndex);

    %}
    

    
    %%%    
    % occlusion reasoning
    regOI                    = zeros(nRows, nCols);
    projIndex              = sub2ind([nRows, nCols], projY, projX);
    regOI(projIndex)    = 1;
        
%     % depth of key-frame
%     tmpFileName = fullfile(depth_dir, [kfList{ikfList}, depthExtension, depthFileType]);        
%     depthKf = imread(tmpFileName);  
%     depthKf = depthKf/1000;
%     depthKf = depthKf(valid); % valid index were saved along with xyzworld 
%     depthKf = depthKf(tmpIndex);
    
    % depth of the current-frame    
    tmpFileName = fullfile(depth_dir, [curFrameName, depthExtension, depthFileType]);        
    depth = double(imread(tmpFileName));  
    depth = depth/1000;
    DEPTH_CUTOFF_THRESHOLD = 7; % there are some artifacts in the depth image (active vision dataset). 7m or more
    valid =  (depth >= DEPTH_CUTOFF_THRESHOLD);
    depth(valid) = 0;
    
%     tmpFileName = fullfile(worldpc_dir, [fileNameC, worldpclExtension, worldpclFileType]);        
%     load(tmpFileName, 'valid');  % valid index is used to pick only those label-pixels that have valid XYZworld coordinate  
%     depth = depth(valid);
%     depth = depthKf(valid); % valid index were saved along with xyzworld 
%     depth = depthKf(tmpIndex);

    projDepth   = zeros(nRows, nCols);
    ptsDepth    = -pts(:,3);    % depths are negative in matlab coordinate system so convert them back to positive
    for jj=1:length(ptsDepth)
        
        curProjX = projX(jj);
        curProjY = projY(jj);
        
        % save the closest depth
        if (projDepth(curProjY, curProjX) == 0)
            projDepth(curProjY, curProjX) = ptsDepth(jj); 
        else
            projDepth(curProjY, curProjX) = min(projDepth(curProjY, curProjX), ptsDepth(jj));
        end
        
        
    end
    
    %figure; imagesc(projDepth); title('keyframe projected on curr only closest to camera projected');  
    depth(regOI ~= 1) = 0;
    
    % prune based on occluded part 
    %VISIBLE DEPTH IN CURRENT FRAME IS SMALLER THAN THE PROJECTED DEPTH
    
    DEPTH_DIFF_THRESHOLD = 0.1;
    % do the occlusion reasoning only on the visible depth part, the other part take evidence from the projection (otherwise those will be empty)
    idx = find(depth == 0);
    tmp = projDepth;
    tmp(idx) = 0;
    
    
    % find the non-visible part where depth mask has zero values (missing from kinect after rgb2depth alignment)
    nonVisibleDepthMask = projDepth ~= 0;
    idx = find(tmp ~= 0);
    nonVisibleDepthMask(idx) = 0;

    
    % distance of occluded-reg will be larger than the occluding-reg    
    diff = tmp - depth; 
    idx = find(diff > DEPTH_DIFF_THRESHOLD);
    %     figure; imagesc(tmp); title('projected depth from keyframe');
    %     figure; imagesc(depth); title('depth from current frame');
    %     figure; imagesc(diff); title('occluded part PrDepth > CurDepth');
    tmp(idx) = 0; % figure; imagesc(tmp); title('occluded part removed'); % pixels where current depthmap is closer than the projected depth (denoting occluded region)
    
    % exclude the occluded part and add the region where depth value is missing
    idx = find(tmp ~= 0);
    projMaskWithoutOcclusion = zeros(nRows, nCols);
    projMaskWithoutOcclusion(idx) = 1; % adding the part where current depthmap exist (after dropping occluded part)
    projMaskWithoutOcclusion(find(nonVisibleDepthMask == 1)) = 1; % adding the part where only projected depth exist but current depthmap value is zero
    
    updatedIndex               = sub2ind([nRows, nCols], projY, projX);
    
    
    
   %------------------------------------------------------------------------------        
   %-------  finding projected point on the left, center, and right porstions respectively
   %------------------------------------------------------------------------------        
   if params.LEFT_CENTER_RIGHT_SIDE_PROJECTIONS_ENABLED == 1
        leftPortionMask                                                                               = zeros(nRows, nCols);
        centerPortionMask                                                                           = zeros(nRows, nCols);
        rightPortionMask                                                                             = zeros(nRows, nCols);
        leftPortionMask(1:nRows, 1:round(nCols/3))                                    = 1;
        centerPortionMask(1:nRows, round(nCols/3)+1:2*round(nCols/3))  = 1;
        rightPortionMask(1:nRows, 2*round(nCols/3)+1:end)                      = 1;

        %---------- left portion projected points
        indexLeft                              = find(leftPortionMask == 1);
        [~, aidxL, ~]                           = intersect(updatedIndex, indexLeft);
        projXLeft                               = projX(aidxL);
        projYLeft                               = projY(aidxL);
        tmpLabelPLeft                       = tmpLabelP(aidxL);
        
        
        %---------- center portion projected points
        indexCenter                           = find(centerPortionMask == 1);
        [~, aidxC, ~]                           = intersect(updatedIndex, indexCenter);
        projXCenter                           = projX(aidxC);
        projYCenter                           = projY(aidxC);
        tmpLabelPCenter                   = tmpLabelP(aidxC);


        %---------- right portion projected points
        indexRight                             = find(rightPortionMask == 1);
        [~, aidxR, ~]                           = intersect(updatedIndex, indexRight);
        projXRight                             = projX(aidxR);
        projYRight                             = projY(aidxR);
        tmpLabelPRight                     = tmpLabelP(aidxR);

        
        % keyboard;
        projections.projXLeft               = projXLeft;
        projections.projYLeft               = projYLeft;
        projections.tmpLabelPLeft       = tmpLabelPLeft;


        projections.projXCenter          = projXCenter;
        projections.projYCenter          = projYCenter;
        projections.tmpLabelPCenter  = tmpLabelPCenter;
        

        projections.projXRight           = projXRight;
        projections.projYRight           = projYRight;
        projections.tmpLabelPRight   = tmpLabelPRight;


        %figure; projectedLabel = zeros(nRows, nCols); tmpIndex = sub2ind([nRows, nCols], projYLeft, projXLeft); projectedLabel(tmpIndex) = tmpLabelPLeft; imagesc(projectedLabel); title('Projected labels');
        %figure; projectedLabel = zeros(nRows, nCols); tmpIndex = sub2ind([nRows, nCols], projYCenter, projXCenter); projectedLabel(tmpIndex) = tmpLabelPCenter; imagesc(projectedLabel); title('Projected labels');
        %figure; projectedLabel = zeros(nRows, nCols); tmpIndex = sub2ind([nRows, nCols], projYRight, projXRight); projectedLabel(tmpIndex) = tmpLabelPRight; imagesc(projectedLabel); title('Projected labels');
                        

   end
    


    %------------------------------------------------------------------------------
    % fractions of pixel in the destination frame (because a close up view of a source frame 
    % can projected into only a small portion of the destination frame eg, dest_frame = 507 and source_frame = 1)       
    % uniqueIndex                 = unique(updatedIndex);
    %------------------------------------------------------------------------------        
    %{
    projMaskWithoutOcclusionValues = projMaskWithoutOcclusion(updatedIndex);
    index = find(projMaskWithoutOcclusionValues == 1);
    fraction = length(index)/(size(projMaskWithoutOcclusion,1)*size(projMaskWithoutOcclusion,2));
    %}
    
    indexMaskWithoutOcclusion = find(projMaskWithoutOcclusion == 1);
    [res, aidx, bidx]                    = intersect(updatedIndex, indexMaskWithoutOcclusion);
    fraction                                = length(res)/(size(projMaskWithoutOcclusion,1)*size(projMaskWithoutOcclusion,2));
      
    projX                                    = projX(aidx);
    projY                                    = projY(aidx);
    pts                                       = pts(aidx,:);
    tmpLabelP                            = tmpLabelP(aidx);
    XYZCamera                          = pts;
    
    projections.projX                 = projX;
    projections.projY                 = projY;
    projections.tmpLabelP         = tmpLabelP;


    vis = 0;
    if (vis)
        
        figure; imagesc(depth); title(['Valid depth on the projected part in current frame: ' curFrameName]);    
        figure; imagesc(projMaskWithoutOcclusion); title(['Projection with occluded part removed within valid depth in frame ' curFrameName]);        
        rgbC                     = imread(fullfile(img_dir, [curFrameName,              rgbExtension, rgbFileType]));        
        rgbLabel               = imread(fullfile(img_dir, [propagatedFrameName, rgbExtension, rgbFileType]));  
        figure; imagesc(rgbC); title(['RGB image of current frame: ' curFrameName]);
        figure; imagesc(rgbC); title(['Labeled point-cloud of frame ' propagatedFrameName ' projected in current frame: ' curFrameName]); hold on; plot(projX, projY, '+g');
        figure; projectedLabel = zeros(nRows, nCols); tmpIndex = sub2ind([nRows, nCols], projY, projX); projectedLabel(tmpIndex) = tmpLabelP; imagesc(projectedLabel); title('Projected labels');
        %figure; imagesc(rgbLabel); title(['frame being projected ' propagatedFrameName]);
        pause; %close(f3);
        close all;
        %pts = XYZcamera;plot3(pts(1:500:end,1), pts(1:500:end,2), pts(1:500:end,3), '+g')
    end    

    % figure; projectedLabel = zeros(nRows, nCols); tmpIndex = sub2ind([nRows, nCols], projY, projX); projectedLabel(tmpIndex) = tmpLabelP; imagesc(projectedLabel); title('Projected labels');
    % pause;
    % close all;
    
end
    
    
    
   
    
    
    
    
    
    
   