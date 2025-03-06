# ats-autest

This repository contains shell scripts to run Apache Traffic Server autest with sharding on Fedora 41 Incus containers.

## Set up

Install Incus (See [First steps with Incus - Incus documentation](https://linuxcontainers.org/incus/docs/main/tutorial/first_steps/) or [Incusを使う最初のステップ - Incus ドキュメント](https://incus-ja.readthedocs.io/ja/latest/tutorial/first_steps/)).

Install GNU Parallel.
```
apt-get install parallel
```

Build the base image.
```
./build_base.sh
```

Get the trafficserver repository.
```
git clone --depth 1 https://github.com/apache/trafficserver
```
(Or you can just place the source directory)

Build the image for running autest.
```
./build_ats.sh
```

## Run autest

### Run shared autest

```
SHARDCNT=4 ./autest.sh
```

The work directory like work-YYYYmmddTHHMMSS-shard will be created.


Run the following command in another terminal to tail log files.
```
./tail.sh
```

### Run filtered autest without sharding

```
./autest.sh -f test_name1 test_name2 ...
```

The work directory like work-YYYYmmddTHHMMSS-single will be created.
