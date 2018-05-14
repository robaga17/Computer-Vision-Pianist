function unitMap = applyAccent(unitMap, tb, object, section)
halfSpace = (section.TrebleRows(2) - section.TrebleRows(1))/2;
if tb == 1
    midCRow = section.TrebleRows(5) + halfSpace*2;
else
    midCRow = section.BassRows(1) - halfSpace*2;
end

actualRow = object.Stats.Centroid(2);
offset = round((midCRow - actualRow)/halfSpace);
pitch = offset + 15;

col = object.Stats.Centroid(1);

for p = max(1, pitch-3) : 1 : min(29, pitch + 3)
    for c = col-5 : 1 : col+5
        if ~isempty(unitMap{tb}{p, c})
            unitMap{tb}{p, c}.Articulation = 's';
            return
        end
    end
end

end