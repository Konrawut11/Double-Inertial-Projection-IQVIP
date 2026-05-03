function x_proj = proj_K(x, p)
% PROJ_K  Projects a point x ∈ R^2 onto the set K(p) = 0.5*p + C
% where C = { y : |y1| ≤ |p1|, |y2| ≤ |p2| }.

    % f(p) = p/2
    fp = 0.1 * p;

    % Shift x by subtracting f(p)
    y = x - fp;

    % Box bounds derived from C
    lb = [-abs(p(1)); -abs(p(2))];
    ub = [ abs(p(1));  abs(p(2))];

    % Projection onto the box C (component-wise clipping)
    y_proj = min(max(y, lb), ub);

    % Final projection onto K(p)
    x_proj = fp + y_proj;
end
