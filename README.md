# verilog-template

backward sync with
```shell
scp -P 25 -r root@localhost:/root/verilog-template/* ./verilog-template/
```

forward sync with
```shell
scp -P 25 -r ./verilog-template/* root@localhost:/root/verilog-template/
```

better sync with rsync
```shell
rsync -rvza -e 'ssh -p 25' --exclude='.git/' ./ root@localhost:/root/learn-verilog
```

```shell
rsync -rvza -e 'ssh -p 25' root@localhost:/root/learn-verilog ./
```