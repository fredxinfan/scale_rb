# frozen_string_literal: true

module StorageHelper
  class << self
    # key: {
    #   value: ,
    #   type: ,
    #   hashers: []
    # }
    def encode_storage_key(pallet_name, item_name, key = nil, registry = nil)
      storage_key = Hasher.twox128(pallet_name) + Hasher.twox128(item_name)

      if key && registry

        types, values =
          if key[:hashers].length == 1
            [
              [key[:type]],
              [key[:value]]
            ]
          else
            [
              registry[key[:type]]._get(:def)._get(:tuple),
              key[:value]
            ]
          end

        storage_key + PortableCodec._encode_types_with_hashers(types, values, registry, key[:hashers])
      else
        storage_key
      end
    end

    def decode_storage(data, type, optional, fallback, registry)
      data ||= (optional ? nil : fallback)
      PortableCodec.decode(type, data.to_bytes, registry)[0]
    end
  end
end
