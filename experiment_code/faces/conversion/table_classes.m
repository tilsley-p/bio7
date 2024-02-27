colnum = length(experiment_design.Properties.VariableNames);
classes = cell(2,colnum);

for i = 1:colnum
classes{1,i} = experiment_design.Properties.VariableNames(i);
classes{2,i} = class(experiment_design.(i));
end
