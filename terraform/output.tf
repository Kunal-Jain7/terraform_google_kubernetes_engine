/*
output "bastion_open_tunnel_command" {
  value = "${module.bastion.ssh} -f tail -f /dev/null"
}

output "kubectl_alias_command" {
  value = "alias kube= '${module.bastion.kubectl_command}'"
}
*/