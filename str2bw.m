function bw = str2bw(nr, nc, s)

chunks = strsplit(s);
bw = zeros(nr, nc);
for i = 1:length(chunks)-1
    binVec = hexToBinaryVector(chunks{i});
    bw(i, end-length(binVec)+1:end) = binVec;
end

end

