identity='/root/.ssh/kube_aws_rsa'
chmod 400 $identity

for node in `kubectl get nodes -o jsonpath='{.items[*].metadata.name}'`; do 
	ip=$(kubectl get node $node -o jsonpath='{.status.addresses[?(@.type == "ExternalIP")].address}')
	ssh -tt -i $identity -o "StrictHostKeyChecking no" admin@$ip <<-EOF
		sudo su
			dangling=\$(docker images --filter dangling=true -q)
			[ -n "\$dangling" ] && docker rmi \$dangling
			docker images | grep 'smart-' | awk '{print \$1":"\$2}' | xargs docker rmi | echo 'this ECHO fixes broken pipe & empty image list'
		exit
	exit
	EOF
done
