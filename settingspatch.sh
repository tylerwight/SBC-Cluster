## running into bug  https://github.com/kubernetes/kubeadm/issues/413
#this is workaround to run during kubeadm init install

watch -n 1.0 "sed -i 's/initialDelaySeconds: [0-9]\+/initialDelaySeconds: 180/' /etc/kubernetes/manifests/kube-apiserver.yaml"
