let settings.protocol.voicevox = settings.make.protocol("voicevoox")
let settings.protocol.voicevox.url = settings.make(
  description="URL of VOICEVOX engine",
  "http://localhost:50021"
)

def voicevox_protocol(~rlog, ~maxtime, arg) =
    let [args, ...text] = r/:/.split(arg)
    let text = string.concat(separator=":", text)
    let speaker = args

    output = file.temp("voicevox", ".wav")
    let base = settings.protocol.voicevox.url()

    let query_url = "#{base}/audio_query?speaker=#{speaker}&text=#{text}"
    print(query_url)
    query = http.post(query_url)

    let synthesis_url = "#{base}/synthesis?speaker=#{speaker}"

    let file_writer = file.write.stream(output)
    let response = http.post.stream(synthesis_url, headers=[("Content-Type", "application/json")], data=query, on_body_data=file_writer)

    [output]
end

add_protocol("voicevox", voicevox_protocol)