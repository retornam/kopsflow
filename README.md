
|k|o|p|s|f|l|o|w|
------------------


Kopsflow is an attempt to setup a secure Kubernetes cluster 
based on Kubernetes Operations (Kops), a private docker
registry using AWS S3 as a store for the images and then
deploy airflow services securely without third-party tools
like Helm.



Terraform
---------

```
terraform
├── docker-registry
│  
├── kubernetessetup
│
└── vpcsetup
    └── modules
        ├── subnet-pair
        └── vpc
```




Ansible
--------

```
ansible
├── files
└── templates
```
