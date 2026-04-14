FROM ghcr.io/dingp/test-mpi-images:ubuntu-24.04-cuda-13.2.0-cudnn

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

ENV PYDYNAMIC_ROOT=/opt/pynamic \
    PYDYNAMIC_SRC=/opt/pynamic/pynamic-pyMPI-2.6a1

RUN apt-get update && \
    apt-get install -y --no-install-recommends gawk python-is-python3 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt

COPY . ${PYDYNAMIC_ROOT}

WORKDIR ${PYDYNAMIC_SRC}

RUN python3 config_pynamic.py 10 10 --with-mpi4py --with-cc=mpicc -u 2 2 -s 42 && \
    test -x pynamic-mpi4py && \
    test -f pynamic_driver_mpi4py.py

ENV LD_LIBRARY_PATH=${PYDYNAMIC_SRC}:${LD_LIBRARY_PATH} \
    PATH=${PYDYNAMIC_SRC}:${PATH}

WORKDIR ${PYDYNAMIC_SRC}

CMD ["/bin/bash", "-lc", "echo 'pynamic built in' \"$PWD\"; ls -1 pynamic-mpi4py pynamic_driver_mpi4py.py"]
