sudo apt update

#installazione docker
sudo apt install docker.io

#installazione k3s
curl -sfL https://get.k3s.io | sh -s - --no-deploy=traefik --write-kubeconfig-mode 644

#installazione istio
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.14.1 TARGET_ARCH=x86_64 sh -
cd istio-1.14.1
export PATH=$PWD/bin:$PATH
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
istioctl install --set profile=demo -y

sleep 10

kubectl label namespace default istio-injection=enabled

#apply bookinfo
#kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
sleep 15

#verifica corretto apply
#kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"

#open the application to outside traffic
#kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
#istioctl analyze

#aggiungiamo gli addons di tracing
kubectl apply -f samples/addons
kubectl rollout status deployment/kiali -n istio-system

#simuliamo traffico
#export GATEWAY_URL={EXTERNAL_IP}.nip.io
#for i in $(seq 1 100); do curl -s -o /dev/null "http://$GATEWAY_URL/productpage"; done