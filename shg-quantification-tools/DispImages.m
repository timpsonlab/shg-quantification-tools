function DispImages(ims, names)

fh = figure(20);
set(fh, 'Name', 'Image Display', 'NumberTitle', 'off');
cur_image = 1;
imh = [];

displayImage();

axh = gca();
set(fh, 'KeyPressFcn', @keyPress);

    function displayImage()

        imh = imagesc(max(ims{cur_image}(:,:,1,:),[],4));
        set(gca,'XTick',[],'YTick',[]);
        caxis([0 4000])
        daspect([1 1 1])
        %tightfig();
        title(names{cur_image});        
    end
    
    function keyPress(~,data)
       set(fh,'Pointer','crosshair')
        switch data.Key
           case 'rightarrow'
               cur_image = mod(cur_image, length(ims)) + 1;
               displayImage();
           case 'leftarrow'
               cur_image = mod(cur_image - 2, length(ims)) + 1;
               displayImage();
       end     
       
    end


end

