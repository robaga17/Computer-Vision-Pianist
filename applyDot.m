function unitMap = applyDot(unitMap, tb, object, section)

halfSpace = (section.TrebleRows(2) - section.TrebleRows(1))/2;
if tb == 1
    midCRow = section.TrebleRows(5) + halfSpace*2;
else
    midCRow = section.BassRows(1) - halfSpace*2;
end

actualRow = object.Stats.Centroid(2);
offset = round((midCRow - actualRow)/halfSpace);
if offset > 14 || offset < -14
    return
end
pitch = offset + 15;

dotCol = object.Stats.Centroid(1);
for c = dotCol-10 : -1 : dotCol-30
    if ~isempty(unitMap{tb}{pitch, c})
        unitMap{tb}{pitch, c}.dot();
        return
    elseif ~isempty(unitMap{tb}{pitch-1, c})
        unitMap{tb}{pitch-1, c}.dot();
        return
    end
        
end




