%%
% GrowImage
% --- synthesis whole image
%
% Xi Peng
%%
function result = GrowImage(Img, sImg, wSize)
%% parameters
MaxErrThreshold = 0.3;

%% initiallization
% enlarge img with wSize
img = zeros(size(Img,1)+wSize-1, size(Img,2)+wSize-1);
[iRow, iCol] = size(img);
bRow = ceil(wSize/2); eRow = iRow-floor(wSize/2);
bCol = ceil(wSize/2); eCol = iCol-floor(wSize/2);
fMask = img;

% Gaussian mask
mu = [0, 0];
s = double(wSize) ./ 6.4;
sigma = [s 0;0 s];
[x y] = meshgrid(linspace(-1,1,wSize), linspace(-1,1,wSize));
gMask = mvnpdf([x(:) y(:)], mu, sigma);
gMask = reshape(gMask, wSize, wSize);
%gaussMask = repmat(gaussMask(:), 1, size(sampleImg,2));

% fill the 3*3 seed into the img centre
seed = round([2,2] + [size(sImg,1)-3,size(sImg,2)-3] .* rand(1,2));
img( iRow/2-1:iRow/2+1, iCol/2-1:iCol/2+1 ) = ...
    sImg( seed(1)-1:seed(1)+1, seed(2)-1:seed(2)+1 );
fMask( iRow/2-1:iRow/2+1, iCol/2-1:iCol/2+1 ) = 1;
sMask = ones(size(sImg,1), size(sImg,2));

%% main loop
figure;
fprintf('start to fill pixels...\n');
ufPixelN = size(Img,1) .* size(Img,2) - 3.*3;
while ufPixelN
    progress = 0;
    
    % get unfilled pixels
    uList = GetUnfilledNeighbors(fMask, wSize);
    
    % find matches
    for ii = 1:size(uList,1)
        % get window
        [tImg tfMask] = GetNeighborboodWindow(img, fMask, uList(ii,:), wSize);
        
        % find matches
        BestMatches = FindMatches(tImg, tfMask, sImg, sMask, gMask, wSize);
        
        % random pick
        if size(BestMatches, 1) > 0
            index = randi(size(BestMatches, 1));
        if BestMatches(index, 2) < MaxErrThreshold
            img(uList(ii,1), uList(ii,2)) = BestMatches(index, 1);
            fMask(uList(ii,1), uList(ii,2)) = 1;
            ufPixelN = ufPixelN - 1;
            progress = 1;
        end
        
        if mod(ufPixelN,500) == 0
            fprintf('unfilled pixels num %d\n', size(find(fMask(bRow:eRow, bCol:eCol)==0),1));
            imshow(img);drawnow;
        end
        end
    end
    
    if progress == 0;
        MaxErrThreshold = MaxErrThreshold .* 1.1;
    end        
end

result = img(bRow:eRow,bCol:eCol);
result = imrotate(result, 180);

end
