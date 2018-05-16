classdef Unit < handle
    % Represents a single note (eg eigth, quarter, half, whole)
    
    properties
        BasePitch
        N16ths
        Accidental
        Articulation
        Dynamic
    end
    
    methods
        function unit = Unit(basePitch, n16ths)
            unit.BasePitch = basePitch;
            unit.N16ths = n16ths;
            unit.Accidental = 0; 
            unit.Articulation = 'n'; % n=none, s=stacatto, a=accent
            unit.Dynamic = 'm'; 
        end
        
        function dot(self)
            self.N16ths = 1.5 * self.N16ths;
        end
        
        function audio = getAudio(self, len)
            if self.BasePitch == 30
                audio = zeros(len*self.N16ths, 2);
                return
            end
            pitchOffsets = 1:.5:29;
            pitchNames = {'C2', 'Db2', 'D2', 'Eb2', 'E2', '', 'F2', 'Gb2', 'G2', 'Ab2', 'A2', 'Bb2', 'B2', '', ....
                'C3', 'Db3', 'D3', 'Eb3', 'E3', '', 'F3', 'Gb3', 'G3', 'Ab3', 'A3', 'Bb3', 'B3', '', ...
                'C4', 'Db4', 'D4', 'Eb4', 'E4', '', 'F4', 'Gb4', 'G4', 'Ab4', 'A4', 'Bb4', 'B4', '', ...
                'C5', 'Db5', 'D5', 'Eb5', 'E5', '', 'F5', 'Gb5', 'G5', 'Ab5', 'A5', 'Bb5', 'B5', '', 'C6'}; 
            pitchToNameMap = containers.Map(pitchOffsets, pitchNames);
            global pitchToAudioMap;
            if isempty(pitchToAudioMap)
                pitchToAudioMap = containers.Map({'remove me'}, {[9, 9; 9, 9]});
                pitchToAudioMap.remove('remove me');
            end
            pitch = self.BasePitch + self.Accidental;
            name = pitchToNameMap(pitch);
            if strcmp('', name)
                name = pitchToNameMap(pitch - self.Accidental);
            end
            if self.Articulation ~= 'a' || strcmp(self.Dynamic, 'mf') || strcmp(self.Dynamic, 'f')
                name = ['ff.', name];
            else
                name = ['mf.', name];
            end
            if ~pitchToAudioMap.isKey(name)
                [audio, ~] = audioread(['pitches/', name, '.ogg']);
                pitchToAudioMap(name) = audio;
            end
            audio = pitchToAudioMap(name);
            audioEndIdx = self.N16ths*len-1;
            audio = audio(1:audioEndIdx, :);   
            if self.Articulation == 's'
                audio(1:round(audioEndIdx/2), :) = audio(1:round(audioEndIdx/2), :) * 0;
            end
        end
    end
end

