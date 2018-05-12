classdef Score < MusicPlayer
    % Represents the entire score of a song
    
    properties
        FilePath
        Pages
    end
    
    methods
        function score = Score(filePath)
            score.FilePath = filePath;
            score.Pages = {};
        end
        
        function pages = getPages(self)
            if ~isempty(self.Pages)
                pages = self.Pages;
                return
            end
            
            % create pages
            file = dir(self.FilePath);
            if strcmp(file.name(end-2:end), 'pdf')
                baseName = getBaseName(file.name);
                singleImgFilePath = ['images/', baseName, '.jpg'];
                multipleImgFilePath = ['images/', baseName, '-*.jpg'];
                if isempty(dir(singleImgFilePath)) && isempty(dir(multipleImgFilePath))
                    % no saved images, so create images from pdf
                    pdf2imgs(file.folder, 'images', file.name);
                end
                if ~isempty(dir(singleImgFilePath))
                    % one image, so create one page
                    pages = cell(1, 1);
                    pages{1} = Page(singleImgFilePath);
                else
                    % multiple images, so create multiple pages
                    imgFiles = dir(multipleImgFilePath);
                    pages = cell(length(imgFiles), 1);
                    for i = 1:length(imgFiles)
                        pages{i} = ['images/', imgFiles(i).name];
                    end
                end
            else
                % file is an image
                pages = cell(1, 1);
                pages{1} = Page(self.FilePath);
            end
            self.Pages = pages;
        end
        
        function audio = getAudio(self)
            % check if there is a saved audio file
            baseName = getBaseName(self.FilePath);
%             audioFilePath = ['audio/', baseName, '.ogg'];
%             if ~isempty(dir(audioFilePath))
%                 [audio, ~] = audioread(audioFilePath);
%                 return
%             end

            % construct audio from self.Pages
            pages = self.getPages();
            audioList = cell(length(pages), 1);
            for i = 1:length(pages)
                audioList{i} = pages{i}.getAudio();
            end
            audio = concatenateAudio(audioList);
%             audiowrite(['audio/', baseName, '.ogg'], audio, self.Frequency);
        end

    end
end

