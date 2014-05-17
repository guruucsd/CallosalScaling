function [nintra] = predict_nintra_fibers(brwt, bvol, collation, gmv, ndens, ccdens, cca)
% Predicts the # of intrahemispheric fibers

    % convert to native units
    if ~exist('bvol','var'), bvol = predict_bvol(brwt); end;
    if ~exist('brwt','var'), brwt = predict_brwt(bvol); end;
    if ~exist('collation', 'var'), collation = 'species'; end;
    if ~exist('gmv','var')    , gmv = []; end;
    if ~exist('ndens','var')  , ndens = []; end;
    if ~exist('ccdens','var') , ccdens = []; end;
    if ~exist('cca','var')    , cca = []; end;

    [~,~,nintra] = predict_nfibers(brwt, bvol, collation, gmv, ndens, ccdens, cca);

