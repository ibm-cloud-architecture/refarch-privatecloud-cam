FROM ubuntu:latest
RUN apt-get update
RUN apt-get install sudo
COPY logs_dir_creation.sh /

CMD ["/bin/bash", "/logs_dir_creation.sh", "/CAM_logs"]
