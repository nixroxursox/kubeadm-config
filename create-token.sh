#generate the token and keep in file and push to git 

token_generated=`kubeadm token generate`
if [ $(echo $?) -eq "0" ]
then
echo "Token generated sucessfully !"

token_created=`kubeadm token create $token_generated --print-join-command --ttl=0`
if [ $(echo $?) -eq "0" ]
then

echo "Token created sucessfully !"
else
echo "Error in Creating token"
exit 9
fi;

else
echo "Error in generating token"
exit 9
fi;

echo $token_created > token_create.txt

if [ `git status -su|wc -l` -eq 1 ]
then
echo "List of file updated."
git status -su

echo "Adding all file staging area"
git add --all

echo "Commiting changes to staging area"
git commit -m "Join token update"

echo "Pushing changes to git for the token to be used in the nodes"
git push origin

fi;
