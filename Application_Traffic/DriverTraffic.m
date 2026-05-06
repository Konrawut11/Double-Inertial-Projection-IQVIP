% ========================================================================
% Road Pricing Problem
% ========================================================================
clear all; close all; clc;
tic
%% 1. Network Parameters (Trinh & Vuong, Tables 1 & 2)
% Link free flow travel time (in minutes)
t0 = [60, 40, 60, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20];
% Link capacity
capacity = [150, 100, 300, 200, 300, 300, 300, 300, 300, 300, ...
            300, 300, 300, 300, 300, 300]'; % Transpose to column vector
t0 = t0'; % Transpose to column vector
        
% (Corrected) OD Demand matrix (Table 1)
% Rows: O1, O2, O3, O4. Cols: D1, D2, D3, D4
OD_demand = [60, 50, 20, 20;  % O1 -> (D1, D2, D3, D4)
             30, 160, 30, 15;  % O2 -> (D1, D2, D3, D4)
             20, 45, 20, 15;  % O3 -> (D1, D2, D3, D4)
             15, 30, 10, 40]; % O4 -> (D1, D2, D3, D4)
         
num_links = length(t0); 
num_nodes = 8;
num_controlled_links = 3; % Links 1, 2, 3

% === (ADJUSTED) Network Topology (Figure 3) ===
% Nodes: O1=1, O2=2, O3=3, O4=4, D1=5, D2=6, D3=7, D4=8
% Columns: [Start_Node, End_Node]
node_pairs = [
    1, 5;  % Link 1
    2, 6;  % Link 2
    3, 7;  % Link 3
    4, 8;  % Link 4
    1, 2;  % Link 5
    2, 3;  % Link 6
    3, 4;  % Link 7
    4, 3;  % Link 8
    3, 2;  % Link 9
    2, 1;  % Link 10
    5, 6;  % Link 11
    6, 7;  % Link 12
    7, 8;  % Link 13
    8, 7;  % Link 14
    7, 6;  % Link 15 (*** ADJUSTED: D3 -> D2 ***)
    6, 5   % Link 16
];
% OD Nodes
origin_nodes = [1, 2, 3, 4];
dest_nodes = [5, 6, 7, 8];

%% 2. Constraint Parameters
G = [40; 0; 100];  % Lower bound adjustment
H = [90; 50; 200]; % Upper bound adjustment

%% 3. Algorithm Parameters (Figure 5)
gama = 2;      % Step size
alpha = 0.1;      % Scaling factor
max_iter = 100;    % Maximum iterations (Outer loop)
tol = 1e-2;        % Tolerance for convergence

%% 4. Initialization
x = [0; 0; 0];  % Initial tolls (x_0 = 0)
pnm1=x;
pn=x;

tau=0.015;
rho=0.45;
lam=0.01;
%gama=2;

residual_history = zeros(max_iter, 1);
flow_history = zeros(max_iter, num_controlled_links);
toll_history = zeros(max_iter, num_controlled_links);
fprintf('Starting Road Pricing Algorithm (Full UE Model, Corrected Topology)\n');

%% 5. Main Algorithm Loop (Projection Algorithm - Outer Loop)
for iter = 1:max_iter
    
    % Step 1: Solve traffic assignment (Call the REAL UE "black box")
    sn=pn+lam*(pn-pnm1);
    rn=pn+tau*(pn-pnm1);

    link_flows = solve_UE_MSA_full(sn, iter, t0, capacity, OD_demand, ...
                                   node_pairs, num_nodes, num_links, ...
                                   origin_nodes, dest_nodes);
    

    % Extract flows for the 3 controlled links
    Asn = link_flows(1:num_controlled_links);
    
    % Step 2: Define constraint set Φ(x)
    g_x = sn + G;
    h_x = sn + H;

    % Step 3: Projection onto Φ(x)
    z = Asn + gama * sn;
    proj_z = LOCAL_project_onto_box(z, g_x, h_x);
    
    % Step 4: Update toll
    qn=sn+ alpha * (Asn - proj_z);
    x_new = (1-rho)*rn+rho*qn;
    
    % Compute residual r_n
    residual = norm(alpha * (proj_z - Asn)); 
    residual_history(iter) = residual;
    flow_history(iter, :) = Asn';
    toll_history(iter, :) = x';
    
    % Display progress
    if mod(iter, 10) == 0 
        fprintf('Iter %3d: Residual = %.6f, Flows = [%.2f, %.2f, %.2f]\n', ...
                 iter, residual, Asn(1), Asn(2), Asn(3));
    end
    
    % Check convergence
    if residual < tol && iter > 10
        fprintf('\nConverged at iteration %d!\n', iter);
        break;
    end
    
    pnm1=pn;
    pn=x_new;
    x = x_new;
end

if iter == max_iter
    fprintf('\nReached max iterations (%d).\n', max_iter);
end

