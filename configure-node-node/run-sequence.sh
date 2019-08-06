echo "Started master-pre-boot.sh"
sudo sh master-pre-boot.sh
echo "Completed master-pre-boot.sh"

echo "Started master-post-boot-1"
sudo sh master-post-boot-1.sh
echo "Completed master-post-boot-1"

echo "Started master-post-boot-2"
sh master-post-boot-2.sh
echo "Completed master-post-boot-2"