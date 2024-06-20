{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AutomationOpsRolePermissions",
            "Effect": "Allow",
            "Action": [
                "iam:PassRole",
                "sts:AssumeRole",
                "*"
            ],
            "Resource": "*"
        }
    ]
}