run "guardrails_plan_basic" {
  command = plan
  module {
    source = "./examples/agents-with-guardrails"
  }
}

run "guardrails_apply_basic" {
  command = apply
  module {
    source = "./examples/agents-with-guardrails"
  }
}
