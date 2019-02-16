%%
% FindMatches
% --- find the best match list
%
% Xi Peng
%%
function BestMatches = FindMatches(tImg, tfMask, sImg, sMask, gMask, wSize)              
        % parameters
        ErrThreshold = 0.1;
        
        % totall weight
        tfMaskgMask = tfMask .* gMask;
        tolWeight = sum(tfMaskgMask(:));

        tImgtfMaskgMask = tImg.*tfMaskgMask;
        sImgsImg = sImg.^2;
        sImgsImgConv = conv2(sImgsImg,tfMaskgMask,'same');
        sImgConv = conv2(sImg,tImgtfMaskgMask,'same');
        tImgtfMaskgMask = (tImg).^2.*tfMaskgMask;
        
        SSD = (sImgsImgConv - 2*sImgConv + sum(tImgtfMaskgMask(:)))/tolWeight;
        SSD(SSD<0) = 0;
        SSD(~sMask) = 100;
        
        % find matches
        matches = [sImg(:) SSD(:)];
        minSSD = min(matches(:,2));
        BestMatches = matches(matches(:,2) <= minSSD.*(1+ErrThreshold), :);  
 end
