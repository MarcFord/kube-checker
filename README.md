# kube-checker
Docker image with static analysis tools for checking Kubernetes object definitions.
I am using this image as part of a CI/CD pipeline to check kubernete object definitions
before they are applyed, to ensure best practices are followed.

## Included Tools
- [kube-score](https://github.com/zegl/kube-score)
- [kubeconform](https://github.com/yannh/kubeconform)
- [Polaris](https://github.com/FairwindsOps/polaris)
