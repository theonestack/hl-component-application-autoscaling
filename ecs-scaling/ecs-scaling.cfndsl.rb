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

  ecs_cluster = FnSelect(0, FnSplit('/', Ref(:Service)))
  service_name = FnSelect(1, FnSplit('/', Ref(:Service)))

  ApplicationAutoScaling_ScalableTarget(:ServiceScalingTarget) do
    MaxCapacity Ref(:Max)
    MinCapacity Ref(:Min)
    ResourceId FnJoin( '', [ "service/", ecs_cluster, "/",  service_name ] )
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
    { Name: 'ServiceName', Value: service_name},
    { Name: 'ClusterName', Value: ecs_cluster}
  ]

  scaling_policy = external_parameters.fetch(:scaling_policy, {})


  if scaling_policy['up'].kind_of?(Hash)
    scaling_policy['up'] = [scaling_policy['up']]
  end

  if scaling_policy['down'].kind_of?(Hash)
    scaling_policy['down'] = [scaling_policy['down']]
  end

  scaling_policy['up'].each_with_index do |scale_up_policy, i|
    logical_scaling_policy_name = "ServiceScalingUpPolicy"  + (i > 0 ? "#{i+1}" : "")
    logical_alarm_name          = "ServiceScaleUpAlarm"     + (i > 0 ? "#{i+1}" : "")
    policy_name                 = "scale-up-policy"         + (i > 0 ? "-#{i+1}" : "")
    
    ApplicationAutoScaling_ScalingPolicy(logical_scaling_policy_name) do
      PolicyName FnJoin('-', [ Ref('EnvironmentName'), component_name, policy_name])
      PolicyType "StepScaling"
      ScalingTargetId Ref(:ServiceScalingTarget)
      StepScalingPolicyConfiguration({
        AdjustmentType: "ChangeInCapacity",
        Cooldown: scale_up_policy['cooldown'] || 300,
        MetricAggregationType: "Average",
        StepAdjustments: [{ ScalingAdjustment: scale_up_policy['adjustment'].to_s, MetricIntervalLowerBound: 0 }]
      })
    end

    CloudWatch_Alarm(logical_alarm_name) do
      AlarmDescription FnJoin(' ', [Ref('EnvironmentName'), "#{component_name} ecs scale up alarm"])
      MetricName scale_up_policy['metric_name'] || default_alarm['metric_name']
      Namespace scale_up_policy['namespace'] || default_alarm['namespace']
      Statistic scale_up_policy['statistic'] || default_alarm['statistic']
      Period (scale_up_policy['period'] || default_alarm['period']).to_s
      EvaluationPeriods scale_up_policy['evaluation_periods'].to_s
      Threshold scale_up_policy['threshold'].to_s
      AlarmActions [Ref(logical_scaling_policy_name)]
      ComparisonOperator 'GreaterThanThreshold'
      Dimensions scale_up_policy['dimentions'] || default_alarm['dimentions']
    end
  end

  scaling_policy['down'].each_with_index do |scale_down_policy, i|
    logical_scaling_policy_name = "ServiceScalingDownPolicy"  + (i > 0 ? "#{i+1}" : "")
    logical_alarm_name          = "ServiceScaleDownAlarm"     + (i > 0 ? "#{i+1}" : "")
    policy_name                 = "scale-down-policy"         + (i > 0 ? "-#{i+1}" : "")

    ApplicationAutoScaling_ScalingPolicy(logical_scaling_policy_name) do
      PolicyName FnJoin('-', [ Ref('EnvironmentName'), component_name, policy_name])
      PolicyType 'StepScaling'
      ScalingTargetId Ref(:ServiceScalingTarget)
      StepScalingPolicyConfiguration({
        AdjustmentType: "ChangeInCapacity",
        Cooldown: scale_down_policy['cooldown'] || 900,
        MetricAggregationType: "Average",
        StepAdjustments: [{ ScalingAdjustment: scale_down_policy['adjustment'].to_s, MetricIntervalUpperBound: 0 }]
      })
    end

    CloudWatch_Alarm(logical_alarm_name) do
      AlarmDescription FnJoin(' ', [Ref('EnvironmentName'), "#{component_name} ecs scale down alarm"])
      MetricName scale_down_policy['metric_name'] || default_alarm['metric_name']
      Namespace scale_down_policy['namespace'] || default_alarm['namespace']
      Statistic scale_down_policy['statistic'] || default_alarm['statistic']
      Period (scale_down_policy['period'] || default_alarm['period']).to_s
      EvaluationPeriods scale_down_policy['evaluation_periods'].to_s
      Threshold scale_down_policy['threshold'].to_s
      AlarmActions [Ref(logical_scaling_policy_name)]
      ComparisonOperator 'LessThanThreshold'
      Dimensions scale_down_policy['dimentions'] || default_alarm['dimentions']
    end
  end

end
