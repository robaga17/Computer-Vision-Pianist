classdef Note < MusicPlayer
    
    properties
        Section
        Object
        Contents
        Dotted
    end
    
    methods
        function note = Note(section, object)
            note.Section = section;
            note.Object = object;
            note.Contents = {};
            note.Dotted = 0;
        end
        
        function buildContents(self)
            trebleRows = self.Section.TrebleRows;
            bassRows = self.Section.BassRows;
            img = self.Object.Image;
            [nr, nc] = size(img);
            label = self.Object.Label;
            % TODO: put this logic in Musical Object
            if strcmp(label, 'qrest')
                self.Contents = cell(4, 1);
                return;
            end
            if strcmp(label, 'n h')
                kernel = imread('kernels/halfNote.jpg');
            else
                kernel = imread('kernels/filledNote.jpg');
            end
            if size(kernel, 3) == 3
                kernel = rgb2gray(kernel);
            end
            kernel = imbinarize(kernel);
            kernelVolume = sum(sum(kernel));
            [kr, kc] = size(kernel);
            pitchPlot = zeros(nr, nc);
            for r = 1:nr-kr+1
                for c = 1:nc-kc+1
                    matchScore = sum(sum(img(r:r+kr-1,c:c+kc-1) .* kernel)) / kernelVolume;
                    if (strcmp(label, 'n h') && matchScore > .75) || matchScore == 1
                        pitchPlot(floor(r+kr/2), floor(c+kc/2)) = 1;
                    end
                end
            end
            [cc, labeled] = extractObjects(pitchPlot);
            centroids = {};
            for i = 1:cc.NumObjects
                noteSpace = labeled == i;
                stats = regionprops(noteSpace);
                centroids{length(centroids)+1} = round(stats.Centroid);
            end
            halfSpace = (trebleRows(2) - trebleRows(1))/2;
            trebleMidCRow = trebleRows(5) + halfSpace*2;
            bassMidCRow = bassRows(1) - halfSpace*2;
            pitches = {};
            for i = 1:length(centroids)
                actualRow = centroids{i}(2) + self.Object.BoundingBox(2)- 5;
                trebleOffset = round((actualRow - trebleMidCRow)/halfSpace);
                bassOffset = round((actualRow - bassMidCRow)/halfSpace);
                if abs(trebleOffset) < abs(bassOffset)
                    % in treble cleff
                    pitches{length(pitches)+1} = trebleOffset;
                else
                    % in bass cleff
                    pitches{length(pitches)+1} = bassOffset;
                end
            end
            if strcmp(label, 'n h')
                if self.Dotted
                    contents = cell(12, 1);
                    contents{1} = Unit(pitches, 12);
                else
                    contents = cell(8, 1);
                    contents{1} = Unit(pitches, 8);
                end
            elseif strcmp(label, 'n q')
                contents = cell(4, 1);
                contents{1} = Unit(pitches, 4);
            elseif strcmp(label, 'n ee')
                contents = cell(4, 1);
                if centroids{1}(1) < centroids{2}(1)
                    contents{1} = Unit(pitches(1), 2);
                    contents{2} = Unit(pitches(2), 2);
                else
                    contents{1} = Unit(pitches(2), 2);
                    contents{2} = Unit(pitches(1), 2);
                end
            end
            self.Contents = contents;
        end
        
        function audio = getAudio(self)
            audio = 0;
            self.buildContents();
            contents = self.Contents;
            LEN = 1000;
            audio = zeros(length(contents)*LEN, 2);
            for i = 1:length(contents)
                unit = contents{i};
                if isempty(unit)
                    continue
                end
                startIdx = (i-1)*LEN + 1;
                unitAudio = unit.getAudio();
                endIdx = startIdx + length(unitAudio) - 1;
                
                audio(startIdx:endIdx, :) = unit.getAudio();
            end
        end
        
    end
end

