function cause = copula_granger(series)
    % Function for computing Granger-Copula as described in the following paper:
    % Yan Liu, Mohammad Taha Bahadori, and Hongfei Li, "Sparse-GEV: Sparse Latent Space Model for Multivariate Extreme Value Time Series Modeling", ICML 2012

    % Define parameters
    p = 3; % Order of AR model
    num_lambdas = 6; % Number of lambda values to test
    lambda_min = 1e-3;
    lambda_max = 1e2;
    lambda_vals = exp(linspace(log(lambda_min), log(lambda_max), num_lambdas));

    % Calculate normalization factor delta
    t = size(series, 2);
    delta = 1 / (4 * (t^(1/4)) * sqrt(pi * log(t)));

    % Apply mapping and normalization to input series
    m_series = norminv(arrayfun(@(x) map(series(x,:), delta), 1:size(series,1), 'UniformOutput', false), 0, 1);

    % Initialize output arrays
    p_error = zeros(1, num_lambdas);
    cause_temp = zeros(size(series));
    cause = zeros(size(series));

    % Compute Granger causality for each node
    for i = 1:size(series, 1)
        % Reorder the input series so that the current node is first
        index = [i, 1:i-1, i+1:size(series,1)];
        
        % Test each lambda value using Lasso Granger causality
        for j = 1:num_lambdas
            [~, cause_temp(index,j), p_error(j)] = lasso(m_series(index,:), p, lambda_vals(j));
        end
        
        % Choose the lambda value with the lowest prediction error
        [~, best_lambda] = min(p_error);
        
        % Reorder the output to match the original order of nodes
        index = [2:i, 1, i+1:size(series,1)];
        cause(:,i) = cause_temp(index,best_lambda);
    end
end

function out = map(Seri, delta)
    out = arrayfun(@(x) max(delta, min(1-delta, sum(Seri<Seri(x))/length(Seri))), 1:length(Seri));
end
