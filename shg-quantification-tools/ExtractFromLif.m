function ExtractFromLif(file)

%    folder = '/Volumes/Seagate Backup Plus Drive/SHG Data/TMAs/';
%    file = '2015-08-24 TMA SHG 400Hz.lif';

    if nargin < 1
        [file, folder] = uigetfile('*.lif');
        folder = [folder filesep];
    end

    data = bfopen([folder file]);

    
    n_im = size(data,1);

    im = cell(1,n_im);
    names = cell(1,n_im);

    %%
        
    for i=1:n_im

        md = data{i,1}{1,2};
        md = strsplit(md, '; ');
        names{i} = md{2};
 
        chan_text = regexp(md,'C=\d+/(\d+)','tokens');
        chan_text = chan_text(~cellfun(@isempty,chan_text));
        
        if isempty(chan_text)
            n_chan = 1;
        else
            n_chan = str2double(chan_text{1}{1});
        end

        datai = data{i, 1};
        n_slice = size(datai,1); 

        
        for j=1:n_slice
            im{i}(:,:,j) = datai{j,1};
        end
        
        sz = size(im{i});
        im{i} = reshape(im{i},[sz(1:2) n_chan n_slice/n_chan]);

        im{i} = im{i};

    end
%%
    [names,idx] = sort_nat(names);
    im = im(idx);

    tokens = regexp(names,'(.+)(\.\d+)', 'tokens');
    
    for i=1:n_im
        if ~isempty(tokens{i})
            group{i} = tokens{i}{1}{1};
            id{i} = tokens{i}{1}{2};
        else
            group{i} = names{i};
            id{i} = '';
        end
    end
    
    group = strrep(group,'/',' ');
    groups = unique(group);
    
    for i=1:length(groups)
       
        sel = strcmp(group,groups{i});
        
        sel_id = id(sel);
        sel_im = im(sel);
        
        if length(sel_im) > 1
            subfolder = [folder 'Data' filesep groups{i}];
            mkdir(subfolder);
        else
            subfolder = [folder 'Data' filesep];
        end
        
        for j=1:length(sel_im)
            sz = size(sel_im{j});
            for m=1:size(sel_im{j},3)
                im_file = [subfolder filesep groups{i} sel_id{j} ' Ch' num2str(m,'%03d') '.tif'];
                imwrite(sel_im{j}(:,:,m,1), im_file);
                for k=2:size(sel_im{j},4)
                    imwrite(sel_im{j}(:,:,m,k), im_file,'WriteMode','append');
                end
            end
        end

        
        
        
    end