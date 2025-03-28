variable "karmada_host_cluster_name" {
  default = "k8s-cluster-us-east-1"
}

variable "karmada_host_cluster_region" {
  default = "us-east-1"
}

variable "member_clusters" {
  type = map(object({
    cluster_name = string
    region       = string
  }))
  default = {
    member_1 = {
      cluster_name = "k8s-cluster-eu-west-1"
      region       = "eu-west-1"
    }
    member_2 = {
      cluster_name = "k8s-cluster-ap-southeast-1"
      region       = "ap-southeast-1"
    }
    member_3 = {
      cluster_name = "k8s-cluster-us-west-2"
      region       = "us-west-2"
    }
  }
}
