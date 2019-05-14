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

    reject_zero = true;

    persistent last_root 

    % Get folder from user if it wasn't specified
    if (nargin < 1)
        if isempty(last_root)
            last_root = '';
        end
        root = uigetdir(last_root);
    end
    
    if root == 0
        return
    end
    
    inputs = {'100','n'};
    input_names = {'Correlation Steps', 'Ignore zeros (y/n)'};
    answer = inputdlg(input_names,'GLCM',[1 20],inputs);
    
    n_step = str2double(answer{1});
    reject_zero = strcmp(answer{2},'y');
    
    
    last_root = root;
        
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
    
    var_names = {'correlation','contrast','energy','homogeneity'};
    
    % Set up variables to populate with data
    
    distance = (0:n_step)';

    for i=1:length(var_names)
        avg_table{i} = table();
        all_table{i} = table();
        mean_table{i} = table();
    
        avg_table{i}.Distance = distance;
        all_table{i}.Distance = distance;

    end
    
    wh = waitbar(0, 'Processing...');
    n_images_complete = 0;
    
    for i=1:length(folders)
           
        % Get full file names including path
        image_files = cellfun(@(f) fullfile(folders{i}, f), image_names{i}, 'UniformOutput', false);
        
        exclude = cellfun(@(x) x(1)=='.', image_names{i});
        image_files = image_files(~exclude);
        
        
        % read in all image files
        images = cellfun(@imread, image_files, 'UniformOutput', false);
        
        % get GLCM correlation for each image        
        for k=1:length(var_names)
           var{k} = zeros(length(distance), length(images));
           mean_var{k} = nan(max_n_images, 1);
        end
        
        for j=1:length(images)
                    
            name = matlab.lang.makeValidName(strrep(image_files{j},[root filesep],''));
            
            % Get normalised correlation for this image
            results = GLCMcorrelation(images{j}, n_step, reject_zero);
            
            for k=1:length(var_names)
                v = results.(var_names{k});
                all_table{k}.(name) = v;
                var{k}(:,j) = v;
    
                % Compute mean correlation distance
                mean_var{k}(j) = sum(distance .* v) / sum(v);
            end
                        
            n_images_complete = n_images_complete + 1;
            waitbar(n_images_complete / total_n_images, wh);
        end
        
        % compute average GLCM correlation 
        for k=1:length(var_names)
            avg_table{k}.(folder_var_names{i}) = mean(var{k},2);
            mean_table{k}.(folder_var_names{i}) = mean_var{k};
        end
        
    end
    
    close(wh);
    
    % Save outputs
    for k=1:length(var_names)
        writetable(avg_table{k}, fullfile(root, ['mean-' var_names{k} '.csv']));
        writetable(all_table{k}, fullfile(root, ['all-' var_names{k} '.csv']));
        writetable(mean_table{k}, fullfile(root, ['mean-' var_names{k} '-distances.csv']), 'WriteRowNames', true);
    end
end