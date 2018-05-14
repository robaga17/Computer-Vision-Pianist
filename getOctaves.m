function octaves = getOctaves(pitch)
startPitch = mod(pitch-1, 7) + 1;
octaves = startPitch : 7 : 29;


end

