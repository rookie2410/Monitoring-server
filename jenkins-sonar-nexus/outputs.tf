output "jenkins_public_ip" {
  description = "Public IP of the Jenkins EC2 instance"
  value       = aws_instance.jenkins.public_ip
}

output "nexus_public_ip" {
  description = "Public IP of the Nexus EC2 instance"
  value       = aws_instance.nexus.public_ip
}

output "sonarqube_public_ip" {
  description = "Public IP of the SonarQube EC2 instance"
  value       = aws_instance.sonarqube.public_ip
}

output "jenkins_url" {
  description = "Jenkins Web Interface URL"
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "nexus_url" {
  description = "Nexus Web Interface URL"
  value       = "http://${aws_instance.nexus.public_ip}:8081"
}

output "sonarqube_url" {
  description = "SonarQube Web Interface URL"
  value       = "http://${aws_instance.sonarqube.public_ip}:9000"
}
