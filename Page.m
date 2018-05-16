classdef Page < MusicPlayer
    % Represents one page of a score
    
    properties
        FilePath
        Sections
        Image
    end
    
    methods
        function page = Page(filePath)
            page.FilePath = filePath;
            page.Sections = {};
            page.Image = [];
        end
        
        function img = getImage(self)
            if ~isempty(self.Image)
                img = self.Image;
                return
            end
            img = imread(self.FilePath);
            [~, ~, np] = size(img);
            if np == 3
                img = rgb2gray(img);
            end
            img = imbinarize(img);
            img = ~img;
            self.Image = img;
        end
        
        function [img, staffLines]  = getCleanImage(self)
            % img = binary page (1=black, 0=white) without non-musical words, or staff
            %   lines
            % staffLines = rows of staff lines (one per line)

            img = self.getImage();
            
            staffRows = Page.getStaffRows(img);
            [img, staffLines] = Page.removeStaffLines(img, staffRows);
            img = self.repairImage(img);
        end
      
        function img = repairImage(self, img)
            orig = self.getImage();
            
            % repair half notes
            kernel = imread('kernels/halfNote.jpg');
            if size(kernel, 3) == 3
                kernel = rgb2gray(kernel);
            end
            kernel = imbinarize(kernel);
            kernelVolume = sum(sum(kernel));
            kernel = double(kernel);
            kernel(kernel==0) = -1;
            convPlot = conv2(img, kernel, 'same');
            convPlot = (kernelVolume * 0.45 < convPlot);
            cc = bwconncomp(convPlot);
            if cc.NumObjects ~= 0
                labeled = labelmatrix(cc);
                [kr, kc] = size(kernel);
                kernel(kernel==-1) = 0;
                for i = 1:cc.NumObjects
                    noteSpace = labeled == i;
                    stats = regionprops(noteSpace);
                    centroid = stats.Centroid;
                    img(round(centroid(2)-kr/2):round(centroid(2)+kr/2)-1, round(centroid(1)-kc/2):round(centroid(1)+kc/2)-1) = img(round(centroid(2)-kr/2):round(centroid(2)+kr/2)-1, round(centroid(1)-kc/2):round(centroid(1)+kc/2)-1) + kernel;
                end
            end
            
            % repair whole notes
            kernel = imread('kernels/wholeNote.jpg');
            if size(kernel, 3) == 3
                kernel = rgb2gray(kernel);
            end
            kernel = imbinarize(kernel);
            kernelVolume = sum(sum(kernel));
            kernel = double(kernel);
            kernel(kernel==0) = -1;
            convPlot = conv2(orig, kernel, 'same');
            convPlot = (kernelVolume * 0.45 < convPlot);
            cc = bwconncomp(convPlot);
            if cc.NumObjects ~= 0
                labeled = labelmatrix(cc);
                [kr, kc] = size(kernel);
                kernel(kernel==-1) = 0;
                for i = 1:cc.NumObjects
                    noteSpace = labeled == i;
                    stats = regionprops(noteSpace);
                    centroid = stats.Centroid;
                    img(round(centroid(2)-kr/2):round(centroid(2)+kr/2)-1, round(centroid(1)-kc/2):round(centroid(1)+kc/2)-1) = img(round(centroid(2)-kr/2):round(centroid(2)+kr/2)-1, round(centroid(1)-kc/2):round(centroid(1)+kc/2)-1) + kernel;
                end
            end
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
        
        function tempo = getTempo(self)
            img = self.getImage();
            [nr, nc] = size(img);
            region = img(1:round(nr/4), 1:round(nc/2));
            text = ocr(bwmorph(region, 'skel', inf));
            tempo = tempoMatcher(text.Words);
        end
        
        function audio = getAudio(self)
            tempo = self.getTempo;
            len = round(1/(tempo/60*4/self.Frequency)); % num spaces occupied by a sixteenth note
            sections = self.getSections();
            audio = zeros(len*16*length(sections{1}.BarLines)*length(sections)*2, 2);
            audioIdx = 1;
            for i = 1:length(sections)
                section = sections{i};
                unitMap =  section.getUnitMap();
                
                % see condensed unitMap
                condensed1 = unitMap{1}(:, any(~cellfun('isempty', unitMap{1}), 1));
                condensed2 = unitMap{2}(:, any(~cellfun('isempty', unitMap{2}), 1));
                
                for j = 1:length(section.BarLines)-1
                    colStart = section.BarLines(j);
                    colEnd = section.BarLines(j+1) - 1;
                    trebleBarAudio = [];
                    bassBarAudio = [];
                    for col = colStart:colEnd
                        trebleColAudio = [];
                        bassColAudio = [];
                        for p = 1:30
                            if ~isempty(unitMap{1}{p, col})
                                unit = unitMap{1}{p, col};
                                unitAudio = unit.getAudio(len);
                                trebleColAudio = mergeAudio(trebleColAudio, unitAudio);
                            end
                            if ~isempty(unitMap{2}{p, col})
                                unit = unitMap{2}{p, col};
                                unitAudio = unit.getAudio(len);
                                bassColAudio = mergeAudio(bassColAudio, unitAudio);
                            end
                        end
                        trebleBarAudio = concatenateAudio({trebleBarAudio, trebleColAudio});
                        bassBarAudio = concatenateAudio({bassBarAudio, bassColAudio});
                    end
                    barAudio = mergeAudio(trebleBarAudio, bassBarAudio);
                    audio(audioIdx:audioIdx+length(barAudio)-1, :) = barAudio;
                    audioIdx = audioIdx + length(barAudio);
                end         
            end
            while any(audio(audioIdx+1, :))
                audioIdx = audioIdx + 1;
            end
            audio = audio(1:audioIdx, :);
        end
        
    end
    
    
    methods (Static)
        function staffRows = getStaffRows(img)
            % staffRows = all rows that contain a staff line
            % a single staff line can be spread over multiple rows

            [nr, nc] = size(img);
            % make 0=black and 1=white to make logic easier
            img = ~img;

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
            
            
        end
 
        function [img, staffLines] = removeStaffLines(img, staffRows)
            % page = page without staff lines
            % staffLines = positions of staff lines that were removed 
            %   (median of a staff line's rows)

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

