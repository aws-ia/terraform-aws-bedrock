## NOTE: This is the minimum mandatory test
# run at least one test using the ./examples directory as your module source
# create additional *.tftest.hcl for your own unit / integration tests
# use tests/*.auto.tfvars to add non-default variables

run "mandatory_plan_basic" {
  command = plan
  module {
    source = "./examples/basic"
  }
}

run "mandatory_apply_basic" {
  command = apply
  module {
    source = "./examples/basic"
  }
}
