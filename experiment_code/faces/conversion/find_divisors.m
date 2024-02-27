function divisors = find_divisors(value)
    % Initialize an empty array to store the divisors
    divisors = [];
    
    % Loop through all possible divisors from 1 to the value itself
    for divisor = 1:value
        % Check if the value is divisible by the current divisor
        if mod(value, divisor) == 0
            % If it is divisible, add the divisor to the divisors array
            divisors = [divisors, divisor];
        end
    end
end