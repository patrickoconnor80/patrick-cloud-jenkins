INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=patrick-cloud-dev-jenkins-ec2" Name=instance-state-name,Values=running | grep InstanceId | cut -d \" -f 4)
SNAPSHOT_ID=$(aws ec2 describe-volumes --filters "Name=tag:Name,Values=patrick-cloud-dev-jenkins-volume" | grep SnapshotId | cut -d \" -f 4)
aws ec2 create-replace-root-volume-task \
--instance-id $INSTANCE_ID \
--snapshot-id $SNAPSHOT_ID \
--delete-replaced-root-volume true