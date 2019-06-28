# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: kops/v1alpha2
kind: Cluster
metadata:
  creationTimestamp: 2019-06-27T08:33:58Z
  name: {{.myclusterName}}
spec:
  api:
    loadBalancer:
      type: Public
      sslCertificate: {{.sslCertARN}}
  authorization:
    rbac: {}
  channel: stable
  cloudProvider: aws
  cloudLabels:
     kubernetes.io/cluster/{{.myclusterName}}: owned
  configBase: {{.sthreeBucket}}
  dnsZone: {{.dnsZone}}
  etcdClusters:
  - cpuRequest: 200m
    etcdMembers:
    - instanceGroup: master-{{.awsRegion}}a
      name: a
    - instanceGroup: master-{{.awsRegion}}b
      name: b
    - instanceGroup: master-{{.awsRegion}}c
      name: c
    memoryRequest: 100Mi
    name: main
    version: 3.2.24
  - cpuRequest: 100m
    etcdMembers:
    - instanceGroup: master-{{.awsRegion}}a
      name: a
    - instanceGroup: master-{{.awsRegion}}b
      name: b
    - instanceGroup: master-{{.awsRegion}}c
      name: c
    memoryRequest: 100Mi
    name: events
    version: 3.2.24
  iam:
    allowContainerRegistry: true
    legacy: false
  kubelet:
    anonymousAuth: false
  kubernetesApiAccess:
  {{- range .sshAccess}}
    - {{.}}
  {{- end}}
  kubernetesVersion: 1.12.8
  masterInternalName: api-internal.{{.myclusterName}}
  masterPublicName: api.{{.myclusterName}}
  networkCIDR: {{.vpcCIDR}}
  networkID: {{.vpcID}}
  networking:
    calico:
      majorVersion: v3
      crossSubnet: true
  nonMasqueradeCIDR: 100.64.0.0/10
  sshAccess:
  {{- range .sshAccess}}
    - {{.}}
  {{- end}}
  subnets:
  {{- range $index, $element := .privateNetwork}}
  - egress: {{$element.egress}}
    id: {{$element.subnet}}
    name: {{$element.region}}{{$index}}
    type: Private
    zone: {{$element.region}}{{$index}}
  {{- end}}
  {{- range $index, $element := .publicNetwork}}
  - id: {{ $element.subnet }}
    name: utility-{{$element.region}}{{$index}}
    type: Utility
    zone: {{$element.region}}{{$index}}
  {{- end}}
  topology:
    bastion:
      bastionPublicName: bastion.{{.myclusterName}}
    dns:
      type: Public
    masters: private
    nodes: private
  additionalPolicies:
    node: |
      [
        {
          "Effect": "Allow",
          "Action": [
            "acm:ListCertificates",
            "acm:DescribeCertificate",
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeLoadBalancerTargetGroups",
            "autoscaling:AttachLoadBalancers",
            "autoscaling:DetachLoadBalancers",
            "autoscaling:DetachLoadBalancerTargetGroups",
            "autoscaling:AttachLoadBalancerTargetGroups",
            "cloudformation:*",
            "elasticloadbalancing:*",
            "elasticloadbalancingv2:*",
            "ec2:DescribeInstances",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeRouteTables",
            "ec2:DescribeVpcs",
            "iam:GetServerCertificate",
            "iam:ListServerCertificates"
          ],
          "Resource": ["*"]
        }
      ]

---
apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:    
    kops.k8s.io/cluster: {{.myclusterName}}
  name: bastions
spec:
  image: {{.image}}
  machineType: {{.bastionMachineType}}
  maxSize: 1
  minSize: 1
  nodeLabels:
    kops.k8s.io/instancegroup: {{.myclusterName}}
  role: Bastion
  subnets:
  {{- range $index, $element := .publicNetwork}}
  - utility-{{$element.region}}{{$index}}
  {{- end}}

---

apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: {{.myclusterName}}
  name: master-{{ .awsRegion }}a
spec:
  image: {{.image}}
  machineType: {{.masterMachineType}}
  maxSize: 1
  minSize: 1
  nodeLabels:
    kops.k8s.io/instancegroup: master-{{ .awsRegion }}a
  role: Master
  subnets:
  - {{ .awsRegion }}a

---

apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: {{.myclusterName}}
  name: master-{{ .awsRegion }}b
spec:
  image: {{.image}}
  machineType: {{.masterMachineType}}
  maxSize: 1
  minSize: 1
  nodeLabels:
    kops.k8s.io/instancegroup: master-{{ .awsRegion }}b
  role: Master
  subnets:
  - {{ .awsRegion }}b

---

apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: {{.myclusterName}}
  name: master-{{ .awsRegion }}c
spec:
  image: {{.image}}
  machineType: {{.masterMachineType}}
  maxSize: 1
  minSize: 1
  nodeLabels:
    kops.k8s.io/instancegroup: master-{{ .awsRegion }}c
  role: Master
  subnets:
  - {{ .awsRegion }}c
---

apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: {{.myclusterName}}
  name: nodes
spec:
  image: {{.image}}
  machineType: {{.nodeMachineType}}
  maxSize: {{.nodeMaxSize}}
  minSize: {{.nodeMinSize}}
  nodeLabels:
    kops.k8s.io/instancegroup: nodes
  role: Node
  subnets:
  - {{ .awsRegion }}a
  - {{ .awsRegion }}b
  - {{ .awsRegion }}c
