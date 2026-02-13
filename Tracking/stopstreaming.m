function stopstreaming(sensor)
%STOPSTREAMING stop data streaming from the radar sensor
%   sensor      radar sensor device

switch sensor.mode
    case 'dffile'
        disp('stopped reading data');

    otherwise
    	error('unsupported mode');
end

end
