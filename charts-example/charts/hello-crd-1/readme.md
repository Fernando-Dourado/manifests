# Install CRD Individually

Install only CRD1 without the chart

```bash
helm install crd1 crds/crd1.yaml
```

Or, install both CRDs individually

```bash
helm install crd1 ./hello-crd-1/crds/crd1.yaml
helm install crd2 ./hello-crd-1/crds/crd2.yaml
```
