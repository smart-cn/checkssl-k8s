#!/usr/bin/env bash

echo -e "\nChecking K8S certificates"
echo "===="
echo "Current system date: $(date)"
echo "===="
echo "SSL certificates expiration dates from the Kube-config file:" 
echo "CA certificate:"
grep "certificate-authority-data" ~/.kube/config | awk '{print $2}' |  base64 -d | openssl x509 -noout -startdate -enddate -checkend 0 |   sed "s/Certificate will expire/ (EXPIRED\!)/g" |  sed "s/Certificate will not expire/ (OK)/g"
echo -e "\nClient certificate:"
grep "client-certificate-data" ~/.kube/config | awk '{print $2}' |  base64 -d | openssl x509 -noout -startdate -enddate -checkend 0 |   sed "s/Certificate will expire/ (EXPIRED\!)/g" |  sed "s/Certificate will not expire/ (OK)/g"
echo "===="
echo "SSL certificates expiration dates from the /etc/kubernetes/kubelet.conf file:"
echo "CA certificate:"
sudo grep "certificate-authority-data" /etc/kubernetes/kubelet.conf | awk '{print $2}' | base64 -d | openssl x509 -noout -startdate -enddate -checkend 0 |  sed "s/Certificate will expire/ (EXPIRED\!)/g" |  sed "s/Certificate will not expire/ (OK)/g"
echo -e "\nClient certificate:"
sudo grep "client-certificate" /etc/kubernetes/kubelet.conf | sudo cat $(awk '{print $2}') | openssl x509 -noout -startdate -enddate -checkend 0 | sed "s/Certificate will expire/ (EXPIRED\!)/g" |  sed "s/Certificate will not expire/ (OK)/g"
echo "===="
echo "SSL certificates expiration dates for the cluster certificates:"
for cert in $(find /etc/kubernetes/pki/ -name "*.crt" | sort); do echo "$cert:"; openssl x509 -in $cert -noout -startdate -enddate -checkend 0|   sed "s/Certificate will expire/ (EXPIRED\!)/g" |  sed "s/Certificate will not expire/ (OK)/g"; echo;  done
echo "===="
echo "SSL certificates expiration dates according to kubeadm:"
kubeadm certs check-expiration
