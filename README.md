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

## ECS Application AutoScaling Configuration

TODO


## Outputs/Exports

None


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
CloudFormation YAML template for ecs-scaling written to /workspace/hl-component-application-autoscaling/out/yaml/autoscaling.compiled.yaml
CloudFormation YAML template for application-autoscaling written to /workspace/hl-component-application-autoscaling/out/tests/default_ecs/application-autoscaling.compiled.yaml
Validate template /workspace/hl-component-application-autoscaling/out/tests/default_ecs/application-autoscaling.compiled.yaml locally
SUCCESS
Validate template /workspace/hl-component-application-autoscaling/out/yaml/autoscaling.compiled.yaml locally
SUCCESS

  ============================
  #    CfHighlander Tests    #
  ============================

  Pass: 1
  Fail: 0
  Time: 0.218296452

...

Finished in 3.16 seconds (files took 0.101 seconds to load)
12 examples, 0 failures
```



