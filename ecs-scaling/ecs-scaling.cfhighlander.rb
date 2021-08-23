CfhighlanderTemplate do

  DependsOn 'lib-iam'

  Parameters do
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', isGlobal: true
    ComponentParam 'Service', ''
    ComponentParam 'Min', 1
    ComponentParam 'Max', 10
  end


end
