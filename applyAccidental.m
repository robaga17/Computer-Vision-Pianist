function unitMap = applyAccidental(unitMap, tb, object, section)
% object.Label must be 'natural', 'flat', or 'sharp'
% applies accidental to the appropirate units in unitMap
% handles case were object is part of the key signature

halfSpace = (section.TrebleRows(2) - section.TrebleRows(1))/2;
if tb == 1
    midCRow = section.TrebleRows(5) + halfSpace*2;
else
    midCRow = section.BassRows(1) - halfSpace*2;
end

if strcmp(object.Label, 'flat')
    actualRow = object.Stats.Centroid(2) + object.Stats.BoundingBox(4)/8;
else
    actualRow = object.Stats.Centroid(2);
end
offset = round((midCRow - actualRow)/halfSpace);
if offset > 14 || offset < -14
    return
end
pitch = offset + 15;

colStart = round(object.Stats.Centroid(1));
colEnd = section.BarLines(1);
i = 1;
while i <= length(section.BarLines) && section.BarLines(i) < colStart
    i = i + 1;
end
if i == length(section.BarLines)
    return
elseif i == 2 && (colStart-section.BarLines(1))/(section.BarLines(2)-section.BarLines(1)) < 3/8
    % key sig
    colEnd = section.BarLines(end);
else
    % accidental
    colEnd = section.BarLines(i);
end
   
accidental = 0;
if strcmp(object.Label, 'flat')
    accidental = -0.5;
elseif strcmp(object.Label, 'sharp')
    accidental = 0.5;
end
    
for c = colStart:colEnd
    for p = getOctaves(pitch)
        if ~isempty(unitMap{tb}{p, c})
            unitMap{tb}{p, c}.Accidental = accidental;
        end
    end
end

end