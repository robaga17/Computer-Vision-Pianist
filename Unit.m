classdef Unit < handle
    
    properties
        BasePitch
        N16ths
        Accidental
        Articulation
        StartVolume
        EndVolume
    end
    
    methods
        function unit = Unit(basePitch, n16ths)
            unit.BasePitch = basePitch;
            unit.N16ths = n16ths;
            unit.Accidental = 0; 
            unit.Articulation = 'n'; % n=none, s=stacatto, a=accent
            unit.StartVolume = 3; % 1=p, 2=mp, 3=mf, 4=f, 5=ff
            unit.EndVolume = 3;
        end
        
        function dot(self)
            self.N16ths = 1.5 * self.N16ths;
        end
    end
end

