classdef State
    
    properties
        timeNumerator
        timeDenomenator
        bpm
        flats
        sharps
    end
    
    methods
        function state = State()
            state.timeNumerator = 4;
            state.timeDenomenator = 4;
            state.bpm = 80;
            state.flats = [];
            state.sharps = [];
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

