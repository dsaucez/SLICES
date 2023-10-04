# Parent Helm Charts for Deploying Mini OAI-5G Core Network

Mini deployment contains

1. OAI-AMF
2. OAI-SMF
3. OAI-NRF
4. OAI-SPGWU-TINY
5. MYSQL (Subscriber database)

To change the configuration of any core network component you can use `values.yaml`. To change the parameters which are missing from `values.yaml` you can change them in the helm-chart of the respective network function. 

If the gNB is in a different cluster or different subnet than pod subnet. Then you need to make sure AMF and SPGWU/UPF is reachable from the gNB host machine. You can use AMF and SPGWU/UPF multus interface. In SPGWU/UPF `n3Interface` should be able to reach gNB host machine/pod/container.

Once you are sure with the configuration parameters you can deploy these charts following the below steps. 

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