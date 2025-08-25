What this module does:
This Terraform module makes a small, safe web environment in AWS. It builds one network with three pieces.
a management area you can reach, an app area for web servers, and a backend area. It launches a management server, an internal load balancer, and a group of 2–6 web servers that install Apache on boot. 
The load balancer sends traffic to the web servers; nothing on the web servers is open to the internet. 
Security rules are tight. Only the management subnet can hit the load balancer, only the load balancer can reach the web apps, and only the management server can SSH to them.


Things to keep in mind:
You can tweak this setup to fit your needs. 
pick a different instance size or AMI, make the load balancer internal or public, and choose SSH or SSM for access. 
Keep NAT for installs (or use VPC endpoints), add HTTPS with an ACM certificate, and turn on autoscaling policies instead of a fixed size. 
Adjust health checks, which subnets/AZs you use, and tighten or relax security group sources. Use data source instead of harding subnet ids.
IF you decided to use a different you might to tweak the autoscaling.tf module. The autoscaling.tf module is based an ubuntu ami.
The the vpc.tf, ec2.tf, and autoscaling.tf files are also set to use us-east-2. Change those files based on your needs.



Terraform modules and there usage: 
providers.tf: Sets AWS region (us-east-2).
vpc.tf: Creates VPC and subnets using the Coalfire module.
ec2.tf: Creates the management EC2 and its security group.
autoscaling.tf: Creates an application load balancer + target group + listener, Auto scaling group security group, Launch Template, and Auto scaling group.
