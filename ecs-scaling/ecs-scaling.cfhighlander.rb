CfhighlanderTemplate do

  DependsOn 'lib-iam'

  Parameters do
    ComponentParam 'EcsCluster', ''
    ComponentParam 'Service', ''
    ComponentParam 'Min', 1
    ComponentParam 'Max', 10
  end


end
