function CodeTMAImages(root)

    if nargin < 1
        root = uigetdir('Choose Folder');
    end

    tma_folder = ['TMAs' filesep];

    folders = dir([root tma_folder]);
    folders = folders(folders.isdir);
    folders = folders.name;


folders = {'TMA#1', 'TMA#2', 'TMA#3'};
root = '/Volumes/Seagate Backup Plus Drive 1/SHG Data/TMAs/';
output_folder = 'Montages/';

line_table = readtable([root 'Cell Line Codes.csv']);

rows = {'A'; 'B'; 'C'; 'D'; 'E'; 'F'; 'G'; 'H'};
cols = num2cell(1:12);

pos_names = cellfun(@(a,b) [a num2str(b)], repmat(rows,[1 12]), repmat(cols,[8 1]), 'UniformOutput', false);

for i=1:length(folders)
   
    codes_file = [root folders{i} ' codes.csv'];
    codes = csvread(codes_file,1,1);
    
    unique_codes = unique(codes(:));
    unique_codes = unique_codes(unique_codes > 0);
    
    for j=1:length(unique_codes)
    
        code = unique_codes(j);
        
        line = line_table.Line(line_table.Code == code)
        
        if isempty(line)
            line = '';
        else
            line = [' ' line{1}];
        end
        
        output = [num2str(code) line]
        
        sel_pos = pos_names(codes == code);
        
        im = [];
        for k=1:length(sel_pos)
            filename = [root folders{i} filesep folders{i} '_' sel_pos{k} '.tif'];
            
            imi = imread(filename);
            
            output_file = [root 'Coded Images' filesep output '_' num2str(k) '.tif'];
            imwrite(imi, output_file);
            
            im = [im, imi];
        end
        
        cmap = hot(256);
        
        ims = uint8(double(im) / 70 * 255);
        
        imc = ind2rgb(ims,cmap);
        
        output_file = [root output_folder output '.tif'];
        imwrite(im, output_file)

        output_file = [root output_folder 'Mapped ' output '.tif'];
        imwrite(imc, output_file)

        
        imagesc(im); daspect([1 1 1]);
        drawnow
        
        
    end
    
end