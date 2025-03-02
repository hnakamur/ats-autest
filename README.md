# ats-autest

This repository contains Dockerfile and shell scripts to run Apache Traffic Server autest with sharding.

## Set up

Install Docker.
You can use [setup-my-ubuntu-desktop/setup-docker.sh at main · hnakamur/setup-my-ubuntu-desktop](https://github.com/hnakamur/setup-my-ubuntu-desktop/blob/main/setup-docker.sh).

Install GNU Parallel.
```
apt-get install parallel
```

Get the `trafficserver-ci` repository.

```
git clone --depth 1 https://github.com/apache/trafficserver-ci
```

Build the base image.
```
./build-base.sh
```

Get the trafficserver repository.
```
git clone --depth 1 https://github.com/apache/trafficserver
```
(Or you can just place the source directory)

Build the image for running autest.
```
./build.sh
```

## Run autest

### Run shared autest

```
./shard.sh [shardcnt]
```

The default shardcnt is 4.

The work directory like work-YYYYmmddTHHMMSS will be created.


Run the following command in another terminal to tail log files.
```
./tail.sh
```

### Run filtered autest without sharding

```
./no-shard.sh -f test_name1 test_name2 ...
```

The work directory like work-YYYYmmddTHHMMSS will be created.
