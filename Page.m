classdef Page < MusicPlayer
    % Represents one page of a score
    
    properties
        FilePath
        Sections
    end
    
    methods
        function page = Page(filePath)
            page.FilePath = filePath;
            page.Sections = {};
        end
        
        function [img, staffLines]  = getCleanImage(self)
            % img = binary page (1=black, 0=white) without non-musical words, or staff
            %   lines
            % staffLines = rows of staff lines (one per line)

            img = imread(self.FilePath);
            [~, ~, np] = size(img);
            if np == 3
                img = rgb2gray(img);
            end
            img = imbinarize(img);
            img = ~img;

            staffRows = Page.getStaffRows(img);
            [img, staffLines] = Page.removeStaffLines(img, staffRows);
        end
      
        function sections = getSections(self)
            if ~isempty(self.Sections)
                sections = self.Sections;
                return
            end
            
            [img, staffLines] = self.getCleanImage();
            [nr, ~] = size(img);
            
            % get splits (the rows that divide the page into its sections)
            splits = [];
            for i = 11:10:length(staffLines)
                % TODO: optimize
                splits = [splits, floor((staffLines(i-1)+staffLines(i))/2)];
            end
            splits = [1, splits];
            splits = [splits, nr];

            % build sections
            sections = cell(length(splits)-1, 1);
            for i = 1:length(splits)-1
                sectionImg = img(splits(i):splits(i+1)-1, :);
                trebleRows = staffLines(i*10-9:i*10-5) - splits(i) + 1;
                bassRows = staffLines(i*10-4:i*10) - splits(i) + 1;
                sections{i} = Section(sectionImg, trebleRows, bassRows);
            end
            self.Sections = sections;
        end
        
        function structure = getStructure(self)
            structure1 = {};
            structure2 = {};
            sections = self.getSections();
            for i = 1:length(sections)
                section = sections{i};
                unitMap =  section.getUnitMap();
                s1 = unitMap{1}(:, any(~cellfun('isempty',unitMap{1}), 1));
                s2 = unitMap{2}(:, any(~cellfun('isempty',unitMap{2}), 1));
                structure1 = [structure1, s1];
                structure2 = [structure2, s2];
            end
            structure = {structure1, structure2};
        end
        
        function audio = getAudio(self)
            sections = self.getSections();
            audioList = cell(length(sections), 1);
            for i = 1:length(sections)
                audioList{i} = sections{i}.getAudio();
            end
            audio = concatenateAudio(audioList);
        end
        
    end
    
    methods (Static)
        function staffRows = getStaffRows(img)
            % staffRows = all rows that contain a staff line
            % a single staff line can be spread over multiple rows

            [nr, nc] = size(img);
            % make 0=black and 1=white to make logic easier
            img = ~img;

            % TODO: come up with better identification
            %   noise resistant, expects noise above and below
            % examine the middle section of each row
            start = round(nc/3);
            finish = nc-round(nc/4);
            rowSums = sum(img(:, start:finish), 2);

            % collect all rows that are below the threshold
            THRESHOLD = nc/100;
            staffRows = zeros(nr, 1);
            i = 0;
            for j = 1:nr
                if rowSums(j) < THRESHOLD
                    i = i + 1;
                    staffRows(i) = j;
                end
            end
            staffRows = staffRows(1:i);

            if isempty(staffRows)
                error('staffRows is empty');
            end
            % The code below is an attempt to identify rows via derivatives
            % rowSums = sum(img, 2);
            % rowSums = rowSums - min(min(rowSums));
            % 
            % rowSumDerivs = zeros(nr, 1);
            % for r = 2:nr
            %     rowSumDerivs(r) = rowSums(r) - rowSums(r-1);
            % end
            % plot(rowSumDerivs);
            % 
            % sortedRowSumDerivs = sort(rowSumDerivs);
            % 
            % negDerivCutoff = sortedRowSumDerivs(1);
            % largestJump = 0;
            % i = 1;
            % while i < nr && sortedRowSumDerivs(i+1) <= 0
            %     jump = abs(sortedRowSumDerivs(i) - sortedRowSumDerivs(i+1));
            %     if jump > largestJump
            %         negDerivCutoff = sortedRowSumDerivs(i);
            %         largestJump = jump;
            %     end
            %     i = i + 1;
            % end
            % 
            % posDerivCutoff = sortedRowSumDerivs(nr);
            % largestJump = 0;
            % i = nr;
            % while i > 1 && sortedRowSumDerivs(i-1) >= 0
            %     jump = abs(sortedRowSumDerivs(i) - sortedRowSumDerivs(i-1));
            %     if jump > largestJump
            %         posDerivCutoff = sortedRowSumDerivs(i);
            %         largestJump = jump;
            %     end
            %     i = i - 1;
            % end
            % 
            % rowSumDerivs = rowSumDerivs .* ((rowSumDerivs <= negDerivCutoff) + (rowSumDerivs >= posDerivCutoff));
            % plot(rowSumDerivs);
            % 
            % lineRows = zeros(nr, 1);
            % i = 1;
            % inLine = 0;
            % for j = 1:nr
            %     if rowSumDerivs(j) < 0
            %         lineRows(i) = j;
            %         i = i + 1;
            %         inLine = 1;
            %     elseif rowSumDerivs(j) > 0
            %         inLine = 0;
            %     elseif inLine
            %         lineRows(i) = j;
            %         i = i + 1;
            %     end
            % end
            % 
            % i = 2;
            % while i <= nr && lineRows(i) ~= 0
            %     i = i + 1;
            % end
            % lineRows = lineRows(1:i-1);
        end
 
        function [img, staffLines] = removeStaffLines(img, staffRows)
            % page = page without staff lines
            % staffLines = positions of staff lines that were removed 
            %   (median of a staff line's rows)

            % TODO: better removal proccess
            %   Account for curves (slurs)
            %   Account for the row below
            
            % TODO: time this and see if any optimizations possible

            % to get staffLines, get median of each group of staffRows
            [~, nc] = size(img);
            staffLines = zeros(length(staffRows), 1);
            positions = blanks(length(staffRows));
            i = 1;
            j = 1;
            while j <= length(staffRows)
                k = 1;
                % find grouping
                while j+k <= length(staffRows) && staffRows(j+k) == staffRows(j)+k
                    k = k + 1;
                end
                % each staffRow is labeled: t = top, b = bottom, s = single, m = middle
                positions(j) = 't';
                positions(j+k-1) = 'b';
                if k == 1
                    positions(j) = 's';
                end
                for m = j+1:j+k-2
                    positions(m) = 'm';
                end
                % get median of grouping
                staffLines(i) = staffRows(floor((2*j+k-1)/2));
                i = i + 1;
                j = j + k;
            end
            staffLines = staffLines(1:i-1);

            % Remove middle staffLines
            for i = 1:length(positions)
                if positions(i) == 'm'
                    r = staffRows(i);
                    img(r, :) = img(r, :) * 0;
                end
            end
            
            for i = 1:length(positions)
                r = staffRows(i);
                % remove unneeded top/bottom staffLine pixels
                for c = 1:nc
                    if (positions(i) == 't' && ~img(r-1, c)) || (positions(i) == 'b' && ~img(r+1, c))
                        img(r, c) = 0;
                    end
                end
                % fill in horizontal continuity gaps
%                 rangeParam = 3;
%                 % TODO: make more efficient
%                 for c = rangeParam+1:nc-rangeParam
%                     if sum(img(r, c-rangeParam:c-1)) >= 1 && sum(img(r, c+1:c+rangeParam)) >= 1
%                         img(r, c) = 1;
%                     end
%                 end
%                 for c = nc-rangeParam:-1:rangeParam+1
%                     if sum(img(r, c-rangeParam:c-1)) >= 1 && sum(img(r, c+1:c+rangeParam)) >= 1
%                         img(r, c) = 1;
%                     end
%                 end
            end
            % fill in vertical continuity gaps
            for i = 1:length(positions)
                if positions(i) == 'm'
                    r = staffRows(i);
                    for c = 1:nc
                        if img(r+1, c) || img(r-1, c)
                            img(r, c) = 1;
                        end
                    end
                end
            end
            
            % staff lines should always be in multiples of 5
            if mod(length(staffLines), 5) ~= 0
                error('lineRows not in 5s');
            end
        end
    end
end

