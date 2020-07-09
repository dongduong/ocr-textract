class Ocr::Sns
  def initialize(message)
    @message = message
  end

  def perform
    topic_arn = 'arn:aws:sns:ap-southeast-1:084104329414:demo-textract'
    resp = client.publish(
      topic_arn: topic_arn,
      message: @message
    )
  end

  private

  def client
    @client ||= Aws::SNS::Client.new
  end
end
