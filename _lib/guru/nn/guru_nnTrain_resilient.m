function [model,o_p] = guru_nnTrain_resilient(model,X,Y)
% Train with basic backprop, in batch mode

  nInputs   = size(X,1)-1;
  nDatapts  = size(X,2);
  nUnits    = size(model.Weights,1);
  nOutputs  = size(Y,1);
  nHidden   = nUnits - nInputs - nOutputs - 1;

  if guru_getfield(model, 'Dec', 0) >= 0.1 && guru_getfield(model, 'dropout', 0)
    warning(['Dropout and resilient backprop with Dec set do NOT play well together.\n' ...
             'I suggest setting model.Dec = 0.025']);
  end;

  model.err = zeros([model.MaxIterations nDatapts]);

  % Only do if necessary, for memory reasons
  if (nargout>1)
      o_p       = zeros([model.MaxIterations nUnits nDatapts]);
  end;

  if isfield(model,'AvgError')
    model.Error = model.AvgError * numel(Y);
  end;

  model.Eta = sparse(guru_getfield(model, 'Eta', model.EtaInit) .* model.Conn);

  currErr   = NaN;
  lastGrad  = spalloc(size(model.Conn,1), size(model.Conn,2), nnz(model.Conn));

  if (isfield(model, 'noise_input'))
    X_orig = X;
    noise_std = model.noise_input * std(abs(X(:)));
  end;

  for ip = 1:model.MaxIterations
    % Inject noise into the input
    if any(guru_getfield(model, 'noise_input', 0))
        noise_sig = noise_std * randn(size(X)) / 0.7982; % mean 0 noise
        X = X_orig + noise_sig;
        if ip == 1
            noise_level = mean(abs(noise_sig(:)./X_orig(:)));
            fprintf('%f noise is %.2f%% of activation.\n', model.noise_input, 100*noise_level);
        end;
        % Note: don't change Y!!  We don't want to model the noise...
    end;

    %% Determine model error based on that update
    if guru_getfield(model, 'dropout', 0) > 0
        wOrig = model.Weights;
        cOrig = model.Conn;
        idxHOut = find(rand(nHidden,1)<model.dropout);
        model.Conn(nInputs+idxHOut, 1:nInputs) = false;
        model.Weights(nInputs+idxHOut, 1:nInputs) = 0;
        model.Conn(nInputs+nHidden+[1:nOutputs], nInputs+idxHOut) = false;
        model.Weights(nInputs+nHidden+[1:nOutputs], nInputs+idxHOut) = 0;
    end;

    % Determine model error
    if (nargout>1)
        [model.err(ip,:),grad, o_p(ip,:,:)]=emo_backprop(X, Y, model.Weights, model.Conn, model.XferFn, model.errorType, model.Pow );
    else
        [model.err(ip,:),grad]             =emo_backprop(X, Y, model.Weights, model.Conn, model.XferFn, model.errorType, model.Pow );
    end;

    if guru_getfield(model, 'dropout', 0) > 0
      model.Conn = cOrig;
      model.Weights = wOrig;
    end;

    % Change error only if there are no NaN
    if (any(isnan(model.err(ip,:))))
        lastErr = currErr;
    else
        lastErr = currErr;
        currErr = sum(model.err(ip,:));
    end;

    % Had a problem; probably moving too fast.
    if (any(isnan(model.err(ip,:))))
      break;
    end;

    %% Do checks before applying gradient, as error is for CURRENT weights,
    %% not for weights after weight change!!

    % Finished training
    if (isnan(currErr))
        warning('NaN error; probably Eta is too large');


    elseif (currErr <= model.Error)
      if (ismember(13, model.debug))
          fprintf('Error reached criterion on iteration %d; done!\n', ip);
      end;
      break;

    % We're precisely the same; quit!
    elseif (currErr==lastErr && sum(abs(model.err(ip,:)-model.err(ip-1,:)))==0)
      warning(sprintf('Error didn''t change on iteration %d; done training early.\n',ip));
      break;
    end;

    if (ismember(10, model.debug)), fprintf('[%4d]: err = %6.4e\n', ip, currErr/numel(Y)); end;

    % Adjust the weights
    %guru_assert(~any(isnan(grad(:))));
    model.Weights=model.Weights-model.Eta.*model.Conn.*sign(grad);
    if (isfield(model, 'lambda') && currErr < lastErr)
        model.Weights = model.Weights .* (1-model.lambda);
    end;
    %guru_assert(~any(isnan(model.Weights(:))));
    if (isfield(model, 'wmax'))
        over_wts = abs(model.Weights)>model.wmax;
        model.Weights(over_wts) = sign(model.Weights(over_wts)) .* model.wmax;
    elseif (isfield(model, 'wlim'))
        model.Weights(model.Weights<model.wlim(1)) = model.wlim(1);
        model.Weights(model.Weights>model.wlim(2)) = model.wlim(2);
    end;

    % We're getting better, speed things up
    samesign  = sparse((sign(grad) + sign(lastGrad)) ~= 0);
    model.Eta =model.Eta + ((model.Acc)*currErr.*samesign);
    model.Eta =model.Eta.*(1 - ((model.Dec).*(~samesign)));

    lastGrad = grad;
  end;

%  model = rmfield(model,'Eta');

  % Allows for multiple training calls (to save a history)
  if (~isfield(model, 'Iterations')), model.Iterations = []; end;
  model.Iterations(end+1)    = ip;

  % Reduce outputs to actual data.
  if (exist('o_p','var'))
      o_p                 = o_p(1:model.Iterations(end),:,:);
  end;


