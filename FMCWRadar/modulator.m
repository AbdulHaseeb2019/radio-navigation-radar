function modulation=modulator(sensor)
%MODULATOR generate a triangle
% linearize the VCO
%   modulation  modulation voltage
%   sensor      radar sensor device

switch sensor.mode
    case 'st200klcfmcw'
        % tuning data for K-LC2 provided by RFbeam
        voltage=[2 1 -0.5];
        frequency=[24045000000 24108000000 24197000000];
        vmin=-0.5; % minimum voltage
        vmax=2; % maximum voltage
        
        % quadratic polynomial
        [p,~,mu]=polyfit(frequency,voltage,2);

        % down-chirp and up-chirp
        f=cat(1,linspace(frequency(end),frequency(1),sensor.L)',linspace(frequency(1),frequency(end),sensor.L)');

        % quadratic interpolation
        modulation=polyval(p,f,[],mu);

        % clipping, security check
        modulation=min(max(modulation,vmin*ones(size(f))),vmax*ones(size(f)));

    case 'st200kmcfmcw'
        % tuning data for K-MC1 provided by RFbeam
        voltage=[1 5 10];
        frequency=[24021000000 24079000000 24183000000];
        vmin=0; % minimum voltage
        vmax=10; % maximum voltage

        % quadratic polynomial
        [p,~,mu]=polyfit(frequency,voltage,2);

        % down-chirp and up-chirp
        f=cat(1,linspace(frequency(end),frequency(1),sensor.L)',linspace(frequency(1),frequency(end),sensor.L)'); 

        % quadratic interpolation
        modulation=polyval(p,f,[],mu);

        % clipping, security check
        modulation=min(max(modulation,vmin*ones(size(f))),vmax*ones(size(f)));
        
    otherwise
    	error('unsupported mode');

end
