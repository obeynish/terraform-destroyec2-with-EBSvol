resource "aws_instance" "instance" { ..snip .. }

resource "aws_ebs_volume" "data" { ..snip.. }

resource "aws_volume_attachment" "data_att" {
  device_name  = "/dev/sdf"
  volume_id    = aws_ebs_volume.data.id
  instance_id  = aws_instance.instance.id
}

resource "null_resource" "unmount_data_drive" {
  triggers = {
    public_ip = aws_instance.instance.public_ip
  }

  depends_on = [aws_volume_attachment.data_att, aws_instance.instance]

  provisioner "remote-exec" {
    when       = destroy
    on_failure = continue
    connection {
      type        = "ssh"
      agent       = false
      host        = self.triggers.public_ip
      user        = "ubuntu"
      private_key = file(var.key_pair)
    }
    inline = [
      "sudo umount /opt/data",
      "sudo sed -i '/opt\\/data/d' /etc/fstab"
    ]
  }
}
