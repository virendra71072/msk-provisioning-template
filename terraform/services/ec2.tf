# Fetch the latest Amazon Linux 2 AMI
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_instance" "kafka_instance" {
  count           = var.ec2_enabled ? 1 : 0
  ami             = data.aws_ami.latest_amazon_linux.id # Replace with your desired AMI ID
  instance_type   = "t4g.small"
  subnet_id       = local.private_subnets[0]
  security_groups = [aws_security_group.sg.id]

  #associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.prod_cons_profile[0].id
  # user_data_replace_on_change = true
  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Update system
              sudo yum update -y
              sudo yum install -y telnet

              # Install Java
              sudo yum install -y java-1.8.0

              #Install AWS MSK IAM Auth
              wget https://github.com/aws/aws-msk-iam-auth/releases/download/v2.2.0/aws-msk-iam-auth-2.2.0-all.jar
              sudo mv aws-msk-iam-auth-2.2.0-all.jar /opt/aws-msk-iam-auth-2.2.0-all.jar
              export CLASSPATH=/opt/aws-msk-iam-auth-2.2.0-all.jar  

              # Download and extract Kafka
              wget https://archive.apache.org/dist/kafka/2.8.1/kafka_2.13-2.8.1.tgz
              sudo tar -xzf kafka_2.13-2.8.1.tgz -C /opt/

              # Set up Kafka client properties
              sudo cp /usr/lib/jvm/java-1.8.0-amazon-corretto/jre/lib/security/cacerts /tmp/kafka.client.truststore.jks
              sudo touch /opt/kafka_2.13-2.8.1/bin/client.properties
              sudo chmod 777 /opt/kafka_2.13-2.8.1/bin/client.properties
              echo "security.protocol=SASL_SSL" | sudo tee -a /opt/kafka_2.13-2.8.1/bin/client.properties
              echo "sasl.mechanism=AWS_MSK_IAM" | sudo tee -a /opt/kafka_2.13-2.8.1/bin/client.properties
              echo "sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;" | sudo tee -a /opt/kafka_2.13-2.8.1/bin/client.properties
              echo "sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler" | sudo tee -a /opt/kafka_2.13-2.8.1/bin/client.properties
              echo "ssl.truststore.location=/tmp/kafka.client.truststore.jks" | sudo tee -a /opt/kafka_2.13-2.8.1/bin/client.properties

              for topic in ${join(" ", var.topics)}; do
                /opt/kafka_2.13-2.8.1/bin/kafka-topics.sh --create --bootstrap-server ${aws_msk_cluster.main.bootstrap_brokers_sasl_iam} \
                  --replication-factor 2 --partitions 1 --topic "$topic" \
                  --command-config /opt/kafka_2.13-2.8.1/bin/client.properties || echo "Topic '$topic' already exists."
              done

              # Download Amazon root certificate
              sudo curl -o /AmazonRootCA1.pem https://www.amazontrust.com/repository/AmazonRootCA1.pem

              # Install Python and pip
              sudo yum install -y python
              curl 'https://bootstrap.pypa.io/get-pip.py' > get-pip.py
              sudo python get-pip.py

              # Install Protobuf compiler and necessary Python packages
              sudo yum install -y protobuf-compiler
              pip install boto3 kafka-python confluent-kafka protobuf
              EOF

  tags = {
    Name = "Kafka-Instance-${var.environment}-${var.aws_region}"
  }
  # lifecycle {
  #   ignore_changes = all
  # }
}

resource "aws_iam_instance_profile" "prod_cons_profile" {
  count = var.ec2_enabled ? 1 : 0
  name  = "MSKProducerInstanceProfile-${var.aws_region}"
  role  = data.aws_iam_role.prod_cons_role.name
}

data "aws_iam_role" "prod_cons_role" {
  name = "MSKProducerConsumerRole" # Replace with your actual IAM role name
}
