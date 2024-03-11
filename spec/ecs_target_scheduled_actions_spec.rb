require 'yaml'

describe 'should create ecs application autoscaling resources with scheduled actions' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/ecs_target_scheduled_actions.test.yaml")).to be_truthy
    end
  end

  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/ecs_target_scheduled_actions/application-autoscaling.compiled.yaml") }

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
        "ScheduledActions" => [{
          "ScalableTargetAction" => {"MaxCapacity"=>2, "MinCapacity"=>1},
          "Schedule" => "cron(0 8 * * ? *)",
          "ScheduledActionName" => {"Fn::Join"=>["-", ["service", {"Fn::Select"=>[1, {"Fn::Split"=>["/", {"Ref"=>"Service"}]}]}, {"Fn::Select"=>[2, {"Fn::Split"=>["/", {"Ref"=>"Service"}]}]}, "scheduled-action-1"]]},
          "Timezone" => "America/Denver"
        }]
      })
    end
  end

end