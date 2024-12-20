run "prompt_management_plan" {
  command = plan
  module {
    source = "./examples/prompt_management"
  }
}

run "prompt_management_apply" {
  command = apply
  module {
    source = "./examples/prompt_management"
  }
}
