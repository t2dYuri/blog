CarrierWave.configure do |config|
  config.ftp_host = '194.15.126.111'
  config.ftp_port = 21
  config.ftp_user = 'trend'
  config.ftp_passwd = 'P0likilop'
  config.ftp_folder = '/www/rapidsoft.org/images/blogg'
  config.ftp_url = 'http://rapidsoft.org/images/blogg'
  config.ftp_passive = true
end
