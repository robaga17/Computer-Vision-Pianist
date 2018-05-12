classdef Gui < handle
    % This is the object that the user will interact with
    
    properties
        UploadedScore
    end
    
    methods
        function gui = Gui()
            gui.UploadedScore = [];
            
            % Create a map to be used in Unit objects.
            % Maps offset from middle-C to n-by-2 matrix representing pitch
            % audio
            global pitchToAudioMap;
            pitchToAudioMap = containers.Map({99}, {[9, 9; 9, 9]});
            pitchToAudioMap.remove(99);
        end
        
        function upload(self, filePath)
            % Upload the file to read from. Can be pdf or jpg.
            self.UploadedScore = Score(filePath);
            self.UploadedScore.getPlayer();
        end
        
        function score = getUploadedScore(self)
            if isempty(self.UploadedScore)
                error('No score has been uploaded yet.');
            end
            score = self.UploadedScore;
        end
        
        function play(self)
            self.getUploadedScore().getPlayer().play();
        end
        
        function pause(self)
            self.getUploadedScore().getPlayer().pause();
        end
        
        function resume(self)
            self.getUploadedScore().getPlayer().resume();
        end
        
        function stop(self)
            self.getUploadedScore().getPlayer().stop();
        end
            
    end
end

