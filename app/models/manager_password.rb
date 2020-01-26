class ManagerPassword < ApplicationRecord

  def self.read_file_by_line_and_convert_to_array_of_hashes path_file
    array_of_hashes = []
    text=File.open(path_file).read
    text.gsub!(" ", "\n")
    text.each_line do |line|
      line.gsub!("\n", "")
      array_of_hashes << line
    end
    array_of_hashes
  end

  def self.get_password_hashmd5_online hashes
    result = {}

    require 'net/http'
    require 'uri'
   
    hashes.each do | hash|

      uri = URI.parse("https://md5online.es/")
      request = Net::HTTP::Post.new(uri)
      request.set_form_data(
        "g-recaptcha-response" => "03AOLTBLRnOAeMHbot8n34gTgWxWgx1xhSIUntGBiwwb9OUIaYtOlYsC0pBgNCKKEA2-LCZtH6WjBWvv2AY6idx-q9oimX0QriX-rLXamLygZH4vRFpeva9_S1c0GFibs5LGGRhgElCBwmxN3hCU8VMcqFsgXEbA6qaq3CEuWHOM_AE0g-TDT-TWb5mVhSYC4xoNXFu-vqM02QGQPReZA5PC0cKzE_aRHq-X05erl-_dSTGIiyEqhgEK1GmxosYH-gdXrrWWFHGYqPabqtffIcinosyN8KPen4KcC0DWLCfoZ8Rf7Y_oIVw3__rmEfv_LAG4OD-aj_wNuNcW9DXMuajgLdZGvaVu_5yiD5HXIGTnLcsQV_GgjIoDCE-_6hE_-rWA8mGcPV-lO4y5t9nwhqQqp5-SzfMPM9Vo7p3dsONwEyMJaDvGANva4i9CvGEzfwlJLnXWbeSxxYeEJxek0k-Aa9Zs_T4OGVMR8CZbSAAZLup1UyCX3wlYuxOXqqwUOq4EE9kZMvkE34",
        "hash" => hash,
      )

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      require 'open-uri'
      doc_html = Nokogiri::HTML(response.body)
      container = doc_html.at_css("span.result")
      password = container.children.children.children.text
      result[hash] = password
    end
    result
  end

  def self.write_file_by_line namefile, hashes_with_passowrd
    out_file = File.new(namefile, "w")
    hashes_with_passowrd.each do |key, value|
      if value.present?
        out_file.puts(value)
      else
        out_file.puts("\n")
      end
    end
    out_file.close
  end

  def self.create_new_password_sha256 result_from_md5_hashes
    require 'digest'
    salt = "123abc" + key[0..3]
    result={}
    result_from_md5_hashes.each do |key, value|
      if value.present?
        result[value] = Digest::SHA256.hexdigest(value + salt)
      else
       result[key] = value
      end    
    end
    result
  end
end
