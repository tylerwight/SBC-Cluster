## running into bug  https://github.com/kubernetes/kubeadm/issues/413
#this is workaround to run during kubeadm init install

sudo watch -n 0.2 "sed -i 's/initialDelaySeconds: [0-9]\+/initialDelaySeconds: 800/' /etc/kubernetes/manifests/kube-apiserver.yaml"
