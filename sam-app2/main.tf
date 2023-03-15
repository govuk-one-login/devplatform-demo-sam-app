 existing repo found.

resource "aws_lambda_function_event_invoke_config" "hello_world_function" {
  // CF Property(CodeUri) = "HelloWorldFunction"
  // CF Property(AutoPublishAlias) = "LatestVersion"
  // CF Property(Handler) = "helloworld.App::handleRequest"
  // CF Property(Runtime) = "java11"
  // CF Property(Architectures) = [
  //   "x86_64"
  // ]
  // CF Property(MemorySize) = 512
  // CF Property(ReservedConcurrentExecutions) = 5
  // CF Property(Tags) = {
  //   Product = "GOV.UK Sign In"
  //   System = "Dev Platform"
  //   Environment = "Demo"
  //   Service = "backend"
  //   Name = "HelloWorldFunction"
  //   Source = "alphagov/di-devplatform-demo-sam-app/sam-app2/template.yaml"
  //   CheckovRulesToSkip = "CKV_AWS_116.CKV_AWS_117"
  // }
}
