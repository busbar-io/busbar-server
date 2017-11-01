class Log
  include Mongoid::Document
  include Mongoid::Timestamps

  TTL = Configurations.log.ttl

  field :content, type: String, default: ''
  field :expires_at, type: Time, default: -> { Time.zone.now + TTL }

  belongs_to :build, index: true

  index({ expires_at: 1 }, expire_after_seconds: 0)

  def append(new_content)
    update_attributes(
      content: content + "\n" + new_content
    )
  end

  def append_step(step)
    append_highlight_message(step, '=')
  end

  def append_error(error)
    append_highlight_message(error, '!')
  end

  private

  def append_highlight_message(message, character)
    formated_message = character * (message.length + 4) + "\n"
    formated_message << "#{character} #{message} #{character}\n"
    formated_message << character * (message.length + 4) + "\n"

    append(formated_message)
  end
end
