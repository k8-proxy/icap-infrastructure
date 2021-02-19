## ICAP Infrastructure - Refresh data from Live

Clone the repositories
```
git clone https://github.com/filetrust/icap-infrastructure.git
git clone https://github.com/k8-proxy/icap-infrastructure.git icap-infrastructure-local
```

Copy all the content of the upstream to the local
```
cp -r icap-infrastructure/* icap-infrastructure-local/
```

CD to the local repo
```
cd icap-infrastructure-local
```

Copy our custom templates from custom folder
```
cp -r custom-templates/* ./
```

Identify any other newly created template from upstream using azure files and make it to use persistent volume