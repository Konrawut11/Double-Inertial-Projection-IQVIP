function z = proj_K_rect(r, bounds)
    % Projection onto K(p) = [min(0, p/2), max(0, p/2)]
    z = zeros(2,1);
    for i = 1:2
        low = min(0, bounds(i));
        high = max(0, bounds(i));
        z(i) = max(low, min(r(i), high));
    end