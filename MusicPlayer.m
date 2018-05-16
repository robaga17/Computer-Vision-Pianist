classdef (Abstract) MusicPlayer < handle
    % Abstract class for a music player (Score, Page)
    
    properties
        Player = [] % constructed via audioplayer()
        Frequency = 11025; % constant
    end
    
    methods (Abstract)
        getAudio(self); % the n-by-2 matrix of sampled data
    end
    
    methods
        function player = getPlayer(self)
            if isempty(self.Player)
                self.Player = audioplayer(self.getAudio(), self.Frequency);
            end
            player = self.Player;
        end  
        
        function play(self)
            play(self.getPlayer());
        end
        
        function pause(self)
            pause(self.getPlayer());
        end
        
        function resume(self)
            resume(self.getPlayer());
        end
        
        function stop(self)
            stop(self.getPlayer());
        end
    
    end
end

