folder = ['/Volumes/Seagate Backup Plus Drive/SHG Data/'];
file = '2015-07-22 SHG.lif';

data = bfopen([folder file]);
%%

n_chan = 2;
n_im = size(data,1);

im = cell(1,n_im);
names = cell(1,n_im);

for i=1:n_im
   
    md = data{i,1}{1,2};
    md = strsplit(md, '; ');
    names{i} = md{2};
    
    datai = data{i, 1};
    n_slice = size(datai,1); 
        
    for j=1:n_slice
        im{i}(:,:,j) = datai{j,1};
    end
    
    sz = size(im{i});
    im{i} = reshape(double(im{i}), [sz(1:2) n_chan sz(3)/n_chan]);
    
    
end

order = [1 2 3 4 5 6 18 7 8 9 10 11 12 13 14 15 16 17];
im = im(order);
names = names(order);

%%

n_rep = 3;
n_cond = 2;

zprofile_I = [];
zprofile_r = [];

for i=1:n_im
    
    im{i}(im{i}>=4095) = nan;
    
    zprofile = squeeze(nanmean(nanmean(im{i},1),2))';
    
    zprofile_I(:,i) = zprofile(:,1) + 2 * zprofile(:,2);  
    zprofile_r(:,i) = (zprofile(:,1) - zprofile(:,2)) ./ zprofile_I(:,i);  
    
end


sz = size(zprofile_I);
zprofile_I_all = reshape(zprofile_I,[sz(1) sz(2)/n_rep n_rep]);
zprofile_r_all = reshape(zprofile_r,[sz(1) sz(2)/n_rep n_rep]);

zprofile_I = mean(zprofile_I_all,3);
zprofile_r = mean(zprofile_r_all,3);

zprofile_I_all = reshape(zprofile_I_all, [sz(1) sz(2)/(n_cond) n_cond]);
zprofile_r_all = reshape(zprofile_r_all, [sz(1) sz(2)/(n_cond) n_cond]);

sz = size(zprofile_I);
zprofile_I = reshape(zprofile_I,[sz(1) sz(2)/n_cond n_cond]);
zprofile_r = reshape(zprofile_r,[sz(1) sz(2)/n_cond n_cond]);

zprofile_I_mean = squeeze(mean(zprofile_I,2));
zprofile_r_mean = squeeze(mean(zprofile_r,2));

zprofile_I_std = squeeze(std(zprofile_I,1,2));
zprofile_r_std = squeeze(std(zprofile_r,1,2));


%%

set(0, 'DefaultAxesFontSize',14)

zstep = 2.5;
z1 = (0:(size(zprofile_I_mean,1)-1))' * 2.5;
z = repmat(z1,[1 n_cond]);

subplot(1,2,1)
errorbar(z,zprofile_I_mean, zprofile_I_std);
%ylim([0 3000]);
legend({'Igg', '\alpha-Lox'},'Box','off'); 
set(gca,'Box','off','TickDir','out');
ylabel('SHG Intensity')
xlabel('Depth (\mum)');


subplot(1,2,2)
errorbar(z,zprofile_r_mean, zprofile_r_std);
%ylim([0 0.4]);
legend({'Igg', '\alpha-Lox'},'Box','off'); 
set(gca,'Box','off','TickDir','out');
ylabel('Anisotropy')
xlabel('Depth (\mum)');

%%

for i=1:n_cond
    subplot(1,n_cond,i);
    plot(z1,zprofile_I_all(:,:,i))
    ylim([0 3000])
end
