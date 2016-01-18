
function ProcessSHG()
    while true
        
        
        [file, folder] = uigetfile('*.lif', 'Choose LIF file...');
        if file == 0
            break;
        end
        
        ans = inputdlg({'Filter using string','Channel Number (zero-indexed): '},...
                       'Filter files',1,{'SHG','0'});
                  
        filter = ans{1};
        chan = str2double(ans{2}) + 1;

        file = [folder filesep file];
        data = bfopen(file);
        
        if ~isempty(filter)
            for i=1:size(data,1);
                md = data{i,1}{1,2};
                mds = strsplit(md, '; ');
                name = mds{2};
                sel(i) = ~isempty(strfind(name,filter));
            end
        end
        
        data = data(sel,:);
        
        
        n_im = size(data,1);

        im = cell(1,n_im);
        names = cell(1,n_im);

        for i=1:n_im

            md = data{i,1}{1,2};
            mds = strsplit(md, '; ');
            names{i} = mds{2};

            chan_text = regexp(md,'C=\d/(\d)','tokens');
            if isempty(chan_text)
                n_chan = 1;
            else
                n_chan = str2double(chan_text{1});
            end

            datai = data{i, 1};
            n_slice = size(datai,1) / n_chan; 

            for j=1:n_slice
                im{i}(:,:,j) = datai{(j-1)*n_chan+chan, 1};
            end

        end
        
        [names,idx] = sort_nat(names);
        im = im(idx);

        n_z = cellfun(@(m) size(m,3), im);
        n_z_max = max(n_z);


        t = table();
        for i=1:n_im

            z = nan(1,n_z_max);

            sz = size(im{i});
            imi = reshape(im{i},[sz(1)*sz(2), sz(3)]);
            z(1:sz(3)) = nanmean(imi,1);

            name = strrep(names{i},' ','_');
            name =  matlab.lang.makeValidName(name);
            t.(name) = z';
            plot(z)
            hold on
        end

        x = 1:n_z_max;
        lim = 3*n_z_max;
        xx = -lim:1:lim;
        fields = t.Properties.VariableNames;

        clf
        yy = [];

        for i=1:length(fields)
            y = t.(fields{i}); 
            g = gradient(y);
            xmi = find(g<0,1,'first');

            %[~,xmi] = max(y);
            yy(:,i) = interp1(x,y,xx+xmi);
        end
        plot(xx,yy);

        p = nanmax(yy,[],2);
        x1 = find(~isnan(p),1,'first');
        x2 = find(~isnan(p),1,'last');

        xx = xx(x1:x2);
        yy = yy(x1:x2,:);

        ta = table();

        for i=1:length(fields)
            ta.(fields{i}) = yy(:,i);
        end

        outfile = strrep(file,'.lif','-z-profile.csv');
        writetable(t, outfile);

        outfile = strrep(file,'.lif','-z-profile-aligned.csv');
        writetable(ta, outfile);
    end
end