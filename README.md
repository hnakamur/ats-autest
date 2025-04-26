# ats-autest

This repository contains a Python script to run Apache Traffic Server autest with sharded on Fedora 42 Incus containers.

## Set up

Install Incus (See [First steps with Incus - Incus documentation](https://linuxcontainers.org/incus/docs/main/tutorial/first_steps/) or [Incusを使う最初のステップ - Incus ドキュメント](https://incus-ja.readthedocs.io/ja/latest/tutorial/first_steps/) in Japanese).

If you use a Mac, you can run Incus using Colima: https://www.youtube.com/watch?v=5tcpXcipQ9E.

## Build and run autest

With the following command, you can build trafficserver in one Fedora 42 container,
create 16 containers by copying it, and run autest by sharding tests among those containers.

```
./autest-on-incus build-and-test --shards 16
```

The test results will be put in `./_autest_result` directory.

### Just run autest

After you built a trafficserver, you can just run specified tests like:

```
./autest-on-incus test --tests remap_http
```
