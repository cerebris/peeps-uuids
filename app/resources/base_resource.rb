class BaseResource < JSONAPI::Resource
  root_resource
  caching
  key_type :uuid
end
