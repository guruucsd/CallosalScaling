function [pcorr, residX, residY] = pc(X,Y,Z)
    [~,~,residX] = regress(X, [ones(size(X)) Z]);
    [~,~,residY] = regress(Y, [ones(size(Y)) Z]);
    pcorr  = partialcorr(X,Y,Z);

    fprintf('pcorr (%.3f) vs corr(resid) (%.3f)', pcorr, corr(residX, residY));
    
