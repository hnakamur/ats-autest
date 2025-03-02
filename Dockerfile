FROM fedora41autestbase

ARG username=jenkins
ARG ats_src_dir=/home/${username}/trafficserver
COPY --chown=${username}:${username} ./trafficserver ${ats_src_dir}

USER ${username}
WORKDIR ${ats_src_dir}
ARG build_parallel
RUN cmake -B build --preset ci-fedora-autest -DCMAKE_INSTALL_PREFIX=/home/${username}/ts-autest
RUN cmake --build build -j${build_parallel} -v
RUN cmake --install build

WORKDIR ${ats_src_dir}/build/tests
RUN pipenv install

COPY --chown=${username}:${username} ./run_autest.sh /usr/local/bin/
WORKDIR ${ats_src_dir}/tests
ENTRYPOINT ["run_autest.sh"]
