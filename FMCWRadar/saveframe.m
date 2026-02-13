function saveframe(sensor,df)
%SAVEFRAME save detection results to the file
% adds range-velocity information to the file
%   sensor      radar sensor device
%   df          detected frequency shifts

switch sensor.mode
    case 'convert'
        % save data to HDF5 file
        info=h5info(sensor.file,'/df');
        h5write(sensor.file,'/df',df(:),[1 info.Dataspace.Size(2)+1],[2 1]);
        
    case {'st200klcfmcw','st200kmcfmcw','fmcwfile'}
        
    otherwise
    	error('unsupported mode');
end

end
