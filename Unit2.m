classdef Unit2 < MusicPlayer
    
    properties
        Pitches
        Duration
    end
    
    methods
        function unit = Unit2(pitches, duration)
            unit.Pitches = pitches;
            unit.Duration = duration;
        end
        
        function audio = getAudio(self)
            LEN = 1000;
            pitchOffsets = -14:14;
            pitchNames = {'C2', 'D2', 'E2', 'F2', 'G2', 'A2', 'B2', ....
                'C3', 'D3', 'E3', 'F3', 'G3', 'A3', 'B3', ...
                'C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4', ...
                'C5', 'D5', 'E5', 'F5', 'G5', 'A5', 'B5', 'C6'}; 
            pitchToNameMap = containers.Map(pitchOffsets, pitchNames);
            audio = zeros(self.Duration*LEN-1, 2);
            global pitchToAudioMap;
            for i = 1:length(self.Pitches)
                pitch = self.Pitches{i};
                if ~pitchToAudioMap.isKey(pitch)
                    [pitchAudio, ~] = audioread(['pitches/mf.', pitchToNameMap(pitch), '.ogg']);
                    pitchToAudioMap(pitch) = pitchAudio;
                end
               pitchAudio = pitchToAudioMap(pitch);
                pitchAudio = pitchAudio(1:self.Duration*LEN-1, :);
                audio = audio + pitchAudio;
            end
        end
    end
end

