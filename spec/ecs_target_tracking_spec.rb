require 'yaml'

describe 'should create ecs application autoscaling resources with default CPU based scaling metrics' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/ecs_target_tracking.test.yaml")).to be_truthy
    end
  end

  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/ecs_target_tracking/application-autoscaling.compiled.yaml") }

  context 'Resource ServiceScalingTarget' do
    let(:properties) { template["Resources"]["ServiceScalingTarget"]["Properties"] }

    it 'has properties' do
      expect(properties).to eq({
        "MaxCapacity" => {"Ref"=>"Max"},
        "MinCapacity" => {"Ref"=>"Min"},
        "ResourceId" => {"Fn::Join"=>["", ["service/", {"Fn::Select"=>[1, {"Fn::Split"=>["/", {"Ref"=>"Service"}]}]}, "/", {"Fn::Select"=>[2, {"Fn::Split"=>["/", {"Ref"=>"Service"}]}]}]]},
        "RoleARN" => {"Fn::GetAtt"=>["ServiceECSAutoScaleRole", "Arn"]},
        "ScalableDimension" => "ecs:service:DesiredCount",
        "ServiceNamespace" => "ecs",
      })
    end
  end

  context 'Resource ServiceScalingTarget Policy' do
    let(:properties) { template["Resources"]["ServiceTargetTrackingPolicy"]["Properties"] }

    it 'has properties' do
      expect(properties).to eq({
        "PolicyName" => {"Fn::Join"=>["-", [{"Ref"=>"EnvironmentName"}, "autoscaling", "target-tracking-policy"]]},
        "PolicyType" => "TargetTrackingScaling",
        "ScalingTargetId" => {"Ref"=>"ServiceScalingTarget"},
        "TargetTrackingScalingPolicyConfiguration" => {"PredefinedMetricSpecification"=>{"PredefinedMetricType"=>"ECSServiceAverageCPUUtilization"}, "ScaleInCooldown"=>"180", "ScaleOutCooldown"=>"180", "TargetValue"=>"75"},
      })
    end
  end


end