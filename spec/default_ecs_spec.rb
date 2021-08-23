require 'yaml'

describe 'should fail without a task_definition' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/default_ecs.test.yaml")).to be_truthy
    end
  end

  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/default_ecs/application-autoscaling.compiled.yaml") }

  context 'Has ECS Stack Params' do
    let(:parameters) { template["Parameters"] }
    
    it 'has ECS Service Parameter' do
      expect(parameters["Service"]).to eq({
        "Default" => "",
        "NoEcho" => false,
        "Type" => "String",
      })
    end

    it 'has Min Parameter' do
      expect(parameters["Min"]).to eq({
        "Default" => "1",
        "NoEcho" => false,
        "Type" => "String",
      })
    end

    it 'has Max Parameter' do
      expect(parameters["Max"]).to eq({
        "Default" => "10",
        "NoEcho" => false,
        "Type" => "String",
      })
    end
  end

  context 'Resource IAM Role' do
    let(:properties) { template["Resources"]["ServiceECSAutoScaleRole"]["Properties"] }

    it 'has property AssumeRolePolicyDocument' do
        expect(properties["AssumeRolePolicyDocument"]).to eq(
          {"Statement"=>[{"Action"=>"sts:AssumeRole", "Effect"=>"Allow", "Principal"=>{"Service"=>"application-autoscaling.amazonaws.com"}}], "Version"=>"2012-10-17"}
        )
    end

    it 'has property Policies' do
        expect(properties["Policies"]).to eq([{
          "PolicyDocument"=> {
              "Statement"=> [
                {
                  "Action"=> [
                    "cloudwatch:DescribeAlarms",
                    "cloudwatch:PutMetricAlarm",
                    "cloudwatch:DeleteAlarms"
                  ],
                  "Effect"=>"Allow",
                  "Resource"=>"*"
                },
                {
                  "Action"=>["ecs:UpdateService", "ecs:DescribeServices"],
                  "Effect"=>"Allow",
                  "Resource"=>{"Ref"=>"Service"}
                }
              ]
            },
            "PolicyName"=>"ecs-scaling"
        }])
    end
  end

  context 'Resource ServiceScalingTarget' do
    let(:properties) { template["Resources"]["ServiceScalingTarget"]["Properties"] }

    it 'has properties' do
      expect(properties).to eq({
        "MaxCapacity" => {"Ref"=>"Max"},
        "MinCapacity" => {"Ref"=>"Min"},
        "ResourceId" => {"Fn::Join"=>["", ["service/", {"Fn::Select"=>[0, {"Fn::Split"=>["/", {"Ref"=>"Service"}]}]}, "/", {"Fn::Select"=>[1, {"Fn::Split"=>["/", {"Ref"=>"Service"}]}]}]]},
        "RoleARN" => {"Fn::GetAtt"=>["ServiceECSAutoScaleRole", "Arn"]},
        "ScalableDimension" => "ecs:service:DesiredCount",
        "ServiceNamespace" => "ecs",
      })
    end
  end

  context 'Resource ServiceScalingUpPolicy' do
    let(:properties) { template["Resources"]["ServiceScalingUpPolicy"]["Properties"] }

    it 'has properties' do
      expect(properties).to eq({
        "PolicyName" => {"Fn::Join"=>["-", [{"Ref"=>"EnvironmentName"}, "autoscaling", "scale-up-policy"]]},
        "PolicyType" => "StepScaling",
        "ScalingTargetId" => {"Ref"=>"ServiceScalingTarget"},
        "StepScalingPolicyConfiguration" => {"AdjustmentType"=>"ChangeInCapacity", "Cooldown"=>150, "MetricAggregationType"=>"Average", "StepAdjustments"=>[{"MetricIntervalLowerBound"=>0, "ScalingAdjustment"=>"2"}]},
      })
    end
  end

  context 'Resource ServiceScaleUpAlarm' do
    let(:properties) { template["Resources"]["ServiceScaleUpAlarm"]["Properties"] }

    it 'has properties' do
      expect(properties).to eq({
        "AlarmActions" => [{"Ref"=>"ServiceScalingUpPolicy"}],
        "AlarmDescription" => {"Fn::Join"=>[" ", [{"Ref"=>"EnvironmentName"}, "autoscaling ecs scale up alarm"]]},
        "ComparisonOperator" => "GreaterThanThreshold",
        "Dimensions" => [{"Name"=>"ServiceName", "Value"=>{"Fn::Select"=>[1, {"Fn::Split"=>["/", {"Ref"=>"Service"}]}]}}, {"Name"=>"ClusterName", "Value"=>{"Fn::Select"=>[0, {"Fn::Split"=>["/", {"Ref"=>"Service"}]}]}}],
        "EvaluationPeriods" => "5",
        "MetricName" => "CPUUtilization",
        "Namespace" => "AWS/ECS",
        "Period" => "60",
        "Statistic" => "Average",
        "Threshold" => "70",
      })
    end
  end

  context 'Resource ServiceScalingDownPolicy' do
    let(:properties) { template["Resources"]["ServiceScalingDownPolicy"]["Properties"] }

    it 'has properties' do
      expect(properties).to eq({
        "PolicyName" => {"Fn::Join"=>["-", [{"Ref"=>"EnvironmentName"}, "autoscaling", "scale-down-policy"]]},
        "PolicyType" => "StepScaling",
        "ScalingTargetId" => {"Ref"=>"ServiceScalingTarget"},
        "StepScalingPolicyConfiguration" => {"AdjustmentType"=>"ChangeInCapacity", "Cooldown"=>600, "MetricAggregationType"=>"Average", "StepAdjustments"=>[{"MetricIntervalUpperBound"=>0, "ScalingAdjustment"=>"-1"}]},
      })
    end
  end

  context 'Resource ServiceScaleDownAlarm' do
    let(:properties) { template["Resources"]["ServiceScaleDownAlarm"]["Properties"] }

    it 'has properties' do
      expect(properties).to eq({
        "AlarmActions" => [{"Ref"=>"ServiceScalingDownPolicy"}],
        "AlarmDescription" => {"Fn::Join"=>[" ", [{"Ref"=>"EnvironmentName"}, "autoscaling ecs scale down alarm"]]},
        "ComparisonOperator" => "LessThanThreshold",
        "Dimensions" => [{"Name"=>"ServiceName", "Value"=>{"Fn::Select"=>[1, {"Fn::Split"=>["/", {"Ref"=>"Service"}]}]}}, {"Name"=>"ClusterName", "Value"=>{"Fn::Select"=>[0, {"Fn::Split"=>["/", {"Ref"=>"Service"}]}]}}],
        "EvaluationPeriods" => "5",
        "MetricName" => "CPUUtilization",
        "Namespace" => "AWS/ECS",
        "Period" => "60",
        "Statistic" => "Average",
        "Threshold" => "70",
      })
    end
  end
  
end
