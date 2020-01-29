function output = circ_smooth(varargin)
%CIRC_SMOOTH applies a smoothing algorithm on the input Yin,Xin data,
%assuming that there is data wrap around. This means you can get away with
%using values from the other end of the vector in your smoothing
%calculation, which reduces the edge effects associated with it. Please
%note that you CANNOT use this with arbitrary x-spacing. So please ensure
%you are happy to use a uniform spacing system.
%
%   -Yin is the vector of the y-values.
%
%   -Xin is an optional argument that allows arbritary assignment of
%   x-spacing. Please ensure this is ordered.
%
%   -method is a string that specifies the method. See the help
%   documentation for matlab's 'smooth' function for more.
%
%   -span is the span of the smoothing window. Again, see the help
%   documentation for matlab's 'smooth' function for more.
%
%Valid input patterns:
%
%   -circ_smooth(Yin)
%   -circ_smooth(Yin,method)
%   -circ_smooth(Yin,span)
%   -circ_smooth(Yin,method,span)

%Prepare inputs...
switch nargin
    case 1
        Yin = varargin{1};
        method = 'moving';
        span = round(length(Yin)/8);
    case 2
        if ischar(varargin{2})
            Yin = varargin{1};
            method = varargin{2};
            span = round(length(Yin)/8);
        elseif numel(varargin{2}) == 1
            Yin = varargin{1};
            method = 'moving';
            span = varargin{2};
        end
    case 3
        Yin = varargin{1};
        method = varargin{2};
        span = varargin{3};
end 

[yr,yc] = size(Yin);
if yr < 2
    Yin = Yin';
elseif yr > 1 && yc > 1
    error('Y input was not a vector')
end

%Apply smoothing...
spanWraps = ceil(length(Yin) / (length(Yin) - span)); %The number of times the smooth function will need to be rerun.
wrapLength = length(Yin)/spanWraps; %The amount of padding on the input vectors that needs to be done to allow wrapping.
lowCut = round(length(Yin)/2 - wrapLength/2);
hiCut = round(length(Yin)/2 + wrapLength/2);

smoothStore = zeros(size(Yin));
for i = 0:spanWraps - 1
    Ytemp = [Yin(round(wrapLength*i+1):end);Yin(1:round(wrapLength*i))];
    smoothTemp = smooth(Ytemp,span,method);
    smoothSlice = smoothTemp(lowCut:hiCut);
    
    lowStore = rem(round(i*wrapLength) + lowCut,length(Yin));
    hiStore = rem(round(i*wrapLength) + hiCut,length(Yin));
    
    if hiStore == 0
        hiStore = length(Yin); %Since matlab does indices from 1.
    end
    if lowStore == 0
        lowStore = length(Yin);
    end
    
    if hiStore < length(Yin)/2 && lowStore > length(Yin)/2 %So if the insertion has just wrapped around...
        outHi = length(smoothStore(lowStore:end));
        smoothStore(lowStore:end) = smoothSlice(1:outHi);
        smoothStore(1:hiStore) = smoothSlice(outHi+1:end);
    else
        smoothStore(lowStore:hiStore) = smoothSlice; %Bit convoluted, but smoothStore should have its elements stored in register with the input vectors.
    end
end
output = smoothStore;