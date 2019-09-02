# KUBECONFIG that will be added to ~/.kube/config so that `kubectl` can be used on remote machines to reach the cluster
locals {
  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.demo.endpoint}
    certificate-authority-data: ${aws_eks_cluster.demo.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: ${terraform.workspace}-aws
current-context: ${terraform.workspace}-aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${terraform.workspace}-${var.cluster_name}"
KUBECONFIG
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}

data "template_file" "kubeconfig" {
  template = "${local.kubeconfig}"
}

# Creates a kubeconfig file on your local machine 
resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "echo '${data.template_file.kubeconfig.rendered}' > $HOME/.kube/config.${terraform.workspace}"
  }

  depends_on = ["aws_autoscaling_group.demo"]
}

# aws command to automatically add kubeconfig information given an eks cluster name and region
#resource "null_resource" "kubeconfig2" {
#  provisioner "local-exec" {
#    command = "aws eks --region ${var.region} update-kubeconfig --alias ${terraform.workspace}-aws --name ${terraform.workspace}-${var.cluster_name}"
#  }
#
#  depends_on = ["aws_eks_cluster.demo"]
#}

# Deploy ConfigMap for worker nodes w/demo-node arn to be added to the cluster under the following clusterroles: system:bootstrappers and system:nodes
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data {
    mapRoles = <<YAML
- rolearn: ${aws_iam_role.demo-node.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
YAML
  }
}
