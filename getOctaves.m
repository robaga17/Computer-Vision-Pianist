function octaves = getOctaves(pitch)
% gets all of the octaves of pitch

startPitch = mod(pitch-1, 7) + 1;
octaves = startPitch : 7 : 29;
end

