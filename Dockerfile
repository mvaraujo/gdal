FROM osgeo/gdal

# apt update
RUN apt-get update

# Install jupyter
RUN echo $'2\n134' | apt-get install -y jupyter
# The stdin carries as input for dpkg-reconfigure tzdata:
#   2 - Americas
#   134 - Sao_Paulo

# Install Utils
RUN apt-get install -y sudo net-tools iputils-ping telnet

# Install pip and ipython
RUN apt-get install -y pip ipython3

# Install MySQL Client
RUN apt-get install -y libmysqlclient-dev

# Enable widgetsnbextension
RUN jupyter nbextension enable --py --sys-prefix widgetsnbextension

# Create gdal user
RUN \
    useradd -rm -d /home/gdal -s /bin/bash -g root -G sudo gdal && \
    echo "gdal:gdal" | chpasswd
USER gdal
WORKDIR /home/gdal/Python

# Install jupyter-lab
ENV PATH="${PATH}:/home/gdal/.local/bin"
RUN pip install jupyterlab sqlalchemy mysqlclient pandas dbfread

RUN pip install tqdm

EXPOSE 8888

ENTRYPOINT ["bash", "-c", "jupyter lab --port=80 --no-browser --ip=0.0.0.0 --config=/home/gdal/.jupyter/jupyter_lab_config.py"]
