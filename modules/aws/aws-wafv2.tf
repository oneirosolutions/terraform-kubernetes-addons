locals {

  aws-wafv2 = merge(
    {
      enabled                   = false
      prefix                    = "web-acl"
      web_acl_name              = ""
      association_resource_arn  = ""
      metric_name               = ""
      association_resource_name = ""
    },
    var.aws-wafv2
  )
}

resource "aws_wafv2_web_acl" "custom_web_acl" {
  count   = local.aws-wafv2["enabled"] ? 1 : 0
  name  = "${var.aws-wafv2.prefix}-${var.aws-wafv2.web_acl_name}"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }


  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 20

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 30

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAmazonIpReputationListMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAnonymousIpList"
    priority = 40

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAnonymousIpListMetric"
      sampled_requests_enabled   = true
    }
  }


  rule {
    name     = "AWSManagedRulesLinuxRuleSet"
    priority = 60

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesLinuxRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesUnixRuleSet"
    priority = 70

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesUnixRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesUnixRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  tags = {
    Name = "${var.aws-wafv2.prefix}-${var.aws-wafv2.web_acl_name}"
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.aws-wafv2.metric_name
    sampled_requests_enabled   = true
  }
}

data "aws_lb" "backend" {
  count   = local.aws-wafv2["enabled"] ? 1 : 0
  tags = {
    "ingress.k8s.aws/stack" = local.aws-wafv2.association_resource_name
  }
}

output "load_balancer_name" {
  value = data.aws_lb.backend
}

resource "aws_wafv2_web_acl_association" "web_acl_association_lb" {
  count   = local.aws-wafv2["enabled"] ? 1 : 0
  resource_arn = data.aws_lb.backend[0].arn
  web_acl_arn  = aws_wafv2_web_acl.custom_web_acl[0].arn
}