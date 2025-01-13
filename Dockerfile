FROM ghcr.io/osgeo/gdal:alpine-small-latest

# Set frontend to noninteractive to bypass prompts
# Added 2023/12/27
ENV DEBIAN_FRONTEND=noninteractive

# Install Utils
RUN \
    apk add --no-cache \
        sudo \
        net-tools \
        iputils-ping \
        inetutils-telnet \
        py3-pip

# Install Development Tools
RUN \
    apk add --no-cache \
        py3-mysqlclient \
        gcc \
        python3-dev \
        musl-dev \
        linux-headers

RUN \
    apk add --no-cache \
        g++        

# Create gdal user
RUN \
    adduser -D -h /home/gdal -s /bin/sh gdal && \
    echo "gdal:gdal" | chpasswd && \
    addgroup gdal wheel || true

# Allow wheel group to sudo without password
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER gdal
WORKDIR /home/gdal

# Create and activate venv
RUN python3 -m venv /home/gdal/.venv

# Make sure all future commands use the venv's python/pip
ENV PATH="/home/gdal/.venv/bin:$PATH"

# Install jupyter
RUN \
    pip install \
        jupyter \
        tqdm

# Install pandas, sqlalchemy, dbfread
RUN \
    pip install \
        sqlalchemy \
        pandas \
        dbfread \
        pymysql

# Install gdal
RUN pip install gdal

# Run jupyter lab
EXPOSE 80
ENTRYPOINT ["bash", "-c", "jupyter lab --port=80 --no-browser --ip=0.0.0.0 --config=/home/gdal/.jupyter/jupyter_lab_config.py"]
