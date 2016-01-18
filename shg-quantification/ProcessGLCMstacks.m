function [avg_correlations, all_correlations, mean_correlation_distance] = ProcessGLCMstacks(root)
% Compute the GLCM correlation for stacks of images
%
% - Iterates over all folders in the directory root
% - Computes the GLCM correlation of all images in the folder
% - Saves the following in root
%
%     - mean-correlations.csv
%       Average GLCM correlation over images in each folder
%
%     - all-correlations.csv
%       GLCM correlation for each image in each folder
%
%     - mean-correlation-distances.csv
%       Mean correlation distance for each image, organised by folder
% 

    % Get folder from user if it wasn't specified
    if (nargin < 1)
        root = uigetdir();
    end
    
    if root == 0
        return
    end

    % Default number of steps
    n_step = 100;
    
    % Acceptable image file formats
    valid_extensions = {'tif', 'tiff', 'png'};

    % Get sub-folders
    folder_names = dir(root);
    folder_names = {folder_names([folder_names.isdir]).name};
    
    % If there are no sub folders, use the root folder
    if length(folder_names) == 2
        folder_names = {''};
    else
        folder_names = folder_names(3:end); % ignore this folder and parent
    end
    
    folder_var_names = matlab.lang.makeValidName(folder_names);
    folders = fullfile(root, folder_names);
    
    % Get a cell array of image names from the folders
    image_names = cell(length(folders), 1);
    for i=1:length(folders)
        % Get all images with valid extensions in folder
        names = cellfun(@dir, strcat(folders{i}, [filesep '*.'], valid_extensions), 'UniformOutput', false);
        names = cellfun(@(f) {f.name}, names, 'UniformOutput', false);
        image_names{i} = [names{:}];
    end
    
    % Calculate the largest number of images in a folder 
    n_images = cellfun(@length, image_names);
    max_n_images = max(n_images);
    total_n_images = sum(n_images);
    
    % Set up variables to populate with data
    avg_correlations = table();
    all_correlations = table();
    mean_correlation_distance = table();
    
    distance = (1:n_step)';
    avg_correlations.Distance = distance;
    all_correlations.Distance = distance;
    
    wh = waitbar(0, 'Processing...');
    n_images_complete = 0;
    
    for i=1:length(folders)
           
        % Get full file names including path
        image_files = cellfun(@(f) fullfile(folders{i}, f), image_names{i}, 'UniformOutput', false);
        
        % read in all image files
        images = cellfun(@imread, image_files, 'UniformOutput', false);
        
        % get GLCM correlation for each image
        correlation = zeros(n_step, length(images));
        mean_cor = nan(max_n_images, 1);
        
        for j=1:length(images)
        
            disp(j)
            
            var_name = matlab.lang.makeValidName(strrep(image_files{j},root,''));
            
            % Get normalised correlation for this image
            cor = GLCMcorrelation(images{j}, n_step);
            cor = cor / cor(1);
            
            all_correlations.(var_name) = cor;
            correlation(:,j) = cor;
            
            % Compute mean correlation distance
            mean_cor(j) = sum(distance .* cor) / sum(cor);
            
            n_images_complete = n_images_complete + 1;
            waitbar(n_images_complete / total_n_images, wh);
        end
        
        % compute average GLCM correlation 
        avg_correlations.(folder_var_names{i}) = mean(correlation,2);
        mean_correlation_distance.(folder_var_names{i}) = mean_cor;
        
    end
    
    close(wh);
    
    % Save outputs
    writetable(avg_correlations, fullfile(root, 'mean-correlations.csv'));
    writetable(all_correlations, fullfile(root, 'all-correlations.csv'));
    writetable(mean_correlation_distance, fullfile(root, 'mean-correlation-distances.csv'));
        
end