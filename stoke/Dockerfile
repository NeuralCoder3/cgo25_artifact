FROM stanfordpl/stoke

WORKDIR /home/stoke/stoke
RUN ./configure.sh && make
ENV PATH="/home/stoke/stoke/bin/:${PATH}"
RUN apt-get update && apt-get install -y g++ bc

CMD ["/home/stoke/stoke/bin/stoke"]
# docker run -it cstoke /home/stoke/stoke/bin/stoke --help