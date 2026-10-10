resource "null_resource" "lint_test" {
  triggers = {
    always_run = timestamp()
  }
}

output "lint_test_id" {
  value = null_resource.lint_test.id
}