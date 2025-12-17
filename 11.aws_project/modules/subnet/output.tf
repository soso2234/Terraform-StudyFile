output "sn_id" {
  description = "모든 서브넷 ID의 리스트"
  value = [
    aws_subnet.tf_sn["pub_sn1"].id,
    aws_subnet.tf_sn["pub_sn2"].id,
    aws_subnet.tf_sn["pri_sn3"].id,
    aws_subnet.tf_sn["pri_sn4"].id
  ]
}