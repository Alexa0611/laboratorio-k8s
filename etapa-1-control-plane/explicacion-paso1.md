# Explicación Técnica - Inspección de Arquitectura y Red Plana (Lab 2.1)

## 1. Componentes del Control Plane
- **kube-apiserver:** Punto de entrada REST que valida y almacena los cambios en `etcd`.
- **kube-scheduler:** Asigna los pods creados al nodo `minikube`.
- **kube-controller-manager:** Monitorea que existan 2 réplicas del Pod activas.

## 2. Validación de Red Plana
- Cada Pod recibe una dirección IP única dentro de la subred CNI (`10.244.x.x`).
- Se verificó comunicación punto a punto directa entre el Pod 2 y la IP privada del Pod 1 sin necesidad de NAT.
