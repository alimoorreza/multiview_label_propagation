function [angular_dist_deg, axis_of_rot] = find_angular_distance(R1, R2)

% this function computes the axis-angle representation represents a rotation by an axis of rotation 
% and an angle of rotation about that axis
% assuming input matrices R1 and R2 are valid rotation matrices (orthogonal matrices with determinant +1)

        % calculate the matrix product of the two rotation matrices
        R_product       = R1' * R2;             
        
        % calculate the angle of rotation
        angle_of_rot    = acos((trace(R_product) - 1) / 2);
        
        % convert the angle from radians to degrees
        angular_dist_deg = angle_of_rot*180/pi;

        % find the eigenvector corresponding to eigenvalue +1
        [V, D]                    = eig(R_product);
        [~, index]              = max(diag(D));
        axis_of_rot            = V(:, index);
        

end