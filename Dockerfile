FROM nc5ng/gmt:jupyter

RUN apt-get update &&\
    apt-get install -y gfortran &&\
    rm -rf /var/lib/apt/lists/*

COPY ./ /opt/nc5ng

RUN pip3 install -e /opt/nc5ng


