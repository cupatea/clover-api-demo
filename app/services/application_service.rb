class ApplicationService
  class Failure < StandardError; end

  class ServiceFailed < StandardError
    def initialize(msg = nil)
      super
    end
  end

  include ActiveModel::Validations

  attr_reader :result, :success
  alias success? success

  def self.call(*args)
    new(*args).call
  end

  def self.call!(*args)
    response = new(*args).call
    if response.success?
      response
    else
      raise ServiceFailed, response.errors.full_messages.to_sentence
    end
  end

  def call
    if errors.empty? && valid?
      @result = execute!
      @success = errors.any? ? false : true
    else
      @success = false
    end

    self
  rescue Failure
    self
  end

  private

  def struct_new(hash)
    raise ArgumentError, 'Must be a hash' unless hash.is_a?(Hash)
    raise ArgumentError, 'Must be non empty hash' if hash.blank?

    Struct.new(*(keys = hash.keys)).new(*hash.values_at(*keys))
  end

  def execute!
    raise NotImplementedError
  end

  def fail!
    @success = false
    raise Failure
  end
end
