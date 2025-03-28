terraform {
  source = "../../../../modules/KARMADA/"
}

inputs = {
  karmada_host_cluster = {
    name   = "k8s-cluster-us-east-1"
    region = "us-east-1"
  }

  member_clusters = {
    member_1 = { cluster_name = "k8s-cluster-us-east-1", region = "us-east-1" }
    member_2 = { cluster_name = "k8s-cluster-eu-west-1", region = "eu-west-1" }
    member_3 = { cluster_name = "k8s-cluster-ap-southeast-1", region = "ap-southeast-1" }
  }
}
