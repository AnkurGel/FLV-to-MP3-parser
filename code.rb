=begin
Program extracts mp3 (audio) from a specified flv file by parsing bit-by-bit 
unlike all general approaches of using ffmpeg to parse directly.
Pre-requisite: Must contain audio in mp3 format. 
This is a part of my weekend 1 hour code hack. :) 
=end
file_present=false
str=""; dir_path=""
loop do
print "Enter path of your flv:  "; str=gets.chomp!;pat=/flv\b/; 
str+=".flv" if !(str=~pat)
seed=Dir.pwd
Dir.chdir(File.dirname(str))
if Dir.entries(Dir.pwd).join.include?(File.basename(str))
	file_present=true
	dir_path=File.dirname(str)
	str=File.basename(str)
else
	Dir.chdir(seed)
	puts "File doesn't exist. Again - "
end
break if file_present==true
end
print "Enter name you want to save this mp3 with : " ;name=gets.chomp!;pat=/mp3\b/; name+=".mp3" if !(name=~pat)
puts "Encoding #{str}... Please wait..."
data = File.open(str, 'rb'){|f| f.read }
header_written = false
File.open(name, 'wb'){|f| f.print 
# you need to make it from/with the values from (audio_channels, audio_bits_per_sample, audio_sample_rate) below though
def generate_header(channels, bits_per_sample, sample_rate);  end

signatue, version, flags, offset, data = data.unpack("a3CCNa*")
p [signatue, version, flags, offset]

previousTagSize, data = data.unpack("Na*")
p [previousTagSize]
def unpack_24_be(data); a, b, data = data.unpack('nCa*'); [(a << 8) | b, data]; end
pkt_types = { 0x08 => :audio, 0x09 => :video, 0x12 => :meta }
pkts = []
until data == ""
	type,		data = data.unpack('Ca*') # DON'T directly look for 0x08, it may be the value of any previous tag, so complete it's parsing first.
	body_length,	data = unpack_24_be(data)
	timestamp,	data = unpack_24_be(data)
	timestamp_ex, 	data = data.unpack("Ca*")
	stream_id, 	data = unpack_24_be(data)
	body, 		data = data.unpack("a#{body_length}a*") #till body length, and update data
	previousTagSize, data = data.unpack("Na*")
	pkts << [pkt_types[type], body_length, timestamp, timestamp_ex, stream_id, previousTagSize]
	p pkts.last
if pkt_types[type] == :audio
    audio_flags, body = body.unpack("Ca*")
    b = audio_flags
    audio_channels, audio_bits_per_sample, audio_sample_rate, audio_encoding = [(b&0x01)>>0, (b&0x02)>>1, (b&0x0C)>>2, (b&0xf0)>>4] # or the line below, which is just a different way
#    audio_channels, audio_bits_per_sample, audio_sample_rate, audio_encoding = [b.to_s(2)[7].to_i(2), b.to_s(2)[6].to_i(2), b.to_s(2)[4..5].to_i(2), b.to_s(2)[0..3].to_i(2)]
  if audio_encoding == 2 # mp3 #though 8 is just for audio and not particularly for mp3. (audio_encoding==2)==true for mp3. 
	    puts "MP3 found"
	(f.print generate_header(audio_channels, audio_bits_per_sample, audio_sample_rate); header_written = true) unless header_written
      f.print body
    end
  end
end
}
if header_written==false
puts "#{str} doesn't contain audio in mp3 format. Check output of following command: "
puts "mplayer -frames 0 -identify #{str} 2>/dev/null| grep ID_AUDIO_CODEC"
end
