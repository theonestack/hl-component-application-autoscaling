CloudFormation do

  IAM_Role(:ServiceECSAutoScaleRole) do
    AssumeRolePolicyDocument service_assume_role_policy('application-autoscaling')
    Path '/'
    Policies ([
      PolicyName: 'ecs-scaling',
      PolicyDocument: {
        Statement: [
          {
            Effect: "Allow",
            Action: ['cloudwatch:DescribeAlarms','cloudwatch:PutMetricAlarm','cloudwatch:DeleteAlarms'],
            Resource: "*"
          },
          {
            Effect: "Allow",
            Action: ['ecs:UpdateService','ecs:DescribeServices'],
            Resource: Ref(:Service)
          }
        ]
    }])
  end

  ApplicationAutoScaling_ScalableTarget(:ServiceScalingTarget) do
    MaxCapacity Ref(:Max)
    MinCapacity Ref(:Min)
    ResourceId FnJoin( '', [ "service/", Ref('EcsCluster'), "/", FnGetAtt(:Service,:Name) ] )
    RoleARN FnGetAtt(:ServiceECSAutoScaleRole,:Arn)
    ScalableDimension "ecs:service:DesiredCount"
    ServiceNamespace "ecs"
  end
  
  default_alarm = {}
  default_alarm['metric_name'] = 'CPUUtilization'
  default_alarm['namespace'] = 'AWS/ECS'
  default_alarm['statistic'] = 'Average'
  default_alarm['period'] = '60'
  default_alarm['evaluation_periods'] = '5'
  default_alarm['dimentions'] = [
    { Name: 'ServiceName', Value: FnGetAtt(:Service,:Name)},
    { Name: 'ClusterName', Value: Ref(:EcsCluster)}
  ]

end
