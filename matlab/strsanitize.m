%STRSANITIZE Szöveg átalakítása ékezetek nélküli formátumba.
%
% (C) GPLv2 Barancsuk Ádám, 2013
function [s] = strsanitize (s)
    SANITIZE_PAIRS = {'ÁÉÍÓÖŐÚÜŰáéíóöőúüű', 'AEIOOOUUUaeiooouuu'};
    for i = 1 : length(SANITIZE_PAIRS{1})
        s = strrep(s, SANITIZE_PAIRS{1}(i), SANITIZE_PAIRS{2}(i));
    end
end