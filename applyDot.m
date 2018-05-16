function unitMap = applyDot(unitMap, tb, object, section)
% object.Label must be 'dot'
% applies dot to appropirate unit in unitMap
% handles case where dot is actually a staccato

halfSpace = (section.TrebleRows(2) - section.TrebleRows(1))/2;
if tb == 1
    midCRow = section.TrebleRows(5) + halfSpace*2;
else
    midCRow = section.BassRows(1) - halfSpace*2;
end

isStaccato = 0;
actualRow = object.Stats.Centroid(2);
offset = round((midCRow - actualRow)/halfSpace);
if offset > 14 || offset < -14
    isStaccato = 1;
end
pitch = offset + 15;

dotCol = object.Stats.Centroid(1);

if ~isStaccato
    for c = dotCol-10 : -1 : dotCol-30
        if ~isempty(unitMap{tb}{pitch, c})
            unitMap{tb}{pitch, c}.dot();
            return
        elseif ~isempty(unitMap{tb}{pitch-1, c})
            unitMap{tb}{pitch-1, c}.dot();
            return
        end
    end
end

for p = max(1, pitch-3) : 1 : min(29, pitch + 3)
    for c = dotCol-5 : 1 : dotCol+5
        if ~isempty(unitMap{tb}{p, c})
            unitMap{tb}{p, c}.Articulation = 's';
            return
        end
    end
end
end




