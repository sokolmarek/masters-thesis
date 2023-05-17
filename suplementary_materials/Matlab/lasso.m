function [v, cause, aic] = lasso(series, P, lambda)
    % Function for Lasso-Granger causality relationship among the input time series
    % A. Arnold, Y. Liu, and N. Abe. Temporal causal modeling with graphical granger methods. In KDD, 2007.

    % Extract input dimensions
    [N, T] = size(series);
    
    % Construct design matrix and response vector
    Am = zeros(T-P, P*N);
    bm = series(1, P+1:T)';
    for i = 1:N
        Am(:, (i-1)*P+1:i*P) = flipud(buffer(series(i,:), P, P-1, 'nodelay')');
    end
    
    % Compute Lasso coefficients
    opt = glmnetSet;
    opt.lambda = lambda;
    opt.alpha = 1;
    fit = glmnet(Am, bm, 'gaussian', opt);
    v = fit.beta;
    
    % Compute AIC
    aic = norm(Am * v - bm)^2 / (T - P) + (sum(abs(v) > 0)) * 2 / (T - P);
    
    % Reshape coefficients into NxP matrix and compute Granger causality
    n1Coeff = reshape(v, P, N)';
    sumCause = sum(abs(n1Coeff), 2);
    cause = (sumCause > 0) .* sumCause;
end