require 'securerandom'
require 'time'

class Status
  attr_accessor :posted_at, :description

  def initialize(description: nil, recover_from: {})
    @id = recover_from[:id] || SecureRandom.hex(2)
    @posted_at = recover_from[:posted_at] || Time.now
    @description = recover_from[:description] || description
  end

  def as_json(options={})
  {
    id: @id,
    posted_at: @posted_at,
    description: @description
  }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end
end
