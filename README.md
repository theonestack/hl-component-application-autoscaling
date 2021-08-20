![cftest](https://github.com/theonestack/hl-component-application-autoscaling/actions/workflows/rspec.yaml/badge.svg)

# Application Autoscaling CfHighlander component

Deploys Application Autoscaling Targets and Policies


Base component in which to build AWS network based resources from such as EC2, RDS and ECS

```bash
kurgan add application-autoscaling
```

## Requirements

## Parameters

| Name | Use | Default | Global | Type | Allowed Values |
| ---- | --- | ------- | ------ | ---- | -------------- |
| EnvironmentName | Tagging | dev | true | string
| EnvironmentType | Tagging | development | true | string | ['development','production']

## Configuration





## Outputs/Exports

| Name | Value | Exported |
| ---- | ----- | -------- |
| SecurityGroup | Ecs Service SecurityGroup | true
| TaskTargetGroup | Task Targetgroup | true
| ServiceName | Ecs Service Name | true


## Development

```bash
gem install cfhighlander
```

or via docker

```bash
docker pull theonestack/cfhighlander
```

compiling the templates

```bash
cfcompile application-autoscaling
```

compiling with the vaildate flag to validate the templates

```bash
cfcompile application-autoscaling --validate
```

### Testing

```bash
gem install rspec
```

```bash
rspec

.........
CloudFormation YAML template for ecs-task written to /Users/aaronwalker/Workspaces/theonestack/hl-component-fargate-v2/out/yaml/fargatev2Task.compiled.yaml
CloudFormation YAML template for fargate-v2 written to /Users/aaronwalker/Workspaces/theonestack/hl-component-fargate-v2/out/tests/targetgroup_param/fargate-v2.compiled.yaml
Validate template /Users/aaronwalker/Workspaces/theonestack/hl-component-fargate-v2/out/tests/targetgroup_param/fargate-v2.compiled.yaml locally
SUCCESS
Validate template /Users/aaronwalker/Workspaces/theonestack/hl-component-fargate-v2/out/yaml/fargatev2Task.compiled.yaml locally
SUCCESS

  ============================
  #    CfHighlander Tests    #
  ============================

  Pass: 1
  Fail: 0
  Time: 3.289156

...

Finished in 32.62 seconds (files took 0.31077 seconds to load)
40 examples, 0 failures
```



