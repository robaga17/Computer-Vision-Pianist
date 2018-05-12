function visualizeUnitMap(unitMap)
for i = 1:2
    figure
    title(num2str(i))
    hold on
    [nr, nc] = size(unitMap{i});
    for r = 1:nr
        for c = 1:nc
            if isempty(unitMap{i}{r, c})
                continue
            end
            unit = unitMap{i}{r, c};
            if unit.N16ths == 1
                color = 'r*';
            elseif unit.N16ths == 2
                color = 'm*';
            elseif unit.N16ths == 4
                color = 'c*';
            elseif unit.N16ths == 8
                color = 'g*';
            elseif unit.N16ths == 16
                color = 'k*';
            end
            plot(c, r, color);
        end
    end
end

