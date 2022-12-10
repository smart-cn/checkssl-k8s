#!/usr/bin/env bash

check_ssl() {
        echo $* | sed -e "s/ //g" | base64 -d | openssl x509 -noout -startdate -enddate -checkend 0 |   sed "s/Certificate will expire/ (EXPIRED\!)/g" |  sed "s/Certificate will not expire/ (OK)/g"
}

echo -e "\nChecking K8S certificates"
echo "===="
echo "Current system date: $(date)"
echo "===="
echo "SSL certificates expiration dates from the Kube-config file:"
echo "CA certificate:"
check_ssl $(grep "certificate-authority-data" ~/.kube/config | awk '{print $2}')
echo -e "\nClient certificate:"
check_ssl $(grep "client-certificate-data" ~/.kube/config | awk '{print $2}')
echo "===="
echo "SSL certificates expiration dates from the /etc/kubernetes/kubelet.conf file:"
echo "CA certificate:"
check_ssl $(sudo grep "certificate-authority-data" /etc/kubernetes/kubelet.conf | awk '{print $2}')
echo -e "\nClient certificate:"
check_ssl $(sudo grep "client-certificate" /etc/kubernetes/kubelet.conf | awk '{print $2}')
echo "===="
echo "SSL certificates expiration dates for the cluster certificates:"
for cert in $(find /etc/kubernetes/pki/ -name "*.crt" | sort); do echo "$cert:"; check_ssl $(base64 $cert); echo; done
echo "===="
echo "SSL certificates expiration dates according to kubeadm:"
sudo $(which kubeadm) certs check-expiration
