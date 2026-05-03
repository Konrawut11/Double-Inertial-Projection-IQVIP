clc; clear; close all;

% =============================
% Main Experiment Settings
% ============================= 
x0 = [-2,-8]';  
algNames = {'Ex2Alg1','Ex2HTVAlg25'}; 

algLabels = {'Alg. 1 (Our)','HTV Alg 25'};

logFiles = {'Ex2KAlg1','Ex2HTVAlg25'};

% Initialize results
for a = 1:length(algNames)
    results.(algNames{a}).iter = [];
    results.(algNames{a}).time = [];
end

% =============================
% Run Experiments
% =============================
for a = 1:length(algNames)
    alg = str2func(algNames{a});
    tic;
    [~] = alg(x0);  % run algorithm with initial vector
    elapsed = toc;

    % Load saved file and get last iteration
    M = load(logFiles{a});
    k = M(end,1);  % last iteration number
    results.(algNames{a}).iter = k;
    results.(algNames{a}).time = elapsed;
end

% =============================
% Generate LaTeX Table
% =============================
fprintf('\n===== LATEX TABLE =====\n');
fprintf('\\begin{tabular}{l c c}\n');
fprintf('\\hline\n');
fprintf('Algorithm & Iter & Time \\\\\n');
fprintf('\\hline\n');

for a = 1:length(algNames)
    fprintf('%s & %d & %.4f \\\\\n', ...
        algLabels{a}, results.(algNames{a}).iter, results.(algNames{a}).time);
end

fprintf('\\hline\n');
fprintf('\\end{tabular}\n');
 