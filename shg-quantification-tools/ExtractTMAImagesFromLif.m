function ExtractTMAImagesFromLif(file)

    %% Get all images from LIF file
    % Images should be organised into one folder per TMA with exactly one 
    % image per TMA core


    if nargin < 1
        [file, folder] = uigetfile('*.lif');
        folder = [folder filesep];
    end

    data = bfopen([folder file]);

    mkdir([folder filesep 'Data']);
    
    n_im = size(data,1);

    im = cell(1,n_im);
    names = cell(1,n_im);

    
    %% Get X,Y positions of images in LIF file
    
    for i=1:n_im

        md = data{i,1}{1,2};
        md = strsplit(md, '; ');
        meta = data{i,2};
        names{i} = md{2};
        pos(i,:) = [str2num(meta.get('ATLConfocalSettingDefinition|StagePosX')), ...
                    str2num(meta.get('ATLConfocalSettingDefinition|StagePosY'))];
        meta = data{i,4};

        datai = data{i, 1};
        n_slice = size(datai,1); 
        
        im{i} = datai{3,1};
        
        sz = size(im{i});
        
    end
    
    
    %% Get TMA group names
    
    tokens = regexp(names,'(.+)/Position(\d+)', 'tokens');
    
    for i=1:n_im
        group{i} = tokens{i}{1}{1};
        id{i} = tokens{i}{1}{2};
    end
    
    groups = unique(group);

    
    %% Sort TMA images by position and export as tif's
    
    for i=1:length(groups)
       
        mkdir([folder groups{i}]);
        sel = strcmp(group,groups{i});
        
        sel_pos = pos(sel,:);
        
        sel_id = id(sel);
        sel_im = im(sel);
        
        sel = 1:length(sel_id);
        
        x = sel_pos(:,1);
        y = sel_pos(:,2);

        [sorted_y, siy] = sort(y);
        
        sz = [length(y)/8 8];
        
        siy = reshape(siy,sz);
        
        idx = [];
        for j=1:size(siy,2)
           
            siyj = siy(:,j);
            
            xx = x(siyj);
            [~,six] = sort(xx);
            
            idx = [idx; siyj(six)];
            
        end
        
        % black magic
        idx = reshape(idx, sz);
        idx = idx';
        idx = flipud(idx);
        idx = idx(:);

        
        sz = [sz(2) sz(1)];
        
        x = x(idx);
        y = y(idx);
        
        sel_id = sel_id(idx);
        sel_im = sel_im(idx);
        
        %plot(x,y);
        
        r = char(64 + (1:sz(1)));    
        c = (1:sz(2));
        
        r = repmat(r',[1,sz(2)]);
        c = repmat(c,[sz(1),1]);
               
        r = r(:);
        c = c(:);
        
        
        for j=1:length(sel_im)
            size(sel_im{j})
            im_file = [folder groups{i} filesep groups{i} '_' r(j) num2str(c(j)) '.tif']
            imwrite(sel_im{j}, im_file);
        end
        
        
        ims = reshape(sel_im,sz);
        tiled = [];
        for j=1:sz(1)
            row = [];
            for k=1:sz(2)
                row = [row ims{j,k}];
            end
            tiled = [tiled; row];
        end
            
        figure(i)
        imagesc(tiled);
        daspect([1 1 1]);
        caxis([0 50])
        colormap('hot')
        
    end