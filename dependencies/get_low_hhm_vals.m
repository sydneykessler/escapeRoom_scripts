
function [count, percentage] = get_low_hhm_vals(values)

% see how many values <10 for each part
num_of_values = size(values,2); 
count = zeros(num_of_values,1);
percentage = zeros(num_of_values,1);

for j=1:num_of_values
    count(j) = sum(values <= 10);
    percentage(j) = count(j)/size(values, 2)*100;
end

