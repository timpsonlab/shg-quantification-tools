function Compile
    
    % Build GLCM MEX file
    mex glcm.cpp 'CXXFLAGS="$CXXFLAGS -O3"'
    
    GetBioformats();
    
    % Get version
    [~,ver] = system('git describe','-echo');
    
    % Build App
    mkdir('build');
    delete(['build' filesep '*']);
    mcc('-m','Interface.m', ...
        '-a','bfmatlab', ...
        '-a','glcm.*', ...
        '-C', '-v', '-m', '-d', 'build', '-o', 'SHG_Quantification_Tools');
        
    if ispc
        ext = '.exe';
    else
        ext = '.app';
    end
   
    movefile(['build' filesep 'SHG_Quantification_Tools' ext], ['build' filesep 'SHG Quantification Tools ' ver ext]);
        