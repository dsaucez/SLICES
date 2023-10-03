# Parent Helm Charts for Deploying Slicing OAI-5G Core Network (Includes NSSF)

Slicing deployment contains

1. OAI-AMF
2. OAI-SMF
3. OAI-NRF
4. OAI-UDR
5. OAI-AUSF
6. OAI-UDM
7. OAI-NSSF
8. OAI-SPGWU-TINY
9. MYSQL (Subscriber database)

To change the configuration of any core network component you can use `values.yaml`. To change the parameters which are missing from `values.yaml` you can change them in the helm-chart of the respective network function. 

Once you are sure with the configuration parameters you can deploy these charts following the below steps. 

You can read this [tutorial](../../../docs/DEPLOY_SA5G_SLICING.md) on how to use NSSF with multiple instances of SMF/UPF but it is for docker-compose

1. Make sure you have [helm-spray plugin](https://github.com/ThalesGroup/helm-spray) if you don't then you can download like this

```bash
helm plugin install https://github.com/ThalesGroup/helm-spray
```

2. Perform a dependency update whenever you change anything in the sub-charts or if you have recently clone the repository. 

```bash
helm dependency update
```

3. Deploy the helm-charts

```
helm spray .
```