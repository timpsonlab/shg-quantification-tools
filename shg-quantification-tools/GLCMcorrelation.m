function results = GLCMcorrelation(im, n_step)
% Compute the average GLCM correlation with distance over n_step pixels 
% at 0, 90, 180 and 270 degrees. 
%
% First compile mex function glcm.cpp using
% > mex glcm.cpp 'CXXFLAGS="$CXXFLAGS -O3"'

    if nargin < 2
        n_step = 100;
    end
    
    % Make a matrix of the offsets to evaluate
    angles = [0 pi/2];
    steps = (0:n_step)';
    
    angle = repmat(angles, [length(steps), 1]);
    step = repmat(steps, [1, length(angles)]);
    
    angle = angle(:);
    step = step(:);
    
    offset_x = step .* sin(angle);
    offset_y = step .* cos(angle);
    
    if size(im,3) > 1 
        im = max(im,[],3);
    end
    
    % Convert image to unsigned 8 bit integer
    if isa(im, 'uint16')
        im = im / 255;
    elseif isfloat(im)
        im = im * 255;
    end
    im = uint8(im);
        
    %Compute GLCM
    correlation = zeros([1 length(offset_x)]);
    contrast = zeros([1 length(offset_x)]);
    energy = zeros([1 length(offset_x)]);
    homogeneity = zeros([1 length(offset_x)]);
    for i=1:length(offset_x)
        [correlation(i), contrast(i), energy(i), homogeneity(i)] = glcm(im, offset_x(i), offset_y(i));
    end
    
    %{
    Equiv. using built in (slower) matlab function:
    %g = graycomatrix(im, 'NumLevels', 256, 'Offset', int32([offset_x offset_y]), 'Symmetric', false);
    %stats = graycoprops(g, 'Correlation');
    %correlation = stats.Correlation;
    %}    
    
    results = struct;
    results.correlation = correlation;
    results.contrast = contrast;
    results.energy = energy;
    results.homogeneity = homogeneity;
    
    fields = fieldnames(results);
    
    for i=1:length(fields)    
        % Average over angles
        r = results.(fields{i});
        r = reshape(r, [length(steps), length(angles)]);
        r = mean(r, 2);
        results.(fields{i}) = r;
    end
    
end