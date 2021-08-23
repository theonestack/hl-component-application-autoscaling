CfhighlanderTemplate do
    
  Parameters do
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', isGlobal: true
    case service_namespace
    when 'ecs'
      ComponentParam 'Service', ''
      ComponentParam 'Min', 1
      ComponentParam 'Max', 10
    end
  end

  if service_namespace.nil?
    raise "You must define a service_namespace for application autoscaling valid vaules are: [ecs]"
  end

  ### ECS Service Autoscaling
  if service_namespace == 'ecs'
    Component template: 'ecs-scaling', name: 'autoscaling', render: Inline, config: @config do
      parameter name: 'Service', value: Ref(:Service)
      parameter name: 'Min', value: Ref(:Min)
      parameter name: 'Max', value: Ref(:Max)
    end
  end

end
  