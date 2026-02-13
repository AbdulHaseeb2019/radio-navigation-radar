function radc=mti(radcnew)
%MTI moving target indication
% single canceller
%   radc        data vector with complex raw adc values
%   radcnew     new measurement

persistent radcold

if isempty(radcold)
    radcold=zeros(size(radcnew)); % initialize filter
end

radc=radcnew-radcold;
radcold=radcnew;

end
