// Managed By : CloudDrove
// Description : This Terratest is used to test the Terraform Route53 module.
// Copyright @ CloudDrove. All Right Reserved.
package test

import (
	"testing"
	"strings"
	"github.com/stretchr/testify/assert"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func Test(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		// Source path of Terraform directory.
		TerraformDir: "../../_example/basic-s3-function",
		Upgrade: true,
	}

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// To clean up any resources that have been created, run 'terraform destroy' towards the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// To get the value of an output variable, run 'terraform output'
	Tags := terraform.OutputMap(t, terraformOptions, "tags")
	Arn := strings.Join(terraform.OutputList(t, terraformOptions, "arn"),"")

	// Check that we get back the outputs that we expect
	assert.Equal(t, "test-lambda-clouddrove", Tags["Name"])
	assert.Contains(t, Arn, "arn:aws:lambda")
}