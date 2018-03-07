type Extended_http_report_processor::Endpoint = Struct[{
  format   => Enum['yaml', 'json'],
  headers  => Hash[String, String],
  username => Optional[String],
  password => Optional[String],
}]
