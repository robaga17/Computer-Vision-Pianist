classdef MusicalObject < handle
    
    properties
        LabelTag
        Stats
        Label
    end
    
    properties (Constant)
        DurationMap = containers.Map({'s', 'e', 'q', 'h', 'w'}, {1, 2, 4, 8, 16});
    end
    
    methods
        function obj = MusicalObject(labelTag, stats, label)
            obj.LabelTag = labelTag;
            obj.Stats = stats;
            obj.Label = label;
        end
        
        function tf = isNote(self)
            tf = length(self.Label) > 1 && strcmp('n ', self.Label(1:2));
        end
        
        function tf = isRest(self)
            tf = length(self.Label) == 5 && strcmp('rest', self.Label(2:end));
        end
        
        function duration = getRestDuration(self)
            if ~self.isRest()
                error('Not a rest.');
            end
            duration = self.DurationMap(self.Label(1));
        end
        
        function durations = getNoteDurations(self)
            if ~self.isNote()
                error('Not a note.');
            end
            durations = zeros(length(self.Label)-2, 1);
            for i = 1:length(durations)
                durations(i) = self.DurationMap(self.Label(2+i));
            end
        end
        
    end
end

