data "template_file" "ec2_role_assume_policy" {
  template = file("policies/ec2_role_assume_policy.json.tpl")
  vars = {
    aws_account = var.AWS_ACCOUNT_ID
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "SSMRoleForInstances"
  assume_role_policy = data.template_file.ec2_role_assume_policy.rendered
}

data "template_file" "ec2_role_policy" {
  template = file("policies/ec2_role_policy.json.tpl")
  vars = {
    aws_account = var.AWS_ACCOUNT_ID
  }
}

resource "aws_iam_policy" "ops_policy" {
  name   = "vultr_execution_policies"
  path   = "/"
  policy = data.template_file.ec2_role_policy.rendered
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ops_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attach_1" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attach_2" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
}
