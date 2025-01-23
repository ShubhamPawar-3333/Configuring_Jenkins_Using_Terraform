# Output Jenkins Public IP
output "jenkins_public_ip" {
  value = aws_instance.jenkins_instance.public_ip
  description = "Public IP of the Jenkins instance"
}

# Output SSH Command
output "ssh_command" {
  value = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.jenkins_instance.public_ip}"
  description = "SSH command to connect to the Jenkins server"
}