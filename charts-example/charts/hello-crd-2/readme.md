# How to

## Create Chart

Where `<<directory>>` is a absolute path to a directory where must contains a `Chart.yaml` file.

```bash
helm package <<directory>>
```

## Update Chart Index

```bash
mv *.tgz ../../docs
helm repo index . --url https://fernando-dourado.github.io/manifests/
```

## Publich Chart

Just do a git push with new files to trigger GitHub Pages deployment