%% 6. Final Results
fprintf('\n=== Final Results ===\n');
fprintf('Final Tolls: [%.4f, %.4f, %.4f]\n', x(1), x(2), x(3));
fprintf('Final Flows: [%.4f, %.4f, %.4f]\n', Asn(1), Asn(2), Asn(3));

%% 7. Plotting Results with Enhanced Visibility
figure('Position', [100, 100, 1200, 500]);

% --- Plot 1: Flows with High-Visibility Colors ---
subplot(1, 2, 1);
% Enhanced color scheme: red, blue, black with different line styles
plot(1:iter, flow_history(1:iter, 1), 'r-', 'LineWidth', 2.5, 'Color', [0.8, 0.1, 0.1]); hold on;
plot(1:iter, flow_history(1:iter, 2), 'b-', 'LineWidth', 2.5, 'Color', [0.1, 0.3, 0.9]);
plot(1:iter, flow_history(1:iter, 3), 'k-', 'LineWidth', 2.5, 'Color', [0, 0, 0]);

xlabel('Iteration (n)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Link Flow (vehicles/hour)', 'FontSize', 12, 'FontWeight', 'bold');

% Dynamic y-axis limits
ylim_min = min(min(flow_history(1:iter,:))) - 10;
ylim_max = max(max(flow_history(1:iter,:))) + 10;
ylim([max(0, ylim_min), ylim_max]); 
xlim([0, iter]); 

title('Traffic Flow Evolution on Controlled Bridges', 'FontSize', 13, 'FontWeight', 'bold');
legend('Bridge 1 (Link 1)', 'Bridge 2 (Link 2)', 'Bridge 3 (Link 3)', ...
       'Location', 'best', 'FontSize', 10);
grid on;
set(gca, 'GridAlpha', 0.3);

% --- Plot 2: Residual with Enhanced Styling ---
subplot(1, 2, 2);
semilogy(1:iter, residual_history(1:iter), 'm-', 'LineWidth', 2.5, ...
         'Color', [0.7, 0.1, 0.7], 'Marker', 'o', 'MarkerSize', 4, ...
         'MarkerFaceColor', [0.7, 0.1, 0.7]);
xlabel('Iteration (n)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Residual Norm', 'FontSize', 12, 'FontWeight', 'bold');
ylim([10^-3, 10^1]);  
xlim([0, iter]);
title('Algorithm Convergence Rate', 'FontSize', 13, 'FontWeight', 'bold');
grid on;
set(gca, 'GridAlpha', 0.3);

% Add convergence threshold line
hold on;
plot([0, iter], [tol, tol], 'r--', 'LineWidth', 1.5, 'Color', [1, 0, 0]);
legend('Residual', 'Convergence Threshold', 'Location', 'northeast', 'FontSize', 10);

%% 8. Additional Analysis Plot - Toll Evolution
figure('Position', [100, 100, 800, 400]);
% Enhanced color scheme for tolls
plot(1:iter, toll_history(1:iter, 1), 'r-', 'LineWidth', 2.5, 'Color', [0.8, 0.1, 0.1]); hold on;
plot(1:iter, toll_history(1:iter, 2), 'b-', 'LineWidth', 2.5, 'Color', [0.1, 0.3, 0.9]);
plot(1:iter, toll_history(1:iter, 3), 'k-', 'LineWidth', 2.5, 'Color', [0, 0, 0]);

xlabel('Iteration (n)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Optimal Toll Value', 'FontSize', 12, 'FontWeight', 'bold');
title('Evolution of Optimal Tolls', 'FontSize', 13, 'FontWeight', 'bold');
legend('Bridge 1 Toll', 'Bridge 2 Toll', 'Bridge 3 Toll', 'Location', 'best', 'FontSize', 10);
grid on;
set(gca, 'GridAlpha', 0.3);

%% 9. Final Results Summary Table in Command Window
fprintf('\n=== DETAILED RESULTS SUMMARY ===\n');
fprintf('Bridge\t\tFinal Toll\tFinal Flow\tTarget Range\n');
fprintf('------\t\t----------\t----------\t------------\n');
fprintf('Bridge 1\t%.2f\t\t%.2f\t\t[%.2f, %.2f]\n', x(1), Asn(1), G(1)+x(1), H(1)+x(1));
fprintf('Bridge 2\t%.2f\t\t%.2f\t\t[%.2f, %.2f]\n', x(2), Asn(2), G(2)+x(2), H(2)+x(2));
fprintf('Bridge 3\t%.2f\t\t%.2f\t\t[%.2f, %.2f]\n', x(3), Asn(3), G(3)+x(3), H(3)+x(3));
fprintf('\nConvergence achieved in %d iterations\n', iter);
fprintf('Final residual: %.6f\n', residual_history(iter));

%% --------------------------------------------------------------------
%  HELPER FUNCTIONS (Real UE Solver)
%  --------------------------------------------------------------------

