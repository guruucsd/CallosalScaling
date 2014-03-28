function [nwm,ncc,nintra] = predict_nfibers(brwt, bvol, gmv, ndens, ccdens, cca, pct_proj)
% Predicts the total # of fibers and # callosal fibers,
%   then subtracts them to return the # of intrahemispheric fibers.
%
% Does this by:
%   * Predicing grey matter volume, neuron density, cc_density,
%     callosal area, and % projecting
%   * Computing as:
%     # neurons   = [grey matter volume] * [neuron density/vol]
%     # wm fibers = [# neurons] * [% neurons projecting]
%     # cc fibers = [callosal density/area] * [callosal surface area]

    % convert to native units
    if ~exist('bvol','var'), bvol = predict_bvol(brwt); end;
    if ~exist('brwt','var'), brwt = predict_bwt(bvol); end;
    if exist('gmv','var')      && isempty(gmv),      clear('gmv'); end;
    if exist('ndens','var')    && isempty(ndens),    clear('ndens'); end;
    if exist('ccdens','var')   && isempty(ccdens),   clear('ccdens'); end;
    if exist('cca','var')      && isempty(cca),      clear('cca'); end;
    if exist('pct_proj','var') && isempty(pct_proj), clear('pct_proj'); end;

    % send both weight and volume, it will pick the native one
    if ~exist('gmv','var') || isempty(gmv),          gmv      = predict_gm_volume(brwt, bvol); end;  % default collation (species)
    if ~exist('ndens','var') || isempty(ndens),      ndens    = predict_ndens(brwt, bvol); end;
    if ~exist('ccdens','var') || isempty(ccdens),    ccdens   = predict_cc_density(brwt, bvol); end;
    if ~exist('cca','var') || isempty(cca)           cca      = predict_cc_area(brwt, bvol); end;
    if ~exist('pct_proj','var') || isempty(pct_proj),pct_proj = predict_pct_proj(brwt, bvol); end;

    nneurons = 1E3 * gmv .* ndens;
    nwm = pct_proj .* nneurons;
    ncc = 1E6 * ccdens .* cca;
    nintra = nwm - ncc;
