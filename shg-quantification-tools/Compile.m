function Compile
    
    % Build GLCM MEX file
    mex glcm.cpp 'CXXFLAGS="$CXXFLAGS -O3"'
    
    GetBioformats();
    
    % Get version
    [~,ver] = system('git describe','-echo');
    
    % Build App
    try
        rmdir('build','s');
    catch
    end
    mkdir('build');
    
    mcc('-m','Interface.m', ...
        '-a','bfmatlab', ...
        '-a','glcm.*', ...
        '-C', '-v', '-m', '-d', 'build', '-o', 'SHG_Quantification_Tools');
        
    if ispc
        ext = '.exe';
    else
        ext = '.app';
    end
   
    new_file = ['SHG Quantification Tools ' ver];

    movefile(['build' filesep 'SHG_Quantification_Tools' ext], ['build' filesep new_file ext]);
    
    if ismac
        mkdir(['build' filesep 'dist']);
        movefile(['build' filesep new_file ext], ['build' filesep 'dist' filesep new_file ext]);
        cmd = ['hdiutil create "./build/' new_file '.dmg" -srcfolder ./build/dist/ -ov'];
        disp(cmd)
        system(cmd)
    end
    
    