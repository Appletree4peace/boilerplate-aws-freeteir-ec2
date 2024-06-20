# Boilerplate AWS Freeteir EC2 Setup

Automation script to speed up of setting up a free-teir EC2 instance in a new AWS account.
This is repeatable job that I do often to leverage AWS free-teir, so I create the script to make life easier with few line of commands.

Creates:
- IAM role for session manager and other necessary policies
- EC2 with `m2-micro`, ssh authorized key pre-installed, package pre-installed
- Default security group for home access with http and ssh

TODO: add more doc