function [source_1, source_2] = find_max(P)
%FIND_MAX Summary of this function goes here
%   Detailed explanation goes here
theta = -90:1:90;
[pks, locs] = findpeaks(abs(P));
[pks, Idx] = sort(pks);
pks = fliplr(pks);
Idx = fliplr(Idx);
[isize, ~] = size(Idx);
if isize >= 2
    res = locs(Idx(1:2));
    source_1 = theta(res(1));
    source_2 = theta(res(2));
elseif isize == 1
    res = locs(Idx(1));
    source_1 = theta(res(1));
    source_2 = 1000;
else
    source_1 = 1000;
    source_2 = 1000;
end
tmp = sort([source_1 source_2]);
source_1 = tmp(1);
source_2 = tmp(2);

end

