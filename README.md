# liquidsoap-voicevox-radio

[VOICEVOX](https://voicevox.hiroshiba.jp/) TTS library for [Liquidsoap](https://www.liquidsoap.info/) and HLS web radio example

## How to use

Start HLS server:

```
docker compse up
```

Listen to the stream:

```
mpv http://localhost:8080/live/stream.m3u8
```

Enqueue:

```
curl -v --data-binary '{"speaker": 1, "text": "テストなのだ"}' -H 'Content-type: application/json' http://vv:super-secret-password@localhost:8080/say
```