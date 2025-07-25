<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/GoogleCloudPlatform/cloud-foundation-fabric/master/assets/logos/fabric-logo-colors-gray-800.png?v1">
    <img src="https://raw.githubusercontent.com/GoogleCloudPlatform/cloud-foundation-fabric/master/assets/logos/fabric-logo-colors-800.png?v1" alt="Cloud Foundation Fabric">
  </picture>
</p>

# Terraform Examples and Modules for Google Cloud

This repository provides **end-to-end blueprints** and a **suite of Terraform modules** for Google Cloud, which support different use cases:

- organization-wide [landing zone blueprint](fast/) used to bootstrap real-world cloud foundations
- reference [blueprints](./blueprints/) used to deep dive into network patterns or product features
- a comprehensive source of lean [modules](./modules/) that lend themselves well to changes

The whole repository is meant to be cloned as a single unit, and then forked into separate owned repositories to seed production usage, or used as-is and periodically updated as a complete toolkit for prototyping. You can read more on this approach in our [contributing guide](./CONTRIBUTING.md), and a comparison against similar toolkits [here](./FABRIC-AND-CFT.md).

## Organization blueprint (Fabric FAST)

Setting up a production-ready GCP organization is often a time-consuming process. Fabric [FAST](fast/) aims to speed up this process via two complementary goals. On the one hand, FAST provides a design of a GCP organization that includes the typical elements required by enterprise customers. Secondly, we provide a reference implementation of the FAST design using Terraform.

## Modules

The suite of modules in this repository is designed for rapid composition and reuse, and to be reasonably simple and readable so that they can be forked and changed where the use of third-party code and sources is not allowed.

All modules share a similar interface where each module tries to stay close to the underlying provider resources, support IAM together with resource creation and modification, offer the option of creating multiple resources where it makes sense (eg not for projects), and be completely free of side-effects (eg no external commands).

The current list of modules supports most of the core foundational and networking components used to design end-to-end infrastructure, with more modules in active development for specialized compute, security, and data scenarios.

Currently available modules:

- **foundational** - [billing account](./modules/billing-account), [Cloud Identity group](./modules/cloud-identity-group/), [folder](./modules/folder), [service accounts](./modules/iam-service-account), [logging bucket](./modules/logging-bucket), [organization](./modules/organization), [project](./modules/project), [projects-data-source](./modules/projects-data-source)
- **process factories** - [project factory](./modules/project-factory/README.md)
- **networking** - [DNS](./modules/dns), [DNS Response Policy](./modules/dns-response-policy/), [Cloud Endpoints](./modules/endpoints), [address reservation](./modules/net-address), [NAT](./modules/net-cloudnat), [VLAN Attachment](./modules/net-vlan-attachment/), [External Application LB](./modules/net-lb-app-ext/), [External Passthrough Network LB](./modules/net-lb-ext), [External Regional Application Load Balancer](./modules/net-lb-app-ext-regional/), [Firewall policy](./modules/net-firewall-policy), [Internal Application LB](./modules/net-lb-app-int), [Cross-region Internal Application LB](./modules/net-lb-app-int-cross-region), [Internal Passthrough Network LB](./modules/net-lb-int), [Internal Proxy Network LB](./modules/net-lb-proxy-int), [IPSec over Interconnect](./modules/net-ipsec-over-interconnect), [VPC](./modules/net-vpc), [VPC factory](./modules/net-vpc-factory/README.md), [VPC firewall](./modules/net-vpc-firewall), [VPC peering](./modules/net-vpc-peering), [VPN dynamic](./modules/net-vpn-dynamic), [HA VPN](./modules/net-vpn-ha), [VPN static](./modules/net-vpn-static), [Service Directory](./modules/service-directory), [Secure Web Proxy](./modules/net-swp)
- **compute** - [VM/VM group](./modules/compute-vm), [MIG](./modules/compute-mig), [COS container](./modules/cloud-config-container/cos-generic-metadata/) (coredns, mysql, onprem, squid), [GKE cluster](./modules/gke-cluster-standard), [GKE hub](./modules/gke-hub), [GKE nodepool](./modules/gke-nodepool), [GCVE private cloud](./modules/gcve-private-cloud)
- **data** - [AlloyDB instance](./modules/alloydb), [Analytics Hub](./modules/analytics-hub), [BigQuery dataset](./modules/bigquery-dataset), [Biglake Catalog](./modules/biglake-catalog), [Bigtable instance](./modules/bigtable-instance), [Dataplex](./modules/dataplex), [Dataplex Aspect Types](./modules/dataplex-aspect-types/), [Dataplex DataScan](./modules/dataplex-datascan), [Cloud SQL instance](./modules/cloudsql-instance), [Spanner instance](./modules/spanner-instance), [Firestore](./modules/firestore), [Data Catalog Policy Tag](./modules/data-catalog-policy-tag), [Data Catalog Tag](./modules/data-catalog-tag), [Data Catalog Tag Template](./modules/data-catalog-tag-template), [Datafusion](./modules/datafusion), [Dataproc](./modules/dataproc), [GCS](./modules/gcs), [Pub/Sub](./modules/pubsub), [Dataform Repository](./modules/dataform-repository/), [Looker Core](./modules/looker-core)
- **AI** - [AI Applications](./modules/ai-applications/README.md)
- **development** - [API Gateway](./modules/api-gateway), [Apigee](./modules/apigee), [Artifact Registry](./modules/artifact-registry), [Container Registry](./modules/container-registry), [Cloud Source Repository](./modules/source-repository), [Cloud Deploy](./modules/cloud-deploy), [Secure Source Manager instance](./modules/secure-source-manager-instance), [Workstation cluster](./modules/workstation-cluster)
- **security** - [Binauthz](./modules/binauthz/), [Certificate Authority Service (CAS)](./modules/certificate-authority-service), [KMS](./modules/kms), [SecretManager](./modules/secret-manager), [VPC Service Control](./modules/vpc-sc), [Certificate Manager](./modules/certificate-manager/)
- **serverless** - [Cloud Function v1](./modules/cloud-function-v1), [Cloud Function v2](./modules/cloud-function-v2), [Cloud Run](./modules/cloud-run), [Cloud Run v2](./modules/cloud-run-v2)

For more information and usage examples see each module's README file.

## End-to-end blueprints

The [blueprints](./blueprints/) in this repository are split into several main sections: **[networking blueprints](./blueprints/networking/)** that implement core patterns or features, **[data solutions blueprints](./blueprints/data-solutions/)** that demonstrate how to integrate data services in complete scenarios, **[cloud operations blueprints](./blueprints/cloud-operations/)** that leverage specific products to meet specific operational needs, and **[factories](./blueprints/factories/)** that implement resource factories for the repetitive creation of specific resources, and finally **[GKE](./blueprints/gke)**, **[serverless](./blueprints/serverless)**, and **[third-party solutions](./blueprints/third-party-solutions/)** design blueprints.

<!-- $Id: bdd0fc20346f3a26acf69a8434483007b0597833 $ -->
