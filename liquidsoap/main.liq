%include "voicevox.liq"

settings.server.log.level.set(4)
log.stdout.set(true)
settings.protocol.voicevox.url.set("http://voicevox:50021")
settings.harbor.verbose.set(true)
settings.frame.audio.samplerate.set(24000)
settings.frame.audio.channels.set(1)

port = 8080

formats = [("aac",
      %ffmpeg(
        format="mpegts",
        %audio(codec="aac", b="96k")
      ))]

queue = request.queue(id="request")

radio = mksafe(queue)

def ping_handler(~protocol, ~data, ~headers, uri) =
  http.response(
    protocol=protocol,
    code=200,
    headers=[("Content-Type","application/json; charset=utf-8")],
    data=json.stringify({message = "OK"})
  )
end
harbor.http.register(port=port, method="GET", "/ping", ping_handler)

def get_password(headers) =
  try
    let entry = list.find(fun (v) -> begin
      let (header_name, _) = v
      string.case(lower=true, header_name) == "authorization"
    end, headers)
    let (_, authorization) = entry
    let [scheme, ...credential] = r/ /.split(authorization)
    let credential = string.base64.decode(string.concat(separator=" ", credential))
    let [user, ...password] = r/:/.split(credential)
    string.concat(separator=":", password)
  catch _ : [error.not_found] do
    null()
  end
end

def say_handler(~protocol, ~data, ~headers, uri) =
  pw = get_password(headers)
  if pw == null() then
    http.response(
      protocol=protocol,
      code=401,
      headers=[("Content-Type","application/json; charset=utf-8")],
      data=json.stringify({message = "Unauthorized"})
    )
  else
    if pw != getenv("CONTROL_PASSWORD") then
      http.response(
        protocol=protocol,
        code=401,
        headers=[("Content-Type","application/json; charset=utf-8")],
        data=json.stringify({message = "Unauthorized"})
      )
    else
      let json.parse ({speaker, text} : {speaker: int, text: string} ) = data
      print("speaker: #{speaker}, text: #{text}")
      let req = request.create("voicevox:#{speaker}:#{url.encode(text)}")
      queue.push(req)
      http.response(
        protocol=protocol,
        code=200,
        headers=[("Content-Type","application/json; charset=utf-8")],
        data=json.stringify({message = "OK"})
      )
    end
  end
end
harbor.http.register(port=port, method="POST", "/say", say_handler)

output.harbor.hls(
    segment_duration=5.0,
    segments=5,
    segments_overhead=5,
    path="/live",
    tmpdir="/tmp/hls",
    port=port,
    formats,
    radio)