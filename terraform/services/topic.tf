resource "kafka_topic" "main" {

  name               = "AWS_MSK_TOPIC"
  replication_factor = local.number_of_broker_nodes
  partitions         = 50

  config = {
    "segment.ms"     = "20000"
    "cleanup.policy" = "compact"
  }
}