function link_flows = solve_UE_MSA_full(tolls, iter, t0, capacity, OD_demand, ...
                                        node_pairs, num_nodes, num_links, ...
                                        origin_nodes, dest_nodes)
    
    max_msa_iter = 200; % Number of MSA iterations (Inner loop)
    msa_tol = 1e-3;     % Tolerance for MSA
    
    % BPR function handle (t = t0*(1+0.15*(x/C)^4) + toll)
    bpr_cost = @(x, t0_i, cap_i, toll_i) t0_i * (1 + 0.15 * (x/cap_i)^4) + toll_i;
    
    % Create tolls vector (16 links)
    full_tolls = zeros(num_links, 1);
    full_tolls(1:3) = tolls; % Apply tolls to first 3 links
    
    % --- MSA Step 0: Initialization ---
    x_k = zeros(num_links, 1); 
    
    % Calculate Costs (including tolls)
    t_k = zeros(num_links, 1);
    for i = 1:num_links
        t_k(i) = bpr_cost(0, t0(i), capacity(i), full_tolls(i));
    end
    
    % Run AON first time
    y_k = run_AON(t_k, OD_demand, node_pairs, num_nodes, num_links, origin_nodes, dest_nodes);
    x_k = y_k; 
    
    % --- MSA Step k: Iteration (Inner Loop) ---
    for k = 2:max_msa_iter
        x_prev = x_k;
        
        % 1. Update link costs based on current flow x_k
        for i = 1:num_links
            t_k(i) = bpr_cost(x_k(i), t0(i), capacity(i), full_tolls(i));
        end
        
        % 2. AON (Find new Shortest Paths and get auxiliary flows y_k)
        y_k = run_AON(t_k, OD_demand, node_pairs, num_nodes, num_links, origin_nodes, dest_nodes);
        
        % 3. MSA Averaging Step
        step_size = 1 / k;
        x_k = (1 - step_size) * x_k + step_size * y_k;
        
        % 4. Check convergence of inner loop
        if k > 5 && (norm(x_prev) > 0) && (norm(x_k - x_prev) / norm(x_prev) < msa_tol)
            break;
        end
    end
    
    link_flows = x_k; % Return flow from MSA
end

% --------------------------------------------------------------------

function y_k = run_AON(link_costs, OD_demand, node_pairs, num_nodes, num_links, origin_nodes, dest_nodes)
    % Run All-or-Nothing (AON) Assignment
    y_k = zeros(num_links, 1);
    
    for o_idx = 1:length(origin_nodes)
        origin_node = origin_nodes(o_idx);
        
        % 1. Find shortest path tree from this origin to all dests
        % (Dijkstra's algorithm)
        [dist, prev_link] = dijkstra_links(node_pairs, link_costs, num_nodes, num_links, origin_node);
        
        for d_idx = 1:length(dest_nodes)
            dest_node = dest_nodes(d_idx);
            
            % Access correct demand
            demand = OD_demand(o_idx, d_idx);
            
            if demand == 0 || isinf(dist(dest_node))
                continue; % Skip if no demand or no path
            end
            
            % 2. Load flow onto the shortest path
            curr_node = dest_node;
            while curr_node ~= origin_node
                link_idx = prev_link(curr_node);
                if link_idx == 0
                    break; % Reached origin
                end
                y_k(link_idx) = y_k(link_idx) + demand; % Add demand to link
                curr_node = node_pairs(link_idx, 1); % Move to previous node
            end
        end
    end
end

% --------------------------------------------------------------------

function [dist, prev_link] = dijkstra_links(node_pairs, link_costs, num_nodes, num_links, start_node)
    % Dijkstra algorithm returning link index of paths
    
    dist = inf(num_nodes, 1);
    prev_link = zeros(num_nodes, 1); % Store link index used to reach this node
    visited = false(num_nodes, 1);
    
    dist(start_node) = 0;
    
    % Create Adjacency list (store link index)
    adj = cell(num_nodes, 1);
    for i = 1:num_links
        start_n = node_pairs(i, 1);
        end_n = node_pairs(i, 2);
        cost = link_costs(i);
        adj{start_n} = [adj{start_n}; [end_n, cost, i]]; % [neighbor, cost, link_index]
    end

    for k = 1:num_nodes
        % Find node with smallest dist
        u = -1;
        min_dist = inf;
        for i = 1:num_nodes
            if ~visited(i) && dist(i) < min_dist
                min_dist = dist(i);
                u = i;
            end
        end
        
        if u == -1
            break; % No path
        end
        
        visited(u) = true;
        
        % Relax neighbors
        if ~isempty(adj{u})
            for i = 1:size(adj{u}, 1)
                neighbor_data = adj{u}(i,:);
                v = neighbor_data(1);
                cost = neighbor_data(2);
                link_idx = neighbor_data(3);
                
                if ~visited(v)
                    new_dist = dist(u) + cost;
                    if new_dist < dist(v)
                        dist(v) = new_dist;
                        prev_link(v) = link_idx;
                    end
                end
            end
        end
    end
end

% --------------------------------------------------------------------

function proj = LOCAL_project_onto_box(z, lower, upper)
    % Project z onto the box [lower, upper]
    proj = max(lower, min(z, upper));
end
toc;