function dist = levDistance(s, t)
% Computes Levenshtein distance of s and t
% pseudo code from https://en.wikipedia.org/wiki/Levenshtein_distance

m = length(s);
n = length(t);

d = zeros(m+1, n+1);

for i = 1:m
    d(i+1, 1) = i;
end

for j = 1:n
    d(1, j+1) = j;
end

for j = 1:n
    for i = 1:m
        if s(i) == t(j)
            cost = 0;
        else
            cost = 1;
        end
        d(i+1, j+1) = min([d(i, j+1)+1, d(i+1, j)+1, d(i,j)+cost]);
    end
end

dist = d(m+1, n+1);
end

