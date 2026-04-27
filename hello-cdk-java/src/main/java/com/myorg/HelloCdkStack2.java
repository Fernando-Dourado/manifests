package com.myorg;

import software.amazon.awscdk.CfnOutput;
import software.amazon.awscdk.CfnParameter;
import software.amazon.awscdk.RemovalPolicy;
import software.amazon.awscdk.Stack;
import software.amazon.awscdk.StackProps;
import software.amazon.awscdk.services.secretsmanager.Secret;
import software.constructs.Construct;

public class HelloCdkStack2 extends Stack {
  public HelloCdkStack2(final Construct scope, final String id) {
    this(scope, id, null);
  }

  public HelloCdkStack2(final Construct scope, final String id,
                        final StackProps props) {
    super(scope, id, props);

    CfnParameter parameter = CfnParameter.Builder.create(this,"sname").defaultValue("defaultSecretNameStack2").build();

    Secret secret = Secret.Builder.create(this, "stack2secretId")
        .secretName(parameter.getValueAsString())
        .removalPolicy(RemovalPolicy.DESTROY)
        .build();

    CfnOutput.Builder.create(this, "outputId")
        .exportName(id + "-outputExportName")
        .value(secret.getSecretName())
        .build();
  }
}
