function gmt = predict_gm_thickness(brwt, bvol)
% Function for computing grey matter thickness (cm) from brain volume
%   using regression log-baesd regression in Hofman (1989), eqn 9 (Fig 8 caption)
%
% Input:
%   brwt: brain weight (g)
%   bvol: [native units] brain volume (cm^3)
%
% Output:
%   gmt: grey matter thickness (cm)

    global g_gmt;

    % convert to native units
    if ~exist('bvol','var') || isempty(bvol), bvol = predict_bvol(brwt); end;

    if isempty(g_gmt) || true
        g_gmt.y = @(bvol) 10*(0.0258 * log(bvol) + 0.084); %Hofman, 1989, in cm
    end;

    gmt = g_gmt.y(bvol);  % cm
