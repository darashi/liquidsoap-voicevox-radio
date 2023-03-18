FROM savonet/liquidsoap:v2.1.4

ADD *.liq .

USER root
RUN mkdir /tmp/hls && chown liquidsoap:liquidsoap /tmp/hls
USER liquidsoap

CMD ["main.liq"]
